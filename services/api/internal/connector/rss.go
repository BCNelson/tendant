package connector

import (
	"context"
	"encoding/json"
	"encoding/xml"
	"fmt"
	"io"
	"net/http"

	"github.com/bcnelson/tendant/services/api/internal/intake"
)

const connectorTypeRSS = "rss"

// rssFilter is the connector-side coarse filter (from connector_configs.filter):
// the feed URL to fetch and the disposition every item carries. The owner
// chooses the disposition per feed — a personal reminder feed is forced_task;
// a noisy news feed is llm_judge. Defaults to forced_task (the US1 path: "a
// flagged item becomes a task, no typing").
type rssFilter struct {
	Feed        string `json:"feed"`
	Disposition string `json:"disposition"`
}

// rssFeed/rssItem model the subset of RSS 2.0 we read via stdlib encoding/xml
// (no third-party RSS library — research R2). Atom <entry> is parsed too via
// the shared field names where they overlap; a fuller atom path can be added
// additively later.
type rssFeed struct {
	XMLName xml.Name   `xml:"rss"`
	Channel rssChannel `xml:"channel"`
}

type rssChannel struct {
	Title string    `xml:"title"`
	Items []rssItem `xml:"item"`
}

type rssItem struct {
	Title       string `xml:"title"`
	Link        string `xml:"link"`
	GUID        string `xml:"guid"`
	Description string `xml:"description"`
	PubDate     string `xml:"pubDate"`
}

// RSS is the zero-credential feed connector. Idempotency key = the item GUID
// (or link when no GUID), so an unchanged item across polls dedupes.
type RSS struct {
	doer httpDoer
}

// NewRSS constructs the connector. A nil doer uses http.DefaultClient.
func NewRSS(doer httpDoer) *RSS {
	if doer == nil {
		doer = http.DefaultClient
	}
	return &RSS{doer: doer}
}

// Type implements Connector.
func (*RSS) Type() string { return connectorTypeRSS }

// Run fetches the configured feed and emits one signal per item with the
// owner-chosen disposition (default forced_task).
func (c *RSS) Run(ctx context.Context, cfg ConnectorConfig, emit intake.EmitFunc) error {
	var f rssFilter
	if len(cfg.Filter) > 0 {
		if err := json.Unmarshal(cfg.Filter, &f); err != nil {
			return fmt.Errorf("rss: parse filter: %w", err)
		}
	}
	if f.Feed == "" {
		return fmt.Errorf("rss: filter.feed is required")
	}
	disposition := f.Disposition
	if disposition == "" {
		disposition = intake.DispositionForcedTask
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, f.Feed, http.NoBody)
	if err != nil {
		return fmt.Errorf("rss: build request: %w", err)
	}
	resp, err := c.doer.Do(req)
	if err != nil {
		return fmt.Errorf("rss: fetch feed: %w", err)
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("rss: feed returned status %d", resp.StatusCode)
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("rss: read feed: %w", err)
	}

	var feed rssFeed
	if err := xml.Unmarshal(body, &feed); err != nil {
		return fmt.Errorf("rss: parse feed: %w", err)
	}

	for _, item := range feed.Channel.Items {
		if err := ctx.Err(); err != nil {
			return err
		}
		key := item.GUID
		if key == "" {
			key = item.Link
		}
		if key == "" {
			continue // an item with no stable identity can't be deduped — skip
		}
		payload, err := json.Marshal(map[string]string{
			"title":       item.Title,
			"link":        item.Link,
			"description": item.Description,
			"pub_date":    item.PubDate,
		})
		if err != nil {
			return fmt.Errorf("rss: marshal payload: %w", err)
		}
		sig := intake.PotentialTaskSignal{
			SignalVersion:  intake.SignalVersion,
			SourceID:       sourceID(connectorTypeRSS, cfg.ConnectorID),
			IdempotencyKey: fmt.Sprintf("%s#%s", f.Feed, key),
			Provenance: intake.Provenance{
				RawRef: fmt.Sprintf("rss:%s#%s", f.Feed, key),
				Reason: fmt.Sprintf("feed item from %s", feed.Channel.Title),
			},
			Payload:     payload,
			Disposition: disposition,
		}
		if err := emit(sig); err != nil {
			return err
		}
	}
	return nil
}

package llm

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"net/http"
	"sort"
	"strings"
	"time"
)

// sigv4Creds carries the AWS credentials needed to sign a request.
type sigv4Creds struct {
	AccessKeyID     string
	SecretAccessKey string
	SessionToken    string // optional (STS/temporary credentials)
}

// signV4 signs an *http.Request with AWS Signature Version 4 for the given
// service/region, using payload as the exact body bytes. It mutates req's
// headers (Authorization, X-Amz-Date, X-Amz-Content-Sha256, and
// X-Amz-Security-Token when a session token is present).
//
// This is a focused, stdlib-only implementation covering the single-chunk
// signed-payload case tendant needs for Bedrock — it avoids pulling in the
// AWS SDK, matching the package's no-model-SDK discipline.
func signV4(req *http.Request, payload []byte, creds sigv4Creds, service, region string, now time.Time) {
	now = now.UTC()
	amzDate := now.Format("20060102T150405Z")
	dateStamp := now.Format("20060102")

	payloadHash := hexSHA256(payload)
	req.Header.Set("X-Amz-Date", amzDate)
	req.Header.Set("X-Amz-Content-Sha256", payloadHash)
	if creds.SessionToken != "" {
		req.Header.Set("X-Amz-Security-Token", creds.SessionToken)
	}
	if req.Header.Get("Host") == "" {
		req.Header.Set("Host", req.URL.Host)
	}

	// 1. Canonical request.
	signedHeaders, canonicalHeaders := canonicalHeaders(req)
	canonicalURI := req.URL.EscapedPath()
	if canonicalURI == "" {
		canonicalURI = "/"
	}
	canonicalQuery := req.URL.Query().Encode()
	canonicalRequest := strings.Join([]string{
		req.Method,
		canonicalURI,
		canonicalQuery,
		canonicalHeaders,
		signedHeaders,
		payloadHash,
	}, "\n")

	// 2. String to sign.
	credentialScope := strings.Join([]string{dateStamp, region, service, "aws4_request"}, "/")
	stringToSign := strings.Join([]string{
		"AWS4-HMAC-SHA256",
		amzDate,
		credentialScope,
		hexSHA256([]byte(canonicalRequest)),
	}, "\n")

	// 3. Signing key + signature.
	kDate := hmacSHA256([]byte("AWS4"+creds.SecretAccessKey), dateStamp)
	kRegion := hmacSHA256(kDate, region)
	kService := hmacSHA256(kRegion, service)
	kSigning := hmacSHA256(kService, "aws4_request")
	signature := hex.EncodeToString(hmacSHA256(kSigning, stringToSign))

	// 4. Authorization header.
	auth := "AWS4-HMAC-SHA256 " +
		"Credential=" + creds.AccessKeyID + "/" + credentialScope + ", " +
		"SignedHeaders=" + signedHeaders + ", " +
		"Signature=" + signature
	req.Header.Set("Authorization", auth)
}

// canonicalHeaders returns the SignedHeaders list and the canonical-headers
// block. Host is always included; it is taken from req.URL when absent.
func canonicalHeaders(req *http.Request) (signed string, canonical string) {
	headers := map[string]string{}
	headers["host"] = firstNonEmpty(req.Header.Get("Host"), req.URL.Host)
	for k, vs := range req.Header {
		lk := strings.ToLower(k)
		switch lk {
		case "x-amz-date", "x-amz-content-sha256", "x-amz-security-token":
			headers[lk] = strings.TrimSpace(strings.Join(vs, ","))
		}
	}
	keys := make([]string, 0, len(headers))
	for k := range headers {
		keys = append(keys, k)
	}
	sort.Strings(keys)

	var b strings.Builder
	for _, k := range keys {
		b.WriteString(k)
		b.WriteString(":")
		b.WriteString(headers[k])
		b.WriteString("\n")
	}
	return strings.Join(keys, ";"), b.String()
}

func hmacSHA256(key []byte, data string) []byte {
	h := hmac.New(sha256.New, key)
	h.Write([]byte(data))
	return h.Sum(nil)
}

func hexSHA256(data []byte) string {
	sum := sha256.Sum256(data)
	return hex.EncodeToString(sum[:])
}

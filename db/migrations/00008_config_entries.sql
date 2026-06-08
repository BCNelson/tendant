-- +goose Up
-- config_entries: the DB-layer config overlay. Rows here win at runtime over
-- env/file/defaults for keys marked db_configurable in
-- services/api/internal/config/keys.go. Values are stored as jsonb (a bare
-- scalar like 0.95 / true / "30m", or a small object).
CREATE TABLE config_entries (
    key        text        PRIMARY KEY,
    value      jsonb       NOT NULL,
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Every write fires NOTIFY config_changed with the affected key so each
-- instance's config.Overlay refreshes that key (LISTEN/NOTIFY hot-reload).
-- A trigger (vs. notifying only from the resolver) means direct SQL edits and
-- boot file-reconciliation also propagate.
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION trg_config_changed() RETURNS trigger AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    PERFORM pg_notify('config_changed', OLD.key);
    RETURN OLD;
  END IF;
  PERFORM pg_notify('config_changed', NEW.key);
  RETURN NEW;
END; $$ LANGUAGE plpgsql;
-- +goose StatementEnd
CREATE TRIGGER config_changed_notify
  AFTER INSERT OR UPDATE OR DELETE ON config_entries
  FOR EACH ROW EXECUTE FUNCTION trg_config_changed();

-- +goose Down
DROP TRIGGER IF EXISTS config_changed_notify ON config_entries;
DROP FUNCTION IF EXISTS trg_config_changed();
DROP TABLE IF EXISTS config_entries;

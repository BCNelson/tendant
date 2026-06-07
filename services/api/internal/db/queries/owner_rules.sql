-- name: UpsertOwnerRule :one
-- setOwnerRule (FR-018): single-row-per-(owner,key) upsert. updated_at is
-- advanced on every write so per-rule lifecycle is observable.
INSERT INTO owner_rules (owner_global_uri, key, value)
VALUES ($1, $2, $3)
ON CONFLICT (owner_global_uri, key) DO UPDATE
  SET value = EXCLUDED.value, updated_at = now()
RETURNING owner_global_uri, key, value, updated_at;

-- name: GetOwnerRule :one
-- owner.rule(key) host function backing (FR-018). Returns pgx.ErrNoRows when
-- no rule is set for the key.
SELECT value
FROM owner_rules
WHERE owner_global_uri = $1 AND key = $2
LIMIT 1;

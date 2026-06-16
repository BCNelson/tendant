-- Task↔task relation graph (migration 00021). Edges are directed:
-- from_task --kind--> to_task. The traversal queries below return full task
-- rows (db.Task) so resolvers can map them like any other task.

-- name: InsertTaskRelation :one
-- Add a directed relation. The UNIQUE(from_task,to_task,kind) constraint and
-- the no-self CHECK reject duplicates and self-links at the DB; the partial
-- unique indexes reject a second parent / canonical. The resolver pre-checks
-- cycles via RelationWouldCycle.
INSERT INTO task_relations (from_task, to_task, kind)
VALUES ($1, $2, sqlc.arg('kind')::task_relation_kind)
RETURNING id, from_task, to_task, kind, created_at;

-- name: DeleteTaskRelation :execrows
-- Remove a directed relation. Returns the number of rows deleted so the
-- resolver can report whether anything was actually removed.
DELETE FROM task_relations
WHERE from_task = $1 AND to_task = $2 AND kind = sqlc.arg('kind')::task_relation_kind;

-- name: RelationWouldCycle :one
-- Reports whether adding from→to of `kind` would close a cycle: true when
-- `target` is already reachable from `start` following same-kind edges. The
-- resolver calls it with start=to_task, target=from_task before inserting a
-- blocks / subtask_of edge.
WITH RECURSIVE reach AS (
  SELECT to_task AS node
  FROM task_relations
  WHERE from_task = sqlc.arg('start')::uuid
    AND kind = sqlc.arg('kind')::task_relation_kind
  UNION
  SELECT tr.to_task
  FROM task_relations tr
  JOIN reach r ON tr.from_task = r.node
  WHERE tr.kind = sqlc.arg('kind')::task_relation_kind
)
SELECT EXISTS (SELECT 1 FROM reach WHERE node = sqlc.arg('target')::uuid) AS cycles;

-- name: ListBlockers :many
-- Tasks that must clear before $1 can execute (from_task of a 'blocks' edge to $1).
SELECT t.* FROM tasks t
JOIN task_relations tr ON tr.from_task = t.id
WHERE tr.to_task = $1 AND tr.kind = 'blocks'
ORDER BY t.created_at DESC, t.id DESC;

-- name: ListBlocking :many
-- Tasks that $1 blocks (to_task of a 'blocks' edge from $1).
SELECT t.* FROM tasks t
JOIN task_relations tr ON tr.to_task = t.id
WHERE tr.from_task = $1 AND tr.kind = 'blocks'
ORDER BY t.created_at DESC, t.id DESC;

-- name: GetParentTask :one
-- The parent of $1, if $1 is a subtask (to_task of $1's 'subtask_of' edge).
SELECT t.* FROM tasks t
JOIN task_relations tr ON tr.to_task = t.id
WHERE tr.from_task = $1 AND tr.kind = 'subtask_of'
LIMIT 1;

-- name: ListSubtasks :many
-- Children of $1 (from_task of a 'subtask_of' edge to $1).
SELECT t.* FROM tasks t
JOIN task_relations tr ON tr.from_task = t.id
WHERE tr.to_task = $1 AND tr.kind = 'subtask_of'
ORDER BY t.rank ASC NULLS LAST, t.created_at DESC, t.id DESC;

-- name: ListRelatedTasks :many
-- Non-blocking related tasks in either direction (kind='related'). DISTINCT
-- collapses a task linked in both directions to a single row.
SELECT DISTINCT t.* FROM tasks t
JOIN task_relations tr
  ON (tr.to_task = t.id AND tr.from_task = $1)
  OR (tr.from_task = t.id AND tr.to_task = $1)
WHERE tr.kind = 'related'
ORDER BY t.created_at DESC, t.id DESC;

-- name: GetDuplicateOf :one
-- The canonical task $1 duplicates (to_task of $1's 'duplicate_of' edge).
SELECT t.* FROM tasks t
JOIN task_relations tr ON tr.to_task = t.id
WHERE tr.from_task = $1 AND tr.kind = 'duplicate_of'
LIMIT 1;

-- name: ListDuplicates :many
-- Tasks marked as duplicates of $1 (from_task of a 'duplicate_of' edge to $1).
SELECT t.* FROM tasks t
JOIN task_relations tr ON tr.from_task = t.id
WHERE tr.to_task = $1 AND tr.kind = 'duplicate_of'
ORDER BY t.created_at DESC, t.id DESC;

-- name: CountUnmetBlockers :one
-- Count of $1's blockers that are not yet resolved. A blocker is "met" once it
-- reaches any terminal state (done/dismissed/halted) — counting only
-- non-terminal blockers prevents a cancelled prerequisite from deadlocking the
-- dependent forever (readiness predicate, FR-019).
SELECT count(*) FROM task_relations tr
JOIN tasks b ON b.id = tr.from_task
WHERE tr.to_task = $1 AND tr.kind = 'blocks'
  AND b.state NOT IN ('done', 'dismissed', 'halted');

-- name: ListDependentTaskIDs :many
-- IDs of still-pending tasks that $1 blocks, so the chain can wake them to
-- re-evaluate readiness when $1 reaches a terminal state.
SELECT tr.to_task AS id
FROM task_relations tr
JOIN tasks t ON t.id = tr.to_task
WHERE tr.from_task = $1 AND tr.kind = 'blocks'
  AND t.state IN ('accepted', 'waiting')
ORDER BY tr.to_task;

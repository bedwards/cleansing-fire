-- fire-relay D1 Schema
-- Append-only log of relay events for transparency and auditing.
-- Per Recursive Accountability: the relay itself must be accountable.
--
-- Apply with: npx wrangler d1 execute fire-relay --file=schema.sql

CREATE TABLE IF NOT EXISTS relay_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_type TEXT NOT NULL,       -- 'register', 'heartbeat', 'intelligence_relay', 'deregister'
    node_id TEXT NOT NULL,          -- fire-<hex> node identifier
    endpoint TEXT,                  -- node's FireWire endpoint
    ip TEXT,                        -- connecting IP (for rate limiting context)
    timestamp TEXT NOT NULL,        -- ISO-8601 timestamp
    metadata TEXT                   -- optional JSON metadata
);

CREATE INDEX IF NOT EXISTS idx_relay_events_node ON relay_events(node_id);
CREATE INDEX IF NOT EXISTS idx_relay_events_type ON relay_events(event_type);
CREATE INDEX IF NOT EXISTS idx_relay_events_ts ON relay_events(timestamp);

-- View: Recent registrations
CREATE VIEW IF NOT EXISTS recent_registrations AS
SELECT node_id, endpoint, timestamp
FROM relay_events
WHERE event_type = 'register'
ORDER BY timestamp DESC
LIMIT 100;

-- View: Active nodes (registered in the last hour)
CREATE VIEW IF NOT EXISTS active_nodes AS
SELECT DISTINCT node_id, endpoint, MAX(timestamp) as last_seen
FROM relay_events
WHERE event_type IN ('register', 'heartbeat')
  AND timestamp > datetime('now', '-1 hour')
GROUP BY node_id
ORDER BY last_seen DESC;

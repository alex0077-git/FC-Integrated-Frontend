# Mission database

Ground Plan **Save** and successful **Upload & fly** persist waypoints in a local SQLite file:

- File: `fuselage_missions.db` under the app documents directory
- Table: `missions` (`id`, `name`, `origin` saved|uploaded, `saved_at`, `waypoints_json`)
- No DB password or encryption key — local unencrypted store

**Load** lists saved and uploaded missions so the same waypoints can be restored after restart.

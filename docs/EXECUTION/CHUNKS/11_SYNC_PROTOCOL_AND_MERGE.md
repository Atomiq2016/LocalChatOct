# Chunk 11 — Sync Protocol & Merge

**Objective**  
On join, client requests deltas; host sends messages/rooms/blocked since timestamp; client merges with conflict policy.

**Deliverables**
- Join handshake carries `lastSeenTimestamp` and receives `Δ(messages|rooms|blocked)`
- `DatabaseManager`: delta + merge (from 07) wired through P2P channel
- UI refresh after sync completes

**Acceptance Criteria**
1. Fresh client joining a populated host gets history within ≤ 5 seconds for 100 messages.
2. Conflict resolution matches “latest wins; UUID tie-break”.
3. Blocklist transferred and honored client-side.

**Tasks for Codex**
- Define minimal JSON protocol: `{type:"sync", since:<epoch>, payload:{messages:[...], rooms:[...], blocked:[...]}}`
- Hook into approve path (Chunk 09) to trigger initial sync.

**Tests**
- Unit: encode/decode payload correctness.
- Integration: join → sync → chat continues normally.

**Risks/Notes**
- Large payloads: paginate if > 500 messages (basic loop acceptable).

**Issue Seed:** _Chunk 11 — Sync Protocol & Merge_

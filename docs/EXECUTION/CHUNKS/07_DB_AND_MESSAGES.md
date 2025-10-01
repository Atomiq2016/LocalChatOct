# Chunk 07 — Database & Messages

**Objective**  
Implement production-worthy local persistence for rooms/messages with blocklist + cleanup and sync helpers.

**Deliverables**
- SQLite schema: rooms, messages, blocked_users; indices (room,timestamp) and (id)
- Thread-safe DatabaseManager (serial queue)
- Message APIs: add text/image (image by file path), fetch oldest→newest
- Blocklist enforcement at query time
- 24h cleanup
- Sync helpers: delta (since timestamp), merge (newest wins, UUID tie-break)

**Acceptance Criteria**
1. Schema & indices created on first run/upgrades with no crashes.
2. `addRoom`, `getRooms` (newest→oldest).
3. `addTextMessage`, `addImageMessage`, `getMessages(room, limit)` (oldest→newest, respects limit, hides blocked authors).
4. `blockUser`, `isUserBlocked` implemented; blocked messages excluded.
5. `deleteOldMessages()` removes >24h rows.
6. `getMessagesDelta(since:)` returns ASC deltas; `mergeIncoming` follows policy inside a transaction.
7. Unit tests cover rooms, messages, blocklist, cleanup, delta/merge.

**Tasks for Codex**
- Implement/upgrade DatabaseManager per above.
- Store image **paths** (no BLOBs).
- Add unit tests as specified in the file.
- Update CODE_INDEX.md + ARCHITECTURE.md DB section if function names differ.

**Tests**
- Unit tests for CRUD, block, cleanup, delta/merge.
- Manual: send text + image; verify order, thumbnail load path used by UI (placeholder until Chunk 10).

**Risks/Notes**
- Do not log PII.
- Keep migrations additive.

**Issue Seed (create one GitHub Issue with this title/AC)**  
_Title:_ Chunk 07 — Database & Messages  
_AC:_ Use “Acceptance Criteria” block above.

**PR Checklist**
- [ ] All AC met
- [ ] Tests added/passing
- [ ] CODE_INDEX.md updated
- [ ] No PII in logs
- [ ] STATUS footer present

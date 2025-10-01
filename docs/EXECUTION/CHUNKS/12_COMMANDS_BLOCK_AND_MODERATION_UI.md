# Chunk 12 — Commands, Block, and Moderation UI

**Objective**  
User-visible moderation: `/block <key>` command, context actions, and live filtering.

**Deliverables**
- Input parser for `/block <truncatedKey|fullKey>`
- Block/unblock UI entry (long-press on message or overflow menu)
- Chat updates immediately without reload

**Acceptance Criteria**
1. `/block` hides past+future messages from that author.
2. Unblock restores visibility.
3. Tests for parser + DB effect.

**Tasks for Codex**
- Extend ChatView input handling.
- Map truncated→full keys via recent messages.

**Tests**
- Unit: parser edge cases; block/unblock DB coverage.
- UI: long-press action triggers change.

**Issue Seed:** _Chunk 12 — Commands & Moderation UI_

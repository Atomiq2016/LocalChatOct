# LocaChat — Master Execution Plan (Chunks 07 → 16)

**Context**  
Chunks 1–6 are complete (bootstrap, UI shell, basic flows). From **Chunk 07** onward, Codex will implement the durable backbone and ship a testable MVP.

**Ground rules**
- No central backend. Phone-as-server P2P with WebRTC. Phone number only for signaling.
- Offline-first, ephemeral messages (24h baseline).
- Tests added per chunk; CI stays green.
- Minimal PR scope: 1 chunk = 1 PR (unless split by Codex due to size).

---

## Chunk Map (high level)

| Chunk | Goal | Key Deliverables | Depends On |
|------:|------|------------------|------------|
| 07 | DB & Message handling | SQLite schema, CRUD, blocklist, cleanup, sync helpers | 1–6 |
| 08 | P2P/WebRTC foundation | WebRTC SPM, offer/answer via SMS share, data channel open | 07 |
| 09 | Server Mode & Lobby | Host toggle, pending join UI, approve/deny path | 08 |
| 10 | Media UX | Thumbnails, image viewer modal, link previews | 07,08 |
| 11 | Sync protocol | Join delta sync + merge, multi-device consistency | 07,08 |
| 12 | Commands & moderation | `/block`, user list driven by peers, basic presence | 07,09 |
| 13 | Security hardening | Keychain private key, sign/verify messages, PII-safe logs | 07 |
| 14 | Background & resilience | BGTask cleanup, reconnect, low-signal handling | 08,11 |
| 15 | A11y & theme polish | VoiceOver, dynamic type, MSN palette, dark mode pass | 10 |
| 16 | Testing, CI, release | Test matrix, artifacts, TestFlight packaging notes | all |

**Success Criteria (MVP “core nailed”)**
- Two iPhones exchange text & images over **cellular** via WebRTC with **no backend**.
- New client join performs **delta sync** in ≤ 5s for 100 messages.
- Host approval flow works for ≥ 5 peers.
- Keys stored in Keychain; no PII in logs; app stable (crash-free ≥ 99% in internal tests).

**Board cadence**
- One chunk at a time. After merge, move next chunk to **Ready**.
- If a chunk PR exposes gaps, open “follow-up” issues but avoid blocking forward progress unless a blocker.

**Testing cadence**
- Each chunk adds unit/UI tests. On merge, run the **Global QA checklist** (separate file).

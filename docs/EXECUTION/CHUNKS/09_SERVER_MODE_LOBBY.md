# Chunk 09 — Server Mode & Lobby

**Objective**  
Enable phone-as-server: host toggle (Open/Lobby) and approve/deny join requests.

**Deliverables**
- Settings/Toggle: Server Mode (Open | Lobby)
- `LobbyView`: pending joins with username + truncated public key
- Approve/deny handshake messages over the data channel
- Users list in Chat powered by live peers

**Acceptance Criteria**
1. Host toggle stored (in memory is fine for MVP).
2. Lobby lists pending peers; approve adds peer to active list; deny informs client.
3. Chat user list reflects active peers; disconnects remove peers.
4. Tests for approve/deny state changes.

**Tasks for Codex**
- `P2PManager`: pendingPeers @Published, approve/deny APIs.
- Simple UI: LobbyView + entry point from Chat/Settings.

**Tests**
- Unit: pending → approved → active transitions.
- Manual: client request → host approve → chat.

**Risks/Notes**
- Keep UI simple and reliable; fancy later.

**Issue Seed:** _Chunk 09 — Server Mode & Lobby_

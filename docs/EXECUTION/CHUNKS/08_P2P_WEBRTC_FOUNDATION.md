# Chunk 08 — P2P/WebRTC Foundation

**Objective**  
Replace mocked networking with real P2P data channels over cellular: establish connections via SMS-based signaling, open reliable data channel.

**Deliverables**
- WebRTC via SPM; STUN configured
- Offer/Answer flow: Host generates offer blob → SMS share; Client returns answer blob → data channel opens
- `P2PManager`: start/stop lifecycle hooks, connection state, data channel publisher for incoming bytes

**Acceptance Criteria**
1. Add WebRTC package; app compiles.
2. Host can generate offer blob; client can produce answer blob; data channel opens (log confirms).
3. `P2PManager` exposes Combine publisher for inbound messages (bytes/JSON), and `send(data:)`.
4. Works with Wi-Fi off (cellular).

**Tasks for Codex**
- Implement minimal signaling screens (system share sheet / paste prompts).
- Add STUN `stun.l.google.com:19302`.
- Plumb `P2PManager` to `MainView` start/stop.

**Tests**
- Unit: `P2PManager` state transitions & mock channels.
- Manual: two devices open channel over cellular.

**Risks/Notes**
- SMS compose sheet requires Info.plist usage strings; no SMS auto-send.

**Issue Seed**  
_Title:_ Chunk 08 — P2P/WebRTC foundation  
_AC:_ Use block above.

**PR Checklist**
- [ ] WebRTC linked
- [ ] Offer/Answer path operational
- [ ] Data channel publisher+send
- [ ] Tests added; STATUS footer

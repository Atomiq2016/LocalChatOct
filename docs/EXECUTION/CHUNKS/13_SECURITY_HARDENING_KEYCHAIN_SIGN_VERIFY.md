# Chunk 13 — Security Hardening (Keychain, Sign & Verify)

**Objective**  
Finish identity hardening: Keychain for private key; sign messages; verify on receive.

**Deliverables**
- Migrate private key storage from UserDefaults → Keychain
- Add signature to message payloads; verify using sender public key
- Drop messages failing verification

**Acceptance Criteria**
1. Key survives app restarts; never logged.
2. Signed messages verified end-to-end; invalids dropped (with safe log).
3. Tests for sign/verify round-trip.

**Tasks for Codex**
- CryptoKit (Curve25519) for sign/verify.
- Add `sig` field in P2P payloads; update encode/decode.

**Tests**
- Unit: sign/verify, failure path.
- Integration: two devices exchange signed messages.

**Issue Seed:** _Chunk 13 — Security Hardening_

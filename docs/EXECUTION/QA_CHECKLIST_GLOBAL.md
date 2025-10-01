# Global QA Checklist (run after each merged chunk)

- [ ] App builds clean on Xcode 16, iPhone 15 Simulator + iPhone X device
- [ ] New unit/UI tests exist and pass locally
- [ ] CI green on main
- [ ] No PII in logs (phones, private keys, plaintext messages)
- [ ] Performance sanity: send 20 messages in a row without UI jank
- [ ] No regressions in Signup → Rooms → Chat happy path
- [ ] Document updates: CODE_INDEX.md + chunk spec status note appended

# Chunk 14 — Background Cleanup & Resilience

**Objective**  
Keep the app healthy in real phone use: scheduled cleanup, graceful reconnect, low-signal handling.

**Deliverables**
- BGTaskScheduler hourly cleanup (iOS 13+), Timer fallback (iOS 11–12)
- Reconnect strategy on app foreground and network changes
- Backpressure: queue outgoing when channel down; flush on reconnect

**Acceptance Criteria**
1. Old messages get purged automatically without user interaction.
2. Foregrounding triggers reconnect attempt; queue flushes in order.
3. Tests for cleanup call; manual tests for reconnect.

**Tasks for Codex**
- ScenePhase + Reachability hooks.
- Minimal telemetry counters (in-memory) for reconnect attempts (no external backend).

**Issue Seed:** _Chunk 14 — Background & Resilience_

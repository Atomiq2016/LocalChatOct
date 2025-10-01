# Chunk 10 — Media Thumbnails & Viewer

**Objective**  
Upgrade media UX: thumbnails for images, quick viewer modal; basic link previews.

**Deliverables**
- Message content enum supports image path (already from 07)
- Thumbnail generation (safe size) and caching
- Tap to open full-screen image viewer; close returns to chat
- LinkPresentation previews for pasted URLs in text

**Acceptance Criteria**
1. Thumbnails render in chat cells, scrolling remains smooth.
2. Full-screen viewer supports pinch to zoom (if feasible) or fit-to-screen.
3. Link previews show title/icon for valid URLs.
4. Unit/UI tests for thumbnail pipeline and tap-to-viewer.

**Tasks for Codex**
- Lightweight cache in memory/disk.
- Update MessageRow/ChatView; do not block main thread on decode.

**Tests**
- Snapshot/UI tests for cells with text/image/link.
- Manual performance: 50 mixed messages smooth scroll.

**Issue Seed:** _Chunk 10 — Media Thumbnails & Viewer_

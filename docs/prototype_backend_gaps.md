# Prototype Backend Gaps

This document tracks Companion prototype features now represented in the iOS UI but not yet backed by a production API contract.

## Already Connected

- Chat uses the existing WebSocket and REST history/status paths through `ChatViewModel`, `ChatService`, `BoundaryService`, `EmotionService`, and `IntimacyService`.
- Memory pages use `GET /memories` and `POST /memories/search`.
- Emotion pages use `GET /emotions/{agent_id}/current` and `GET /emotions/{agent_id}/timeline`.
- Schedule pages use `GET /agents/{agent_id}/schedule-history`.
- Portrait pages use `GET /users/{user_id}/portrait` plus `GET /agents/{agent_id}` for AI life overview.
- Agent creation still uses the existing onboarding flow: `POST /agents` then conversation creation.

## Gaps To Implement Later

### Share To Chat

Prototype pages include the concept of sending a music/movie/game/daily/offline/progress card back into chat. The iOS UI currently hides the share button instead of leaving a no-op control.

Needed API shape:
- Create a share-card payload type for `music`, `movie`, `game`, `daily`, `offline_invite`, and `progress`.
- Accept either a chat WebSocket event or REST endpoint that persists the card as a message.
- Return a message model that can render rich card metadata, not only plain text.

### Rich Message Attachments

The WebSocket currently exposes `sticker_url`, but the iOS `Message` model only stores text content. Stickers and rich cards need first-class fields.

Needed client/backend contract:
- Add optional attachment metadata to message history and live WebSocket reply events.
- Preserve attachment type, URL, title, subtitle, image, and action metadata.
- Backfill history decoding so old text-only messages remain valid.

### Voice And Plus Menu Actions

The chat composer visually matches the prototype, but voice, image, camera, gift, location, search, and call actions do not yet have backend or native capability wiring.

Needed work:
- Voice capture/transcription/upload flow.
- Image/camera attachment upload and message persistence.
- Location sharing permission and payload format.
- Decide whether gift/call/search are product features or prototype-only affordances.

### Online Rooms

Music, movie, game, and daily pages are implemented as prototype UI with local state and bundled assets. They do not yet synchronize real room state.

Needed APIs:
- Music room: playback state, queue, lyrics, user/AI playlist source, play/pause events.
- Movie room: catalog, selected movie, playback progress, controls, barrage messages.
- Game room: game catalog, session creation, score/progress, optional voice sync.
- Daily board: photo/book/film/food content sources and generated share summaries.

### Scene Interaction

Offline invite and progress pages currently render prototype data locally.

Needed APIs:
- Offline invites: event list, ticket/pass payload, pickup code, reminders, accept/draft status.
- Progress tracking: delivery/package/focus tasks, progress percentage, next reminder, state transitions.

### Notification And Privacy Settings

The settings page preserves existing local theme/language/delete-agent behavior. Prototype rows for notification, privacy, subscription, export, and account device controls need backend contracts before they become active pages.

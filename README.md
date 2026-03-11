# MeshLink

> **Offline peer-to-peer communication — text, voice messages, and live calls — with zero infrastructure.**

MeshLink is a Flutter application that enables structured, resilient mesh networking between Android devices using WiFi Direct. Devices discover each other automatically, relay messages across multi-hop chains, and support real-time voice calls — all without a router, cell tower, or internet connection.

---

## Table of Contents

- [Use Cases](#use-cases)
- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Permissions](#permissions)
- [Build Plan](#build-plan)
- [Testing](#testing)
- [Packet Format](#packet-format)

---

## Use Cases

| Scenario | How MeshLink Helps |
|---|---|
| **Disaster response** | Maintain chat and voice calls when cell towers are down or overloaded |
| **Remote field ops** | Connect team members in areas with no internet infrastructure |
| **Privacy-first networking** | Share voice and text directly between devices, no cloud relay |
| **Tactical coordination** | Rapid peer discovery with resilient multi-hop route fallback |

---

## Features

- **Automatic peer discovery** — devices advertise and discover simultaneously; no manual IP or node configuration required
- **Multi-hop message relay** — messages propagate across the mesh even when sender and recipient have no direct link
- **Text chat** — broadcast or targeted messaging with severity tagging (`NORMAL` / `MODERATE` / `CRITICAL`)
- **Voice messages** — hold-to-record, base64-encoded, chunked for large files, played back on any mesh node
- **Live voice calls** — WebRTC audio over the mesh, with signaling relayed through intermediate peers
- **Triage / emergency broadcast** — structured emergency form that broadcasts to all reachable nodes
- **Hop counter** — every message displays how many relay hops it traversed
- **No single point of failure** — mesh self-heals when nodes disconnect or rejoin

---

## Architecture

```
Phone A ←——WiFi Direct——→ Phone B ←——WiFi Direct——→ Phone C
  (advertise + discover)    (relay node)               (discover only)
         ↑                        ↑                          ↑
    MeshService             MeshService                MeshService
    ChatService             ChatService                ChatService
    VoiceService            VoiceService               VoiceService
    CallService             CallService                CallService
```

**Transport layer:** `nearby_connections` (WiFi Direct, `P2P_CLUSTER` strategy) — allows both star and chain topologies, with every node acting as both hub and leaf simultaneously.

**Calling layer:** `flutter_webrtc` for real-time audio. The mesh itself acts as the WebRTC signaling channel — no STUN or TURN servers needed on a local WiFi Direct network.

**Voice messages:** Recorded with `record`, encoded to base64, transmitted as JSON payload, decoded and played back with `just_audio`. Audio larger than ~500 KB is automatically chunked.

---

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── message.dart          # Chat + voice message model
│   ├── peer.dart             # Connected device info
│   └── call_session.dart     # Call state model
├── services/
│   ├── mesh_service.dart     # WiFi Direct core — advertising + discovery
│   ├── chat_service.dart     # Text message send / receive / relay
│   ├── voice_service.dart    # Record, encode, send, play voice notes
│   └── call_service.dart     # WebRTC signaling over mesh
├── screens/
│   ├── home_screen.dart      # Mesh map + peer list
│   ├── chat_screen.dart      # Messaging UI
│   ├── call_screen.dart      # Active call UI
│   └── triage_screen.dart    # Emergency broadcast form
└── widgets/
    ├── mesh_map.dart          # Visual node graph
    ├── message_bubble.dart    # Chat bubble with hop badge
    ├── voice_bubble.dart      # Play/pause waveform widget
    └── call_overlay.dart      # Incoming call banner
```

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Android SDK 30+ (Android 10 minimum for `NEARBY_WIFI_DEVICES`)
- **3 physical Android devices** — WiFi Direct cannot be tested on emulators

### Installation

```bash
git clone https://github.com/your-org/meshlink.git
cd meshlink
flutter pub get
flutter run
```

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  nearby_connections: ^4.1.0      # WiFi Direct mesh transport
  flutter_webrtc: ^0.9.47         # Real-time voice calling
  record: ^5.0.4                  # Audio recording
  just_audio: ^0.9.36             # Audio playback
  provider: ^6.1.0                # State management
  uuid: ^4.3.3                    # Unique packet IDs
  path_provider: ^2.1.2           # Temp file paths
  permission_handler: ^11.3.0     # Runtime permissions
  encrypt: ^5.0.3                 # Optional AES encryption
```

---

## Permissions

Add the following to `AndroidManifest.xml`:

```xml
<!-- WiFi Direct / Nearby Connections -->
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.NEARBY_WIFI_DEVICES"/>

<!-- Microphone -->
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>

<!-- Temp file storage for voice messages -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

<!-- Optional: video calling -->
<uses-permission android:name="android.permission.CAMERA"/>
```

---

## Build Plan

The app was designed to be buildable in approximately 10 focused hours:

| Hour | Focus |
|---|---|
| 1 | Project setup, dependencies, permissions |
| 2 | `MeshService` — WiFi Direct advertising, discovery, broadcast |
| 3 | `ChatService` — text messaging with hop relay and deduplication |
| 4 | `VoiceService` — record, encode, transmit, decode, playback |
| 5 | `CallService` — WebRTC signaling and audio over mesh |
| 6 | Screens — Home, Chat, Call, Triage, Incoming Call overlay |
| 7 | Packet type system — smart relay logic, hop limits, targeted vs. broadcast |
| 8 | Voice message polish — chunked transfer for audio >500 KB |
| 9 | Testing on 3 physical devices — full test matrix |
| 10 | Edge cases, memory management, demo prep |

---

## Testing

Testing requires **3 physical Android devices** on Android 10 or later. WiFi should be enabled but does not need to be connected to any router — WiFi Direct operates independently.

### Test Matrix

| Test | Phone A | Phone B | Phone C | Expected Result |
|---|---|---|---|---|
| Basic connect | Start app | Start app | — | A ↔ B discover each other |
| Hop relay | Send message | Relay | Receive | C gets message with `hops: 1` |
| Voice message | Record + send | — | — | B receives and plays audio |
| Call via relay | Initiate call | Relay signals | Receive call | Two-way audio works |
| Disconnection | Kill app | — | — | Mesh self-heals; C reconnects to A |

---

## Packet Format

All packets are JSON transmitted as UTF-8 byte payloads over Nearby Connections.

**Text message:**
```json
{
  "id": "uuid-v4",
  "type": "text",
  "fromId": "Device_1234",
  "fromName": "Device_1234",
  "toId": null,
  "content": "Need help on 3rd floor",
  "severity": "CRITICAL",
  "hops": 0,
  "timestamp": "2024-01-01T12:00:00Z"
}
```

**Voice message:**
```json
{
  "id": "uuid-v4",
  "type": "voice",
  "fromId": "Device_1234",
  "toId": "Device_5678",
  "content": "<base64-encoded AAC audio>",
  "hops": 0,
  "timestamp": "2024-01-01T12:00:00Z"
}
```

**WebRTC call signal:**
```json
{
  "id": "uuid-v4",
  "type": "call_signal",
  "fromId": "Device_1234",
  "toId": "Device_5678",
  "content": "{\"type\":\"offer\",\"sdp\":\"...\"}",
  "hops": 0,
  "timestamp": "2024-01-01T12:00:00Z"
}
```

### Relay Logic

- Packets are deduplicated by `id` using a `seenPacketIds` set — loops are impossible.
- Broadcast packets (`toId: null`) are delivered locally and relayed with `hops + 1`.
- Targeted packets (`toId` set) are delivered if addressed to this device; otherwise relayed without local display.
- Maximum hop limit of `10` prevents runaway relay chains.
- Packet IDs older than 10 minutes are pruned to prevent unbounded memory growth.

---

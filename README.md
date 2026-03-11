# 📡 MeshLink
## 🔗 Offline Peer-to-Peer Communication Mesh

🚨 Offline peer-to-peer communication — text, voice messages, and live calls — with zero infrastructure.

MeshLink is a Flutter application that enables structured, resilient mesh networking between Android devices using WiFi Direct. Devices discover each other automatically, relay messages across multi-hop chains, and support real-time voice calls — all without a router, cell tower, or internet connection.

## ✨ Key Highlights

⚡ No Internet Required  
📡 WiFi Direct Mesh Networking  
📨 Text Messaging  
🎙 Voice Messages  
📞 Live Voice Calls (WebRTC)  
🔁 Multi-Hop Message Relay  
🚨 Emergency Broadcast System  
🧠 Self-Healing Network

## 📸 Demo
### 🎥 Demo Video

Demo Video:  
WhatsApp.Video.2026-03-11.at.5.12.13.PM.mp4

(You can also upload it to YouTube later and paste the link here)

## 📱 App Screenshots

(Add real screenshots here later)

Home Screen  
Chat Screen  
Voice Message  
Call Screen

## 🧠 Mesh Architecture Diagram

(You can later upload an architecture diagram image)

Example:

## 📚 Table of Contents

- [Use Cases](#-use-cases)
- [Features](#-features)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Permissions](#-permissions)
- [Build Plan](#-build-plan)
- [Testing](#-testing)
- [Packet Format](#-packet-format)
- [Relay Logic](#-relay-logic)
- [Contributing](#-contributing)
- [Developer](#-developer)
- [Support](#-support)

## 🌍 Use Cases

| Scenario | How MeshLink Helps |
|---|---|
| Disaster response | Maintain chat and voice calls when cell towers are down |
| Remote field ops | Connect team members in areas with no internet |
| Privacy-first networking | Share voice and text directly between devices |
| Tactical coordination | Rapid peer discovery with multi-hop routing |

## 🚀 Features

Automatic peer discovery — devices advertise and discover simultaneously; no manual IP or node configuration required.

Multi-hop message relay — messages propagate across the mesh even when sender and recipient have no direct link.

Text chat — broadcast or targeted messaging with severity tagging  
(NORMAL / MODERATE / CRITICAL).

Voice messages — hold-to-record, base64-encoded, chunked for large files, played back on any mesh node.

Live voice calls — WebRTC audio over the mesh, with signaling relayed through intermediate peers.

Triage / emergency broadcast — structured emergency form that broadcasts to all reachable nodes.

Hop counter — every message displays how many relay hops it traversed.

No single point of failure — mesh self-heals when nodes disconnect or rejoin.

## 🏗 Architecture

```text
Phone A ←——WiFi Direct——→ Phone B ←——WiFi Direct——→ Phone C
  (advertise + discover)    (relay node)               (discover only)
         ↑                        ↑                          ↑
    MeshService             MeshService                MeshService
    ChatService             ChatService                ChatService
    VoiceService            VoiceService               VoiceService
    CallService             CallService                CallService
```

Transport layer: nearby_connections (WiFi Direct, P2P_CLUSTER strategy)

Calling layer: flutter_webrtc for real-time audio.

Voice messages: Recorded with record, encoded to base64, transmitted as JSON payload, decoded and played back with just_audio.

## 📂 Project Structure

```text
lib/
├── main.dart
├── models/
│   ├── message.dart
│   ├── peer.dart
│   └── call_session.dart
│
├── services/
│   ├── mesh_service.dart
│   ├── chat_service.dart
│   ├── voice_service.dart
│   └── call_service.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── chat_screen.dart
│   ├── call_screen.dart
│   └── triage_screen.dart
│
└── widgets/
    ├── mesh_map.dart
    ├── message_bubble.dart
    ├── voice_bubble.dart
    └── call_overlay.dart
```

## ⚙️ Getting Started

### Prerequisites

Flutter SDK >=3.0.0  
Android SDK 30+

⚠ WiFi Direct cannot be tested on emulators.

You need 3 physical Android devices.

### Installation

```bash
git clone https://github.com/your-org/meshlink.git
cd meshlink
flutter pub get
flutter run
```

## 📦 Dependencies

```yaml
nearby_connections: ^4.1.0
flutter_webrtc: ^0.9.47
record: ^5.0.4
just_audio: ^0.9.36
provider: ^6.1.0
uuid: ^4.3.3
path_provider: ^2.1.2
permission_handler: ^11.3.0
encrypt: ^5.0.3
```

## 🔐 Permissions

Add to AndroidManifest.xml

```text
BLUETOOTH
BLUETOOTH_ADMIN
ACCESS_WIFI_STATE
CHANGE_WIFI_STATE
ACCESS_FINE_LOCATION
NEARBY_WIFI_DEVICES

RECORD_AUDIO
MODIFY_AUDIO_SETTINGS

READ_EXTERNAL_STORAGE
WRITE_EXTERNAL_STORAGE
CAMERA
```

## 🛠 Build Plan

| Hour | Focus |
|---|---|
| 1 | Project setup |
| 2 | MeshService |
| 3 | ChatService |
| 4 | VoiceService |
| 5 | CallService |
| 6 | UI screens |
| 7 | Packet system |
| 8 | Voice chunk transfer |
| 9 | Multi-device testing |
| 10 | Edge cases |

## 🧪 Testing

Testing requires 3 Android devices.

| Test | Phone A | Phone B | Phone C | Result |
|---|---|---|---|---|
| Basic connect | Start | Start | — | A ↔ B |
| Hop relay | Send | Relay | Receive | Works |
| Voice message | Record | — | — | Works |
| Call via relay | Initiate | Relay | Receive | Works |
| Disconnection | Kill app | — | — | Self-heals |

## 📦 APK Build

APK Download:

https://drive.google.com/file/d/16vyuYAnuxbvokqJTreew4oc5GHST9YcF/view

## 📡 Packet Format

Text message:

```json
{
  "id": "uuid-v4",
  "type": "text",
  "fromId": "Device_1234",
  "content": "Need help on 3rd floor",
  "severity": "CRITICAL",
  "hops": 0
}
```

Voice message:

```json
{
  "id": "uuid-v4",
  "type": "voice",
  "content": "<base64 audio>"
}
```

WebRTC call signal:

```json
{
  "type": "call_signal",
  "content": "{\"type\":\"offer\"}"
}
```

## 🔁 Relay Logic

Packets deduplicated using seenPacketIds.

Broadcast packets → delivered locally then relayed.  
Target packets → delivered only to target device.

Max hop limit = 10.

Old packets removed after 10 minutes.

## 🤝 Contributing

Contributions are welcome!

1️⃣ Fork the repository  
2️⃣ Create a new branch  
3️⃣ Make improvements  
4️⃣ Submit a Pull Request

## 👨‍💻 Developer

Developed by Tamal Kar

🎓 Computer Science Engineering Student  
💡 Interested in AI, Networking, and Real-World Problem Solving

GitHub:  
https://github.com/tamal151947-bit

## ⭐ Support

If you like this project:

⭐ Star the repository  
🍴 Fork the project  
📢 Share it with others

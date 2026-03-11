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


https://github.com/user-attachments/assets/012ab89a-68ca-437b-b3b3-5ab7e4fb30db



## 📱 App Screenshots

# Home Screen 

![WhatsApp Image 2026-03-11 at 5 06 13 PM](https://github.com/user-attachments/assets/894685a7-6520-4f53-b5b9-6639d6d986c3)
![WhatsApp Image 2026-03-11 at 5 06 14 PM](https://github.com/user-attachments/assets/e76058fb-a728-4e40-b12a-1423a753cee8)
![WhatsApp Image 2026-03-11 at 5 06 15 PM](https://github.com/user-attachments/assets/c79b36ef-aa1b-4f36-8d25-e56315a88ec1)
![WhatsApp Image 2026-03-11 at 5 06 15 PM (1)](https://github.com/user-attachments/assets/d7b7fc29-8488-43d4-94f4-8972bd75c893) 
![WhatsApp Image 2026-03-11 at 5 06 16 PM](https://github.com/user-attachments/assets/c76ebe23-f4d3-4b75-81da-1fa2859eeb72)
![WhatsApp Image 2026-03-11 at 5 06 18 PM](https://github.com/user-attachments/assets/1448e852-0b9f-4fe9-9362-80337dfbe6e3)

# Chat Screen 

![WhatsApp Image 2026-03-11 at 5 07 00 PM](https://github.com/user-attachments/assets/4bc6d943-4497-47fd-a3f5-c6f9338c978d)
![WhatsApp Image 2026-03-11 at 5 07 01 PM](https://github.com/user-attachments/assets/95805e02-5f5e-4970-9ace-9072e9a9a12a)
![WhatsApp Image 2026-03-11 at 5 07 01 PM (1)](https://github.com/user-attachments/assets/d632c8e6-eaa3-43fa-b0ef-f0f9075a82c7)

# Voice Message 

![WhatsApp Image 2026-03-11 at 5 07 01 PM](https://github.com/user-attachments/assets/1d99ac0d-634e-4618-b3cf-f739a6c05411)

# Call Screen

![WhatsApp Image 2026-03-11 at 5 06 18 PM (1)](https://github.com/user-attachments/assets/407a3e9e-40dc-4b87-8713-deac85c80ddd)
![WhatsApp Image 2026-03-11 at 5 07 01 PM (3)](https://github.com/user-attachments/assets/340a7b5a-c053-413c-a003-616e3992080a)

# Emergency Broadcast Message

![WhatsApp Image 2026-03-11 at 5 06 17 PM](https://github.com/user-attachments/assets/08a17070-a506-4e87-b976-c7e685e4d6c7)


## 🧠 Mesh Architecture Diagram

![pic1](https://github.com/user-attachments/assets/693c8ed3-5b26-4215-90a4-26dad544fd34)
![pic2](https://github.com/user-attachments/assets/dd9b22b4-8d0f-4dbd-aa89-ecb76caffc2e)
![pic3](https://github.com/user-attachments/assets/1d995bc3-197d-4af1-97d0-3e90991bf58c)


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
│   ├── message.dart            # Chat + voice message model
│   ├── peer.dart               # Connected device info
│   └── call_session.dart       # Call state model
│
├── services/
│   ├── mesh_service.dart       # WiFi Direct core — advertising + discovery
│   ├── chat_service.dart       # Text message send / receive / relay
│   ├── voice_service.dart      # Record, encode, send, play voice notes
│   └── call_service.dart       # WebRTC signaling over mesh
│
├── screens/
│   ├── home_screen.dart        # Mesh map + peer list
│   ├── chat_screen.dart        # Messaging UI
│   ├── call_screen.dart        # Active call UI
│   └── triage_screen.dart      # Emergency broadcast form
│
└── widgets/
    ├── mesh_map.dart           # Visual node graph
    ├── message_bubble.dart     # Chat bubble with hop badge
    ├── voice_bubble.dart       # Play/pause waveform widget
    └── call_overlay.dart       # Incoming call banner
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

## 🔐 Permissions

Add to AndroidManifest.xml

```text
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

https://drive.google.com/file/d/1IfzvklMEI16f69HWfpEBkn_ZgnjNDomF/view?usp=drive_link

## 📡 Packet Format

Text message:

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

Voice message:

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

WebRTC call signal:

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

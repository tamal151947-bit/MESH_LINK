import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/message.dart';
import 'call_service.dart';
import 'mesh_service.dart';

class ChatService extends ChangeNotifier {
  final MeshService mesh;
  final List<MeshMessage> messages = [];

  ChatService(this.mesh) {
    mesh.onPacketReceived = _handleIncoming;
  }

  void _handleIncoming(String raw, String senderEndpointId) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final msg = MeshMessage.fromJson(json);

    if (mesh.seenPacketIds.length > 1000) mesh.seenPacketIds.clear();
    if (mesh.seenPacketIds.contains(msg.id)) return;
    mesh.seenPacketIds.add(msg.id);

    if (msg.type == MessageType.call_signal) {
      if (msg.toId == null || msg.toId == mesh.deviceId) {
        CallService.instance?.handleSignal(msg);
      }
      if (msg.toId != null && msg.toId == mesh.deviceId) return;
      if (msg.hops < 10) {
        msg.hops += 1;
        mesh.broadcast(
          jsonEncode(msg.toJson()),
          excludeEndpoint: senderEndpointId,
        );
      }
      return;
    }

    if (msg.toId != null) {
      if (msg.toId == mesh.deviceId) {
        messages.add(msg);
        notifyListeners();
      } else {
        if (msg.hops < 10) {
          msg.hops += 1;
          mesh.broadcast(
            jsonEncode(msg.toJson()),
            excludeEndpoint: senderEndpointId,
          );
        }
      }
      return;
    }

    messages.add(msg);
    notifyListeners();
    if (msg.hops < 10) {
      msg.hops += 1;
      mesh.broadcast(
        jsonEncode(msg.toJson()),
        excludeEndpoint: senderEndpointId,
      );
    }
  }

  void sendText(String text, {String? toId, String severity = 'NORMAL'}) {
    final msg = MeshMessage(
      id: const Uuid().v4(),
      fromId: mesh.deviceId,
      fromName: mesh.deviceId,
      toId: toId,
      type: MessageType.text,
      content: text,
      timestamp: DateTime.now(),
      hops: 0,
      severity: severity,
    );
    mesh.seenPacketIds.add(msg.id);
    messages.add(msg);
    mesh.broadcast(jsonEncode(msg.toJson()));
    notifyListeners();
  }

  void sendVoice(String base64Audio, {String? toId}) {
    final msg = MeshMessage(
      id: const Uuid().v4(),
      fromId: mesh.deviceId,
      fromName: mesh.deviceId,
      toId: toId,
      type: MessageType.voice,
      content: base64Audio,
      timestamp: DateTime.now(),
      hops: 0,
    );
    mesh.seenPacketIds.add(msg.id);
    messages.add(msg);
    mesh.broadcast(jsonEncode(msg.toJson()));
    notifyListeners();
  }

  void sendSignal(String signalJson, {String? toId}) {
    final msg = MeshMessage(
      id: const Uuid().v4(),
      fromId: mesh.deviceId,
      fromName: mesh.deviceId,
      toId: toId,
      type: MessageType.call_signal,
      content: signalJson,
      timestamp: DateTime.now(),
      hops: 0,
    );
    mesh.seenPacketIds.add(msg.id);
    mesh.broadcast(jsonEncode(msg.toJson()));
  }
}

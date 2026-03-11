import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';

import '../models/peer.dart';

class MeshService extends ChangeNotifier {
  final Strategy strategy = Strategy.P2P_CLUSTER;
  String deviceId =
      'Node-${Random().nextInt(0xFFFF).toRadixString(16).toUpperCase().padLeft(4, '0')}';

  final Map<String, MeshPeer> connectedPeers = {};
  final Map<String, String> _pendingNames = {};
  final Set<String> seenPacketIds = {};

  Function(String raw, String senderEndpointId)? onPacketReceived;

  Future<void> start() async {
    await _startAdvertising();
    await _startDiscovery();
  }

  Future<void> _startAdvertising() async {
    await Nearby().startAdvertising(
      deviceId,
      strategy,
      onConnectionInitiated: _handleConnectionInitiated,
      onConnectionResult: _handleConnectionResult,
      onDisconnected: _handleDisconnected,
    );
  }

  Future<void> _startDiscovery() async {
    await Nearby().startDiscovery(
      deviceId,
      strategy,
      onEndpointFound: (id, name, serviceId) {
        Nearby().requestConnection(
          deviceId,
          id,
          onConnectionInitiated: _handleConnectionInitiated,
          onConnectionResult: _handleConnectionResult,
          onDisconnected: _handleDisconnected,
        );
      },
      onEndpointLost: (id) {},
    );
  }

  void _handleConnectionInitiated(String id, ConnectionInfo info) {
    _pendingNames[id] = info.endpointName;
    Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (endId, payload) {
        if (payload.type == PayloadType.BYTES) {
          final raw = String.fromCharCodes(payload.bytes!);
          onPacketReceived?.call(raw, endId);
        }
      },
      onPayloadTransferUpdate: (endId, update) {},
    );
  }

  void _handleConnectionResult(String id, Status status) {
    if (status == Status.CONNECTED) {
      final name = _pendingNames.remove(id) ?? id;
      connectedPeers[id] = MeshPeer(
        endpointId: id,
        displayName: name,
        lastSeen: DateTime.now(),
        isConnected: true,
      );
    } else {
      _pendingNames.remove(id);
    }
    notifyListeners();
  }

  void _handleDisconnected(String id) {
    connectedPeers.remove(id);
    _pendingNames.remove(id);
    notifyListeners();
  }

  void broadcast(String raw, {String? excludeEndpoint}) {
    for (final id in connectedPeers.keys) {
      if (id != excludeEndpoint) {
        Nearby().sendBytesPayload(id, Uint8List.fromList(raw.codeUnits));
      }
    }
  }

  Future<void> sendBytes(String endpointId, Uint8List bytes) async {
    await Nearby().sendBytesPayload(endpointId, bytes);
  }
}

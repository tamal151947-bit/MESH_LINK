import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';

import '../models/peer.dart';

class MeshService extends ChangeNotifier {
  final Strategy strategy = Strategy.P2P_CLUSTER;
  final String deviceId = 'Device_${DateTime.now().millisecondsSinceEpoch}';

  Map<String, MeshPeer> connectedPeers = {};
  Set<String> seenPacketIds = {};

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
      onConnectionResult: (id, status) {
        if (status == Status.CONNECTED) notifyListeners();
      },
      onDisconnected: (id) {
        connectedPeers.remove(id);
        notifyListeners();
      },
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
          onConnectionResult: (id, status) {
            if (status == Status.CONNECTED) notifyListeners();
          },
          onDisconnected: (id) {
            connectedPeers.remove(id);
            notifyListeners();
          },
        );
      },
      onEndpointLost: (id) {},
    );
  }

  void _handleConnectionInitiated(String id, ConnectionInfo info) {
    connectedPeers[id] = MeshPeer(
      endpointId: id,
      displayName: info.endpointName,
      lastSeen: DateTime.now(),
      isConnected: true,
    );
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

class MeshPeer {
  final String endpointId;
  final String displayName;
  final DateTime lastSeen;
  bool isConnected;

  MeshPeer({
    required this.endpointId,
    required this.displayName,
    required this.lastSeen,
    this.isConnected = false,
  });

  @override
  bool operator ==(Object other) =>
      other is MeshPeer && other.endpointId == endpointId;

  @override
  int get hashCode => endpointId.hashCode;
}

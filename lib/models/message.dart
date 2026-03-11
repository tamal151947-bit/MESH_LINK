enum MessageType { text, voice, call_signal }

class MeshMessage {
  final String id;
  final String fromId;
  final String fromName;
  final String? toId;          // null = broadcast
  final MessageType type;
  final String content;        // text or base64 audio or JSON signal
  final DateTime timestamp;
  int hops;
  final String severity;       // NORMAL / MODERATE / CRITICAL

  MeshMessage({
    required this.id,
    required this.fromId,
    required this.fromName,
    this.toId,
    required this.type,
    required this.content,
    required this.timestamp,
    this.hops = 0,
    this.severity = 'NORMAL',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromId': fromId,
    'fromName': fromName,
    'toId': toId,
    'type': type.name,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'hops': hops,
    'severity': severity,
  };

  factory MeshMessage.fromJson(Map<String, dynamic> j) => MeshMessage(
    id: j['id'],
    fromId: j['fromId'],
    fromName: j['fromName'],
    toId: j['toId'],
    type: MessageType.values.byName(j['type']),
    content: j['content'],
    timestamp: DateTime.parse(j['timestamp']),
    hops: j['hops'],
    severity: j['severity'] ?? 'NORMAL',
  );
}
enum CallState { idle, calling, ringing, active, ended }

class CallSession {
  final String callId;
  final String remotePeerId;
  final String remoteName;
  final DateTime startedAt;
  CallState state;

  CallSession({
    required this.callId,
    required this.remotePeerId,
    required this.remoteName,
    required this.startedAt,
    this.state = CallState.idle,
  });
}

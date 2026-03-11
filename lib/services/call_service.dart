import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';

import '../models/call_session.dart';
import '../models/message.dart';
import '../models/peer.dart';
import 'chat_service.dart';
import 'mesh_service.dart';

class CallService extends ChangeNotifier {
  static CallService? instance;

  final MeshService mesh;
  final ChatService chat;

  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  CallSession? currentSession;
  MeshPeer? incomingCallFrom;
  Map<String, dynamic>? _pendingOffer;

  bool get inCall =>
      currentSession?.state == CallState.active ||
      currentSession?.state == CallState.calling ||
      currentSession?.state == CallState.ringing;

  CallService(this.mesh, this.chat) {
    instance = this;
    remoteRenderer.initialize();
  }

  // ─── Outgoing call ───

  Future<void> startCall(String peerId, String peerName) async {
    final callId = const Uuid().v4();
    currentSession = CallSession(
      callId: callId,
      remotePeerId: peerId,
      remoteName: peerName,
      startedAt: DateTime.now(),
      state: CallState.calling,
    );
    notifyListeners();

    await _setupPeerConnection(peerId);

    final offer = await _pc!.createOffer({'offerToReceiveAudio': true});
    await _pc!.setLocalDescription(offer);
    chat.sendSignal(
      jsonEncode({'type': 'offer', 'callId': callId, 'sdp': offer.sdp}),
      toId: peerId,
    );
  }

  // ─── Signal dispatch ───

  void handleSignal(MeshMessage msg) {
    final data = jsonDecode(msg.content) as Map<String, dynamic>;
    final type = data['type'] as String;
    switch (type) {
      case 'offer':
        _handleOffer(msg.fromId, msg.fromName, data);
      case 'answer':
        _handleAnswer(data);
      case 'ice':
        _handleIce(data);
      case 'hangup':
        _handleRemoteHangup();
    }
  }

  void _handleOffer(
      String fromId, String fromName, Map<String, dynamic> data) {
    incomingCallFrom = mesh.connectedPeers[fromId] ??
        MeshPeer(
          endpointId: fromId,
          displayName: fromName,
          lastSeen: DateTime.now(),
        );
    _pendingOffer = data;
    currentSession = CallSession(
      callId: data['callId'] as String,
      remotePeerId: fromId,
      remoteName: fromName,
      startedAt: DateTime.now(),
      state: CallState.ringing,
    );
    notifyListeners();
  }

  Future<void> acceptCall() async {
    if (_pendingOffer == null || currentSession == null) return;
    await _setupPeerConnection(currentSession!.remotePeerId);

    final offer =
        RTCSessionDescription(_pendingOffer!['sdp'] as String, 'offer');
    await _pc!.setRemoteDescription(offer);

    final answer = await _pc!.createAnswer();
    await _pc!.setLocalDescription(answer);
    chat.sendSignal(
      jsonEncode({
        'type': 'answer',
        'callId': currentSession!.callId,
        'sdp': answer.sdp,
      }),
      toId: currentSession!.remotePeerId,
    );

    currentSession!.state = CallState.active;
    incomingCallFrom = null;
    _pendingOffer = null;
    notifyListeners();
  }

  void declineCall() {
    if (currentSession == null) return;
    chat.sendSignal(
      jsonEncode({'type': 'hangup', 'callId': currentSession!.callId}),
      toId: currentSession!.remotePeerId,
    );
    _cleanup();
  }

  void endCall() {
    if (currentSession == null) return;
    chat.sendSignal(
      jsonEncode({'type': 'hangup', 'callId': currentSession!.callId}),
      toId: currentSession!.remotePeerId,
    );
    _cleanup();
  }

  Future<void> _handleAnswer(Map<String, dynamic> data) async {
    final answer =
        RTCSessionDescription(data['sdp'] as String, 'answer');
    await _pc?.setRemoteDescription(answer);
    currentSession?.state = CallState.active;
    notifyListeners();
  }

  Future<void> _handleIce(Map<String, dynamic> data) async {
    final candidate = RTCIceCandidate(
      data['candidate'] as String,
      data['sdpMid'] as String?,
      data['sdpMLineIndex'] as int?,
    );
    await _pc?.addCandidate(candidate);
  }

  void _handleRemoteHangup() => _cleanup();

  Future<void> _setupPeerConnection(String remotePeerId) async {
    _pc = await createPeerConnection({'iceServers': []});

    _localStream = await navigator.mediaDevices
        .getUserMedia({'audio': true, 'video': false});
    for (final track in _localStream!.getAudioTracks()) {
      await _pc!.addTrack(track, _localStream!);
    }

    _pc!.onIceCandidate = (candidate) {
      if (candidate.candidate == null) return;
      chat.sendSignal(
        jsonEncode({
          'type': 'ice',
          'callId': currentSession?.callId,
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        }),
        toId: remotePeerId,
      );
    };

    _pc!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams.first;
        notifyListeners();
      }
    };
  }

  void _cleanup() {
    _pc?.close();
    _pc = null;
    _localStream?.dispose();
    _localStream = null;
    remoteRenderer.srcObject = null;
    currentSession = null;
    incomingCallFrom = null;
    _pendingOffer = null;
    notifyListeners();
  }

  void toggleMute() {
    if (_localStream == null) return;
    for (final track in _localStream!.getAudioTracks()) {
      track.enabled = !track.enabled;
    }
    notifyListeners();
  }

  bool get isMuted {
    if (_localStream == null) return false;
    final tracks = _localStream!.getAudioTracks();
    if (tracks.isEmpty) return false;
    return !tracks.first.enabled;
  }

  @override
  void dispose() {
    instance = null;
    _cleanup();
    remoteRenderer.dispose();
    super.dispose();
  }
}

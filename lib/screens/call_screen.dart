import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

import '../models/call_session.dart';
import '../services/call_service.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late Timer _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CallService>(
      builder: (context, callService, _) {
        final session = callService.currentSession;

        if (session == null || session.state == CallState.ended) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.canPop(context)) Navigator.pop(context);
          });
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade900,
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 0,
                  height: 0,
                  child: RTCVideoView(callService.remoteRenderer),
                ),
                const Spacer(),
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.teal,
                  child: Text(
                    (session?.remoteName ?? '?')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  session?.remoteName ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  session?.state == CallState.calling
                      ? 'Calling...'
                      : session?.state == CallState.ringing
                      ? 'Ringing...'
                      : _formatDuration(_seconds),
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CallButton(
                      icon: callService.isMuted ? Icons.mic_off : Icons.mic,
                      label: callService.isMuted ? 'Unmute' : 'Mute',
                      color: Colors.grey.shade700,
                      onTap: callService.toggleMute,
                    ),
                    _CallButton(
                      icon: Icons.call_end,
                      label: 'End',
                      color: Colors.red,
                      onTap: callService.endCall,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CallButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: label,
          backgroundColor: color,
          onPressed: onTap,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

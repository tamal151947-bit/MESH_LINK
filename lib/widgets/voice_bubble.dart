import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/voice_service.dart';

class VoiceBubble extends StatelessWidget {
  final String base64Audio;
  final bool isMe;

  const VoiceBubble({
    super.key,
    required this.base64Audio,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final voice = context.read<VoiceService>();
    final iconColor = isMe ? Colors.white : Colors.black87;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.play_arrow, color: iconColor),
          onPressed: () => voice.playBase64(base64Audio),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 4),
        Icon(Icons.graphic_eq, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Text(
          'Voice message',
          style: TextStyle(fontSize: 12, color: iconColor),
        ),
      ],
    );
  }
}

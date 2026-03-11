import 'package:flutter/material.dart';

import '../models/message.dart';
import 'voice_bubble.dart';

class MessageBubble extends StatelessWidget {
  final MeshMessage message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  Color get _severityColor {
    switch (message.severity) {
      case 'CRITICAL':
        return Colors.red;
      case 'MODERATE':
        return Colors.orange;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor =
        isMe ? Theme.of(context).colorScheme.primary : Colors.grey.shade200;
    final textColor = isMe ? Colors.white : Colors.black87;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
          border: _severityColor != Colors.transparent
              ? Border.all(color: _severityColor, width: 2)
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.fromName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textColor.withAlpha(180),
                ),
              ),
            if (message.type == MessageType.voice)
              VoiceBubble(base64Audio: message.content, isMe: isMe)
            else
              Text(
                message.content,
                style: TextStyle(color: textColor),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.hops > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${message.hops} hop${message.hops > 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                if (message.hops > 0) const SizedBox(width: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor.withAlpha(150),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

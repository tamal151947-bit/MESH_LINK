import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/message.dart';
import '../models/peer.dart';
import '../services/call_service.dart';
import '../services/chat_service.dart';
import '../services/voice_service.dart';
import '../widgets/message_bubble.dart';
import 'call_screen.dart';

class ChatScreen extends StatefulWidget {
  final MeshPeer peer;

  const ChatScreen({super.key, required this.peer});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<MeshMessage> _filteredMessages(ChatService chat, String deviceId) {
    return chat.messages.where((m) {
      final isFromPeer = m.fromId == widget.peer.displayName;
      final isFromMeToPeer =
          m.fromId == deviceId && m.toId == widget.peer.displayName;
      return isFromPeer || isFromMeToPeer;
    }).toList();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _sendText(ChatService chat) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    chat.sendText(text, toId: widget.peer.displayName);
    _textController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatService>();
    final voice = context.read<VoiceService>();
    final callService = context.read<CallService>();
    final deviceId = context.read<ChatService>().mesh.deviceId;
    final messages = _filteredMessages(chat, deviceId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peer.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              callService.startCall(
                widget.peer.displayName,
                widget.peer.displayName,
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CallScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                return MessageBubble(
                  message: msg,
                  isMe: msg.fromId == deviceId,
                );
              },
            ),
          ),
          _buildInputRow(context, chat, voice),
        ],
      ),
    );
  }

  Widget _buildInputRow(
    BuildContext context,
    ChatService chat,
    VoiceService voice,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onSubmitted: (_) => _sendText(chat),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _sendText(chat),
            ),
            Listener(
              onPointerDown: (_) => voice.startRecording(),
              onPointerUp: (_) async {
                final encoded = await voice.stopAndEncode();
                if (encoded != null) {
                  chat.sendVoice(encoded, toId: widget.peer.displayName);
                }
              },
              child: Consumer<VoiceService>(
                builder: (_, v, child) => CircleAvatar(
                  backgroundColor: v.isRecording ? Colors.red : Colors.teal,
                  child: Icon(
                    v.isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

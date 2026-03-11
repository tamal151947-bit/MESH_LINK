import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/chat_service.dart';

class TriageScreen extends StatefulWidget {
  const TriageScreen({super.key});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _injuryController = TextEditingController();
  String _severity = 'NORMAL';

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _injuryController.dispose();
    super.dispose();
  }

  void _submit(ChatService chat) {
    if (_nameController.text.isEmpty) return;
    final text = 'TRIAGE REPORT\n'
        'Name: ${_nameController.text}\n'
        'Location: ${_locationController.text}\n'
        'Injury: ${_injuryController.text}';
    chat.sendText(text, severity: _severity);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.read<ChatService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Broadcast')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.medical_services, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _injuryController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Injury / Condition',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Severity', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'NORMAL', label: Text('Stable')),
                ButtonSegment(value: 'MODERATE', label: Text('Moderate')),
                ButtonSegment(value: 'CRITICAL', label: Text('Critical')),
              ],
              selected: {_severity},
              onSelectionChanged: (s) => setState(() => _severity = s.first),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _submit(chat),
              icon: const Icon(Icons.send),
              label: const Text('BROADCAST'),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/peer.dart';
import '../services/call_service.dart';
import '../services/mesh_service.dart';
import '../widgets/call_overlay.dart';
import '../widgets/mesh_map.dart';
import 'call_screen.dart';
import 'chat_screen.dart';
import 'triage_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mesh = context.watch<MeshService>();
    final peers = mesh.connectedPeers.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MeshLink'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              avatar: Icon(
                mesh.connectedPeers.isEmpty
                    ? Icons.wifi_off
                    : Icons.wifi,
                size: 16,
                color: mesh.connectedPeers.isEmpty
                    ? Colors.grey
                    : Colors.teal,
              ),
              label: Text('${peers.length} peer${peers.length == 1 ? '' : 's'}'),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(
                height: 200,
                child: MeshMap(),
              ),
              const Divider(height: 1),
              Expanded(
                child: peers.isEmpty
                    ? const _EmptyPeerList()
                    : ListView.builder(
                        itemCount: peers.length,
                        itemBuilder: (context, index) =>
                            _PeerTile(peer: peers[index]),
                      ),
              ),
            ],
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CallOverlay(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TriageScreen()),
        ),
        icon: const Icon(Icons.medical_services),
        label: const Text('Triage'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class _EmptyPeerList extends StatelessWidget {
  const _EmptyPeerList();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sensors, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text('Scanning for peers…', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 4),
          Text(
            'Make sure nearby devices have MeshLink open',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PeerTile extends StatelessWidget {
  final MeshPeer peer;

  const _PeerTile({required this.peer});

  @override
  Widget build(BuildContext context) {
    final callService = context.read<CallService>();

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.teal.shade100,
        child: Text(
          peer.displayName[0].toUpperCase(),
          style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(peer.displayName),
      subtitle: const Text('Connected'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.teal),
            tooltip: 'Call',
            onPressed: () {
              callService.startCall(peer.displayName, peer.displayName);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CallScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.teal),
            tooltip: 'Chat',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatScreen(peer: peer)),
            ),
          ),
        ],
      ),
    );
  }
}

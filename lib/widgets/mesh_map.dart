import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/peer.dart';
import '../services/mesh_service.dart';

class MeshMapPainter extends CustomPainter {
  final Map<String, MeshPeer> peers;
  final String selfId;

  MeshMapPainter({required this.peers, required this.selfId});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const selfRadius = 20.0;
    const peerRadius = 14.0;
    const orbitRadius = 70.0;

    final linePaint = Paint()
      ..color = Colors.teal.withAlpha(100)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final selfPaint = Paint()..color = Colors.teal;
    final peerPaint = Paint()..color = Colors.grey.shade400;

    final peerList = peers.values.toList();
    final peerOffsets = <Offset>[];

    // Compute peer positions evenly around a circle
    for (int i = 0; i < peerList.length; i++) {
      final angle = (2 * pi * i) / max(peerList.length, 1) - pi / 2;
      peerOffsets.add(Offset(
        center.dx + orbitRadius * cos(angle),
        center.dy + orbitRadius * sin(angle),
      ));
    }

    // Draw edges first
    for (final offset in peerOffsets) {
      canvas.drawLine(center, offset, linePaint);
    }

    // Draw peer nodes
    for (int i = 0; i < peerList.length; i++) {
      canvas.drawCircle(peerOffsets[i], peerRadius, peerPaint);
      _drawLabel(canvas, peerList[i].displayName, peerOffsets[i],
          peerRadius + 4);
    }

    // Draw self node on top
    canvas.drawCircle(center, selfRadius, selfPaint);
    _drawLabel(canvas, 'You', center, selfRadius + 4);
  }

  void _drawLabel(Canvas canvas, String text, Offset center, double yOffset) {
    final tp = TextPainter(
      text: TextSpan(
        text: text.length > 8 ? '${text.substring(0, 8)}…' : text,
        style: const TextStyle(color: Colors.black87, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy + yOffset),
    );
  }

  @override
  bool shouldRepaint(MeshMapPainter oldDelegate) =>
      oldDelegate.peers.length != peers.length;
}

class MeshMap extends StatelessWidget {
  const MeshMap({super.key});

  @override
  Widget build(BuildContext context) {
    final mesh = context.watch<MeshService>();
    return CustomPaint(
      painter: MeshMapPainter(
        peers: mesh.connectedPeers,
        selfId: mesh.deviceId,
      ),
      size: const Size(double.infinity, 200),
    );
  }
}

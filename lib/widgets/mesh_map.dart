import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/peer.dart';
import '../services/mesh_service.dart';

class MeshMapPainter extends CustomPainter {
  final Map<String, MeshPeer> peers;
  final String selfId;
  final double orbitRadius;

  MeshMapPainter({
    required this.peers,
    required this.selfId,
    required this.orbitRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const selfRadius = 18.0;
    const peerRadius = 13.0;

    final linePaint = Paint()
      ..color = const Color(0xFF00D4AA).withAlpha(60)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final peerList = peers.values.toList();
    final peerOffsets = <Offset>[];

    for (int i = 0; i < peerList.length; i++) {
      final angle = (2 * pi * i) / max(peerList.length, 1) - pi / 2;
      peerOffsets.add(
        Offset(
          center.dx + orbitRadius * cos(angle),
          center.dy + orbitRadius * sin(angle),
        ),
      );
    }

    for (final offset in peerOffsets) {
      canvas.drawLine(center, offset, linePaint);
    }

    for (int i = 0; i < peerList.length; i++) {
      canvas.drawCircle(
        peerOffsets[i],
        peerRadius + 4,
        Paint()
          ..color = const Color(0xFF4D9EFF).withAlpha(40)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(
        peerOffsets[i],
        peerRadius,
        Paint()
          ..shader =
              const LinearGradient(
                colors: [Color(0xFF4D9EFF), Color(0xFF1E5FAA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(
                Rect.fromCircle(center: peerOffsets[i], radius: peerRadius),
              ),
      );
      canvas.drawCircle(
        peerOffsets[i],
        peerRadius,
        Paint()
          ..color = const Color(0xFF6BB8FF).withAlpha(160)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      _drawLabel(
        canvas,
        peerList[i].displayName,
        peerOffsets[i],
        peerRadius + 4,
      );
    }

    canvas.drawCircle(
      center,
      selfRadius + 6,
      Paint()
        ..color = const Color(0xFF00D4AA).withAlpha(50)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
      center,
      selfRadius,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF00D4AA), Color(0xFF008F72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: center, radius: selfRadius)),
    );
    canvas.drawCircle(
      center,
      selfRadius,
      Paint()
        ..color = const Color(0xFF80FFDF).withAlpha(160)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    _drawLabel(
      canvas,
      selfId.isNotEmpty ? selfId : 'You',
      center,
      selfRadius + 4,
    );
  }

  void _drawLabel(Canvas canvas, String text, Offset center, double yOffset) {
    final tp = TextPainter(
      text: TextSpan(
        text: text.length > 8 ? '${text.substring(0, 8)}…' : text,
        style: const TextStyle(
          color: Color(0xFFB0C8E0),
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + yOffset));
  }

  @override
  bool shouldRepaint(MeshMapPainter oldDelegate) =>
      oldDelegate.peers.length != peers.length ||
      oldDelegate.orbitRadius != orbitRadius;
}

class MeshMap extends StatelessWidget {
  const MeshMap({super.key});

  @override
  Widget build(BuildContext context) {
    final mesh = context.watch<MeshService>();
    final peerCount = mesh.connectedPeers.length;
    final autoOrbitRadius = max(
      72.0,
      72.0 + (peerCount - 3).clamp(0, 100) * 24.0,
    );

    return InteractiveViewer(
      minScale: 0.3,
      maxScale: 5.0,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      child: SizedBox.expand(
        child: CustomPaint(
          painter: MeshMapPainter(
            peers: mesh.connectedPeers,
            selfId: mesh.deviceId,
            orbitRadius: autoOrbitRadius,
          ),
        ),
      ),
    );
  }
}

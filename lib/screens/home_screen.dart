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
    final isOnline = peers.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A0E1A),
                  Color(0xFF0D1B2A),
                  Color(0xFF0A1628),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00D4AA), Color(0xFF0099CC)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00D4AA).withAlpha(100),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.hub_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MeshLink',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Decentralised mesh network',
                            style: TextStyle(
                              color: Color(0xFF6B7A99),
                              fontSize: 11,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _StatusBadge(isOnline: isOnline, peerCount: peers.length),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF111827), Color(0xFF0D1F2D)],
                      ),
                      border: Border.all(
                        color: const Color(0xFF1E3A4A),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D4AA).withAlpha(20),
                          blurRadius: 30,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: const Size(double.infinity, 220),
                            painter: _GridPainter(),
                          ),
                          const MeshMap(),
                          Positioned(
                            top: 12,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00D4AA).withAlpha(30),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF00D4AA).withAlpha(80),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.radar,
                                    size: 11,
                                    color: Color(0xFF00D4AA),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'LIVE MESH',
                                    style: TextStyle(
                                      color: Color(0xFF00D4AA),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text(
                        'Nearby Peers',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (peers.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D4AA).withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${peers.length}',
                            style: const TextStyle(
                              color: Color(0xFF00D4AA),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: peers.isEmpty
                      ? const _EmptyPeerList()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: peers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) =>
                              _PeerTile(peer: peers[index]),
                        ),
                ),
              ],
            ),
          ),

          const Positioned(top: 0, left: 0, right: 0, child: CallOverlay()),

          Positioned(
            bottom: 28,
            right: 24,
            child: _TriageFAB(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TriageScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isOnline;
  final int peerCount;

  const _StatusBadge({required this.isOnline, required this.peerCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOnline
            ? const Color(0xFF00D4AA).withAlpha(20)
            : const Color(0xFF6B7A99).withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOnline
              ? const Color(0xFF00D4AA).withAlpha(80)
              : const Color(0xFF3A4A5E),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline
                  ? const Color(0xFF00D4AA)
                  : const Color(0xFF6B7A99),
              boxShadow: isOnline
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00D4AA).withAlpha(150),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline
                ? '$peerCount peer${peerCount == 1 ? '' : 's'}'
                : 'Scanning',
            style: TextStyle(
              color: isOnline
                  ? const Color(0xFF00D4AA)
                  : const Color(0xFF6B7A99),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPeerList extends StatefulWidget {
  const _EmptyPeerList();

  @override
  State<_EmptyPeerList> createState() => _EmptyPeerListState();
}

class _EmptyPeerListState extends State<_EmptyPeerList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => CustomPaint(
              size: const Size(80, 80),
              painter: _PulsePainter(_controller.value),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Scanning for peers…',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Make sure nearby devices have MeshLink open',
            style: TextStyle(color: Color(0xFF6B7A99), fontSize: 12),
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

    final hue =
        (peer.displayName.codeUnits.fold(0, (a, b) => a + b) * 137) % 360;
    final avatarColor = HSLColor.fromAHSL(
      1,
      hue.toDouble(),
      0.55,
      0.45,
    ).toColor();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111827), Color(0xFF0F1E2C)],
        ),
        border: Border.all(color: const Color(0xFF1E3A4A), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarColor.withAlpha(40),
                border: Border.all(
                  color: avatarColor.withAlpha(120),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  peer.displayName[0].toUpperCase(),
                  style: TextStyle(
                    color: avatarColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    peer.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF00D4AA),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Connected',
                        style: TextStyle(
                          color: Color(0xFF00D4AA),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _ActionButton(
              icon: Icons.call_rounded,
              color: const Color(0xFF00D4AA),
              tooltip: 'Call',
              onTap: () {
                callService.startCall(peer.displayName, peer.displayName);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CallScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
            _ActionButton(
              icon: Icons.chat_bubble_rounded,
              color: const Color(0xFF4D9EFF),
              tooltip: 'Chat',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatScreen(peer: peer)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(25),
            border: Border.all(color: color.withAlpha(80), width: 1),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

class _TriageFAB extends StatelessWidget {
  final VoidCallback onTap;

  const _TriageFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE53935).withAlpha(100),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.medical_services_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Triage',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  final double t;
  _PulsePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 3; i++) {
      final progress = ((t + i / 3) % 1.0);
      final radius = 10.0 + progress * 36;
      final alpha = ((1 - progress) * 120).toInt();
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0xFF00D4AA).withAlpha(alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = const Color(0xFF00D4AA)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = Colors.white.withAlpha(60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_PulsePainter old) => old.t != t;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A2E40).withAlpha(120)
      ..strokeWidth = 0.5;
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter _) => false;
}

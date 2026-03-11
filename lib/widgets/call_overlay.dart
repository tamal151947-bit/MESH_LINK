import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/call_screen.dart';
import '../services/call_service.dart';

class CallOverlay extends StatelessWidget {
  const CallOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CallService>(
      builder: (context, callService, _) {
        if (callService.incomingCallFrom == null) {
          return const SizedBox.shrink();
        }
        return Material(
          elevation: 8,
          color: Colors.green.shade700,
          child: SafeArea(
            bottom: false,
            child: ListTile(
              leading: const Icon(Icons.call, color: Colors.white),
              title: Text(
                'Incoming call from ${callService.currentSession?.remoteName ?? 'Unknown'}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.white),
                    tooltip: 'Accept',
                    onPressed: () async {
                      await callService.acceptCall();
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CallScreen()),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.call_end, color: Colors.red),
                    tooltip: 'Decline',
                    onPressed: () => callService.declineCall(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/call_service.dart';
import 'services/chat_service.dart';
import 'services/mesh_service.dart';
import 'services/voice_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MeshLinkApp());
}

class MeshLinkApp extends StatelessWidget {
  const MeshLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MeshService()),
        ChangeNotifierProxyProvider<MeshService, ChatService>(
          create: (ctx) => ChatService(ctx.read<MeshService>()),
          update: (ctx, mesh, prev) => prev ?? ChatService(mesh),
        ),
        ChangeNotifierProxyProvider2<MeshService, ChatService, CallService>(
          create: (ctx) => CallService(
            ctx.read<MeshService>(),
            ctx.read<ChatService>(),
          ),
          update: (ctx, mesh, chat, prev) => prev ?? CallService(mesh, chat),
        ),
        ChangeNotifierProvider(create: (_) => VoiceService()),
      ],
      child: MaterialApp(
        title: 'MeshLink',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const PermissionGateway(),
      ),
    );
  }
}

class PermissionGateway extends StatefulWidget {
  const PermissionGateway({super.key});

  @override
  State<PermissionGateway> createState() => _PermissionGatewayState();
}

class _PermissionGatewayState extends State<PermissionGateway> {
  bool _ready = false;
  String _status = 'Requesting permissions…';

  @override
  void initState() {
    super.initState();
    _initPermissionsAndMesh();
  }

  Future<void> _initPermissionsAndMesh() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
      Permission.microphone,
      Permission.nearbyWifiDevices,
    ].request();

    final denied =
        statuses.values.any((s) => s.isDenied || s.isPermanentlyDenied);

    if (denied) {
      setState(
          () => _status = 'Some permissions were denied. Please grant them in Settings.');
      return;
    }

    if (!mounted) return;
    await context.read<MeshService>().start();

    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return const HomeScreen();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sensors, size: 64, color: Colors.teal),
              const SizedBox(height: 24),
              const Text(
                'MeshLink',
                style:
                    TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              if (_status.contains('denied'))
                FilledButton(
                  onPressed: openAppSettings,
                  child: const Text('Open Settings'),
                )
              else
                const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

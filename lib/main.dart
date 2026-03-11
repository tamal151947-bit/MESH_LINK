import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
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
          create: (ctx) =>
              CallService(ctx.read<MeshService>(), ctx.read<ChatService>()),
          update: (ctx, mesh, chat, prev) => prev ?? CallService(mesh, chat),
        ),
        ChangeNotifierProvider(create: (_) => VoiceService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MeshLink',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00D4AA),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0A0E1A),
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
  bool _loading = true; // While reading saved name from disk
  bool _hasName = false; // True once a name is confirmed
  String _status = 'Requesting permissions…';
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkSavedName();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<File> _nameFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/username.txt');
  }

  Future<void> _checkSavedName() async {
    final file = await _nameFile();
    if (await file.exists()) {
      final name = (await file.readAsString()).trim();
      if (name.isNotEmpty && mounted) {
        context.read<MeshService>().deviceId = name;
        setState(() {
          _loading = false;
          _hasName = true;
        });
        _initPermissionsAndMesh();
        return;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _submitName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final file = await _nameFile();
    await file.writeAsString(name);
    if (!mounted) return;
    context.read<MeshService>().deviceId = name;
    setState(() => _hasName = true);
    _initPermissionsAndMesh();
  }

  Future<void> _initPermissionsAndMesh() async {
    setState(() => _status = 'Requesting permissions…');
    final statuses = await [
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
      Permission.microphone,
      Permission.nearbyWifiDevices,
    ].request();

    final denied = statuses.values.any(
      (s) => s.isDenied || s.isPermanentlyDenied,
    );

    if (denied) {
      setState(
        () => _status =
            'Some permissions were denied. Please grant them in Settings.',
      );
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

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_hasName) return _buildNameEntry();

    return _buildPermissionStatus();
  }

  Widget _buildNameEntry() {
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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your name so others can identify you',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Your name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                onSubmitted: (_) => _submitName(),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _submitName,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionStatus() {
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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              if (_status.contains('denied'))
                Column(
                  children: [
                    FilledButton(
                      onPressed: openAppSettings,
                      child: const Text('Open Settings'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _initPermissionsAndMesh,
                      child: const Text('Try Again'),
                    ),
                  ],
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

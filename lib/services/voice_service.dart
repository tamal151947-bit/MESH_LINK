import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class VoiceService extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool isRecording = false;

  Future<void> startRecording() async {
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 32000,
        sampleRate: 16000,
      ),
      path: path,
    );
    isRecording = true;
    notifyListeners();
  }

  Future<String?> stopAndEncode() async {
    final path = await _recorder.stop();
    isRecording = false;
    notifyListeners();
    if (path == null) return null;
    final bytes = await File(path).readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> playBase64(String encoded) async {
    final bytes = base64Decode(encoded);
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/playback_${DateTime.now().millisecondsSinceEpoch}.m4a');
    await file.writeAsBytes(bytes);
    await _player.setFilePath(file.path);
    await _player.play();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }
}

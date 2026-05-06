import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class RecordingService {
  MediaRecorder? _recorder;

  Future<void> startRecording(MediaStream stream, String userName) async {
    // Saves to the "Downloads" or "Documents" folder of the phone
    final storage = await getExternalStorageDirectory();
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final path = "${storage!.path}/${userName}_Class_$timestamp.mp4";

    _recorder = MediaRecorder();
    
    // Captures the video and audio from the current stream
    await _recorder!.start(path, 
      videoTrack: stream.getVideoTracks().first,
      audioChannel: stream.getAudioTracks().first as dynamic
    );
    print("Recording started at: $path");
  }

  Future<void> stopRecording() async {
    await _recorder?.stop();
    print("Video saved to mobile storage!");
  }
}

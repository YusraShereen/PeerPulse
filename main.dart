import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MaterialApp(
  title: "PeerPulse",
  theme: ThemeData.dark(),
  home: PeerPulseHome(),
));

class PeerPulseHome extends StatefulWidget {
  @override
  _PeerPulseHomeState createState() => _PeerPulseHomeState();
}

class _PeerPulseHomeState extends State<PeerPulseHome> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  bool _isJoined = false;
  String _userName = "";
  MediaRecorder? _recorder;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
  }

  // This handles the "Ask Once" logic
  void _joinClass() async {
    if (_nameController.text.isNotEmpty && _roomController.text.isNotEmpty) {
      setState(() {
        _userName = _nameController.text;
        _isJoined = true;
      });
      _startCamera();
    }
  }

  void _startCamera() async {
    var stream = await navigator.mediaDevices.getUserMedia({'video': true, 'audio': true});
    _localRenderer.srcObject = stream;
    setState(() {});
  }

  void _toggleRecording() async {
    if (_isRecording) {
      await _recorder?.stop();
      setState(() => _isRecording = false);
    } else {
      final dir = await getExternalStorageDirectory();
      // Saves with the person's name so you know who recorded it
      final path = "${dir!.path}/${_userName}_Class_${DateTime.now().millisecond}.mp4";
      _recorder = MediaRecorder();
      await _recorder!.start(path, videoTrack: _localRenderer.srcObject!.getVideoTracks().first);
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PeerPulse")),
      body: !_isJoined 
        ? _buildJoinScreen() // Show this first
        : _buildVideoGrid(),  // Show this after joining
    );
  }

  Widget _buildJoinScreen() {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Welcome to PeerPulse", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 30),
          TextField(controller: _nameController, decoration: InputDecoration(labelText: "Your Name")),
          TextField(controller: _roomController, decoration: InputDecoration(labelText: "Class Room ID")),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: _joinClass,
            style: ElevatedButton.styleFrom(minimumSize: Size(200, 50)),
            child: Text("Join Class"),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoGrid() {
    return Column(
      children: [
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            children: [
              Stack(
                children: [
                  RTCVideoView(_localRenderer, mirror: true),
                  Positioned(bottom: 10, left: 10, child: Text(_userName, style: TextStyle(backgroundColor: Colors.black54))),
                ],
              ),
              // Friends' video slots would go here
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: ElevatedButton.icon(
            onPressed: _toggleRecording,
            icon: Icon(Icons.circle, color: _isRecording ? Colors.red : Colors.white),
            label: Text(_isRecording ? "STOP RECORDING" : "START RECORDING"),
            style: ElevatedButton.styleFrom(backgroundColor: _isRecording ? Colors.red[900] : Colors.blueGrey),
          ),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart'; // Untuk platform non-web
// import 'package:web_socket_channel/html.dart'; // Untuk web
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat',
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  late WebSocketChannel _channel;
  String _username = '';
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    // Buat koneksi WebSocket yang kompatibel dengan web
    _channel = kIsWeb
        ? WebSocketChannel.connect(Uri.parse('ws://localhost:8083')) // Web
        : IOWebSocketChannel.connect('ws://localhost:8083'); // Non-web

    _channel.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['type'] == 'requestUsername') {
        // Minta pengguna untuk memasukkan username
        _showUsernameDialog();
      } else if (data['type'] == 'usernameSet') {
        // Username berhasil diset
        setState(() {
          _username = data['username'];
        });
      } else if (data['type'] == 'chat') {
        // Terima pesan chat
        setState(() {
          _messages.add('${data['sender']}: ${data['message']}');
        });
      }
    });
  }

  void _showUsernameDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Masukkan Username'),
          content: TextField(
            controller: _usernameController,
            decoration: InputDecoration(hintText: 'Username'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final username = _usernameController.text;
                if (username.isNotEmpty) {
                  _channel.sink.add(jsonEncode({
                    'type': 'setUsername',
                    'username': username,
                  }));
                  Navigator.of(context).pop();
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _sendMessage() {
    final recipient = _recipientController.text;
    final message = _messageController.text;
    if (recipient.isNotEmpty && message.isNotEmpty) {
      _channel.sink.add(jsonEncode({
        'type': 'chat',
        'recipient': recipient,
        'message': message,
      }));
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Chat - $_username'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _recipientController,
                    decoration: InputDecoration(
                      hintText: 'Recipient',
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

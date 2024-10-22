import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;
  Function(dynamic)? onNewMessageCallback;

  SocketService() {
    String url;

    if (kIsWeb) {
      url = 'http://localhost:3000';
    } else if (Platform.isAndroid || Platform.isIOS) {
      url = 'http://10.0.2.2:3000';
    } else {
      url = 'http://localhost:3000';
    }

    socket = IO.io(url, IO.OptionBuilder()
        .setTransports(['websocket'])
        .build()
    );

    socket.onConnect((_) {
      print('Connected to socket server');
    });

    socket.onDisconnect((_) {
      print('Disconnected from socket server');
    });

    socket.on('newMessage', (messageData) {
      if (onNewMessageCallback != null) {
        onNewMessageCallback!(messageData);
      }
    });
  }

  void joinRoom(String chatId) {
    socket.emit('joinRoom', chatId);
  }

  void sendMessage(String chatId, Map<String, dynamic> message) {
    socket.emit('sendMessage', {
      'chatId': chatId,
      'message': message,
    });
  }

  void onNewMessage(Function(dynamic) callback) {
    onNewMessageCallback = callback;
  }

  void dispose() {
    socket.dispose();
  }
}

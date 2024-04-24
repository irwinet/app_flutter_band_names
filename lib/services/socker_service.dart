import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { OnLine, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    print('_initConfig');
    // Dart client
    // IP Emulator = 10.0.2.2
    
    IO.Socket socket = IO.io('http://10.0.2.2:3000', {
      'transports': ['websocket'],
      'autoConnect': true
    });

    //IO.Socket socket = IO.io('http://10.0.2.2:3000', IO.OptionBuilder().setTransports(['transports']).enableAutoConnect().build());

    socket.onConnect((_) {
      print('connect');
      //socket.emit('mensaje', 'test');
    });
    socket.onDisconnect((_) => print('disconnect'));
    socket.onConnectError((error) => print('Error al conectar: $error'));
    socket.onReconnect((attempt) => print('Reintentando conexión, intento: $attempt'));
    // socket.on('event', (data) => print(data));
    // socket.on('fromServer', (_) => print(_));
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/socker_service.dart';

class StatusPage extends StatelessWidget {
   
  const StatusPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    // socketService.socket.emit('');

    return Scaffold(
      body: Center(
         child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ServerStatus: ${socketService.serverStatus}')
          ],
         ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {
          socketService.socket.emit('emitir-mensaje', {'nombre': 'Irwin', 'mensaje': 'Hola Mundo'});
        },
      ),
    );
  }
}
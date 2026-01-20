import 'package:google_doc/urls.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  IO.Socket? socket;
  static SocketClient? _instance;

  SocketClient._internal() {
    socket = IO.io(
      Urls.getUserData,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])  // ✅ Try both transports
          .enableForceNewConnection()  // ✅ Force new connection
          .enableReconnection()  // ✅ Enable reconnection
          .setReconnectionAttempts(3)
          .setReconnectionDelay(1000)
          .build(),
    );
    socket!.onConnect((_) {
      print('Connected to WebSocket');
    });

    socket!.onConnectError((data) {
      print('Connection Error: $data');
    });

    socket!.onDisconnect((_) {
      print('Disconnected from WebSocket');
    });

    socket!.connect();

  }
  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }
}

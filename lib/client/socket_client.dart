import 'package:google_doc/urls.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  IO.Socket? socket;
  static SocketClient? _instance;

  SocketClient._internal() {
    socket = IO.io(
      Urls.getUserData,
      IO.OptionBuilder()
          .setTransports(['websockets'])
          .disableAutoConnect()
          .build(),
    );
    socket!.connect();
  }
  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }
}

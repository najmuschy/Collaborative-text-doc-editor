import 'package:socket_io_client/socket_io_client.dart';

import 'package:google_doc/client/socket_client.dart';

class SocketRepository{
  final _socketClient = SocketClient.instance.socket! ;

  Socket get socketClient => _socketClient ;
}
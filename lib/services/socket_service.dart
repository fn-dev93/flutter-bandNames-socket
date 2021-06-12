
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


enum ServerStatus {
  Online,
  Offline,
  Connecting
}

class SocketService with ChangeNotifier{

  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket ;

  Function get emit =>this._socket.emit;

  ServerStatus get serverStatus =>this._serverStatus;
  IO.Socket get socket =>this._socket;

  SocketService(){
    this._initConfig();
  }

  void _initConfig(){

    // Dart client
  this._socket = IO.io('http://192.168.0.249:3000/', {
    'transports':['websocket'],
    'autoConnect':true,
  });

  this._socket.onConnect((_) {
  this._serverStatus = ServerStatus.Online;
  notifyListeners();

  });

  this._socket.onDisconnect((_){
    this._serverStatus = ServerStatus.Offline;
  notifyListeners();
  });
  
  this._socket.on('nuevo-mensaje',(payload){
    print('nuevo-mensaje: $payload');
    print(payload.containsKey('mensaje2') ? payload['mensaje2'] : 'No hay' );
    notifyListeners();
  });

  }
}
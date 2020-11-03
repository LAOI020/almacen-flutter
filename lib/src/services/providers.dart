

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class Networking {

  void estadoRed(BuildContext context){


    var redInternetProvider = Provider.of<ClaseProviders>(context, listen: false);

    Timer.periodic(Duration(seconds: 10), (timer) async{
      
      try {
          
          var result = await InternetAddress.lookup('google.com');
          if(result.isNotEmpty && result[0].rawAddress.isNotEmpty){                        
          
            redInternetProvider.internet = 'si';
            debugPrint('si hay');  
            
          } 
        } on SocketException catch(e){
          
          redInternetProvider.internet = 'no';         
          debugPrint("ERROOORRRR ==== $e");
        
        }

    });


  }

}


class ClaseProviders with ChangeNotifier {

  String _internet = 'si';

  get internet{
    return _internet;
  }

  set internet(String nombre){
    this._internet = nombre;
    notifyListeners();
  }

}
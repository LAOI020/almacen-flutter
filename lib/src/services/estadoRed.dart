

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';


class EstadoRED extends GetxService{

  RxString hayInternet = 'si'.obs;

  void estadoRed(){

    Timer.periodic(Duration(seconds: 10), (timer) async{
      
      try {
          
          var result = await InternetAddress.lookup('google.com');
          if(result.isNotEmpty && result[0].rawAddress.isNotEmpty){                        
          
            this.hayInternet.value = 'si';
            print('si hay internet');
            print(hayInternet.value);
            
          } 
        } on SocketException catch(e){

          this.hayInternet.value = 'no';  
          print('no hya intener');
          print(hayInternet.value);
          //debugPrint("ERROOORRRR ==== $e");
        
        }

    });


  }

}



import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class Tokens {


  iniciarNotificaciones(BuildContext context){

    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

    _firebaseMessaging.requestNotificationPermissions();
   
    print('se iniciarion las notificaciones');
    
    _firebaseMessaging.configure(      

      onMessage: (info) async{ //CUANDO ESTA ABIERTA LA APP
        debugPrint("======On Message====");
        print(info);

        String argumento = 'no-data';
        
        if(Platform.isAndroid){
          argumento = info['notification']['body'] ?? 'no-data';
        }
        
        Toast.show(argumento, context, duration: 3, backgroundColor: Colors.black,);

      },

      onLaunch: (info) async{ //CUANDO ESTA FINALIZADA LA APP
        debugPrint("=====ON LAUNCH");
        print(info);
      },

      onResume: (info) async{ //CUANDO ESTA EN 2DO PLANO
        print("=====ON RESUME");
        print(info);
      },
      

    );

  }


  void verYactualizarToken(String negocio,String nombreCodigo){

    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

    if(nombreCodigo != 'finanzas'){

      _firebaseMessaging.getToken().then((token){
        FirebaseFirestore.instance
          .collection('cholula')
          .doc(negocio)
          .collection('codigos')
          .doc(nombreCodigo)
          .update({
            'token': token
          });
      });

    }

  }



}
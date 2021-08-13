
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class Tokens {


  iniciarNotificaciones(){

    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

    _firebaseMessaging.requestNotificationPermissions();
    
    _firebaseMessaging.configure(      

      onMessage: (info) async{ //CUANDO ESTA ABIERTA LA APP
        debugPrint("======On Message====");
        //print(info);

        String argumento = 'no-data';
        
        if(Platform.isAndroid){
          argumento = info['notification']['body'] ?? 'no-data';
        }

        Get.snackbar(
          'Nuevo pedido', argumento,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white
        );

      },

      onLaunch: (info) async{ //CUANDO ESTA FINALIZADA LA APP
        debugPrint("=====ON LAUNCH");
        //print(info);
      },

      onResume: (info) async{ //CUANDO ESTA EN 2DO PLANO
        debugPrint("=====ON RESUME");
        //print(info);
      },
      

    );

  }


  void verYactualizarToken(String oficina,String negocio,String puestoPersona){

    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

    if(puestoPersona != 'finanzas' && puestoPersona != 'administracion'){

      _firebaseMessaging.getToken().then((token){
        FirebaseFirestore.instance
          .collection(oficina)
          .doc(negocio)
          .collection('codigos')
          .doc(puestoPersona)
          .update({
            'token': token
          });
      });

    } else {

      if(puestoPersona == 'administracion'){

        _firebaseMessaging.getToken().then((token){
          FirebaseFirestore.instance
            .collection(oficina)
            .doc('finanzas')
            .update({
              'tokenAdministracion': token
            });
        });
      }

    }

  }



}
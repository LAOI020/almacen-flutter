
import 'package:almacen/src/screens/1-inicio.dart';
import 'package:almacen/src/screens/2A-unidadNegocio.dart';
import 'package:almacen/src/screens/2B-requisicionesCedis.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences preferencias = await SharedPreferences.getInstance();
  var oficina = preferencias.getString('oficina');
  var negocio = preferencias.getString('negocio');
  var puestoPersona = preferencias.getString('puestoPersona');

  await Firebase.initializeApp();

  runApp(
    GetMaterialApp(
      home: negocio == 'cedis' ?
              RequisicionesCedis(oficina: oficina, puestoPersona: puestoPersona)
              :
              negocio != null ?
                UnidadNegocio(oficina: oficina, negocio: negocio, puestoPersona: puestoPersona)
                :
                Inicio(),
    )
  );
}
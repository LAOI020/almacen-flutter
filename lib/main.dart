
import 'package:almacen/src/screens/1-inicio.dart';
import 'package:almacen/src/screens/2A-unidadNegocio.dart';
import 'package:almacen/src/screens/2B-requisicionesCedis.dart';
import 'package:almacen/src/services/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences preferencias = await SharedPreferences.getInstance();
  var negocio = preferencias.getString('negocio');
  var nombreCodigo = preferencias.getString('nombreCodigo');
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ClaseProviders(),
      builder: (context, _){

        Networking().estadoRed(context);
        
        return MaterialApp(
          home: negocio == 'cedis' ?
                  RequisiconesCedis(nombreCodigo: nombreCodigo)
                  :
                  negocio != null ?
                    UnidadNegocio(negocio: negocio, nombreCodigo: nombreCodigo)
                    :
                    Inicio(),
        );
      },
    )
  );
}
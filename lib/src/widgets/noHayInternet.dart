

import 'package:almacen/src/widgets/widgettss.dart';
import 'package:flutter/material.dart';

class NoHayInternet {

  Widget sinInternet(){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.signal_wifi_off, size: 70.0, ),
            Widgettss().etiquetaText(titulo: 'Sin conexion a internet', tamallo: 20.0,)
          ],
        ),
      ),
    );
  }

}
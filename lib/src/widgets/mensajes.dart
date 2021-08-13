

import 'package:almacen/src/widgets/widgettss.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';


class Mensajess {

  alertaMensaje(String texto){

    return Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(12.0),

        child: Stack(
          overflow: Overflow.visible,
          alignment: Alignment.center,
          
          children: [
            Container(
              width: Get.width,
              height: 250.0,

              decoration: BoxDecoration(
                color: Color(int.parse('0xff1565bf')),
                borderRadius: BorderRadius.all(Radius.circular(25.0))
              ),

              child: Center(child: Widgettss().etiquetaText(titulo: texto, tamallo: 22.0, color: Colors.white))
            ),

            Positioned(
              top: -60,

              child: Container(
                height: 110.0,
                width: 110.0,
                
                decoration: BoxDecoration(
                  color: Color(int.parse('0xff1565bf')),
                  borderRadius: BorderRadius.circular(100.0)
                ),
                child: Icon(Icons.error_rounded, color: Colors.white, size: 110.0)
              ),
            )
          ],
        ),
      )
    );
  }

}
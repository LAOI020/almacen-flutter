
import 'package:almacen/src/widgets/widgettss.dart';
import 'package:almacen/src/widgets/input.dart';
import 'package:almacen/src/widgets/mensajes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';


class AlertDialogPregunta {

  preguntar({String titulo,String contenido,
                                 VoidCallback onPresSi
                                }){

    return Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0))
        ),
        title: Text(titulo),

        content: Widgettss().etiquetaText(
          titulo: contenido,
        ),
        actions: [
          MaterialButton(
            child: Text('NO'),
            onPressed: (){                
              Get.back();
            },
          ),
          MaterialButton(
            child: Text('SI'),
            onPressed: onPresSi
          )
        ],
      )
    );

  }


  ventanaYaSeHizoUnPedido({String oficina,String negocio,VoidCallback onPresSi}){

    TextEditingController codigoControlador = TextEditingController();

    return Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0))
        ),
        title: Text(negocio),

        content: SingleChildScrollView(
          child: Column(
            children: [
              
              Widgettss().etiquetaText(titulo: '...YA HICISTE UN PEDIDO HOY...'),
              
              SizedBox(height: 10.0,),
              
              Widgettss().etiquetaText(titulo: 'Ingresa tu codigo para hacer otro pedido',),
                
              Input(
                etiqueta: 'Codigo',
                controlador: codigoControlador,
                tipo: TextInputType.number,
                oscurecer: true,

                next: (valor) async{

                  final QuerySnapshot result = await FirebaseFirestore.instance
                    .collection(oficina)
                    .doc(negocio)
                    .collection('codigos')
                    .where('codigo', isEqualTo: codigoControlador.text)
                    .limit(1)
                    .get();
                    
                  final List<DocumentSnapshot> documents = result.docs;
                    
                  if(documents.length == 1){
                    //HACER PEDIDO                      
                    onPresSi();

                  } else {
                    Mensajess().alertaMensaje('Codigo Incorrecto');
                  }
                    
                },
              )
            ],
          ),
        ),
        
        actions: [
          MaterialButton(
            child: Text('Cancelar'),
            onPressed: (){                
              Get.back();
            },
          )
        ],
      )
    );

  }


}
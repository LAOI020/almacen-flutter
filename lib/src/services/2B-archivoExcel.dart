
import 'dart:io';

import 'package:almacen/src/widgets/input.dart';
import 'package:almacen/src/widgets/mensajes.dart';
import 'package:almacen/src/widgets/widgettss.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Service2B {

  ventana(BuildContext context){

    TextEditingController codigoControlador = TextEditingController();
    bool codigoCorrecto;
    int contadorREF = 0;

    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0))
          ),

          title: Text('Finanzas'),

          content: SingleChildScrollView(
            child: Column(
              children: [
                
                Widgettss().etiquetaText(titulo: 'Enviar correo'),

                Input(
                  etiqueta: 'Codigo',
                  controlador: codigoControlador,
                  tipo: TextInputType.number,
                  oscurecer: true,
                  next: (v){ FocusScope.of(context).nextFocus(); },
                ),
              ],
            ),
          ),

          actions: [
            MaterialButton(
              child: Text('Listo'),
              onPressed: () async{
                if(codigoControlador.text != ''){                  
                
                  FirebaseFirestore.instance
                    .collection('cholula')
                    .doc('finanzas')
                    .get().then((dooc){

                      contadorREF = dooc.data()['contador'];

                      if(dooc.data()['codigo'] != codigoControlador.text){

                        Mensajes().mensajeAlerta(context, 'Codigo incorrecto');                        

                      } else {
                        codigoCorrecto = true;
                      }

                    }).then((value){
                      
                      if(codigoCorrecto == true){
                        
                        Navigator.pop(context);
                        Mensajes().mensajeAlerta(context, 'Listo, el excel estara en el correo de finanzas en unos minutos');
                        
                        ponerDatosExcel(contadorREF);
                      }

                    });
                }
              },
            )
          ],
        );
      }
    );
  }

  void ponerDatosExcel(int contadorREF){

    var libro = Excel.createExcel();

    int indx = 0;

    FirebaseFirestore.instance
      .collection('cholula')
      .doc('finanzas')
      .collection('pedidos')
      .get().then((pedidos) async{

        int numeroPedidos = pedidos.docs.length;

        await Future.forEach(pedidos.docs, (pedido) async{
          
          indx = indx + 1;

          libro.updateCell(pedido.id, CellIndex.indexByString('A2'), 'UNIDAD NEGOCIO');
          libro.updateCell(pedido.id, CellIndex.indexByString('B2'), pedido.data()['negocio']);

          libro.updateCell(pedido.id, CellIndex.indexByString('A3'), 'ENTREGADA A LA PRIMERA');
          libro.updateCell(pedido.id, CellIndex.indexByString('B3'), pedido.data()['incompleta']);

          libro.updateCell(pedido.id, CellIndex.indexByString('A4'), 'SE PIDIO');
          libro.updateCell(pedido.id, CellIndex.indexByString('B4'), pedido.data()['SePidio']);

          libro.updateCell(pedido.id, CellIndex.indexByString('A5'), 'SE ENTREGO');
          libro.updateCell(pedido.id, CellIndex.indexByString('B5'), pedido.data()['SeEntrego']);

          libro.updateCell(pedido.id, CellIndex.indexByString('A6'), 'SE COMPLETO');
          libro.updateCell(pedido.id, CellIndex.indexByString('B6'), pedido.data()['SeCompleto']);

          libro.updateCell(pedido.id, CellIndex.indexByString('A7'), 'DINERO TOTAL VERDE');
          libro.updateCell(pedido.id, CellIndex.indexByString('B7'), pedido.data()['totalDinero']);

          libro.updateCell(pedido.id, CellIndex.indexByString('A8'), 'DINERO TOTAL ROJO');
          libro.updateCell(pedido.id, CellIndex.indexByString('B8'), pedido.data()['totalDineroCancelado']);

          libro.updateCell(pedido.id, CellIndex.indexByString('A10'), 'DESCRIPCION');
          libro.updateCell(pedido.id, CellIndex.indexByString('B10'), 'GRUPO');
          libro.updateCell(pedido.id, CellIndex.indexByString('C10'), 'UNIDAD MEDIDA');
          libro.updateCell(pedido.id, CellIndex.indexByString('D10'), 'PRECIO UNITARIO');
          libro.updateCell(pedido.id, CellIndex.indexByString('E10'), 'STOCK');
          libro.updateCell(pedido.id, CellIndex.indexByString('F10'), 'CANTIDAD QUE PIDIO');
          libro.updateCell(pedido.id, CellIndex.indexByString('G10'), 'CANTIDAD QUE FALTO');
          libro.updateCell(pedido.id, CellIndex.indexByString('H10'), 'COLOR');
          libro.updateCell(pedido.id, CellIndex.indexByString('I10'), 'ENTREGADO EN VARIAS VUELTAS');
          libro.updateCell(pedido.id, CellIndex.indexByString('J10'), 'DINERO ROJO');
          libro.updateCell(pedido.id, CellIndex.indexByString('K10'), 'DINERO VERDE');

          await FirebaseFirestore.instance
            .collection('cholula')
            .doc('finanzas')
            .collection('pedidos')
            .doc(pedido.id)
            .collection('detalles')
            .get().then((productos){

              int y = 11;

              for(DocumentSnapshot producto in productos.docs){              

                libro.updateCell(pedido.id, CellIndex.indexByString('A${y.toString()}'), producto.id);
                libro.updateCell(pedido.id, CellIndex.indexByString('B${y.toString()}'), producto.data()['grupo']);
                libro.updateCell(pedido.id, CellIndex.indexByString('C${y.toString()}'), producto.data()['medida']);
                libro.updateCell(pedido.id, CellIndex.indexByString('D${y.toString()}'), producto.data()['precioUnitario']);
                libro.updateCell(pedido.id, CellIndex.indexByString('E${y.toString()}'), producto.data()['stock']);
                libro.updateCell(pedido.id, CellIndex.indexByString('F${y.toString()}'), producto.data()['pidio']);
                libro.updateCell(pedido.id, CellIndex.indexByString('G${y.toString()}'), producto.data()['falta']);
                libro.updateCell(pedido.id, CellIndex.indexByString('H${y.toString()}'), producto.data()['color']);
                libro.updateCell(pedido.id, CellIndex.indexByString('I${y.toString()}'), producto.data()['amarillo']);
                libro.updateCell(pedido.id, CellIndex.indexByString('J${y.toString()}'), producto.data()['dineroRojo']);

                y = y + 1;
                
              }

            });

            if(indx == numeroPedidos){

                libro.encode().then((bytess) async{
                  
                  Directory dirTemporal = await getTemporaryDirectory();
                  String pathTemporal = dirTemporal.path;

                  File excelListo = File("$pathTemporal/cholula-$contadorREF.xlsx")
                    ..createSync(recursive: true)
                    ..writeAsBytesSync(bytess);

                  final storageREF = FirebaseStorage.instance
                                      .ref()
                                      .child('cholula-$contadorREF.xlsx');
                                      //.child('cholulaFinanzas.xlsx');

                  StorageUploadTask cargarArchivo = storageREF.putFile(excelListo);

                  StorageTaskSnapshot cargaCompleta = await cargarArchivo.onComplete;

                  if(cargarArchivo.isComplete){

                    cargaCompleta.ref.getDownloadURL().then((value){

                      FirebaseFirestore.instance
                        .collection('FUNCTIONS')
                        .doc('enviarEmailFinanzas')
                        .collection('detalles')
                        .add({
                          'urlArchivo': value.toString(),
                          'oficina': 'cholula',          
                          'fecha': DateTime.now().toString()          
                        });

                    });
                    
                    excelListo.delete().then((value) => debugPrint('archivo borrado de cache'));

                  }

                              
                  debugPrint('todo termino bien');

                });
              }


        });

      });

  }



}
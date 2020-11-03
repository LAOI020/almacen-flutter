

import 'package:almacen/src/widgets/mensajes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class Services2A {

  //YA QUEDO
  void hacerInventario(BuildContext context,String negocio){   

    FirebaseFirestore.instance
      .collection('cholula')
      .doc(negocio)
      .update({
        'hacerInventario': true
      });

    FirebaseFirestore.instance
      .collection('cholula')
      .doc(negocio)
      .collection('almacen')
      .get().then((snap){

        for(DocumentSnapshot producto in snap.docs){
          producto.reference.update({
            'color': '7f7f7f' //GRIS
          });
        }

      });
      
    Navigator.pop(context);
    Mensajes().mensajeAlerta(context, '¡Listo!');
    
  }

  //YA QUEDO
  void verificarInventario(BuildContext context,String negocio){

    int faltanProductosPorRevisar = 0;

    FirebaseFirestore.instance
      .collection('cholula')
      .doc(negocio)      
      .collection('almacen')
      .get().then((snapshot){

        for(DocumentSnapshot producto in snapshot.docs){
          
          //NO SE HA ACTUALIZADO LA EXISTENCIA DE ESE PRODUCTO
          if(producto.data()['color'] == "7f7f7f"){
            faltanProductosPorRevisar = faltanProductosPorRevisar + 1;
            
          
          } else { //SI SE ACTUALIZO LA EXISTENCIA
            producto.reference.update({
              'color': 'fba21c'
            });
          }
        }

      }).then((value){

        if(faltanProductosPorRevisar == 0){
          
          Mensajes().mensajeAlerta(context, 'Listo');          

        } else {
          Mensajes().mensajeAlerta(context, 'Faltan productos por revisar');
        }


      });
      

  }



  //YA QUEDO
  Future<bool> crearPedidoo(BuildContext context,String negocio) async{
    
    bool pedidoHechoCorrectamente;    

    DateTime fecha = DateTime.now();
    String diaMesAno = DateFormat('dd-MM-yyyy').format(fecha);
    String hora = DateFormat.jm().format(fecha); 

    int cantidadGrupoFaltaActualizar = 0;

    FirebaseFirestore.instance //VERIFICAR SI SE PUEDE HACER UN PEDIDO
      .collection('cholula')
      .doc(negocio)
      .collection('almacen')
      .get().then((snapshot){

        for(DocumentSnapshot producto in snapshot.docs){
          if(producto.data()['color'] == "7f7f7f"){
            cantidadGrupoFaltaActualizar = cantidadGrupoFaltaActualizar + 1;
          }
        }

      }).then((value){ //CREACION DEL PEDIDO
        
        if(cantidadGrupoFaltaActualizar == 0){    

          pedidoHechoCorrectamente = true;          
        
          FirebaseFirestore.instance
            .collection('cholula')
            .doc('cedis')
            .get().then((documento){
                          
              String idPedido = "${negocio[0]}${documento.data()[negocio]}";
              
              FirebaseFirestore.instance.collection('cholula')
                                        .doc('cedis')
                                        .collection('requisiciones')
                                        .doc(idPedido)
                                        .set({
                                          'negocio': 'cholula',
                                          
                                          'totalDinero': 0,
                                          'totalDineroCancelado': 0,

                                          'SePidio' : "$diaMesAno -- $hora",
                                          'fechaDev': DateTime.now().toString(),

                                          'SeEntrego' : 'aun no',
                                          'SeCompleto': 'aun no',
                                          'incompleta': false,
                                        });

              FirebaseFirestore.instance.collection('cholula')
                                        .doc('cedis')
                                        .collection('requisiciones')
                                        .doc(idPedido)
                                        .collection('detalles')
                                        .doc('zzz')
                                        .set({
                                          'ejemplo': 'nada'
                                        });
              
              FirebaseFirestore.instance.collection('cholula')
                                        .doc(negocio)
                                        .collection('requisiciones')
                                        .doc(idPedido)
                                        .set({
                                          'totalDinero': 0,
                                          'totalDineroCancelado': 0,
                                          
                                          'SePidio' : "$diaMesAno -- $hora",
                                          'fechaDev': DateTime.now().toString(),

                                          'SeEntrego' : 'aun no',
                                          'SeCompleto': 'aun no',
                                          'incompleta': false,
                                        });
              
              FirebaseFirestore.instance.collection('cholula')
                                        .doc(negocio)
                                        .collection('requisiciones')
                                        .doc(idPedido)
                                        .collection('detalles')
                                        .doc('zzz')
                                        .set({
                                          'ejemplo': 'nada'
                                        });

              FirebaseFirestore.instance
                .collection('cholula')
                .doc(negocio)
                .update({
                  'hacerInventario': false
                });

              recorrerProductosParaPedido(context, negocio, idPedido);
              
              documento.reference.update({ //ACTUALIZAR FOLIO DE PEDIDOS
                negocio: FieldValue.increment(1)
              });

              

              Navigator.pop(context);
              Mensajes().mensajeAlerta(context, "¡Listo! Pedido Enviado");

            });

        } else {
          Navigator.pop(context);
          Mensajes().mensajeAlerta(context, 'No puedes hacer el pedido porque no has completado el inventario');
        }
        
      });    

      return pedidoHechoCorrectamente;
    
  }

  void recorrerProductosParaPedido(BuildContext context,String negocio,String pedidoREF){

    double dineroTotalDePedido = 0.000;

    FirebaseFirestore.instance
      .collection('cholula')
      .doc(negocio)
      .collection('almacen')
      .get().then((snap){

        for(DocumentSnapshot producto in snap.docs){

          String indexREF = producto.data()['grupo'];
          
          double stockDouble = double.parse(producto.data()['stock'].toString());
          double actualDouble = double.parse(producto.data()['actual'].toString());

          double cantidadFaltante = stockDouble - actualDouble;
          double dineroDePedido = double.parse(producto.data()['precioUnitario'].toString()) * cantidadFaltante;
          print(dineroDePedido);

          if(cantidadFaltante > 0){ //ENVIAR SOLO LOS PRODUCTOS DONDE LA CANTIDAD FALTANTE SEA MAYOR A 0

            FirebaseFirestore.instance
              .collection('cholula')
              .doc(negocio)
              .collection('requisiciones')
              .doc(pedidoREF)
              .collection('detalles')
              .doc(producto.id)
              .set({
                'indx': indexREF[0],
                'medida': producto.data()['medida'],
                
                'pidio': cantidadFaltante,
                'stock': producto.data()['stock'],
                'falta': 0,

                'amarillo': 'no',
                
                'color': "ffffff",
                'grupo': producto.data()['grupo'],
                'precioUnitario': producto.data()['precioUnitario'],
                'dineroRojo': 0
              });

            FirebaseFirestore.instance
              .collection('cholula')
              .doc('cedis')
              .collection('requisiciones')
              .doc(pedidoREF)
              .collection('detalles')
              .doc(producto.id)
              .set({
                'indx': indexREF[0],
                
                'revisado': 'no',

                'medida': producto.data()['medida'],
                
                'pidio': cantidadFaltante,
                'stock': producto.data()['stock'],
                'falta': 0,

                'amarillo': 'no',

                'color': "ffffff",
                'grupo': producto.data()['grupo'],
                'precioUnitario': producto.data()['precioUnitario'],
                'dineroRojo': 0
              });

            dineroTotalDePedido = dineroTotalDePedido + dineroDePedido;

          }


        }

      }).then((value){

        FirebaseFirestore.instance
          .collection('cholula')
          .doc('cedis')
          .collection('requisiciones')
          .doc(pedidoREF)
          .update({
            'totalDinero': dineroTotalDePedido
          });
        
        FirebaseFirestore.instance
          .collection('cholula')
          .doc(negocio)
          .collection('requisiciones')
          .doc(pedidoREF)
          .update({
            'totalDinero': dineroTotalDePedido
          });

        FirebaseFirestore.instance
          .collection('cholula')
          .doc('cedis')
          .collection('requisiciones')
          .doc(pedidoREF)
          .collection('detalles')
          .doc('zzz')
          .delete();
        
        FirebaseFirestore.instance
          .collection('cholula')
          .doc(negocio)
          .collection('requisiciones')
          .doc(pedidoREF)
          .collection('detalles')
          .doc('zzz')
          .delete();      


        enviarNotificacion(negocio);


      });

  }

  
  void enviarNotificacion(String negocioREF) async{

    final HttpsCallable cloudFunction = CloudFunctions.instance
      .getHttpsCallable(functionName: 'notificacionesAcedis');
    
    final llamarFuncion = await cloudFunction.call(
      <String, dynamic>{
        'oficina': 'cholula',
        'negocio': negocioREF
      }
    );

    debugPrint(llamarFuncion.data);    

  }


}
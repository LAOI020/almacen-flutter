
import 'package:almacen/src/widgets/mensajes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Services2A1A {

  //YA QUEDO
  void terminoRevisionPedido(BuildContext context,String negocio,String pedidoREF){

    DateTime fecha = DateTime.now();
    String diaMesAno = DateFormat('dd-MM-yyyy').format(fecha);
    String hora = DateFormat.jm().format(fecha);

    bool todosProductosRevisados;
    bool hayAmarillos;

    bool seEnviaAfinanzas;

    FirebaseFirestore.instance
      .collection('cholula')
      .doc(negocio)
      .collection('requisiciones')
      .doc(pedidoREF)
      .collection('detalles')
      .get().then((snapshot){

        for(DocumentSnapshot producto in snapshot.docs){

          if(producto.data()['color'] == 'ffffff'){ //BLANCO       

            todosProductosRevisados = false;
          
            String indexMinuscula = producto.data()['grupo'][0];

            producto.reference.update({
              'indx': indexMinuscula.toLowerCase()
            });
            FirebaseFirestore.instance
              .collection('cholula')
              .doc('cedis')
              .collection('requisiciones')
              .doc(pedidoREF)
              .collection('detalles')
              .doc(producto.id).update({ 
                'indx': indexMinuscula.toLowerCase()
              });

          }
          
          if(producto.data()['color'] == 'fff200'){ //AMARILLO
            
            hayAmarillos = true;

            producto.reference.update({
              'indx': "00",
              'amarillo': 'si'
            });
            FirebaseFirestore.instance
              .collection('cholula')
              .doc('cedis')
              .collection('requisiciones')
              .doc(pedidoREF)
              .collection('detalles')
              .doc(producto.id).update({ 'indx': "00", 'amarillo': 'si' });
          }

          if(producto.data()['color'] == '22b14c' //VERDE
             && 
             producto.data()['indx'] == '00'
          ){

            producto.reference.update({ 'indx': producto.data()['grupo'][0] });

          }
          
        }

      }).then((value) async{ 

        if(todosProductosRevisados != false){

          await FirebaseFirestore.instance
            .collection('cholula')
            .doc(negocio)
            .collection('requisiciones')
            .doc(pedidoREF)
            .get().then((docPedido){

              if(hayAmarillos == true){

                docPedido.reference.update({ 'incompleta': true }); 

                FirebaseFirestore.instance
                  .collection('cholula')
                  .doc('cedis')
                  .collection('requisiciones')
                  .doc(pedidoREF)
                  .update({ 'incompleta': true });
              }
              
              if(docPedido.data()['SeEntrego'] == 'aun no'){

                docPedido.reference.update({ 'SeEntrego':  "$diaMesAno -- $hora"});

                FirebaseFirestore.instance
                  .collection('cholula')
                  .doc('cedis')
                  .collection('requisiciones')
                  .doc(pedidoREF)
                  .update({ 'SeEntrego': "$diaMesAno -- $hora" });
              }

            });

            Mensajes().mensajeAlerta(context, 'Verificado Correctamente');

          } else {
            Mensajes().mensajeAlerta(context, 'No verificaste todos los productos');
          }
        

      }).then((value) async{

        await FirebaseFirestore.instance
          .collection('cholula')
          .doc(negocio)
          .collection('requisiciones')
          .doc(pedidoREF)
          .get().then((docPedidooo){

            if(docPedidooo.data()['incompleta'] == true && hayAmarillos != true &&
               docPedidooo.data()['SeCompleto'] == 'aun no'
            ){
              
              docPedidooo.reference.update({ 'SeCompleto': "$diaMesAno -- $hora"});

              FirebaseFirestore.instance
                .collection('cholula')
                .doc('cedis')
                .collection('requisiciones')
                .doc(pedidoREF)
                .update({ 'SeCompleto': "$diaMesAno -- $hora" });  

              seEnviaAfinanzas = true;                  

            }     

            if(docPedidooo.data()['SeEntrego'] != 'aun no' && 
               docPedidooo.data()['incompleta'] == false
            ){
              
              seEnviaAfinanzas = true;

            }           
                  
          });
        

      }).then((value) async{

        await FirebaseFirestore.instance
          .collection('cholula')
          .doc('cedis')
          .collection('requisiciones')
          .doc(pedidoREF)
          .collection('detalles')
          .get().then((snapshott){

            for(DocumentSnapshot productoo in snapshott.docs){
              productoo.reference.update({ 'revisado': 'no' });
            }

          });
        

          
        if(seEnviaAfinanzas == true){
          
          enviarPedidoAfinanzas(negocio, pedidoREF);

        }

      });

  }




  void ponerEnVerde(String negocio,String pedidoREF,DocumentSnapshot data){

    String indexOriginal = data.data()['grupo'][0];

    if(data.data()['falta'] != 0){
      data.reference.update({
        'falta': 0,
        'color': '22b14c',
        'indx': indexOriginal
      });

      FirebaseFirestore.instance
        .collection('cholula')
        .doc('cedis')
        .collection('requisiciones')
        .doc(pedidoREF)
        .collection('detalles')
        .doc(data.id)
        .update({
          'falta': 0,
          'color': '22b14c',
          'indx': indexOriginal
        });


    }else {

      data.reference.update({
        'color': '22b14c'
      });

      FirebaseFirestore.instance
        .collection('cholula')
        .doc('cedis')
        .collection('requisiciones')
        .doc(pedidoREF)
        .collection('detalles')
        .doc(data.id)
        .update({          
          'color': '22b14c',
        });
    }

  }


  //YA QUEDO
  void verificarCodigoParaEliminarProducto({BuildContext context,String negocio,String pedidoREF,
                                            DocumentSnapshot doc,
                                            String codigoIntroducido
                                          }){
    
    DocumentReference docRefCedis = FirebaseFirestore.instance.collection('cholula').doc('cedis')
                          .collection('requisiciones').doc(pedidoREF).collection('detalles')
                          .doc(doc.id);

    FirebaseFirestore.instance
      .collection('cholula')
      .doc(negocio)
      .collection('codigos')
      .doc('gerente')                  
      .get().then((documento){

        if(documento.data()['codigo'] == codigoIntroducido){
          
          doc.reference.update({
            'color': 'ed1c24' //ROJO
          });
          docRefCedis.update({
            'color': 'ed1c24' //ROJO
          });            
        

          if(doc.data()['falta'] != 0){ //SE ENTREGO UNA PARTE Y LA OTRA SE CANCELO

            double dineroRojo = double.parse(doc.data()['precioUnitario'].toString()) 
                                  * 
                                  double.parse(doc.data()['falta'].toString());

            double cantidadEntregada = double.parse(doc.data()['pidio'].toString()) - double.parse(doc.data()['falta'].toString());            

            doc.reference.update({
              'pidio': cantidadEntregada,
              'dineroRojo': dineroRojo,
              'indx': '01'
            });
            docRefCedis.update({
              'pidio': cantidadEntregada,
              'dineroRojo': dineroRojo,
              'indx': '01'
            });
            
            FirebaseFirestore.instance
              .collection('cholula')
              .doc(negocio)
              .collection('requisiciones')
              .doc(pedidoREF)
              .update({
                'totalDineroCancelado': FieldValue.increment(dineroRojo),
                'totalDinero': FieldValue.increment(-dineroRojo)
              });
            FirebaseFirestore.instance
              .collection('cholula')
              .doc('cedis')
              .collection('requisiciones')
              .doc(pedidoREF)
              .update({
                'totalDineroCancelado': FieldValue.increment(dineroRojo),
                'totalDinero': FieldValue.increment(-dineroRojo)
              });

          } else { //SE CANCELO Y NO SE ENTREGO NADA

            double dineroProducto = double.parse(doc.data()['precioUnitario'].toString())
                                    *
                                    double.parse(doc.data()['pidio'].toString());

            doc.reference.update({
              'dineroRojo': dineroProducto,
              'indx': '01'
            });

            docRefCedis.update({
              'dineroRojo': dineroProducto,
              'indx': '01'
            });
            

            FirebaseFirestore.instance
              .collection('cholula')
              .doc(negocio)
              .collection('requisiciones')
              .doc(pedidoREF)
              .update({
                'totalDineroCancelado': FieldValue.increment(dineroProducto),
                'totalDinero': FieldValue.increment(-dineroProducto)
              });
            FirebaseFirestore.instance
              .collection('cholula')
              .doc('cedis')
              .collection('requisiciones')
              .doc(pedidoREF)
              .update({
                'totalDineroCancelado': FieldValue.increment(dineroProducto),
                'totalDinero': FieldValue.increment(-dineroProducto)
              });
          }
          
          Navigator.pop(context);
          Mensajes().mensajeAlerta(context, 'Cancelado Correctamente');

        } else {
          Mensajes().mensajeAlerta(context, 'Codigo Incorrecto');
        }

      }); 

  }


  


  void enviarPedidoAfinanzas(String negocio,String pedidoREF){  

    FirebaseFirestore.instance
      .collection('cholula')
      .doc(negocio)
      .collection('requisiciones')
      .doc(pedidoREF)
      .get().then((pedidoDOC){

        FirebaseFirestore.instance
          .collection('cholula')
          .doc('finanzas')
          .collection('pedidos')
          .doc(pedidoREF)
          .set({
            'negocio': negocio,

            'SeCompleto': pedidoDOC.data()['SeCompleto'],
            'SeEntrego': pedidoDOC.data()['SeEntrego'],
            'SePidio': pedidoDOC.data()['SePidio'],
            
            'incompleta': pedidoDOC.data()['incompleta'],
            
            'totalDinero': pedidoDOC.data()['totalDinero'],
            'totalDineroCancelado': pedidoDOC.data()['totalDineroCancelado']
          });
        FirebaseFirestore.instance
          .collection('cholula')
          .doc('finanzas')
          .collection('pedidos')
          .doc(pedidoREF)
          .collection('detalles')
          .doc('zzz')
          .set({ 'ejemplo': 'nada' });

      }).then((value){      
        agregarProductosAfinanzas(negocio, pedidoREF);
      });

  }

  void agregarProductosAfinanzas(String negocio,String pedidoREF){
    
    FirebaseFirestore.instance
      .collection('cholula')
      .doc(negocio)
      .collection('requisiciones')
      .doc(pedidoREF)
      .collection('detalles')
      .get().then((snaps){

        for(DocumentSnapshot productoo in snaps.docs){
          
          FirebaseFirestore.instance
            .collection('cholula')
            .doc('finanzas')
            .collection('pedidos')
            .doc(pedidoREF)
            .collection('detalles')
            .doc(productoo.id)
            .set({
              'amarillo': productoo.data()['amarillo'],
              'color': productoo.data()['color'],

              'dineroRojo': productoo.data()['dineroRojo'],

              'falta': productoo.data()['falta'],
              
              'grupo': productoo.data()['grupo'],
              'medida': productoo.data()['medida'],
              
              'pidio': productoo.data()['pidio'],
              'stock': productoo.data()['stock'],
              
              'precioUnitario': productoo.data()['precioUnitario']
            });
        }        

      }).then((value){

        FirebaseFirestore.instance
            .collection('cholula')
            .doc('finanzas')
            .collection('pedidos')
            .doc(pedidoREF)
            .collection('detalles')
            .doc('zzz')
            .delete();

      });
  }

}
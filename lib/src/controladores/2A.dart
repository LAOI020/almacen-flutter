

import 'dart:async';

import 'package:almacen/src/screens/1-inicio.dart';
import 'package:almacen/src/screens/2A-unidadNegocio.dart';
import 'package:almacen/src/widgets/alertDialogPregunta.dart';
import 'package:almacen/src/widgets/mensajes.dart';
import 'package:almacen/src/widgets/widgettss.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnidadNegocioController extends GetxController {

  bool modificarInventario;

  String oficina = '';
  String negocio = '';

  TextEditingController buscarProductoControlador = TextEditingController();
  List<String> listaProductosBuscados = [];
  List<String> listaGrupoREFproductoBuscado = [];

  List<bool> onPresNombresGrupos = [];


  void metodoInicial(String oficinaREF,String negocioREF) async{

    this.oficina = oficinaREF;
    this.negocio = negocioREF;

    FirebaseFirestore.instance
      .collection(this.oficina)
      .doc(this.negocio)
      .collection('grupos')
      .get().then((grupos) async{
        
        await Future.forEach(grupos.docs, (grupoREF) async{

          //AGREGAR VARIABLES AL ONPRES DE TODOS LOS GRUPOS
          this.onPresNombresGrupos.add(false);


          await FirebaseFirestore.instance
            .collection(this.oficina)
            .doc(this.negocio)
            .collection('grupos')
            .doc(grupoREF.id)
            .collection('productos')
            .get().then((productos){

              for(DocumentSnapshot producto in productos.docs){

                //AGREGA EL NOMBRE DEL PRODUCTO A LISTA PARA DESPUES PODER BUSCARLO
                this.listaProductosBuscados.add(producto.id);
                //AGREGA EL GRUPO AL QUE PERTENECE EL PRODUCTO
                this.listaGrupoREFproductoBuscado.add(producto.data()['grupo']);


              }

            });


        });

      }).then((value){
        
        FirebaseFirestore.instance
          .collection(oficinaREF)
          .doc(negocioREF)
          .get().then((snap){       
            modificarInventario = snap.data()['hacerInventario'];     
            update(['principal']);
          });

      });    

  }  

  
  void onTapItemBarraBuscador(String producto){

    int indxREF = this.listaProductosBuscados.indexOf(producto);
    
    Widgettss().resultadoProductoBuscado(
      oficina: this.oficina,
      negocio: this.negocio,
      grupo: this.listaGrupoREFproductoBuscado[indxREF],
      producto: producto
    );
  }


  void onTapContenedorGrupo(int indx){    
    this.onPresNombresGrupos[indx] = !this.onPresNombresGrupos[indx];
    update(["nombreGrupoHijos${indx.toString()}"]);
  }



  Future obtenerTotalesGrupo(String nombreGrupo) async{

    double stockTotal = 0.000;
    double actualTotal = 0.000;
    double faltanteTotal = 0.000;

    await FirebaseFirestore.instance
      .collection(oficina)
      .doc(negocio)
      .collection('grupos')
      .doc(nombreGrupo)
      .collection('productos')
      .get().then((snapshot){
        
        for(DocumentSnapshot producto in snapshot.docs){  
          
          double cantidadFaltante = double.parse(producto.data()['stock'].toString()) - double.parse(producto.data()['actual'].toString());
          double actualDinero = producto.data()['precioUnitario'].toDouble() * producto.data()['actual'].toDouble();
          double stockDinero = producto.data()['precioUnitario'].toDouble() * producto.data()['stock'].toDouble();
          double faltanteDinero = producto.data()['precioUnitario'].toDouble() * cantidadFaltante;
        
          stockTotal = stockTotal + stockDinero;
          actualTotal = actualTotal + actualDinero;
          faltanteTotal = faltanteTotal + faltanteDinero;
          
          
        }

      });

    return bottomSheetTotalGrupo(nombreGrupo, stockTotal, actualTotal, faltanteTotal);

  }


  void onTapIconoCerrarSesion(){

    return AlertDialogPregunta().preguntar(
      titulo: 'Informacion',
      contenido: '¿Estas seguro de cerrar sesion',

      onPresSi: () async{

        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.clear();

        Get.offAll(Inicio());

      }
    );
  }

  void onTapIconoHacerInventario(){

    return AlertDialogPregunta().preguntar(
      titulo: 'Informacion',
      contenido: '¿Quieres hacer inventario?',

      onPresSi: (){
        
        hacerInventario();

        this.modificarInventario = true;
        update(['principal']);

      }
    );
  }

  void onTapIconoHacerPedido(){

    bool yaHizoPedido;

    FirebaseFirestore.instance
      .collection(this.oficina)
      .doc(this.negocio)
      .collection('requisiciones')
      .get().then((requisiciones){

        for(DocumentSnapshot requi in requisiciones.docs){

          DateTime fecha = DateTime.now();
          
          String diaMesAnoDispositivo = 
            DateFormat('dd-MM-yyyy').format(fecha);
          
          String diaMesAnoPedido = 
            DateFormat('dd-MM-yyyy').format(
              DateTime.parse(requi.data()['fechaDev'])
            );

          if(diaMesAnoDispositivo == diaMesAnoPedido){
            yaHizoPedido = true;
          }
        }

      }).then((value){

        if(yaHizoPedido == true){

          AlertDialogPregunta().ventanaYaSeHizoUnPedido(
            oficina: this.oficina,
            negocio: this.negocio,

            onPresSi: (){
              crearPedidoo().then((value){

                FirebaseFirestore.instance
                  .collection(this.oficina)
                  .doc(this.negocio)
                  .get().then((doc){
                    this.modificarInventario = doc.data()['hacerInventario'];
                    update(['principal']);
                  });

              });
            }
          );

        } else {

          AlertDialogPregunta().preguntar(
            titulo: this.negocio,
            contenido: 'Estas seguro de hacer un pedido',
            
            onPresSi: (){
              crearPedidoo().then((value){

                FirebaseFirestore.instance
                  .collection(this.oficina)
                  .doc(this.negocio)
                  .get().then((doc){
                    this.modificarInventario = doc.data()['hacerInventario'];
                    update(['principal']);
                  });

              });
            }

          );
        }

      });
  }







  void hacerInventario(){   

    int indxGrupo = 0;

    FirebaseFirestore.instance
      .collection(this.oficina)
      .doc(this.negocio)
      .update({
        'hacerInventario': true
      });


    Get.back();
    Mensajess().alertaMensaje('¡Listo! Espera un momento');


    FirebaseFirestore.instance
      .collection(this.oficina)
      .doc(this.negocio)
      .collection('grupos')
      .get().then((grupos) async{

        for(DocumentSnapshot grupoo in grupos.docs){
          grupoo.reference.update({ 
            'indx':  indxGrupo,
            'color': 'ed1c24'
          });
          
          indxGrupo = indxGrupo + 1;
        }

        await Future.forEach(grupos.docs, (grupo) async{

          await FirebaseFirestore.instance
            .collection(this.oficina)
            .doc(this.negocio)
            .collection('grupos')
            .doc(grupo.id)
            .collection('productos')
            .get().then((productos){

              for(DocumentSnapshot producto in productos.docs){
                producto.reference.update({
                  'color': '7f7f7f' //GRIS
                });
              }

            });

        });

      });    
    
  }


  void verificarInventario(){

    int faltanProductosPorRevisar = 0;

    FirebaseFirestore.instance
      .collection(this.oficina)
      .doc(this.negocio)      
      .collection('grupos')
      .get().then((gruposs) async{

        await Future.forEach(gruposs.docs, (DocumentSnapshot grupo) async{

          print("bucle de grupos ${grupo.id}");

          await FirebaseFirestore.instance
            .collection(this.oficina)
            .doc(this.negocio)
            .collection('grupos')
            .doc(grupo.id)
            .collection('productos')
            .get().then((productoss){

              bool falta;

              for(DocumentSnapshot productoo in productoss.docs){

                if(productoo.data()['color'] == '7f7f7f'){
                  //NO SE ACTUALIZO LA EXISTENCIA DEL PRODUCTOS
                  faltanProductosPorRevisar = faltanProductosPorRevisar + 1;
                  falta = true;

                }
              }

              return falta;

            }).then((bool resultado){

              if(resultado == true){
                grupo.reference.update({ 'indx': 1 , 'color': 'ed1c24' });
              }else {
                grupo.reference.update({ 'indx': 2 , 'color': '000000' });
              }

            });

        });

      }).then((value){

        if(faltanProductosPorRevisar == 0){
          
          Mensajess().alertaMensaje('Listo');          

        } else {
          Mensajess().alertaMensaje('Faltan productos por revisar');
        }


      });
      

  }



  Future<bool> crearPedidoo() async{
    
    bool pedidoHechoCorrectamente;    

    DateTime fecha = DateTime.now();
    String diaMesAno = DateFormat('dd-MM-yyyy').format(fecha);
    String hora = DateFormat.jm().format(fecha); 

    int cantidadGrupoFaltaActualizar = 0;

    await FirebaseFirestore.instance //VERIFICAR SI SE PUEDE HACER UN PEDIDO
      .collection(this.oficina)
      .doc(this.negocio)
      .collection('grupos')
      .get().then((snapshot) async{

        await Future.forEach(snapshot.docs, (grupo) async{

          await FirebaseFirestore.instance
            .collection(this.oficina)
            .doc(this.negocio)
            .collection('grupos')
            .doc(grupo.id)
            .collection('productos')
            .get().then((productos){

              for(DocumentSnapshot producto in productos.docs){
                if(producto.data()['color'] == "7f7f7f"){
                  cantidadGrupoFaltaActualizar = cantidadGrupoFaltaActualizar + 1;
                }
              }

            });

        });

      }).then((value){ //CREACION DEL PEDIDO
        
        if(cantidadGrupoFaltaActualizar == 0){    

          pedidoHechoCorrectamente = true;          
        
          FirebaseFirestore.instance
            .collection(this.oficina)
            .doc('cedis')
            .get().then((documento){
                          
              String idPedido = "${negocio[0]}${documento.data()[negocio]}";
              
              FirebaseFirestore.instance.collection(this.oficina)
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

              FirebaseFirestore.instance.collection(this.oficina)
                                        .doc('cedis')
                                        .collection('requisiciones')
                                        .doc(idPedido)
                                        .collection('detalles')
                                        .doc('zzz')
                                        .set({
                                          'ejemplo': 'nada'
                                        });
              
              FirebaseFirestore.instance.collection(this.oficina)
                                        .doc(this.negocio)
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
              
              FirebaseFirestore.instance.collection(this.oficina)
                                        .doc(this.negocio)
                                        .collection('requisiciones')
                                        .doc(idPedido)
                                        .collection('detalles')
                                        .doc('zzz')
                                        .set({
                                          'ejemplo': 'nada'
                                        });

              FirebaseFirestore.instance
                .collection(this.oficina)
                .doc(this.negocio)
                .update({
                  'hacerInventario': false
                });

              recorrerProductosParaPedido(idPedido);
              
              documento.reference.update({ //ACTUALIZAR FOLIO DE PEDIDOS
                negocio: FieldValue.increment(1)
              });

              

              Get.back();
              Mensajess().alertaMensaje("¡Listo! Pedido Enviado");

            });

        } else {
          Get.back();
          Mensajess().alertaMensaje('No puedes hacer el pedido porque no has completado el inventario');
        }
        
      });    

    return pedidoHechoCorrectamente;
    
  }

  void recorrerProductosParaPedido(String pedidoREF){

    double dineroTotalDePedido = 0.000;

    FirebaseFirestore.instance
      .collection(this.oficina)
      .doc(this.negocio)
      .collection('grupos')
      .get().then((snap) async{

        await Future.forEach(snap.docs, (grupo) async{

          await FirebaseFirestore.instance
            .collection(this.oficina)
            .doc(this.negocio)
            .collection('grupos')
            .doc(grupo.id)
            .collection('productos')
            .get().then((productos){

              for(DocumentSnapshot producto in productos.docs){

                String indexREF = producto.data()['grupo'];

                double stockDouble = producto.data()['stock'].toDouble();
                double actualDouble = producto.data()['actual'].toDouble();

                double cantidadFaltante = stockDouble - actualDouble;
                double dineroDePedido = producto.data()['precioUnitario'].toDouble() * cantidadFaltante;

                //ENVIA SOLO LOS PRODUCTOS DONDE LA CANTIDAD FALTANTE SEA MAYOR 0
                if(cantidadFaltante > 0){

                  FirebaseFirestore.instance
                    .collection(this.oficina)
                    .doc(this.negocio)
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
                    .collection(this.oficina)
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

            });

        });

      }).then((value){

        FirebaseFirestore.instance
          .collection(this.oficina)
          .doc('cedis')
          .collection('requisiciones')
          .doc(pedidoREF)
          .update({
            'totalDinero': dineroTotalDePedido
          });
        
        FirebaseFirestore.instance
          .collection(this.oficina)
          .doc(this.negocio)
          .collection('requisiciones')
          .doc(pedidoREF)
          .update({
            'totalDinero': dineroTotalDePedido
          });

        FirebaseFirestore.instance
          .collection(this.oficina)
          .doc('cedis')
          .collection('requisiciones')
          .doc(pedidoREF)
          .collection('detalles')
          .doc('zzz')
          .delete();
        
        FirebaseFirestore.instance
          .collection(this.oficina)
          .doc(this.negocio)
          .collection('requisiciones')
          .doc(pedidoREF)
          .collection('detalles')
          .doc('zzz')
          .delete();      


        enviarNotificacion(this.negocio);


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

    debugPrint(llamarFuncion.data.toString());

  } 



}

import 'package:almacen/src/services/2A1A.dart';
import 'package:almacen/src/widgets/widgettss.dart';
import 'package:almacen/src/widgets/input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';


class DisenoRequisicionesRestaurant {

  Widget contenedorEstado(String titulo){
    return Align(
      alignment: Alignment.centerLeft,

      child: Container(
        decoration: BoxDecoration(
          color: titulo == 'Incompleta' ?
                  Colors.yellow
                  :
                  titulo == 'Completada' ?
                    Colors.green
                    :
                    Colors.black,

          borderRadius: BorderRadius.all(Radius.circular(20.0))
        ),

        child: Padding(
          padding: const EdgeInsets.all(8.0),

          child: Widgettss().etiquetaText(titulo: titulo, tamallo: 15.0, 
                              color: titulo == 'Incompleta' ?
                                Colors.black
                                :
                                titulo == 'Completada' ?
                                  Colors.black
                                  :
                                  Colors.white
          ),
        ),
      ),
    );
  }

  Widget mostrarSoloFolio({BuildContext context,String negocioREF,
                           DocumentSnapshot data,
                           bool verDetalles,
                           VoidCallback onLongPresVerDetalles
                          }){
    
    final formatoMoneda = NumberFormat.simpleCurrency();

    String folio = data.id;
    String sePidio = data.data()['SePidio'];
    String seEntrego = data.data()['SeEntrego'];
    String seCompleto = data.data()['SeCompleto'];

    bool incompleta = data.data()['incompleta'];  

    double dineroTotal = data.data()['totalDinero'];
    double dineroTotalRojo = data.data()['totalDineroCancelado'] == 0 ? 0.000 : data.data()['totalDineroCancelado'];

    return Padding(
      padding: const EdgeInsets.all(10.0),

      child: GestureDetector(
        
        onLongPress: onLongPresVerDetalles,

        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(25.0))
          ),

          child: Padding(
            padding: const EdgeInsets.all(10.0),

            child: Column(
              children: [

                Widgettss().etiquetaText(titulo: "FOLIO : ${folio.toUpperCase()}", tamallo: 17.0,),

                SizedBox(height: 10.0,),
                
                Align(
                  alignment: Alignment.centerLeft,
                  child: Widgettss().etiquetaText(titulo: "Se pidio : $sePidio", tamallo: 15.0,)
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Widgettss().etiquetaText(titulo: "Se entrego : $seEntrego", tamallo: 15.0,)
                ),


                incompleta == true && seCompleto != 'aun no' ?
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Widgettss().etiquetaText(titulo: "Se completo : $seCompleto", tamallo: 15.0,)
                  )
                  :
                  SizedBox(height: 0.0,),


                verDetalles == false ?
                  SizedBox(height: 0.0)
                  :
                  verDetallesPedido(context, negocioREF, folio),



                seEntrego != 'aun no' && incompleta == false ?
                  SizedBox(height: 0.0,)
                  :
                  seCompleto != 'aun no' ?
                    SizedBox(height: 0.0,)
                    :
                    verDetalles == false ?
                      SizedBox(height: 0.0,)
                      :
                      //VERIFICAR TODO EL PEDIDO
                      Widgettss().botonIcono(Icons.check_box, 50.0, () async{                         
                        
                        Services2A1A().terminoRevisionPedido(context, negocioREF, folio);                                                                        

                      }),

                SizedBox(height: 10.0,),

                Row(
                  children: [
                    contenedorEstado(
                      seEntrego == 'aun no' ?
                        'Aun no llega'
                        :
                        incompleta == false ?
                          'Completada'
                          :
                          seCompleto == 'aun no' ?
                            'Incompleta'
                            :
                            'Completada'
                    ),
                    
                    Spacer(),

                    Align(
                      alignment: Alignment.bottomRight,
                      child: Widgettss().etiquetaText(titulo: formatoMoneda.format(dineroTotal), tamallo: 17.0,)
                    ),
                  ],
                ),

                //DINERO ROJO
                Align(
                  alignment: Alignment.bottomRight,

                  child: dineroTotalRojo == 0 ?
                    SizedBox(height: 0.0,)
                    :
                    Widgettss().etiquetaText(titulo: "Cancelado : ${formatoMoneda.format(dineroTotalRojo)}", tamallo: 17.0,),
                )
                
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget verDetallesPedido(BuildContext context,String negocio,String pedidoREF){
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('cholula')
                                        .doc(negocio)
                                        .collection('requisiciones')
                                        .doc(pedidoREF)
                                        .collection('detalles')
                                        .orderBy('indx')
                                        .snapshots(),
      builder: (context, snapshot){
        if (snapshot.data == null)
          return Center(child: CircularProgressIndicator()); 

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),

          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index){
             
            bool separar;

            if(index != 0){
              if(snapshot.data.documents[index].data()['grupo'] 
                 != 
                snapshot.data.documents[index - 1].data()['grupo']
                ){
                  separar = true;
                }
            }

            return cuerpoFirestoreDetallesPedido(
              negocio,
              pedidoREF,
              separar,
              snapshot.data.documents[index], 
              context, 
              index
            );

          }
        );
      },
    );
  }

  Widget cuerpoFirestoreDetallesPedido(String negocio,String pedidoREF,bool separar,
                                        DocumentSnapshot data,BuildContext context,int index
                                      ){

    final formatoMoneda = NumberFormat.simpleCurrency();

    double total = double.parse(data.data()['precioUnitario'].toString()) * data.data()['pidio'];
    double cantidadPidio = double.parse(data.data()['pidio'].toString());
    double cantidadFalta = double.parse(data.data()['falta'].toString());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),

      child: Column(
        children: [

          separar != true ?
            SizedBox(height: 0.0,)
            :
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 30.0),
              child: Divider(thickness: 5.0, height: 5.0, color: Colors.black,)
            ),
          
          
          Slidable(
            actionPane: SlidableDrawerActionPane(),
            actions: [
              IconSlideAction(
                icon: Icons.check,
                color: Colors.green,
                onTap: (){
                  if(data.data()['color'] != 'ed1c24'){ //ROJO
                    if(data.data()['color'] != '22b14c'){ //VERDE

                      Services2A1A().ponerEnVerde(negocio, pedidoREF, data);

                    }
                                        
                  }                  
                },
              ),
              IconSlideAction(
                icon: Icons.mode_edit,
                color: Colors.yellow,
                onTap: (){
                  if(data.data()['color'] != 'ed1c24'){ //ROJO 
                    if(data.data()['color'] != '22b14c'){ //VERDE

                      modificarCantidadPedido(context, negocio, pedidoREF, data);

                    }
                  }
                },
              ),
              IconSlideAction(
                icon: Icons.cancel,
                color: Colors.red,
                onTap: (){
                  if(data.data()['color'] != 'ed1c24' ){ //ROJO
                    if(data.data()['color'] != '22b14c'){ //VERDE
                      
                      cancelarProducto(context, negocio, data, pedidoREF);

                    }
                  }
                },
              ),
            ],

            child: GestureDetector(
              
              onTap: (){ //VER DETALLES PRODUCTO CANCELADO

                if(data.data()['color'] == 'ed1c24'){ //ROJO
                  Widgettss().verDetallesProductoRojo(context, data);
                }

              },

              child: Column(
                children: [                

                  IntrinsicHeight(

                    child: Row(
                      children: [
                        SizedBox(width: MediaQuery.of(context).size.width * 0.1,),                      

                        Container(                          
                          decoration: BoxDecoration(
                            color: data.data()['color'] == 'ffffff' ? 
                              Colors.transparent 
                              : 
                              Color(int.parse("0xff${data.data()['color']}")),
                            border: Border.all(color: Colors.black)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Widgettss().etiquetaText(titulo: 'CANT',),
                                Widgettss().etiquetaText(titulo: data.data()['falta'] == 0 ?
                                                      cantidadPidio.toStringAsFixed(2)
                                                      :
                                                      data.data()['dineroRojo'] != 0 ?
                                                        cantidadFalta.toStringAsFixed(2)
                                                        :
                                                        cantidadFalta.toStringAsFixed(2)
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(                          
                            decoration: BoxDecoration(
                              color: data.data()['color'] == 'ffffff' ? 
                                Colors.transparent 
                                : 
                                Color(int.parse("0xff${data.data()['color']}")),
                              border: Border.all(color: Colors.black)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),

                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Widgettss().etiquetaText(titulo: 'DESC',),
                                  Widgettss().etiquetaText(titulo: data.id,)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]
                    ),
                  ),

                  IntrinsicHeight(
                    child: Row(
                      children: [
                        SizedBox(width: MediaQuery.of(context).size.width * 0.1,),
                        
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: data.data()['color'] == 'ffffff' ? 
                                Colors.transparent 
                                : 
                                Color(int.parse("0xff${data.data()['color']}")),
                              border: Border(
                                left: BorderSide(color: Colors.black),
                                right: BorderSide(color: Colors.black),
                                bottom: BorderSide(color: Colors.black),
                              )
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),

                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Widgettss().etiquetaText(titulo: 'UNI',),
                                  Widgettss().etiquetaText(titulo: data.data()['medida'],),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: data.data()['color'] == 'ffffff' ? 
                                Colors.transparent 
                                : 
                                Color(int.parse("0xff${data.data()['color']}")),
                              border: Border(
                                left: BorderSide(color: Colors.black),
                                right: BorderSide(color: Colors.black),
                                bottom: BorderSide(color: Colors.black),
                              )
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),

                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Widgettss().etiquetaText(titulo: 'P.U',),
                                  Widgettss().etiquetaText(titulo: formatoMoneda.format(data.data()['precioUnitario']),),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: data.data()['color'] == 'ffffff' ? 
                                Colors.transparent 
                                : 
                                Color(int.parse("0xff${data.data()['color']}")),
                              border: Border(
                                left: BorderSide(color: Colors.black),
                                right: BorderSide(color: Colors.black),
                                bottom: BorderSide(color: Colors.black),
                              )
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),

                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Widgettss().etiquetaText(titulo: 'TOTAL',),
                                  Widgettss().etiquetaText(titulo: formatoMoneda.format(total),),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          

        ],
      ),
    );
  }



  modificarCantidadPedido(BuildContext context,String negocio,String pedidoREF,DocumentSnapshot data){

    TextEditingController cantidadControlador = TextEditingController();

    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0))
          ),
          
          title: Text(negocio),

          content: SingleChildScrollView(
            child: Column(
              children: [
                Widgettss().etiquetaText(titulo: data.id),

                SizedBox(height: 8.0),

                Input(
                  etiqueta: 'Cantidad',
                  controlador: cantidadControlador,
                  tipo: TextInputType.number,

                  next: (valor){
                    if(cantidadControlador.text != ''){
                      try {
                        
                        double cantidadConversion = double.parse(cantidadControlador.text);
                        
                        double cantidadFaltante = double.parse(data.data()['pidio'].toString()) - cantidadConversion;
                        
                        double restarAfaltante = double.parse(data.data()['falta'].toString()) - cantidadConversion;

                        if(data.data()['falta'] != 0){
                          

                          if(data.data()['falta'] == cantidadConversion){

                            data.reference.update({
                              'falta': restarAfaltante,
                              'color': "22b14c", //VERDE                          
                            });
                            FirebaseFirestore.instance
                              .collection('cholula')
                              .doc('cedis')
                              .collection('requisiciones')
                              .doc(pedidoREF)
                              .collection('detalles')
                              .doc(data.id)
                              .update({
                                'falta': restarAfaltante,
                                'color': "22b14c" //VERDE
                              });

                            Navigator.pop(context);

                          } else {

                            if(restarAfaltante >= 0){

                              data.reference.update({
                                'falta': restarAfaltante,
                                'color': "fff200" //AMARILLO
                              });
                              FirebaseFirestore.instance
                                .collection('cholula')
                                .doc('cedis')
                                .collection('requisiciones')
                                .doc(pedidoREF)
                                .collection('detalles')
                                .doc(data.id)
                                .update({
                                  'falta': restarAfaltante,
                                  'color': "fff200" //AMARILLO
                                });

                              Navigator.pop(context);
                            }

                          }
                          

                        } else {

                          if(cantidadFaltante >= 0){

                            if(cantidadConversion == data.data()['pidio']){

                              data.reference.update({
                                'color': "22b14c" //VERDE
                              });
                              FirebaseFirestore.instance
                                .collection('cholula')
                                .doc('cedis')
                                .collection('requisiciones')
                                .doc(pedidoREF)
                                .collection('detalles')
                                .doc(data.id)
                                .update({
                                  'color': "22b14c" //VERDE
                                });

                              Navigator.pop(context);

                            }else {

                              data.reference.update({
                                'falta': cantidadFaltante,
                                'color': "fff200" //AMARILLO
                              });
                              FirebaseFirestore.instance
                                .collection('cholula')
                                .doc('cedis')
                                .collection('requisiciones')
                                .doc(pedidoREF)
                                .collection('detalles')
                                .doc(data.id)
                                .update({
                                  'falta': cantidadFaltante,
                                  'color': "fff200" //AMARILLO
                                });

                              Navigator.pop(context);

                            }

                          }     

                        }                   

                      } catch (e) {
                        debugPrint(e);
                      }
                      
                    }
                  },
                ),

                SizedBox(height: 10.0,),
              ],
            ),
          ),
        );
      }
    );

  }

  cancelarProducto(BuildContext context,String negocio,DocumentSnapshot docREF,String pedidoREF){

    TextEditingController codeControlador = TextEditingController();

    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0))
          ),

          title: Text(negocio),

          content: SingleChildScrollView(
            child: Input(
              etiqueta: 'Codigo',
              controlador: codeControlador,
              tipo: TextInputType.number,
              oscurecer: true,

              next: (valor){

                Services2A1A().verificarCodigoParaEliminarProducto(
                  context: context,
                  
                  negocio: negocio,
                  pedidoREF: pedidoREF,

                  doc: docREF,

                  codigoIntroducido: codeControlador.text

                );

              },
            ),
          ),

        );
      }
    );
  }


  


}
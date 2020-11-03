

import 'package:almacen/src/widgets/widgettss.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class DisenoCedis {


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


  Widget mostrarSoloFolio({BuildContext context,                          
                           DocumentSnapshot data,
                           bool verDetalles,bool vistaRepartidor,
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

                Widgettss().etiquetaText(titulo: data.data()['negocio'].toString().toUpperCase(), tamallo: 17.0,),

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
                  verDetallesPedido(context, folio, vistaRepartidor),
                

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


  Widget verDetallesPedido(BuildContext context,String pedidoREF,bool vistaRepartidor){
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('cholula')
                                        .doc('cedis')
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
              context: context, 
              vistaRepartidor: vistaRepartidor,
              index: index,
              separar: separar,
              data: snapshot.data.documents[index], 
            );

          }
        );
      },
    );
  }


  Widget cuerpoFirestoreDetallesPedido({bool separar,bool vistaRepartidor,
                                        DocumentSnapshot data,BuildContext context,int index
                                      }){

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
          
          
          Column(
            children: [                        

              IntrinsicHeight(
                child: Row(
                  children: [

                    data.data()['revisado'] == 'no' ? 
                      GestureDetector(
                        onTap: (){ data.reference.update({ 'revisado': 'bien' }); },
                        child: Container(
                          height: 30.0,
                          width: 30.0,

                          child: Icon(Icons.check_box, size: 30.0,)
                        ),
                      )

                      :

                      data.data()['revisado'] == 'bien' ?
                        Icon(Icons.check, size: 30.0,)
                        :
                        Icon(Icons.cancel, size: 30.0,),


                    Container(
                      decoration: BoxDecoration(
                        color: data.data()['color'] == 'ffffff' ? 
                          Colors.transparent 
                          : 
                          Color(int.parse("0xff${data.data()['color']}")),
                        border: Border.all(color: Colors.black)
                      ),

                      child: GestureDetector(
                        onTap: (){
                          if(data.data()['color'] == 'ed1c24'){ //ROJO
                            Widgettss().verDetallesProductoRojo(context, data);
                          }
                        },

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
                    ),

                    Expanded(
                      child: GestureDetector(
                        onTap: (){
                          if(data.data()['color'] == 'ed1c24'){ //ROJO
                            Widgettss().verDetallesProductoRojo(context, data);
                          }
                        },

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
                    ),

                    data.data()['revisado'] == 'no' ? 
                      GestureDetector(
                        onTap: (){ data.reference.update({ 'revisado': 'mal' }); },
                        child: Container(
                          height: 30.0,
                          width: 30.0,

                          child: Icon(Icons.cancel, size: 30.0,)
                        ),
                      )
                      
                      :
                      SizedBox(height: 30.0, width: 30.0,)

                  ]
                ),
              ),

              IntrinsicHeight(
                child: Row(
                  children: [

                    SizedBox(height: 30.0, width: 30.0,),
                    
                    Expanded(
                      child: GestureDetector(
                        onTap: (){
                          if(data.data()['color'] == 'ed1c24'){ //ROJO
                            Widgettss().verDetallesProductoRojo(context, data);
                          }
                        },

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
                    ),

                    vistaRepartidor == true ? 
                      SizedBox(height: 0.0,)
                      :
                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            if(data.data()['color'] == 'ed1c24'){ //ROJO
                              Widgettss().verDetallesProductoRojo(context, data);
                            }
                          },

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
                      ),

                    vistaRepartidor == true ?
                     SizedBox(height: 0.0,)
                     :
                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            if(data.data()['color'] == 'ed1c24'){ //ROJO
                              Widgettss().verDetallesProductoRojo(context, data);
                            }
                          },

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
                      ),
                      
                      SizedBox(height: 30.0, width: 30.0,)
                  ],
                ),
              ),
            ],
          ),
          

        ],
      ),
    );
  }




}
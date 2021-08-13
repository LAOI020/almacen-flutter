
import 'package:almacen/src/controladores/2B.dart';
import 'package:almacen/src/screens/1-inicio.dart';
import 'package:almacen/src/services/2B-archivoExcel.dart';
import 'package:almacen/src/widgets/alertDialogPregunta.dart';
import 'package:almacen/src/widgets/widgettss.dart';
import 'package:almacen/src/widgets/input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';



class RequisicionesCedis extends StatelessWidget {

  final String oficina;
  final String puestoPersona;

  const RequisicionesCedis({this.oficina,this.puestoPersona});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CedisController>(
      init: CedisController(),
      builder: (_){
        
        if(_.pantallaCargada != true){
          _.metodoInicial(oficina, puestoPersona);
        }
        
        return _.pantallaCargada != true ? 
          Center(child: CircularProgressIndicator())
          :
          Scaffold(
            appBar: AppBar(
              backgroundColor: Color(int.parse('0xff1565bf')),
              centerTitle: true,
              title: Text('Cedis'),

              leading: Widgettss().botonIcono(Icons.power_settings_new, 30.0, () {           

                AlertDialogPregunta().preguntar(
                  titulo: 'Informacion',
                  contenido: '¿Estas seguro de cerrar sesion?',
                  
                  onPresSi: () async{
                    
                    SharedPreferences preferences = await SharedPreferences.getInstance();
                    preferences.clear();

                    Get.offAll(Inicio());

                  }

                );
                
              }),

              actions: [
                GestureDetector(
                  child: Icon(Icons.remove_red_eye, size: 30.0),
                  onTap: (){ vistaDetallesCediss(); },            
                ),
                
                SizedBox(width: puestoPersona == 'finanzas' ? 20.0 : 0.0),

                puestoPersona != 'finanzas' ?  
                  SizedBox(height: 0.0,)
                  :
                  GestureDetector(
                    child: Icon(Icons.mark_email_unread, size: 30.0),
                    onTap: (){ Service2B().ventana(oficina); },            
                  )
              ],
            ),

            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/fondoo.png"),
                  fit: BoxFit.cover
                )
              ),

              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection(oficina)
                                                  .doc('cedis')
                                                  .collection('requisiciones')
                                                  .orderBy('fechaDev', descending: true)
                                                  .snapshots(),
                builder: (context, snapshot){
                  if(snapshot.data == null){
                    return Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index){

                      return MostrarFolioCedis(
                        data: snapshot.data.documents[index],
                        index: index,
                      );
                    }

                  );
                }
              )
            ),

            floatingActionButton: puestoPersona != 'finanzas' && puestoPersona != 'administracion' ?
              SizedBox(height: 0.0)
              :
              FloatingActionButton(
                backgroundColor: Color(int.parse('0xff1565bf')),
                child: Icon(Icons.monetization_on_outlined, size: 50.0),
                onPressed: () => _.onTapIconoFinanzas(),
              ),
          );
      }
    );
  }

  vistaDetallesCediss(){

    TextEditingController codigoControlador = TextEditingController();
    
    return Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0))
        ),
        
        title: Text('Cedis'),
        
        content: GetBuilder<CedisController>(
          builder: (_){
            return Input(
              etiqueta: 'Codigo',
              controlador: codigoControlador,
              oscurecer: true,
              tipo: TextInputType.number,

              next: (valor) => _.verificarCodigoVistaDetallada(codigoControlador.text)
            );
          },
        )
      ),
    );
  }


}



class ContenedorEstadoCedis extends StatelessWidget {

  final String titulo;

  const ContenedorEstadoCedis(this.titulo);

  @override
  Widget build(BuildContext context) {
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
}


class MostrarFolioCedis extends StatelessWidget {

  final DocumentSnapshot data;
  final int index;

  const MostrarFolioCedis({this.data,this.index});

  @override
  Widget build(BuildContext context) {

    final formatoMoneda = NumberFormat.simpleCurrency();

    String folio = data.id;
    String sePidio = data.data()['SePidio'];
    String seEntrego = data.data()['SeEntrego'];
    String seCompleto = data.data()['SeCompleto'];

    bool incompleta = data.data()['incompleta'];  

    double dineroTotal = data.data()['totalDinero'];
    double dineroTotalRojo = data.data()['totalDineroCancelado'] == 0 ? 0.000 : data.data()['totalDineroCancelado'];
    
    return GetBuilder<CedisController>(
      id: 'contenedorFolio$index',
      builder: (_){
        return Padding(
          padding: const EdgeInsets.all(10.0),

          child: GestureDetector(
            onLongPress: () => _.onLongPresVerDetalles('contenedorFolio$index', index),

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


                    _.onPresDetallesPedido[index] == false ?
                      SizedBox(height: 0.0)
                      :
                      DetallesPedidoCedis(
                        oficina: _.oficina,
                        pedidoREF: folio,
                        vistaRepartidor: _.vistaRepartidor,
                      ),
                    

                    SizedBox(height: 10.0,),

                    Row(
                      children: [
                        ContenedorEstadoCedis(
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
      },
    );
  }
}


class DetallesPedidoCedis extends StatelessWidget {

  final String oficina;
  final String pedidoREF;
  final bool vistaRepartidor;

  const DetallesPedidoCedis({this.oficina,this.pedidoREF,this.vistaRepartidor});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection(oficina)
                                        .doc('cedis')
                                        .collection('requisiciones')
                                        .doc(pedidoREF)
                                        .collection('detalles')
                                        .orderBy('indx')
                                        .snapshots(),
      builder: (context, snapshot){
        if(snapshot.data == null){
          return Center(child: CircularProgressIndicator());
        }

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

            return PedidoCedisFirestore(
              separar: separar,
              vistaRepartidor: vistaRepartidor,
              data: snapshot.data.documents[index],
              index: index,
            );
          }
        );
      }
    );
  }
}

class PedidoCedisFirestore extends StatelessWidget {

  final bool separar;
  final bool vistaRepartidor;
  final DocumentSnapshot data;
  final int index;

  const PedidoCedisFirestore({this.separar,this.vistaRepartidor,this.data,this.index});

  @override
  Widget build(BuildContext context) {

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
                            Widgettss().verDetallesProductoRojo(data);
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
                            Widgettss().verDetallesProductoRojo(data);
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
                            Widgettss().verDetallesProductoRojo(data);
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
                              Widgettss().verDetallesProductoRojo(data);
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
                              Widgettss().verDetallesProductoRojo(data);
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

        ]
      ),
    );
  }
}


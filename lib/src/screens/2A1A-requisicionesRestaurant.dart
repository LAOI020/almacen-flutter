

import 'package:almacen/src/controladores/2A1A.dart';
import 'package:almacen/src/widgets/input.dart';
import 'package:almacen/src/widgets/widgettss.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';


class RequisicionesRestaurant extends StatelessWidget {

  final String oficina;
  final String negocio;

  const RequisicionesRestaurant({this.oficina,this.negocio});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RequisicionesRestaurantController>(
      init: RequisicionesRestaurantController(),
      builder: (_){
        
        if(_.pantallacargada != true){
          _.metodoInicial(oficina, negocio);
        }

        return _.pantallacargada != true ? 
          Center(child: CircularProgressIndicator())
          :
          Scaffold(
            appBar: AppBar(
              backgroundColor: Color(int.parse('0xff1565bf')),
              centerTitle: true,
              title: Text('Pedidos')
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
                                                  .doc(negocio)
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

                      return MostrarSoloFolio(
                        oficina, negocio,
                        snapshot.data.documents[index], index
                      );
                    }
                  );
                },
              ),
            ),
          );
      }
    );
  }
}

class MostrarSoloFolio extends StatelessWidget {

  final String oficina;
  final String negocio;
  final DocumentSnapshot data;
  final int indx;

  const MostrarSoloFolio(this.oficina,this.negocio,this.data,this.indx);

  @override
  Widget build(BuildContext context) {

    final formatoMoneda = NumberFormat.simpleCurrency();
    
    return GetBuilder<RequisicionesRestaurantController>(
      id: "folio$indx",
      builder: (_){
        return Padding(
          padding: const EdgeInsets.all(8.0),

          child: GestureDetector(
            onLongPress: (){ _.longPresPedido(indx, "folio$indx"); },

            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(25.0))
              ),

              child: Padding(
                padding: const EdgeInsets.all(8.0),

                child: Column(
                  children: [

                    Widgettss().etiquetaText(
                      titulo: "FOLIO : ${data.id.toUpperCase()}", 
                      tamallo: 17.0
                    ),

                    SizedBox(height: 10.0,),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Widgettss().etiquetaText(
                        titulo: "Se pidio : ${data.data()['SePidio']}",
                        tamallo: 15.0,
                      )
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Widgettss().etiquetaText(
                        titulo: "Se entrego : ${data.data()['SeEntrego']}", 
                        tamallo: 15.0,
                      )
                    ),

                    data.data()['incompleta'] == true &&
                    data.data()['SeCompleto'] != 'aun no' ?
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Widgettss().etiquetaText(
                          titulo: "Se completo : ${data.data()['SeCompleto']}", 
                          tamallo: 15.0,
                        )
                      )
                      :
                      SizedBox(height: 0.0,),

                    //ON LONG PRES PARA VER DETALLES DEL PEDIDO
                    _.onLongPresPedido[indx] == false ?
                      SizedBox(height: 0.0,)
                      :
                      DetallesPedido(oficina, negocio, data.id),

                    
                    //MOSTRAR BOTON PARA VERIFICAR PEDIDO SOLO SE VE
                    //CUANDO ESTA ABIERTO EL PEDIDO
                    data.data()['SeEntrego'] != 'aun no' &&
                    data.data()['incompleta'] == false ?
                      SizedBox(height: 0.0,)
                      :
                      data.data()['SeCompleto'] != 'aun no' ?
                        SizedBox(height: 0.0,)
                        :
                        _.onLongPresPedido[indx] == false ?
                          SizedBox(height: 0.0,)
                          :
                          GetBuilder<RequisicionesRestaurantController>(                           
                            builder: (_){
                              return Widgettss().botonIcono(Icons.check_box, 50.0, () { 
                                _.terminoRevisionPedido(data.id);
                              });
                            }
                          ),

                    SizedBox(height: 10.0,),

                    Row(
                      children: [
                        contenedorEstado(
                          data.data()['SeEntrego'] == 'aun no' ?
                            'Aun no llega'
                            :
                            data.data()['incompleta'] == false ?
                              'Completada'
                              :
                              data.data()['SeCompleto'] == 'aun no' ?
                                'Incompleta'
                                :
                                'Completada'
                        ),

                        Spacer(),

                        //DINERO VERDE
                        Align(
                          alignment: Alignment.bottomRight,

                          child: Widgettss().etiquetaText(
                            titulo: formatoMoneda.format(data.data()['totalDinero']),
                            tamallo: 17.0
                          ),
                        )
                      ]
                    ),

                    //DINERO ROJO
                    Align(
                      alignment: Alignment.bottomRight,

                      child: data.data()['totalDineroCancelado'] == 0 ? 
                        SizedBox(height: 0.0,)
                        :
                        Widgettss().etiquetaText(
                          titulo: "Cancelado : ${formatoMoneda.format(data.data()['totalDineroCancelado'])}",
                          tamallo: 17.0
                        ),
                    )

                  ],                  
                ),
              ),
            )
          ),
        );
      }
    );

  }

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

          child: Widgettss().etiquetaText(
            titulo: titulo, 
            tamallo: 15.0,
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


class DetallesPedido extends StatelessWidget {

  final String oficina;
  final String negocio;
  final String pedidoREF;

  const DetallesPedido(this.oficina,this.negocio,this.pedidoREF);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection(oficina)
                                        .doc(negocio)
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

            return ProductosDePedido(
              oficina: oficina,
              negocio: negocio,

              data: snapshot.data.documents[index],
              separar: separar,

              pedidoREF: pedidoREF
            );
          }
        );
      }
    );
  }
}


class ProductosDePedido extends StatelessWidget {

  final String oficina;
  final String negocio;
  final DocumentSnapshot data;
  final bool separar;
  final String pedidoREF;

  const ProductosDePedido({this.pedidoREF,this.oficina,this.negocio,this.data,this.separar});

  @override
  Widget build(BuildContext context) {

    double total = double.parse(data.data()['precioUnitario'].toString()) * data.data()['pidio'];

    final formatoMoneda = NumberFormat.simpleCurrency();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),

      child: Column(
        children: [

          //LINEA QUE SEPARA LOS PRODUCTOS POR GRUPO
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
              GetBuilder<RequisicionesRestaurantController>(
                builder: (_){
                  return IconSlideAction(
                    icon: Icons.check,
                    color: Colors.green,
                    onTap: (){
                      if(data.data()['color'] != 'ed1c24'){ //ROJO
                        if(data.data()['color'] != '22b14c'){ //VERDE
                          
                          _.ponerEnVerde(pedidoREF, data);

                        }
                                            
                      }                  
                    },
                  );
                }
              ),
              IconSlideAction(
                icon: Icons.mode_edit,
                color: Colors.yellow,
                onTap: (){
                  if(data.data()['color'] != 'ed1c24'){ //ROJO 
                    if(data.data()['color'] != '22b14c'){ //VERDE

                      modificarCantidad(
                        oficina: oficina,
                        negocio: negocio,
                        pedidoREF: pedidoREF,
                        data: data,
                      );

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
                      
                      cancelarProductoo(
                        negocio: negocio,
                        pedidoREF: pedidoREF,
                        data: data
                      );

                    }
                  }
                },
              ),
            ],

            child: GestureDetector(
              onTap: (){
                if(data.data()['color'] == 'ed1c24'){ //ROJO
                  Widgettss().verDetallesProductoRojo(data);
                }
              },

              child: Column(
                children: [
                  
                  //CANTIDAD Y NOMBRE PRODUCTO
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        SizedBox(width: Get.width * 0.1),

                        //CANTIDAD
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
                                                      data.data()['pidio'].toString()
                                                      :
                                                      data.data()['dineroRojo'] != 0 ?
                                                        data.data()['falta'].toString()
                                                        :
                                                        data.data()['falta'].toString()
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        //NOMBRE PRODUCTO
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
                      ],
                    ),
                  ),
                  
                  //UNIDAD DE MEDIDA  PRECIO UNITARIO  TOTAL
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        SizedBox(width: MediaQuery.of(context).size.width * 0.1,),
                        
                        //UNIDAD MEDIDA
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

                        //PRECIO UNITARIO
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

                        //TOTAL
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
          )

        ],
      )
    );
  }


  modificarCantidad({String oficina,String negocio,String pedidoREF,DocumentSnapshot data}){

    TextEditingController cantidadControlador = TextEditingController();

    return Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0))
        ),

        title: Text(negocio),

        content: SingleChildScrollView(
          child: Column(
            children: [

              Widgettss().etiquetaText(titulo: data.id),

              SizedBox(height: 8.0,),

              GetBuilder<RequisicionesRestaurantController>(            
                builder: (_){
                  return Input(
                    etiqueta: 'Cantidad',
                    controlador: cantidadControlador,
                    tipo: TextInputType.number,

                    next: (valor) => _.modificarCantidadProducto(
                      texto: cantidadControlador.text,
                      pedidoREF: pedidoREF,
                      data: data
                    ),
                  );
                }
              ),

              SizedBox(height: 10.0,)

            ],
          ),
        ),
      )
    );
  }


  cancelarProductoo({String pedidoREF,String negocio,DocumentSnapshot data}){

    TextEditingController codigoControlador = TextEditingController();

    return Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0))
        ),
        title: Text(negocio),

        content: SingleChildScrollView(
          child: GetBuilder<RequisicionesRestaurantController>(
            builder: (_){
              return Input(
                etiqueta: 'Codigo',
                controlador: codigoControlador,
                tipo: TextInputType.number,
                oscurecer: true,

                next: (valor) => 
                  _.verificarCodigoParaEliminarProducto(
                    pedidoREF: pedidoREF,
                    doc: data,
                    codigoIntroducido: codigoControlador.text
                  )              
              );
            }
          ),
        ),
      )
    );
  }

}

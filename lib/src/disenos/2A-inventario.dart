
//PANTALLA QUE SE VE CUANDO HACEN INVENTARIO

import 'package:almacen/src/controladores/2A.dart';
import 'package:almacen/src/widgets/widgettss.dart';
import 'package:almacen/src/widgets/input.dart';
import 'package:almacen/src/widgets/mensajes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';


class PantallaHacerInventario extends StatelessWidget {

  final String oficina;
  final String negocio;

  PantallaHacerInventario({this.oficina,this.negocio});

  final ScrollController scrollControlador = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder(
          stream: FirebaseFirestore.instance.collection(oficina)
                                            .doc(negocio)
                                            .collection('grupos')
                                            .orderBy('indx')
                                            .snapshots(),
          builder: (context, snapshot){
            if (snapshot.data == null)
              return Center(child: CircularProgressIndicator()); 

            return ListView.builder(
              controller: scrollControlador,

              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index){

                bool ultimo;

                if(index + 1 == snapshot.data.documents.length){
                  ultimo = true;
                }

                return lineaGrupo(
                  data: snapshot.data.documents[index], 
                  oficina: oficina, 
                  negocio: negocio,
                  ultimo: ultimo
                );

              }
            );
          },
        ),

        //SCROLL CONTROLADORES
        Align(
          alignment: Alignment.topRight,

          child: Widgettss().botonIcono(Icons.arrow_circle_up, 50.0, () { 
            scrollControlador.animateTo(
              0, duration: Duration(milliseconds: 500), curve: Curves.bounceIn
            );
          }),
        ),

        //BOTON VERIFICAR INVENTARIO
        Align(
          alignment: Alignment.bottomCenter,

          child: GetBuilder<UnidadNegocioController>(
            builder: (_){
              return Widgettss().botonIcono(Icons.check_box, 50.0, () { 
                _.verificarInventario();
              });
            }
          ),
        )
      ],
    );
  }


  Widget lineaGrupo({DocumentSnapshot data,String oficina,String negocio,bool ultimo}){
    return Column(
      children: [

        Divider(thickness: 7.0,color: Color(int.parse('0xff${data.data()['color']}'))),

        StreamBuilder(
          stream: FirebaseFirestore.instance
                    .collection(oficina)
                    .doc(negocio)
                    .collection('grupos')
                    .doc(data.id)
                    .collection('productos')
                    .snapshots(),

          builder: (context, snap){

            if(snap.data == null){
              return Center(child: CircularProgressIndicator());
            }    
                    
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
                      
              itemCount: snap.data.documents.length,
              itemBuilder: (context, indeex){

                bool ultimoItemm;

                if(indeex + 1 == snap.data.documents.length && ultimo == true){
                  ultimoItemm = true;
                }

                return Get.width < 580.0 ? 
                  productosMovil(
                    oficina: oficina,
                    negocio: negocio,

                    data: snap.data.documents[indeex],
                    index: indeex,
                    ultimoItem: ultimoItemm
                  )
                  :
                  productos(
                    oficina: oficina,
                    negocio: negocio,

                    data: snap.data.documents[indeex],
                    index: indeex,
                    ultimoItem: ultimoItemm,
                  );

              }
            );
          },
        )
      ],
    );
  }

  Widget productos({DocumentSnapshot data,int index,bool ultimoItem,
                    String negocio,String oficina
              }){

    String colorString = data.data()['color'] == null ? "fba21c" : data.data()['color'];

    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
        bottom: 10.0,
        left: 15.0,
        right: 10.0
      ),

      child: Column(
        children: [

          IntrinsicHeight(      
            child: GestureDetector(

              onTap: (){ 
                if(data.data()['color'] == '7f7f7f'){

                  modificarExistencia(
                    oficina: oficina,
                    negocio: negocio,
                    data: data
                  );

                }
              },

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  //NOMBRE PRODUCTO
                  Container(
                    
                    width: Get.width * 0.5,

                    decoration: BoxDecoration(
                      color: Color(int.parse("0xff$colorString")), //fba21c NARANJA
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        bottomLeft: Radius.circular(25.0)
                      )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 5.0),

                      child: Align(
                        alignment: Alignment.centerLeft,
                        
                        child: Widgettss().etiquetaText(titulo: data.id,)
                      ),
                    )
                  ),
                  
                  //MEDIDA O UNIDAD
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(int.parse("0xff$colorString")),
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.only()
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 5.0, right: 5.0),

                        child: Widgettss().etiquetaText(titulo: data.data()['medida'],),
                      )
                    ),
                  ),
                  
                  //STOCK
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(int.parse("0xff$colorString")),
                        border: Border.all(color: Colors.white),                  
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 10.0, right: 10.0),

                        child: Widgettss().etiquetaText(titulo: data.data()['stock'].toString(),),
                      )
                    ),
                  ),

                  //CANTIDAD ACTUAL
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(int.parse("0xff$colorString")),
                        border: Border.all(color: Colors.white),                  
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 10.0, right: 10.0),

                        child: Widgettss().etiquetaText(titulo: data.data()['actual'].toString(),),
                      )
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          ultimoItem != true ?
            SizedBox(height: 0.0,)
            :
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),              
            )

        ],
      ),
    );
  }


  Widget productosMovil({DocumentSnapshot data,int index,bool ultimoItem,
                          String negocio,String oficina
                        }){

    String colorString = data.data()['color'] == null ? "fba21c" : data.data()['color'];

    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
        bottom: 10.0,
        left: 15.0,
        right: 10.0
      ),

      child: Column(
        children: [

          IntrinsicHeight(      
            child: GestureDetector(

              onTap: (){ 
                if(data.data()['color'] == '7f7f7f'){

                  modificarExistencia(
                    oficina: oficina,
                    negocio: negocio,
                    data: data
                  );
                }
              },

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  //NOMBRE PRODUCTO
                  Expanded(
                    flex: 2,

                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(int.parse("0xff$colorString")), //fba21c NARANJA
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25.0),
                        )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 5.0),

                        child: Align(
                          alignment: Alignment.centerLeft,
                          
                          child: Widgettss().etiquetaText(titulo: data.id,)
                        ),
                      )
                    ),
                  ),
                                    
                ],
              ),
            ),
          ),

          IntrinsicHeight(
            child: GestureDetector(
              
              onTap: (){ 
                if(data.data()['color'] == '7f7f7f'){

                  modificarExistencia(
                    oficina: oficina,
                    negocio: negocio,
                    data: data
                  );

                }
              },

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  //MEDIDA O UNIDAD
                  Expanded(

                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(int.parse("0xff$colorString")),
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25.0)
                        )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 5.0, right: 5.0),

                        child: Widgettss().etiquetaText(titulo: data.data()['medida'],),
                      )
                    ),
                  ),

                  //STOCK
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(int.parse("0xff$colorString")),
                          border: Border.all(color: Colors.white),  
                          borderRadius: BorderRadius.only()
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 10.0, right: 10.0),

                          child: Widgettss().etiquetaText(titulo: data.data()['stock'].toString(),),
                        )
                      ),
                    ),

                    //CANTIDAD ACTUAL
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(int.parse("0xff$colorString")),
                          border: Border.all(color: Colors.white),                  
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 10.0, right: 10.0),

                          child: Widgettss().etiquetaText(titulo: data.data()['actual'].toString(),),
                        )
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          ultimoItem != true ?
            SizedBox(height: 0.0,)
            :
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
            )

        ],
      ),
    );
  }


  modificarExistencia({String oficina,String negocio,DocumentSnapshot data}){

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

              SizedBox(height: 8.0),

              Input(
                etiqueta: 'Cantidad',
                controlador: cantidadControlador,
                tipo: TextInputType.number,

                next: (valor){
                  if(cantidadControlador.text != ''){
                    try {
                      double cantidadConversion = double.parse(cantidadControlador.text);

                      if(cantidadConversion > data.data()['stock']){
                          
                        return Mensajess().alertaMensaje('No puedes superar el stok');

                      } else {

                        data.reference.update({
                          'actual': cantidadConversion,
                          'color': "fba21c" //VERDE
                        });

                      }
                      
                      Get.back();

                    } catch (e) {

                    }
                      
                  }
                },
              ),

              SizedBox(height: 10.0,),
            ],
          ),
        ),
      )
    );

  }



}


  
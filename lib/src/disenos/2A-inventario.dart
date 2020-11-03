
//PANTALLA QUE SE VE CUANDO HACEN INVENTARIO

import 'package:almacen/src/services/2A.dart';
import 'package:almacen/src/widgets/widgettss.dart';
import 'package:almacen/src/widgets/input.dart';
import 'package:almacen/src/widgets/mensajes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class PantallaHacerInventario {

  
  Widget grupos(BuildContext context,String negocio){

    double width = MediaQuery.of(context).size.width;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('cholula')
                                        .doc(negocio)
                                        .collection('almacen')
                                        .orderBy('grupo')
                                        .snapshots(),
      builder: (context, snapshot){
        if (snapshot.data == null)
          return Center(child: CircularProgressIndicator()); 

        return ListView.builder(
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index){
             
            bool separar;
            bool ultimoItem;

            if(index != 0){
              if(snapshot.data.documents[index].data()['grupo'] 
                 != 
                snapshot.data.documents[index - 1].data()['grupo']
                ){
                  separar = true;
                }
            }

            if(index + 1 == snapshot.data.documents.length){
              ultimoItem = true;
            }

            return width < 580.0 ? 
              nombreMMovil(
                context, snapshot.data.documents[index], index, 
                separar, 
                ultimoItem,
                negocio
              )
              :
              nombre(
                context, snapshot.data.documents[index], index, 
                separar, 
                ultimoItem,
                negocio
              );

          }
        );
      },
    );
  }

  Widget nombre(BuildContext context,DocumentSnapshot data, 
                  int index, bool separar,bool ultimoItem,String negocio
              ){

    String colorString = data.data()['color'] == null ? "fba21c" : data.data()['color'];

    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
        bottom: 10.0,
        left: 30.0,
        right: 10.0
      ),

      child: Column(
        children: [    

          SizedBox(height: index == 0 ? 30.0 : 0.0,),
          
          separar != true ?
            SizedBox(height: 0.0,)
            :
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 30.0),
              child: Divider(thickness: 5.0, height: 5.0, color: Colors.black,)
            ),

          IntrinsicHeight(      
            child: GestureDetector(

              onTap: (){ 
                if(data.data()['color'] == '7f7f7f'){
                  modificarExistencia(context, negocio, data);
                }
              },

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  //NOMBRE PRODUCTO
                  Container(
                    
                    width: MediaQuery.of(context).size.width * 0.5,

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
              padding: const EdgeInsets.symmetric(vertical: 20.0),

              child: Widgettss().botonIcono(Icons.check_box, 50.0, () { 
                Services2A().verificarInventario(context, negocio);
              }),
            )

        ],
      ),
    );
  }


  Widget nombreMMovil(BuildContext context,DocumentSnapshot data, 
                  int index, bool separar,bool ultimoItem,String negocio
              ){

    String colorString = data.data()['color'] == null ? "fba21c" : data.data()['color'];

    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
        bottom: 10.0,
        left: 30.0,
        right: 10.0
      ),

      child: Column(
        children: [    

          SizedBox(height: index == 0 ? 30.0 : 0.0,),
          
          separar != true ?
            SizedBox(height: 0.0,)
            :
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 30.0),
              child: Divider(thickness: 5.0, height: 5.0, color: Colors.black,)
            ),

          IntrinsicHeight(      
            child: GestureDetector(

              onTap: (){ 
                if(data.data()['color'] == '7f7f7f'){
                  modificarExistencia(context, negocio, data);
                }
              },

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  //NOMBRE PRODUCTO
                  Expanded(
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
                  
                  //MEDIDA O UNIDAD
                  Container(
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
                                    
                ],
              ),
            ),
          ),

          IntrinsicHeight(
            child: GestureDetector(
              
              onTap: (){ 
                if(data.data()['color'] == '7f7f7f'){
                  modificarExistencia(context, negocio, data);
                }
              },

              child: Row(
                children: [
                  //STOCK
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
              padding: const EdgeInsets.symmetric(vertical: 20.0),

              child: Widgettss().botonIcono(Icons.check_box, 50.0, () { 

                Services2A().verificarInventario(context, negocio);
                
              }),
            )

        ],
      ),
    );
  }


  modificarExistencia(BuildContext context,String negocio,DocumentSnapshot data){

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

                        if(cantidadConversion > data.data()['stock']){
                          
                          return Mensajes().mensajeAlerta(context, 'No puedes superar el stok');

                        } else {

                          data.reference.update({
                            'actual': cantidadConversion,
                            'color': "22b14c" //VERDE
                          });

                        }
                        

                        Navigator.pop(context);

                      } catch (e) {

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



}
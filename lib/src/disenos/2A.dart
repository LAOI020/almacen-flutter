
import 'package:almacen/src/disenos/2A1B.dart';
import 'package:almacen/src/screens/1-inicio.dart';
import 'package:almacen/src/screens/2A1A-requisicionesRestaurant.dart';
import 'package:almacen/src/widgets/alertDialogPregunta.dart';
import 'package:almacen/src/widgets/widgettss.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DisenoUnidadNegocio {



  Widget soloMostrarGrupos({BuildContext context,String negocio,String nombreGrupo,
                            String colorContenedor,
                            bool verTotales,bool verProductos,
                            double stockDineroGrupo,double invDineroGrupo,double faltanteDineroGrupo,
                            VoidCallback onTapVerTotales,VoidCallback onLongTapVerProductos,
                            }){

    Size size = MediaQuery.of(context).size;

    String colorREF = colorContenedor == null ? "fba21c" : colorContenedor;
  
    final formatoMoneda = NumberFormat.simpleCurrency();

    return Padding(
      padding: EdgeInsets.all(15.0),

      child: GestureDetector(
        onTap: verProductos == true ? null : onTapVerTotales,
        onLongPress: onLongTapVerProductos,

        child: Container(
          decoration: BoxDecoration(
            color: Color(int.parse("0xff$colorREF")),
            border: Border.all(color: Colors.black, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(25.0))
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [

                Padding(
                  padding: const EdgeInsets.all(12.0),

                  child: Container(
                    child: Widgettss().etiquetaText(titulo: nombreGrupo, tamallo: 20.0, color: Colors.white,)
                  ),
                ),

                verTotales == false ? 
                  SizedBox(height: 0.0,)              
                  :
                  Column(
                  children: [
                    DisenoProductosGrupo().filasDetallesProducto(
                      valor1: 'STOCK',
                      valor2: 'INV',
                      valor3: 'FALTANTE'
                    ),
                    DisenoProductosGrupo().filasDetallesProducto(
                      valor1: formatoMoneda.format(stockDineroGrupo),
                      valor2: formatoMoneda.format(invDineroGrupo),
                      valor3: formatoMoneda.format(faltanteDineroGrupo)
                    ),
                  ],
                ),

                verProductos == false ?
                  SizedBox(height: 0.0,)
                  :
                  mostrarProductosResumidos(context, negocio, nombreGrupo),

                
                
                verTotales == true || verProductos == true ? SizedBox(height: 15.0,) : SizedBox(height: 0.0,)
              ],
            ),
          ),
        ),
      )
    );
  }



  Widget mostrarProductosResumidos(BuildContext context,String negocio,String nombreGrupo){

    double width = MediaQuery.of(context).size.width;
    
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('cholula')
                                        .doc(negocio)
                                        .collection('almacen')
                                        .where('grupo', isEqualTo: nombreGrupo)
                                        .snapshots(),
      builder: (context, snapshot){

        if (snapshot.data == null)
          return Center(child: CircularProgressIndicator()); 

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),

          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index){

            return width < 580.0 ? 
              cuerpoFirestoreProductoResumidoMMovil(
                snapshot.data.documents[index], 
                context, 
                index,
                negocio
              )
              :
              cuerpoFirestoreProductoResumido(
                snapshot.data.documents[index], 
                context, 
                index,
                negocio
              );
          }
        );
      },
    );
  }



  Widget cuerpoFirestoreProductoResumido(DocumentSnapshot data,BuildContext context, int index,
                                          String negocio
                                        ){

    final formatoMoneda = NumberFormat.simpleCurrency();
    int lenthhMedida = data.data()['medida'].toString().length;
    String medidaRecortado = data.data()['medida'].toString().substring(0, lenthhMedida);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),

      child: IntrinsicHeight(      
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            //NOMBRE PRODUCTO
            Container(

              width: MediaQuery.of(context).size.width * 0.4,
              
              decoration: BoxDecoration(
                color: Color(int.parse("0xfffba21c")), //fba21c NARANJA
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

            //PRECIO UNITARIO
            Container(
              
              width: MediaQuery.of(context).size.width * 0.15,

              decoration: BoxDecoration(
                color: Color(int.parse("0xfffba21c")),
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.only()
              ),
              
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 5.0, right: 5.0),

                child: Widgettss().etiquetaText(titulo: formatoMoneda.format(data.data()['precioUnitario'])),
              )
            ),
            
            //MEDIDA O UNIDAD
            Container(
              decoration: BoxDecoration(
                color: Color(int.parse("0xfffba21c")),
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.only()
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 5.0, right: 5.0),

                child: Widgettss().etiquetaText(titulo: medidaRecortado,),
              )
            ),
            
            //CANTIDAD ACTUAL
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(int.parse("0xfffba21c")),
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
                  color: Color(int.parse("0xfffba21c")),
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
    );
  }  

  Widget cuerpoFirestoreProductoResumidoMMovil(DocumentSnapshot data,BuildContext context, int index,
                                          String negocio
                                        ){

    final formatoMoneda = NumberFormat.simpleCurrency();
    int lenthhMedida = data.data()['medida'].toString().length;
    String medidaRecortado = data.data()['medida'].toString().substring(0, lenthhMedida);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),

      child: Column(
        children: [

          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                //NOMBRE PRODUCTO
                Expanded(
                  child: Container(              
                    decoration: BoxDecoration(
                      color: Color(int.parse("0xfffba21c")), //fba21c NARANJA
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                      )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 5.0),

                      child: Align(
                        alignment: Alignment.centerLeft,
                        
                        child: Widgettss().etiquetaText(titulo: data.id,)
                      ),
                    )
                  ),
                ),

                //PRECIO UNITARIO
                Container(
                  width: MediaQuery.of(context).size.width * 0.27,

                  decoration: BoxDecoration(
                    color: Color(int.parse("0xfffba21c")),
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.only()
                  ),
                  
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 5.0, right: 5.0),

                    child: Center(child: Widgettss().etiquetaText(titulo: formatoMoneda.format(data.data()['precioUnitario']))),
                  )
                ),
                                
              ],
            ),
          ),

          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //MEDIDA O UNIDAD
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(int.parse("0xfffba21c")),
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25.0)
                      )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 5.0, right: 5.0),

                      child: Widgettss().etiquetaText(titulo: medidaRecortado),
                    )
                  ),
                ),
                
                //CANTIDAD ACTUAL
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(int.parse("0xfffba21c")),
                      border: Border.all(color: Colors.white),                  
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 5.0, right: 5.0),

                      child: Center(child: Widgettss().etiquetaText(titulo: data.data()['stock'].toString(),)),
                    )
                  ),
                ),

                //CANTIDAD ACTUAL
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(int.parse("0xfffba21c")),
                      border: Border.all(color: Colors.white),                  
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 5.0, right: 5.0),

                      child: Center(child: Widgettss().etiquetaText(titulo: data.data()['actual'].toString(),)),
                    )
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }  

  

  Widget floatingBoton({BuildContext context,String negocio,
                        VoidCallback hacerInventario,VoidCallback hacerPedido
                      }){

    return FabCircularMenu(
      fabOpenIcon: Icon(Icons.menu, color: Colors.white,),
      fabCloseIcon: Icon(Icons.close, color: Colors.white),

      ringColor: Colors.white,
      fabColor: Colors.black,
      
      children: [
        //CERRAR SESION
        Widgettss().botonIcono(Icons.power_settings_new, 30.0, () {           

          AlertDialogPregunta().preguntarParaHacerRequisicion(
            context: context,
            titulo: 'Informacion',
            contenido: '¿Estas seguro de cerrar sesion',

            onPresSi: () async{            

              SharedPreferences preferences = await SharedPreferences.getInstance();
              preferences.clear();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => Inicio()
                ),
                (Route<dynamic> route) => false
              );
            }
          );

        }),
        
        //HACER INVENTARIO
        Widgettss().botonIcono(Icons.edit, 30.0, () {          
          
          AlertDialogPregunta().preguntarParaHacerRequisicion(
            context: context,
            titulo: negocio,
            contenido: '¿Quieres Hacer Inventario?',
            onPresSi: hacerInventario
          );
        }),
        
        //IR AL HISTORIAL DE PEDIDOS
        Widgettss().botonIcono(Icons.receipt, 30.0, () {          
          
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => RequisicionesRestaurant(negocio: negocio,)
          ));

        }),
        
        //HACER PEDIDO
        Widgettss().botonIcono(Icons.featured_play_list, 30.0, () {
          
          bool yaHizoPedidoHoy;

          //VERIFICAR SI YA HIZO ALGUUN PEDIDO EL DIA DE HOY
          FirebaseFirestore.instance
            .collection('cholula')
            .doc(negocio)
            .collection('requisiciones')
            .get().then((snapshot){

              for(DocumentSnapshot pedido in snapshot.docs){

                DateTime fecha = DateTime.now();
                String diaMesAnoDispositivo = DateFormat('dd-MM-yyyy').format(fecha);
                String diaMesAnoPedido = DateFormat('dd-MM-yyyy').format(DateTime.parse(pedido.data()['fechaDev']));
                
                if(diaMesAnoDispositivo == diaMesAnoPedido){
                  yaHizoPedidoHoy = true;
                }
              }

            }).then((value){
              
              if(yaHizoPedidoHoy == true){
                
                AlertDialogPregunta().ventanaYaSeHizoUnPedido(
                  context: context,
                  titulo: negocio,
                  onPresSi: hacerPedido
                );

              } else {

                AlertDialogPregunta().preguntarParaHacerRequisicion(
                  context: context,
                  titulo: negocio,
                  contenido: 'Estas seguro de hacer un pedido',
                  onPresSi: hacerPedido
                );
                
              }

            });


        }),
      ],
    );
  }
            
            /*FirebaseFirestore.instance
              .collection('cholula')
              .doc('cholula')
              .collection('almacen')
              .get().then((snapshot){

                for(DocumentSnapshot producto in snapshot.docs){

                  List<String> splitList = producto.id.replaceAll(" ", "").split(" ");
                  List<String> array = [];

                  for(int i = 0; i < splitList.length; i++){
                    for(int y = 1; y < splitList[i].length + 1; y++){
                      array.add(splitList[i].substring(0, y).toLowerCase());
                      print(array);
                    }
                  }

                  producto.reference.update({
                    'buscador': array
                  });

                }
              });*/
                
            

}
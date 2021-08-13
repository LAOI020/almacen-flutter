
import 'dart:ui';

import 'package:almacen/src/controladores/2A.dart';
import 'package:almacen/src/screens/2A1A-requisicionesRestaurant.dart';
import 'package:almacen/src/widgets/widgettss.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:almacen/src/disenos/2A-inventario.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';

class UnidadNegocio extends StatelessWidget {

  final String oficina;
  final String negocio;
  final String puestoPersona;

  UnidadNegocio({this.oficina, this.negocio, this.puestoPersona});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 191, 67, 1),

      body: GetBuilder<UnidadNegocioController>(
        id: 'principal',
        init: UnidadNegocioController(),
        builder: (_) {
         
          //PARA QUE SOLO SE EJECUTE UNA SOLA VEZ
          if (_.modificarInventario == null) {
            _.metodoInicial(oficina, negocio);
          }

          return _.modificarInventario == null ? 

            Center(child: CircularProgressIndicator())
            :
            SafeArea(
              child: _.modificarInventario == true ? 
                  PantallaHacerInventario(oficina: oficina, negocio: negocio)
                  : 
                  Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("images/fondoo.png"),
                          fit: BoxFit.cover)
                      ),
                      child: Stack(
                        children: [
                          //TODOS LOS PRODUTOS DIVIDIDOS POR GRUPO
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection(oficina)
                                .doc(negocio)
                                .collection('grupos')
                                .snapshots(),

                            builder: (context, snapshot) {
                              
                              if (snapshot.data == null) {
                                return Center(child: CircularProgressIndicator());
                              }

                              return ListView.builder(
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (context, index) {

                                  return MostrarSoloGrupo(
                                    nombreGrupo: snapshot.data.documents[index].id,
                                    indx: index,

                                    oficina: oficina,
                                    negocio: negocio,
                                  );

                                }
                              );
                            },
                          ),

                          //CONTENEDOR APPBAR BUSCAR PRODUCTO
                          BuscardorAppBar()
                        ],
                      ),
                    ),
            );
        },
      ),

      floatingActionButton: puestoPersona != 'finanzas' && 
                            puestoPersona != 'administracion' ? 
                              BotonFlotante()
                              :
                              Icon(Icons.block)

    );
  }
}

class BotonFlotante extends StatelessWidget {
  const BotonFlotante({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UnidadNegocioController>(
      id: 'botonFlotante',
      builder: (_){
        return FabCircularMenu(
          fabOpenIcon: Icon(Icons.menu, color: Colors.white,),
          fabCloseIcon: Icon(Icons.close, color: Colors.white),

          ringColor: Colors.white,
          fabColor: Colors.black,

          children: [
            //CERRAR SESION
            Widgettss().botonIcono(Icons.power_settings_new, 30.0, (){ 
              _.onTapIconoCerrarSesion();
            }),

            //HACER INVENTARIO
            Widgettss().botonIcono(Icons.edit, 30.0, (){ 
              _.onTapIconoHacerInventario();
            }),

            //IR AL HISTORIAL DE PEDIDOS
            Widgettss().botonIcono(Icons.receipt, 30.0, (){ 
              Get.to(RequisicionesRestaurant(
                oficina: _.oficina, negocio: _.negocio
              ));
            }),

            //HACER PEDIDO
            Widgettss().botonIcono(Icons.featured_play_list, 30.0, (){ 
              _.onTapIconoHacerPedido();
            })
          ],
        );
      }
    );
  }
}

class BuscardorAppBar extends StatelessWidget {
  const BuscardorAppBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UnidadNegocioController>(
      id: 'appBar',
      builder: (_){
        return Padding(
          padding: const EdgeInsets.all(4.0),

          child: Container(            
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20.0))
            ),

            child: Padding(
              padding: const EdgeInsets.only(right: 5.0),

              child: AutoCompleteTextField(
                key: null,       
                style: TextStyle(fontSize: 18.0),
                
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search)
                ),

                controller: _.buscarProductoControlador,
                                
                suggestions: _.listaProductosBuscados,

                itemFilter: (String item, consulta){
                  return item.toLowerCase().startsWith(consulta.toLowerCase());
                },
                itemSorter: (String a, b){
                  return a.compareTo(b);
                }, 
                itemSubmitted: (producto){
                  return _.onTapItemBarraBuscador(producto);
                }, 
                itemBuilder: (context, producto){
                  return Container(
                    margin: EdgeInsets.only(left: 6.0, right: 6.0, top: 20.0, bottom: 20.0),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      //borderRadius: BorderRadius.all(Radius.circular(25.0))
                    ),
                    child: Text(producto, style: TextStyle(fontSize: 17.0),),
                  );
                }, 
              ),
            ),
          ),
        );
      }
    );
  }
}


class MostrarSoloGrupo extends StatelessWidget {

  final String nombreGrupo;
  final int indx;
  final String oficina;
  final String negocio;

  const MostrarSoloGrupo({this.nombreGrupo,this.indx,this.oficina,this.negocio});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 8.0, 
        right: 8.0, 
        bottom: 15.0,
        top: indx == 0 ? 100.0 : 15.0
      ),

      child: GetBuilder<UnidadNegocioController>(
        id: "nombreGrupoPadre${indx.toString()}",
        builder: (_){
          
          return GestureDetector(
            onTap: (){
              _.onTapContenedorGrupo(indx);
            },
            onLongPress: (){
              //CUANDO OBTENGA LOS TOTALES, ABRE EL BOTTOM SHEET ESCRITO ABAJO
              _.obtenerTotalesGrupo(nombreGrupo);
            },

            child: Container(
            
              width: Get.width,

              decoration: BoxDecoration(
                color: Color(int.parse('0xff1565bf')),
                border: Border.all(color: Colors.black, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(25.0))
              ),

              child: Column(
                children: [

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 13.0),

                    child: Widgettss().etiquetaText(
                      titulo: nombreGrupo, tamallo: 20.0, color: Colors.white
                    ),
                  ),

                  GetBuilder<UnidadNegocioController>(
                    id: "nombreGrupoHijos${indx.toString()}",
                    builder: (_){
                      
                      return _.onPresNombresGrupos[indx] == false ?
                        SizedBox(height: 0.0,)
                        :
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                                    .collection(oficina)
                                    .doc(negocio)
                                    .collection('grupos')
                                    .doc(nombreGrupo)
                                    .collection('productos')
                                    .snapshots(),

                          builder: (context, snapshot) {
                                  
                            if (snapshot.data == null) {
                              return Center(child: CircularProgressIndicator());
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),

                              itemCount: snapshot.data.documents.length,
                              itemBuilder: (context, index) {

                                return Get.width < 580.0 ?                            
                                  ProductosUnidadNegocioMovil(
                                    doc: snapshot.data.documents[index],
                                    index: index,
                                  )
                                  :
                                  ProductosUnidadNegocio(
                                    doc: snapshot.data.documents[index],
                                    indx: index, 
                                  );
                              }
                            );
                          },
                        );
                    }
                  )

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


class ProductosUnidadNegocio extends StatelessWidget {

  final DocumentSnapshot doc;
  final int indx;

  const ProductosUnidadNegocio({this.doc, this.indx});

  @override
  Widget build(BuildContext context) {

    final formatoMoneda = NumberFormat.simpleCurrency();
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),

      child: IntrinsicHeight(      
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            //NOMBRE PRODUCTO
            Container(

              width: Get.width * 0.4,
              
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
                  
                  child: Widgettss().etiquetaText(titulo: doc.id,)
                ),
              )
            ),

            //PRECIO UNITARIO
            Container(
              
              width: Get.width * 0.15,

              decoration: BoxDecoration(
                color: Color(int.parse("0xfffba21c")),
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.only()
              ),
              
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 5.0, right: 5.0),

                child: Widgettss().etiquetaText(titulo: formatoMoneda.format(doc.data()['precioUnitario'])),
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

                child: Widgettss().etiquetaText(titulo: doc.data()['medida']),
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

                  child: Widgettss().etiquetaText(titulo: doc.data()['stock'].toString(),),
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

                  child: Widgettss().etiquetaText(titulo: doc.data()['actual'].toString(),),
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductosUnidadNegocioMovil extends StatelessWidget {

  final DocumentSnapshot doc;
  final int index;

  const ProductosUnidadNegocioMovil({this.doc,this.index});

  @override
  Widget build(BuildContext context) {

    final formatoMoneda = NumberFormat.simpleCurrency();

    return Padding(
      padding: EdgeInsets.all(10.0),

      child: Column(
        children: [

          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                //NOMBRE PRODUCTO
                Expanded(
                  flex: 2,
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
                        
                        child: Widgettss().etiquetaText(titulo: doc.id,)
                      ),
                    )
                  ),
                ),

                //PRECIO UNITARIO
                Expanded(
                  flex: 1,
                  child: Container(
                    //width: (Get.width * 0.27) + 20.0,

                    decoration: BoxDecoration(
                      color: Color(int.parse("0xfffba21c")),
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.only()
                    ),
                    
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 5.0, right: 5.0),

                      child: Center(
                        child: Widgettss().etiquetaText(
                          titulo: formatoMoneda.format(doc.data()['precioUnitario'])
                        )
                      ),
                    )
                  ),
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

                      child: Widgettss().etiquetaText(titulo: doc.data()['medida']),
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

                      child: Center(child: Widgettss().etiquetaText(titulo: doc.data()['stock'].toString(),)),
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

                      child: Center(child: Widgettss().etiquetaText(titulo: doc.data()['actual'].toString(),)),
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
}


bottomSheetTotalGrupo(String nombreGrupo,
                      double totalStock,double totalActual,double totalFaltante
                    ){
  
  final formatoMoneda = NumberFormat.simpleCurrency();

  return Get.bottomSheet(
    Container(
      height: Get.height * 0.3,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),

        child: Column(
          children: [
            SizedBox(height: Get.height * 0.02,),

            Widgettss().etiquetaText(titulo: nombreGrupo, tamallo: 20.0),

            IntrinsicHeight(            
              child: Row(
                children: [

                  //STOCK INV FALTA
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black)
                      ),

                      child: Center(                        
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),

                          child: Widgettss().etiquetaText(
                            titulo: 'STOCK',
                            tamallo: 16.0
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black)
                      ),

                      child: Center(                        
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),

                          child: Widgettss().etiquetaText(
                            titulo: 'INV',
                            tamallo: 16.0
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black)
                      ),

                      child: Center(                        
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),

                          child: Widgettss().etiquetaText(
                            titulo: 'FALTA',
                            tamallo: 16.0
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //DINEROS STOCK INV FALTA
            IntrinsicHeight(            
              child: Row(
                children: [

                  //STOCK
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black)
                      ),

                      child: Center(                        
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),

                          child: Widgettss().etiquetaText(
                            titulo: formatoMoneda.format(totalStock),
                            tamallo: 16.0
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black)
                      ),

                      child: Center(                        
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),

                          child: Widgettss().etiquetaText(
                            titulo: formatoMoneda.format(totalActual),
                            tamallo: 16.0
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black)
                      ),

                      child: Center(                        
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),

                          child: Widgettss().etiquetaText(
                            titulo: formatoMoneda.format(totalFaltante),
                            tamallo: 16.0
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      )
    )
  );

}


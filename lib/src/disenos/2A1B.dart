

import 'package:almacen/src/widgets/widgettss.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class DisenoProductosGrupo {


  Widget grupoEspecifico({DocumentSnapshot data, BuildContext context, int index,
                          bool verGrupoPerteneciente
                        }){    

    Size size = MediaQuery.of(context).size;
    double width = MediaQuery.of(context).size.width;
    
    final formatoMoneda = NumberFormat.simpleCurrency();

    int lenthhMedida = data.data()['medida'].toString().length;
    String medidaRecortado = data.data()['medida'].toString().substring(0, lenthhMedida);


    return width < 580.0 ? 
      grupoEspecificoMMovil(
        context: context,
        index: index,
        data: data,
        verGrupoPerteneciente: verGrupoPerteneciente
      )
      :
      Padding(
        padding: EdgeInsets.all(8.0),

        child: GestureDetector(
          onTap: (){ FocusScope.of(context).unfocus(); },
          child: Card(
            elevation: 10.0,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))
            ),

            child: Padding(
              padding: EdgeInsets.only(top: 15.0, left: 8.0, right: 8.0),

              child: Column(
                children: [

                  verGrupoPerteneciente != true ? 
                    SizedBox(height: 0.0,)
                    : 
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8.0),

                        child: Widgettss().etiquetaText(titulo: data.data()['grupo'] ?? ".",),
                      )
                    ),
              
                  IntrinsicHeight(      
                    child: Row(
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
                
                  SizedBox(height: size.height * 0.02,)
                ],
              ),
            ),
          ),
        ),
      );
  }


  Widget grupoEspecificoMMovil({DocumentSnapshot data, BuildContext context, int index,
                                bool verGrupoPerteneciente
                              }){ 

    Size size = MediaQuery.of(context).size;
    
    final formatoMoneda = NumberFormat.simpleCurrency();

    int lenthhMedida = data.data()['medida'].toString().length;
    String medidaRecortado = data.data()['medida'].toString().substring(0, lenthhMedida);

    return Padding(
      padding: EdgeInsets.all(8.0),

      child: GestureDetector(
        onTap: (){ FocusScope.of(context).unfocus(); },
        child: Card(
          elevation: 10.0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))
          ),

          child: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 8.0, right: 8.0),

            child: Column(
              children: [

                verGrupoPerteneciente != true ? 
                  SizedBox(height: 0.0,)
                  : 
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.0),

                      child: Widgettss().etiquetaText(titulo: data.data()['grupo'] ?? ".",),
                    )
                  ),
            
                IntrinsicHeight(      
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      //NOMBRE PRODUCTO
                      Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          decoration: BoxDecoration(
                            color: Color(int.parse("0xfffba21c")), //fba21c NARANJA
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

                      //PRECIO UNITARIO
                      Container(                      

                        width: size.width * 0.29,
                        
                        decoration: BoxDecoration(
                          color: Color(int.parse("0xfffba21c")),
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.only()
                        ),
                        
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 5.0, right: 5.0),

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
                            padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 5.0, right: 5.0),

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
                            padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 10.0, right: 10.0),

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
                            padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 10.0, right: 10.0),

                            child: Center(child: Widgettss().etiquetaText(titulo: data.data()['actual'].toString(),)),
                          )
                        ),
                      ),
                    ],
                  ),
                ),
               
                SizedBox(height: size.height * 0.02,)
              ],
            ),
          ),
        ),
      ),
    );
  }


  

  Widget filasDetallesProducto({double espacio, String valor1,String valor2,String valor3}){
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          
          SizedBox(width: espacio),

          Expanded(child: contenedorConBordes(
            colorContainer: Color.fromRGBO(251, 162, 29, 1),
            colorBorde: Colors.white,
            texto: valor1, 
            posicion: Alignment.center,
            radiusTopLeft: valor1[0] == 'S' ? 25.0 : 0.0,
            radiusBottomLeft: valor1[0] == '\$' ? 25.0 : 0.0
          )),
          Expanded(child: contenedorConBordes(
            colorContainer: Color.fromRGBO(251, 162, 29, 1),
            colorBorde: Colors.white,
            texto: valor2, 
            posicion: Alignment.center
          )),
          Expanded(child: contenedorConBordes(
            colorContainer: Color.fromRGBO(251, 162, 29, 1),
            colorBorde: Colors.white,
            texto: valor3, 
            posicion: Alignment.center,
            radiusTopRight: valor1[0] == 'S' ? 25.0 : 0.0,
            radiusBottomRight: valor1[0] == '\$' ? 25.0 : 0.0
          )),
        ],
      ),
    );
  }

  Widget contenedorConBordes({String texto,Color colorTexto,Color colorContainer,Color colorBorde,
                              Alignment posicion,
                              double radiusTopLeft,double radiusTopRight,double radiusBottomLeft,double radiusBottomRight
                            }){    

    return Container(

      decoration: BoxDecoration(
        color: colorContainer,
        border: Border.all(color: colorBorde),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radiusTopLeft ?? 0),
          topRight: Radius.circular(radiusTopRight ?? 0),
          bottomLeft: Radius.circular(radiusBottomLeft ?? 0),
          bottomRight: Radius.circular(radiusBottomRight ?? 0),
        )
      ),
      
      child: Padding(
        padding:  EdgeInsets.all(5.0),
                      
        child: Align(alignment: posicion, 
          child: Widgettss().etiquetaText(titulo: texto ?? '.', color: colorTexto, tamallo: 15.0,)
        ),
      ),
    );
  }


}
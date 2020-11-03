

import 'package:almacen/src/screens/2A-unidadNegocio.dart';
import 'package:almacen/src/screens/2B-requisicionesCedis.dart';
import 'package:almacen/src/widgets/widgettss.dart';
import 'package:almacen/src/widgets/input.dart';
import 'package:almacen/src/widgets/mensajes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DisenoInicio {

  final formatoMoneda = NumberFormat.simpleCurrency();
  


  Widget contenedorCedis(BuildContext context,VoidCallback onPresBoton){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onPresBoton,           
                              
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 60.0,

              decoration: BoxDecoration(
                color: Colors.blue[800],
                border: Border.all(color: Colors.black, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(25.0))
              ),

              child: Center(child: Widgettss().etiquetaText(titulo: 'Entrar', tamallo: 30.0, color: Colors.white,)),

            ),
          ),
        ],
      ),
    );
  }
  

  Widget infoNegocio({BuildContext context,
                      double totalStock,double totalActual,double totalFaltante,
                      VoidCallback onPresBotonEntrar
                    }){    

    Size size = MediaQuery.of(context).size;


    return Padding(
      padding: EdgeInsets.all(8.0),

      child: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 8.0, right: 8.0),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [                                  
                         
            //NOMBRE STOCK ACTUAL FALTANTE
            filasDetallesProducto(
              valor1: "STOCK",
              valor2: "INV",
              valor3: "FALTANTE"
            ),
                                      
            //DINEROS STOCK ACTUAL FALTANTE
            filasDetallesProducto(
              valor1: formatoMoneda.format(totalStock).toString(),
              valor2: formatoMoneda.format(totalActual).toString(),
              valor3: formatoMoneda.format(totalFaltante).toString()
            ),
            
            SizedBox(height: size.height * 0.02,),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),

              child: GestureDetector(
                onTap: onPresBotonEntrar,
                          
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 60.0,

                  decoration: BoxDecoration(
                    color: Colors.blue[800],
                    border: Border.all(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(25.0))
                  ),

                  child: Center(child: Widgettss().etiquetaText(titulo: 'Entrar', tamallo: 30.0, color: Colors.white,)),

                ),
              ),
            ),

          ],
        ),
      ),
    );
  }


  

  Widget filasDetallesProducto({String valor1,String valor2,String valor3}){
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

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
        
          child: Widgettss().etiquetaText(titulo: texto ?? '.', color: Colors.black, tamallo: 16.0,)
        ),
      ),
    );
  }


  ponerCodigoUnidadNegocio(BuildContext context,String negocioREF){

    TextEditingController codigoControlador = TextEditingController();

    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
          
          title: Text(negocioREF),
          
          content: SingleChildScrollView(
            child: Input(
              etiqueta: 'Codigo', 
              controlador: 
              codigoControlador, 
              tipo: TextInputType.number, 
              oscurecer: true,

              next: (value) async{ 
                FocusScope.of(context).nextFocus(); 

                final QuerySnapshot result = await FirebaseFirestore.instance
                    .collection('cholula')
                    .doc(negocioREF)
                    .collection('codigos')
                    .where('codigo', isEqualTo: codigoControlador.text)
                    .limit(1)
                    .get();
                
                final DocumentSnapshot finanzas = await FirebaseFirestore.instance
                    .collection('cholula')
                    .doc('finanzas')
                    .get();

                  
                final String codigoFinanzas = finanzas.data()['codigo'];
                final List<DocumentSnapshot> documents = result.docs;
                                  
                    if(documents.length == 1){

                      agregarValoresSharedPreferences(
                        negocio: negocioREF,
                        nombreCodigo: documents[0].id
                      );

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => negocioREF == 'cedis' ?
                                                RequisiconesCedis(
                                                  nombreCodigo: documents[0].id
                                                )
                                                :
                                                UnidadNegocio(
                                                  negocio: negocioREF,
                                                  nombreCodigo: documents[0].id,
                                                )
                        ),
                        (Route<dynamic> route) => false
                      );

                    } else {
                      
                      if(codigoFinanzas == codigoControlador.text){                        

                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => negocioREF == 'cedis' ? 
                                                  RequisiconesCedis(
                                                    nombreCodigo: 'finanzas',
                                                  )
                                                  :
                                                  UnidadNegocio(
                                                    negocio: negocioREF,
                                                    nombreCodigo: 'finanzas',
                                                  )
                        ));

                      } else {
                        Mensajes().mensajeAlerta(context, 'Codigo incorrecto');
                      }


                    }
              },
            ),
          ),
        );
      }
    );
  }

  void agregarValoresSharedPreferences({String nombreCodigo,String negocio}) async{
    SharedPreferences preferencias = await SharedPreferences.getInstance();
    preferencias.setString('nombreCodigo', nombreCodigo);
    preferencias.setString('negocio', negocio);
  }


}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class Widgettss {

  Widget botonIcono(IconData icono,double tamallo,VoidCallback onPres){
    return IconButton(
      iconSize: tamallo,
      icon: Icon(icono),
      onPressed: onPres,
    );
  }

  Widget etiquetaText({String titulo,double tamallo,Color color}){
    return Text(
      titulo,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: tamallo,
        color: color,
        fontWeight: FontWeight.w600,
        
      ),
    );
  }



  verDetallesProductoRojo(BuildContext context,DocumentSnapshot data){

    Size size = MediaQuery.of(context).size;
    double cantidadTotalPidio = double.parse(data.data()['pidio'].toString()) + double.parse(data.data()['falta'].toString());
    
    return showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0)
        )
      ),

      context: context, 
      builder: (context){
        return Container(
          height: size.height * 0.3,

          child: Padding(
            padding: EdgeInsets.only(
              top: 10.0,
              bottom: 10.0,
              left: 30.0,
              right: 30.0
            ),

            child: Column(
              children: [

                Row(
                  children: [

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)
                        ),
                        
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          
                          child: etiquetaText(
                            titulo: "Pidio",
                          ),
                        ),
                      ),
                    ),

                    Container(
                      
                      width: MediaQuery.of(context).size.width * 0.2,
                      
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black)
                      ),
                      
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        
                        child: etiquetaText(
                          titulo: cantidadTotalPidio.toStringAsFixed(2),
                        ),
                      ),
                    ),

                  ],
                ),

                Row(
                  children: [

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)
                        ),
                        
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          
                          child: etiquetaText(
                            titulo: "Le entregaron",
                          ),
                        ),
                      ),
                    ),

                    Container(
                      
                      width: MediaQuery.of(context).size.width * 0.2,
                      
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black)
                      ),
                      
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        
                        child: etiquetaText(
                          titulo: data.data()['pidio'].toString(),
                        ),
                      ),
                    ),

                  ],
                ),

                Row(
                  children: [

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)
                        ),
                        
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          
                          child: etiquetaText(
                            titulo: "Cancelo",
                          ),
                        ),
                      ),
                    ),

                    Container(

                      width: MediaQuery.of(context).size.width * 0.2,

                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black)
                      ),
                      
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        
                        child: etiquetaText(
                          titulo: data.data()['falta'].toString(),
                        ),
                      ),
                    ),

                  ],
                ),

              ],
            ),
          ),
        );
      }

    );

  }
  

}
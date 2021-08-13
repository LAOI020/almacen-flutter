
import 'package:almacen/src/screens/2A-unidadNegocio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';


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


  resultadoProductoBuscado({String oficina,String negocio,String grupo,String producto}) async{
        
    String medida;

    double precio;
    double cantidadActual;
    double stock;

    await FirebaseFirestore.instance
      .collection(oficina)
      .doc(negocio)
      .collection('grupos')
      .doc(grupo)
      .collection('productos')
      .doc(producto)
      .get().then((doc){
        medida = doc.data()['medida'];
        precio = doc.data()['precioUnitario'].toDouble();
        cantidadActual = doc.data()['actual'].toDouble();
        stock = doc.data()['stock'].toDouble();
      });

    return Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(12.0),

        child: Stack(
          overflow: Overflow.visible,
          alignment: Alignment.center,
          
          children: [
            Container(
              width: Get.width,
              height: 350.0,

              decoration: BoxDecoration(
                color: Color(int.parse('0xff1565bf')),
                borderRadius: BorderRadius.all(Radius.circular(25.0))
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  //NOMBRE PRODUCTO Y MEDIDA
                  Row(
                    children: [

                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 3.0)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),

                            child: Widgettss().etiquetaText(
                              titulo: "$producto", tamallo: 19.0, color: Colors.white
                            ),
                          )
                        ),
                      ),

                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 3.0)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),

                            child: Widgettss().etiquetaText(
                              titulo: "$medida", tamallo: 19.0, color: Colors.white
                            ),
                          )
                        ),
                      ),
                    ],
                  ),

                  //STOCK INVENTARIO PRECIO-UNITARIO
                  Row(
                    children: [

                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 3.0)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),

                            child: Widgettss().etiquetaText(
                              titulo: "Stock", tamallo: 18.0, color: Colors.white
                            ),
                          )
                        ),
                      ),

                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 3.0)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),

                            child: Widgettss().etiquetaText(
                              titulo: "Inv", tamallo: 18.0, color: Colors.white
                            ),
                          )
                        ),
                      ),

                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 3.0)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),

                            child: Widgettss().etiquetaText(
                              titulo: "P.U", tamallo: 19.0, color: Colors.white
                            ),
                          )
                        ),
                      ),

                    ],
                  ),

                  //CANTIDAD STOCK  CANTIDAD INVENTARIO  DINERO PRECIO-UNITARIO
                  Row(
                    children: [
                      
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 3.0)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),

                            child: Widgettss().etiquetaText(
                              titulo: stock.toString(),
                              tamallo: 18.0, 
                              color: Colors.white
                            ),
                          )
                        ),
                      ),

                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 3.0)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),

                            child: Widgettss().etiquetaText(
                              titulo: cantidadActual.toString(),
                              tamallo: 18.0, 
                              color: Colors.white
                            ),
                          )
                        ),
                      ),
                      
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 3.0)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),

                            child: Widgettss().etiquetaText(
                              titulo: NumberFormat.simpleCurrency().format(precio), 
                              tamallo: 18.0, 
                              color: Colors.white
                            ),
                          )
                        ),
                      ),

                    ],
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Widgettss().etiquetaText(titulo: grupo, tamallo: 18.0, color: Colors.white)
                  )

                ],                
              )
            ),

            Positioned(
              top: -60,

              child: Container(
                height: 110.0,
                width: 110.0,
                
                decoration: BoxDecoration(
                  color: Color(int.parse('0xff1565bf')),
                  borderRadius: BorderRadius.circular(100.0)
                ),
                child: Icon(Icons.note, color: Colors.white, size: 50.0)
              ),
            )
          ],
        ),
      )
    );
  }


  verDetallesProductoRojo(DocumentSnapshot data){

    double cantidadTotalPidio = double.parse(data.data()['pidio'].toString()) + double.parse(data.data()['falta'].toString());

    return Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
        ),
        
        height: Get.height * 0.3,

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
                      
                    width: Get.width * 0.2,
                      
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
                      
                    width: Get.width * 0.2,
                      
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

                    width: Get.width * 0.2,

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
      )
    );

  }


  finanzasVerTotalesNegocio(String oficina,List<String> negocios) async{
    

    List<double> stockDinerosNegocios = [];
    List<double> inventarioDinerosNegocios = [];
    List<double> faltanteDinerosNegocios = [];
    
    await Future.forEach(negocios, (String negocioo) async{

      double stockk = 0.000;
      double inventario = 0.000;
      double faltante = 0.000;
      
      await FirebaseFirestore.instance
        .collection(oficina)
        .doc(negocioo)
        .collection('grupos')
        .get().then((grupos) async{

          await Future.forEach(grupos.docs, (DocumentSnapshot grupo) async{
            
            await grupo.reference
            .collection('productos')
            .get().then((productos){

              for(DocumentSnapshot producto in productos.docs){

                double cantidadFaltante = 
                  double.parse(producto.data()['stock'].toString())
                  -
                  double.parse(producto.data()['actual'].toString());

                double dineroStock = 
                  double.parse(producto.data()['precioUnitario'].toString()) 
                  *
                  double.parse(producto.data()['stock'].toString());

                double dineroInventario = 
                  double.parse(producto.data()['precioUnitario'].toString()) 
                  *
                  double.parse(producto.data()['actual'].toString());

                double dineroFaltente =
                  double.parse(producto.data()['precioUnitario'].toString())
                  *
                  cantidadFaltante;
                
                stockk = stockk + dineroStock;
                inventario = inventario + dineroInventario;
                faltante = faltante + dineroFaltente;
              }
              
            });
            
          });

        });
      
      stockDinerosNegocios.add(stockk);
      inventarioDinerosNegocios.add(inventario);
      faltanteDinerosNegocios.add(faltante);

    });    

    return Get.bottomSheet(
      Container(
        height: Get.height * 0.6,

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
        ),

        child: ListView.builder(
          itemCount: negocios.length,
          itemBuilder: (context, index){

            return cuerpoTotalesNegocio(
              oficinaREF: oficina,
              nombreNegocio: negocios[index],
              stock: stockDinerosNegocios[index],
              inventario: inventarioDinerosNegocios[index],
              faltante: faltanteDinerosNegocios[index]
            );
          }
        ),
      )
    );

  }

  cuerpoTotalesNegocio({String oficinaREF,String nombreNegocio,
                        double stock,double inventario,double faltante
                      }){

    final formatoMoneda = NumberFormat.simpleCurrency();

    return Padding(
      padding: const EdgeInsets.all(8.0),

      child: Column(
        children: [
          Row(
            children: [
              Widgettss().etiquetaText(titulo: nombreNegocio, tamallo: 22.0),
              Spacer(),
              Widgettss().botonIcono(Icons.arrow_forward, 40.0, () { 

                Get.to(UnidadNegocio(
                  oficina: oficinaREF,
                  negocio: nombreNegocio,
                  puestoPersona: 'finanzas',
                ));

              })
            ],
          ),

          SizedBox(height: 10.0),

          IntrinsicHeight(
            child: Row(
              children: [
                //STOCK
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black)
                    ),
                    
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),

                      child: Center(
                        child: Widgettss().etiquetaText(titulo: 'Stock', tamallo: 16.0)
                      ),
                    ),
                  ),
                ),

                //INVENTARIO
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black)
                    ),
                    
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),

                      child: Center(
                        child: Widgettss().etiquetaText(titulo: 'Inv', tamallo: 16.0)
                      ),
                    ),
                  ),
                ),

                //FALTANTE
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black)
                    ),
                    
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),

                      child: Center(
                        child: Widgettss().etiquetaText(titulo: 'Falta', tamallo: 16.0)
                      ),
                    ),
                  ),
                ),
              ]
            ),
          ),

          IntrinsicHeight(
            child: Row(
              children: [
                //DINERO STOCK
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black)
                    ),
                    
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),

                      child: Center(
                        child: Widgettss().etiquetaText(
                          titulo: formatoMoneda.format(stock),
                          tamallo: 16.0
                        )
                      ),
                    ),
                  ),
                ),

                //DINERO INVENTARIO
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black)
                    ),
                    
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),

                      child: Center(
                        child: Widgettss().etiquetaText(
                          titulo: formatoMoneda.format(inventario),
                          tamallo: 16.0
                        )
                      ),
                    ),
                  ),
                ),

                //DINERO FALTANTE
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black)
                    ),
                    
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),

                      child: Center(
                        child: Widgettss().etiquetaText(
                          titulo: formatoMoneda.format(faltante),
                          tamallo: 16.0
                        )
                      ),
                    ),
                  ),
                ),
              ]
            ),
          ),

          

        ],
      ),
    );
  }
  

}
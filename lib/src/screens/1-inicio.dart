

import 'package:almacen/src/disenos/1.dart';
import 'package:almacen/src/services/providers.dart';
import 'package:almacen/src/widgets/widgettss.dart';
import 'package:almacen/src/widgets/noHayInternet.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class Inicio extends StatefulWidget {
  Inicio({Key key}) : super(key: key);

  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {

  
  double totalStockNegocio = 0.0;
  double totalActualNegocio = 0.0;
  double totalFaltanteNegocio = 0.0;

  String negocio = 'cedis';

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    var internetProvider = Provider.of<ClaseProviders>(context); 

    return internetProvider.internet == 'no' ? 
      NoHayInternet().sinInternet()
      :
      Scaffold(

      body: SingleChildScrollView(
        child: Container(
          height: size.height,

          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/fondoo.png"),
              fit: BoxFit.cover
            )
          ),

          child: Column(
            children: [

              SizedBox(height: size.height * 0.2),


              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('cholula')
                                            .doc('negocios')
                                            .collection('unidades')
                                            .orderBy('indx')
                                            .snapshots(),

                builder: (context, snapshot){
                                
                  if (snapshot.data == null)
                    return Center(child: CircularProgressIndicator());                    

                  return CarouselSlider.builder(
                    options: CarouselOptions(
                      enlargeCenterPage: true,
                      height: 150.0,
                      onPageChanged: (indx, _){
                        
                        setState((){
                          negocio = snapshot.data.documents[indx].id;
                          totalStockNegocio = 0.0;
                          totalActualNegocio = 0.0;
                          totalFaltanteNegocio = 0.0;
                        });

                        obtenerTotalesNegocio(negocio);

                      }
                    ),
                    itemCount: snapshot.data.documents.length, 
                    itemBuilder: (context, index){
                      return cuerpo(snapshot.data.documents[index], context, index);
                    }, 
                  );
                },
              ),

              SizedBox(height: 40.0),
              
              Container(
                width: MediaQuery.of(context).size.width,
                
                child: SafeArea(
                  child: negocio == 'cedis' ? 
                    DisenoInicio().contenedorCedis(
                      context, 
                      (){
                        DisenoInicio().ponerCodigoUnidadNegocio(context, 'cedis');
                        print(MediaQuery.of(context).size.width);
                      }
                    )
                    :
                    DisenoInicio().infoNegocio(
                      context: context,
                      totalStock: totalStockNegocio,
                      totalActual: totalActualNegocio,
                      totalFaltante: totalFaltanteNegocio,

                      onPresBotonEntrar: (){
                        DisenoInicio().ponerCodigoUnidadNegocio(context, negocio);
                      }
                    )
                ),
              ),
            

            ],
          ),
        ),
      ),
    );
  }

  //AlertDial().ponerCodigoUnidadNegocio(context, data.id);


  Widget cuerpo(DocumentSnapshot data, BuildContext context, int index){
    
    return Container(
      width: MediaQuery.of(context).size.width,

      decoration: BoxDecoration(
        color: Colors.blue[800],
        border: Border.all(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(25.0))
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Widgettss().etiquetaText(titulo: data.id.toUpperCase(), tamallo: 25.0, color: Colors.white,),
        ],
      )
    );
  }


  void obtenerTotalesNegocio(String nombreNegocio){

    if(nombreNegocio != 'cedis'){
    
      FirebaseFirestore.instance
      .collection('cholula')
      .doc(nombreNegocio)
      .collection('almacen')
      .get().then((snapshot){
        for(DocumentSnapshot producto in snapshot.docs){
          
          double cantidadFaltante = double.parse(producto.data()['stock'].toString()) - double.parse(producto.data()['actual'].toString());
          double actualDinero = double.parse(producto.data()['precioUnitario'].toString()) * producto.data()['actual'];
          double stockDinero = double.parse(producto.data()['precioUnitario'].toString()) * producto.data()['stock'];
          double faltanteDinero = double.parse(producto.data()['precioUnitario'].toString()) * cantidadFaltante;

          setState(() {
            totalStockNegocio = totalStockNegocio + stockDinero;
            totalActualNegocio = totalActualNegocio + actualDinero;
            totalFaltanteNegocio = totalFaltanteNegocio + faltanteDinero;
          });

        }
      });

    }
    

  }


}
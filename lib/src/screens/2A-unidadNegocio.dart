
import 'dart:async';

import 'package:almacen/src/disenos/2A-inventario.dart';
import 'package:almacen/src/disenos/2A.dart';
import 'package:almacen/src/disenos/2A1B.dart';
import 'package:almacen/src/services/2A.dart';
import 'package:almacen/src/services/providers.dart';
import 'package:almacen/src/services/tokens.dart';
import 'package:almacen/src/widgets/widgettss.dart';
import 'package:almacen/src/widgets/noHayInternet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rounded_floating_app_bar/rounded_floating_app_bar.dart';


class UnidadNegocio extends StatefulWidget {

  final String negocio;
  final String nombreCodigo;

  UnidadNegocio({this.negocio,this.nombreCodigo});

  @override
  _UnidadNegocioState createState() => _UnidadNegocioState();
}

class _UnidadNegocioState extends State<UnidadNegocio> {


  final formatoMoneda = NumberFormat.simpleCurrency();


  FocusNode foco = new FocusNode();
  
  bool modificarInventario;


  List<bool> onPresGrupo = [false];
  List<bool> onLongPresGrupo = [false];

  List<double> dineroTotalActual = [];
  List<double> dineroTotalFaltante = [];
  List<double> dineroTotalStock = [];

  String busquedaEspecifica = '';
  TextEditingController busquedaControlador = TextEditingController();
  
  @override
  void initState() {

    Tokens().iniciarNotificaciones(context);
    Tokens().verYactualizarToken(widget.negocio, widget.nombreCodigo);
    
    FirebaseFirestore.instance
      .collection('cholula')
      .doc(widget.negocio)
      .get().then((snap){
        setState(() {
          modificarInventario = snap.data()['hacerInventario'];
        });
      });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    var internetProvider = Provider.of<ClaseProviders>(context); 

    return internetProvider.internet == 'no' ? 
      NoHayInternet().sinInternet()
      :
      Scaffold(
      backgroundColor: Color.fromRGBO(255, 191, 67, 1),    
    
      body: SafeArea(

        child: modificarInventario == true ? 
          PantallaHacerInventario().grupos(context, widget.negocio)
          :
          NestedScrollView(
            headerSliverBuilder: (context, isInner){
              return [
                RoundedFloatingAppBar(
                  floating: true,
                  snap: true,

                  actions: [
                    Widgettss().botonIcono(Icons.cancel, 30.0, () {

                      FocusScope.of(context).unfocus();

                      setState(() {
                        busquedaControlador.text = '';
                        busquedaEspecifica = '';
                      });

                    })
                  ],

                  title: TextField(
                    decoration: InputDecoration(
                      hintText: 'BUSCAR',
                      border: InputBorder.none
                    ),
                    controller: busquedaControlador,

                    onChanged: (value){
                      setState(() => busquedaEspecifica = value.replaceAll(" ", ""));
                    },
                    onSubmitted: (v){ FocusScope.of(context).unfocus(); },
                  ),
                )
              ];
            },

            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/fondoo.png"),
                  fit: BoxFit.cover
                )
              ),

              child: StreamBuilder(
                stream: busquedaEspecifica == '' ? 
                                FirebaseFirestore.instance.collection('cholula')
                                  .doc(widget.negocio)
                                  .collection('grupos')
                                  .snapshots()

                                :

                                FirebaseFirestore.instance.collection('cholula')
                                  .doc(widget.negocio)
                                  .collection('almacen')
                                  .where('buscador', arrayContains: busquedaEspecifica)
                                  .snapshots(),

                builder: busquedaEspecifica == '' ? 
                  
                  (context, snapshot){

                  if (snapshot.data == null)
                    return Center(child: CircularProgressIndicator());  

                  if(onPresGrupo.length < snapshot.data.documents.length){
                    for(int i = 0; i < snapshot.data.documents.length ; i++){
                      onPresGrupo.add(false);
                      onLongPresGrupo.add(false);
                      dineroTotalStock.add(0.000);
                      dineroTotalActual.add(0.000);
                      dineroTotalFaltante.add(0.000);
                    } 
                  }

                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index){
                      
                      return DisenoUnidadNegocio().soloMostrarGrupos(
                        context: context,
                        negocio: widget.negocio,                
                        colorContenedor: snapshot.data.documents[index].data()['color'],

                        nombreGrupo: snapshot.data.documents[index].id,
                        
                        verProductos: onLongPresGrupo[index],
                        verTotales: onPresGrupo[index],

                        stockDineroGrupo: dineroTotalStock[index],
                        invDineroGrupo: dineroTotalActual[index],
                        faltanteDineroGrupo: dineroTotalFaltante[index],

                        onLongTapVerProductos: (){

                          setState(() {
                            onLongPresGrupo[index] = !onLongPresGrupo[index];
                          });

                        },

                        onTapVerTotales: (){   

                          FocusScope.of(context).unfocus();

                          setState(() {
                            dineroTotalStock[index] = 0.000;
                            dineroTotalActual[index] = 0.000;
                            dineroTotalFaltante[index] = 0.000;
                          });                  
                          
                          sacarTotalesDeGrupo(snapshot.data.documents[index].id, index);

                        },
                      );
                    }
                  );

                }

                :
                
                (context, snap){
                  
                  if (snap.data == null)
                    return Center(child: CircularProgressIndicator()); 

                  return ListView.builder(                          
                    itemCount: snap.data.documents.length,
                    itemBuilder: (context, index){
                              
                      return busquedaEspecifica.length < 2 ? 
                        SizedBox(height: 0.0,)
                        :
                        DisenoProductosGrupo().grupoEspecifico(
                          context: context, 
                          index: index,
                          verGrupoPerteneciente: true,                        

                          data: snap.data.documents[index], 
                                                                  
                        );
                    }, 
                  );
                }
              ),
            ),
          ),
      ),
      

      floatingActionButton: DisenoUnidadNegocio().floatingBoton(
        context: context, 
        negocio: widget.negocio,

        hacerInventario: (){

          Services2A().hacerInventario(context, widget.negocio);                    
          setState(() => modificarInventario = true);

        },

        hacerPedido: (){

          Services2A().crearPedidoo(context, widget.negocio).then((v){
            
            //PARA QUITAR LA VISTA INVENTARIO
            Timer(Duration(seconds: 4), (){
              
              FirebaseFirestore.instance
              .collection('cholula')
              .doc(widget.negocio)
              .get().then((value) => 
                setState(() => modificarInventario = value.data()['hacerInventario'])
              );
              
            });
            

          });
        }

      )

    );
  }

  
  void sacarTotalesDeGrupo(String nombreGrupo,int grupoREF){

    FirebaseFirestore.instance
      .collection('cholula')
      .doc(widget.negocio)
      .collection('almacen')      
      .where('grupo', isEqualTo: nombreGrupo)
      .get().then((snapshot){
        
        for(DocumentSnapshot producto in snapshot.docs){  
          
          double cantidadFaltante = double.parse(producto.data()['stock'].toString()) - double.parse(producto.data()['actual'].toString());
          double actualDinero = producto.data()['precioUnitario'] * producto.data()['actual'];
          double stockDinero = producto.data()['precioUnitario'] * producto.data()['stock'];
          double faltanteDinero = producto.data()['precioUnitario'] * cantidadFaltante;

          setState(() {
            dineroTotalStock[grupoREF] = dineroTotalStock[grupoREF] + stockDinero;
            dineroTotalActual[grupoREF] = dineroTotalActual[grupoREF] + actualDinero;
            dineroTotalFaltante[grupoREF] = dineroTotalFaltante[grupoREF] + faltanteDinero;
          });
          
        }

      }).then((value){

        setState(() {
          onLongPresGrupo[grupoREF] = false;
          onPresGrupo[grupoREF] = !onPresGrupo[grupoREF];
        });

      });

      
  }

}
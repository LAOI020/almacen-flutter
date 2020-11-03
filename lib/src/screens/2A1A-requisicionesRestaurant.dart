

import 'package:almacen/src/disenos/2A1A.dart';
import 'package:almacen/src/services/providers.dart';
import 'package:almacen/src/widgets/widgettss.dart';
import 'package:almacen/src/widgets/noHayInternet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class RequisicionesRestaurant extends StatefulWidget {

  final String negocio;

  RequisicionesRestaurant({this.negocio});

  @override
  _RequisicionesRestaurantState createState() => _RequisicionesRestaurantState();
}

class _RequisicionesRestaurantState extends State<RequisicionesRestaurant> {

  List<bool> onPresRequisicion = [];

  @override
  Widget build(BuildContext context) {

    var internetProvider = Provider.of<ClaseProviders>(context); 

    return internetProvider.internet == 'no' ? 
      NoHayInternet().sinInternet()
      :
      Scaffold(

      appBar: AppBar(
        backgroundColor: Color(int.parse('0xff1565bf')),
        centerTitle: true,
        title: Text('Pedidos'),
      ),

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/fondoo.png"),
            fit: BoxFit.cover
          )
        ),

        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('cholula')
                                            .doc('cholula')
                                            .collection('requisiciones')
                                            .orderBy('SePidio', descending: true)
                                            .snapshots(),
          builder: (context, snapshot){

            if (snapshot.data == null)
              return Center(child: CircularProgressIndicator()); 

            if(onPresRequisicion.length < snapshot.data.documents.length){
              for(int i = 0; i < snapshot.data.documents.length; i++){
                onPresRequisicion.add(false);
              } 
            }

            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index){             

                return DisenoRequisicionesRestaurant().mostrarSoloFolio(
                  context: context,
                  negocioREF: widget.negocio,      

                  data: snapshot.data.documents[index],

                  verDetalles: onPresRequisicion[index],

                  onLongPresVerDetalles: (){

                    setState(() {
                      onPresRequisicion[index] = !onPresRequisicion[index];
                    });
                    
                  }

                );
              }
            );

          },
        ),
      ),
    );
  }

  Widget cuerpoRequisicion(DocumentSnapshot data, BuildContext context, int index){
    return Padding(
      padding: EdgeInsets.all(10.0),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.all(Radius.circular(25.0))
        ),

        child: Column(
          children: [
            SizedBox(height: 15.0),
            Widgettss().etiquetaText(titulo: data.id),
            SizedBox(height: 15.0)
          ],
        ),
      ),
    );
  }

}

import 'package:almacen/src/disenos/2B.dart';
import 'package:almacen/src/screens/1-inicio.dart';
import 'package:almacen/src/services/2B-archivoExcel.dart';
import 'package:almacen/src/services/providers.dart';
import 'package:almacen/src/services/tokens.dart';
import 'package:almacen/src/widgets/alertDialogPregunta.dart';
import 'package:almacen/src/widgets/widgettss.dart';
import 'package:almacen/src/widgets/input.dart';
import 'package:almacen/src/widgets/mensajes.dart';
import 'package:almacen/src/widgets/noHayInternet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RequisiconesCedis extends StatefulWidget {
  
  final String nombreCodigo;

  RequisiconesCedis({this.nombreCodigo});

  @override
  _RequisiconesCedisState createState() => _RequisiconesCedisState();
}

class _RequisiconesCedisState extends State<RequisiconesCedis> {

  List<bool> onPresRequisicion = [];

  bool vistaRepartidor = true;

  @override
  void initState() {
    
    Tokens().iniciarNotificaciones(context);
    Tokens().verYactualizarToken('cedis', widget.nombreCodigo);
    
    super.initState();
  }

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
        title: Text('Cedis'),

        leading: Widgettss().botonIcono(Icons.power_settings_new, 30.0, () {           

          AlertDialogPregunta().preguntarParaHacerRequisicion(
            context: context,
            titulo: 'Informacion',
            contenido: '¿Estas seguro de cerrar sesion?',
            
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

        actions: [
          
          GestureDetector(
            child: Icon(Icons.remove_red_eye, size: 30.0,),

            onTap: (){ vistaDetalladaCedis(); },
            
            onLongPress: (){ Service2B().ventana(context); },
          )
        ],
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
                                            .doc('cedis')
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

                return DisenoCedis().mostrarSoloFolio(
                  context: context,      

                  vistaRepartidor: vistaRepartidor,

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


  vistaDetalladaCedis(){

    TextEditingController codigoControlador = TextEditingController();

    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0))
          ),
          title: Text('Cedis'),
          content: Input(
            etiqueta: 'Codigo',
            controlador: codigoControlador,
            oscurecer: true,
            tipo: TextInputType.number,

            next: (valor){
              FirebaseFirestore.instance
                .collection('cholula')
                .doc('cedis')
                .collection('codigos')
                .doc('gerente')
                .get().then((doc){

                  if(codigoControlador.text == doc.data()['codigo']){
                    setState(() {
                      vistaRepartidor = false;
                    });

                    Navigator.pop(context);
                    Mensajes().mensajeAlerta(context, 'Listo');

                  } else {
                    Mensajes().mensajeAlerta(context, 'Codigo Incorrecto');
                  }

                });
            },
          ),
        );
      }
    );
  }


}
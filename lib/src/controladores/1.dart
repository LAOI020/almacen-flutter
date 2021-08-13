
import 'package:almacen/src/screens/2A-unidadNegocio.dart';
import 'package:almacen/src/screens/2B-requisicionesCedis.dart';
import 'package:almacen/src/widgets/mensajes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InicioController extends GetxController {


  double widthContenedor = 0.0;

  String codigoValor = '';

  bool circuloProgreso = false;


  @override
  void onReady() {    
    super.onReady(); 
    this.widthContenedor = Get.width;
    update(['inputs']);
  }

  //USADO EN EL ON CHANGED DEL TEXT FIELD
  void codigoControlador(String texto){
    this.codigoValor = texto;
  }

  //USADO EN EL ONPRESS DEL ICONBUTTON FLECHA
  void verificarCodigo() async{  

    if(this.codigoValor != ''){
      
      //DA LA APARIENCIA DE QUE ESTA CARGANDO LA PANTALLA
      this.circuloProgreso = true;
      update(['inputs']);

      final QuerySnapshot result = await FirebaseFirestore.instance
                      .collection('USUARIOS')
                      .doc('appAlmacen')
                      .collection('usuarios')
                      .where('codigo', isEqualTo: this.codigoValor)
                      .limit(1)
                      .get();
      
      final List<DocumentSnapshot> documents = result.docs;

      if(documents.length == 1){

        agregarValoresSharedPreferences(
          puestoPersona: documents[0].data()['puesto'],
          oficina: documents[0].data()['oficina'],
          negocio: documents[0].data()['negocio']
        );

        if(documents[0].data()['negocio'] == 'cedis' || 
            documents[0].data()['puesto'] == 'finanzas' ||
            documents[0].data()['puesto'] == 'administracion'
        ){          

          Get.offAll(RequisicionesCedis(
            oficina: documents[0].data()['oficina'],
            puestoPersona: documents[0].data()['puesto']
          ));

        } else {

          Get.offAll(UnidadNegocio(
            oficina: documents[0].data()['oficina'],
            negocio: documents[0].data()['negocio'],
            puestoPersona: documents[0].data()['puesto'],
          ));
        }

      } else {//CODIGO INCORRECTO

        this.circuloProgreso = false;
        update(['inputs']);

        Mensajess().alertaMensaje('Codigo incorrecto');

      }

    }    

  }

  void agregarValoresSharedPreferences({String puestoPersona,String negocio,String oficina}) async{
      
    SharedPreferences preferencias = await SharedPreferences.getInstance();
    preferencias.setString('puestoPersona', puestoPersona);
    preferencias.setString('oficina', oficina);
    preferencias.setString('negocio', negocio);

  }

}
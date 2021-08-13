
import 'package:almacen/src/services/tokens.dart';
import 'package:almacen/src/widgets/mensajes.dart';
import 'package:almacen/src/widgets/widgettss.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/state_manager.dart';
import 'package:get/route_manager.dart';

class CedisController extends GetxController {

  bool pantallaCargada;

  String oficina = '';

  bool vistaRepartidor = true;

  List<bool> onPresDetallesPedido = [];


  void metodoInicial(String oficinaREF,String puestoPersona){

    this.oficina = oficinaREF;

    Tokens().iniciarNotificaciones();
    Tokens().verYactualizarToken(oficinaREF, 'cedis', puestoPersona);

    FirebaseFirestore.instance
      .collection(oficinaREF)
      .doc('cedis')
      .collection('requisiciones')
      .get().then((pedidos){

        for(DocumentSnapshot pedido in pedidos.docs){
          onPresDetallesPedido.add(false);
        }
      }).then((value){
        this.pantallaCargada = true;
        update();
      });
  }

  void onTapIconoFinanzas() async{

    List<String> negociosREFS = [];

    await FirebaseFirestore.instance
      .collection(this.oficina)
      .doc('NEGOCIOS')
      .collection('negocios')
      .get().then((negocioss){
        for(DocumentSnapshot negocio in negocioss.docs){
          negociosREFS.add(negocio.id);
        }
      });

    Widgettss().finanzasVerTotalesNegocio(oficina, negociosREFS);
    
  }


  void verificarCodigoVistaDetallada(String codigo){
    
    FirebaseFirestore.instance
      .collection(this.oficina)
      .doc('cedis')
      .collection('codigos')
      .doc('gerente')
      .get().then((doc){

        if(codigo == doc.data()['codigo']){
          
          this.vistaRepartidor = false;
          update();

          Get.back();
          Mensajess().alertaMensaje('Listo');

        } else {
          Mensajess().alertaMensaje('Codigo Incorrecto');
        }

      });
  }


  void onLongPresVerDetalles(String id,int indx){
    this.onPresDetallesPedido[indx] = !this.onPresDetallesPedido[indx];
    update([id]);
  }


}
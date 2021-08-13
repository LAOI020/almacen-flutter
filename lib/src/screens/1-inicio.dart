
import 'package:almacen/src/controladores/1.dart';
import 'package:almacen/src/widgets/widgettss.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Inicio extends StatelessWidget {
  const Inicio({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GetBuilder<InicioController>(
      init: InicioController(),
      builder: (_) {
      
        return Scaffold(
          body: Stack(
            children: [

              
              //FONDO NARANJA
              SingleChildScrollView(                
                child: Container(             
                  height: Get.height,
                  width: Get.width,   

                  color: Color(int.parse('0xfffba21c'))           
                ),
              ),

              //CONTENEDOR COLOR BLANCO
              SingleChildScrollView(
                child: Container(             
                  height: Get.height,
                  width: Get.width,   

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(350.0)
                    )
                  ),
                ),
              ),

              //CIRCULO AZUL
              Positioned(
                top: - Get.height * 0.1,
                left: - Get.width * 0.1,
                
                child: Container(
                  height: Get.width > 580.0 ? Get.height * 0.5 : Get.height * 0.4,
                  width: Get.width > 580.0 ? Get.height * 0.5 : Get.height * 0.4,
                  
                  decoration: BoxDecoration(
                    color: Color(int.parse('0xff1565bf')),
                    borderRadius: BorderRadius.circular(180.0)
                  ),
                ),
              ),

              //CIRCULO NARANJA
              Positioned(
                top: - Get.height * 0.1,
                right: - Get.width * 0.1,
                
                child: Container(
                  height: Get.width > 580.0 ? Get.height * 0.4 : Get.height * 0.3,
                  width: Get.width > 580.0 ? Get.height * 0.4 : Get.height * 0.3,
                  
                  decoration: BoxDecoration(
                    color: Color(int.parse('0xfffba21c')),
                    borderRadius: BorderRadius.circular(250.0)
                  ),
                ),
              ),

              
              //BOTON INGRESAR
              SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Padding(
                  padding:  EdgeInsets.only(
                    top: Get.height * 0.85,
                    left: Get.width > 580.0 ? Get.width * 0.88 : Get.width * 0.82
                  ),
                  child: Widgettss().botonIcono(Icons.arrow_forward_ios, 50.0, () { 
                    _.verificarCodigo();
                  }),
                )
              ),


              //CONTENEDOR CON LOS INPUTS
              SingleChildScrollView(
                child: GetBuilder<InicioController>(
                  id: 'inputs',
                  builder: (_) {
                    return Align(
                      alignment: Alignment.centerRight,

                      child: AnimatedContainer(                        
                        width: _.widthContenedor,

                        duration: Duration(seconds: 2),
                        
                        
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),

                          child: _.circuloProgreso == true ? 
                          
                            Center(child: CircularProgressIndicator())
                            :
                            Column(
                              children: [
                                SizedBox(height: Get.height * 0.35),                                                                                              

                                Card(
                                  elevation: 15.0,
                                  
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(20.0))
                                  ),

                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0,
                                      bottom: 12.0
                                    ),

                                    child: TextField(
                                      obscureText: true,
                                      textAlign: TextAlign.center,
                                      
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(fontSize: 18.0),
                                        hintText: 'Codigo'
                                      ),
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.number,

                                      onSubmitted: (texto){
                                        print(texto);
                                        _.codigoControlador(texto);
                                      },

                                    ),
                                  ),
                                ),

                              ],
                            ),
                        )
                      ),
                    );
                  },
                ),
              ),

            ],
          ),
        );
      },
    );
  }
}



import 'package:flutter/material.dart';

class Input extends StatelessWidget {

 final String etiqueta;
 final TextEditingController controlador;
 final TextInputType tipo;
 final bool oscurecer;
 final Function next;
 
 const Input({this.etiqueta,this.controlador,this.tipo,this.oscurecer,this.next});

  @override
  Widget build(BuildContext context) {
    return TextField(
      textInputAction: TextInputAction.next,
      onSubmitted: next,
      decoration: InputDecoration(
        labelStyle: TextStyle(fontSize: 17.0),
        labelText: etiqueta,
      ),
      //maxLines: null,
      keyboardType: tipo,
      controller: controlador,
      textAlign: TextAlign.center,
      obscureText: oscurecer == null ? false : true,
    );
  }
  
}
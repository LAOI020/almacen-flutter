

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Mensajes {

  mensajeAlerta(BuildContext context,String titulo){
    
    return CoolAlert.show(
      context: context, 
      type: CoolAlertType.info,
      text: titulo
    );
    
  }

}
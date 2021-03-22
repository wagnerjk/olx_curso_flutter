import 'package:flutter/material.dart';
import 'package:validadores/Validador.dart';

class DropDownFormField extends StatelessWidget {

  final List<DropdownMenuItem<String>> listaItensDrop;
  final Function onSaved;
  final Function onChanged;
  final String value;

  DropDownFormField({this.listaItensDrop, this.onSaved, this.onChanged, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: DropdownButtonFormField(
        onSaved: this.onSaved,
        onChanged: this.onChanged,
        value: this.value,
        style: Theme.of(context).textTheme.caption.copyWith(fontSize: 20, color: Colors.black),
        items: this.listaItensDrop,
        validator: (valor){
          return Validador()
              .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
              .valido(valor);
        },
      ),
    );
  }
}

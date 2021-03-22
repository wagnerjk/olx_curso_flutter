import 'package:flutter/material.dart';

class DropDownCustomizado extends StatelessWidget {

  final String itemSelecionado;
  final List<DropdownMenuItem<String>> listaItensDrop;
  final Function funcao;

  DropDownCustomizado({this.itemSelecionado, this.listaItensDrop, this.funcao});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Center(
        child: DropdownButton(
          iconEnabledColor: Theme.of(context).primaryColor,
          value: this.itemSelecionado,
          items: this.listaItensDrop,
          style: Theme.of(context).textTheme.caption.copyWith(fontSize: 22),
          onChanged: this.funcao,
        ),
      ),
    );
  }
}

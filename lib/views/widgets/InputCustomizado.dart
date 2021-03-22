import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputCustomizado extends StatelessWidget {

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final bool autofocus;
  final TextInputType keyboardType;
  final int maxLines;
  final List<TextInputFormatter> inputFormatters;
  final Function(String) validator;
  final Function(String) onSaved;
  final Function(String) onChanged;
  final TextCapitalization textCapitalization;


  InputCustomizado({
    this.controller,
    @ required this.hint,
    this.obscure = false,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.maxLines,
    this.inputFormatters,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: this.controller,
      obscureText: this.obscure,
      autofocus: this.autofocus,
      keyboardType: this.keyboardType,
      maxLines: this.maxLines,
      inputFormatters: this.inputFormatters,
      validator: this.validator,
      onSaved: this.onSaved,
      onChanged: this.onChanged,
      textCapitalization: this.textCapitalization,
      style: TextStyle(fontSize: 20),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
          hintText: this.hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6)
          )
      ),
    );
  }
}

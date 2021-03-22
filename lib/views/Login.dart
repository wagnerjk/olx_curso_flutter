import 'package:flutter/material.dart';
import 'package:olx/RouteGenerator.dart';
import 'package:olx/models/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:olx/views/widgets/BotaoCustomizado.dart';
import 'package:olx/views/widgets/InputCustomizado.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _controllerEmail = TextEditingController(text: "wagnerjk91@gmail.com");
  TextEditingController _controllerSenha = TextEditingController(text: "123456");

  final FirebaseAuth auth = FirebaseAuth.instance;

  String _mensagemErro = "";

  _logarUsuario(Usuario usuario){

    auth.signInWithEmailAndPassword(
      email: usuario.email,
      password: usuario.senha
    ).then((firebaseUser){
      Navigator.pushReplacementNamed(context, "/");
    });

  }

  _validarCampos(){

    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (email.isNotEmpty && email.contains("@")){
      if (senha.isNotEmpty && senha.length >=6){

        Usuario usuario = Usuario();
        usuario.email = email;
        usuario.senha = senha;

        _logarUsuario(usuario);

      } else {
        _mensagemErro = "A senha deve ter ao menos 6 caracteres";
      }
    } else {
      setState(() {
        _mensagemErro = "Insira um e-mail válido!";
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                InputCustomizado(
                  controller: _controllerEmail,
                  hint: "E-mail",
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                ),
                InputCustomizado(
                  controller: _controllerSenha,
                  hint: "Senha",
                  obscure: true,
                  maxLines: 1,
                ),
                SizedBox(height: 20,),
                BotaoCustomizado(
                  texto: "Entrar",
                  onPressed: (){
                    _validarCampos();
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Center(
                    child: GestureDetector(
                      onTap: (){
                        Navigator.pushNamed(context, RouteGenerator.ROTA_CADASTRO);
                      },
                      child: Text("Não tem uma conta? Clique aqui para criar."),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    _mensagemErro,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:olx/views/Anuncios.dart';
import 'package:olx/views/Cadastro.dart';
import 'package:olx/views/DetalhesAnuncio.dart';
import 'package:olx/views/Login.dart';
import 'package:olx/views/MeusAnuncios.dart';
import 'package:olx/views/NovoAnuncio.dart';

class RouteGenerator {

  static const String ROTA_LOGIN = "/login";
  static const String ROTA_CADASTRO = "/cadastro";
  static const String ROTA_MEUSANUNCIOS = "/meus-anuncios";
  static const String ROTA_NOVOANUNCIO = "/novo-anuncio";
  static const String ROTA_DETALHESANUNCIO = "/detalhes-anuncio";

  static Route<dynamic> generateRoute(RouteSettings settings) {

    final args = settings.arguments;

    switch(settings.name){
      case "/" :
        return MaterialPageRoute(
          builder: (_) => Anuncios()
        );
      case ROTA_LOGIN :
        return MaterialPageRoute(
            builder: (_) => Login()
        );
      case ROTA_CADASTRO :
        return MaterialPageRoute(
            builder: (_) => Cadastro()
        );
      case ROTA_MEUSANUNCIOS :
        return MaterialPageRoute(
            builder: (_) => MeusAnuncios()
        );
      case ROTA_NOVOANUNCIO :
        return MaterialPageRoute(
            builder: (_) => NovoAnuncio()
        );
      case ROTA_DETALHESANUNCIO :
        return MaterialPageRoute(
            builder: (_) => DetalhesAnuncio(args)
        );
      default:
        _erroRota();
    }
  }

  static Route<dynamic> _erroRota(){

    return MaterialPageRoute(
      builder: (_){
        return Scaffold(
          appBar: AppBar(
            title: Text("Tela não encontrada!"),
          ),
          body: Center(
            child: Text("Tela não encontrada!"),
          ),
        );
      }
    );

  }

}
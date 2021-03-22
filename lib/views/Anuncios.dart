import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:olx/RouteGenerator.dart';
import 'package:olx/models/Anuncio.dart';
import 'package:olx/utils/Configuracoes.dart';
import 'package:olx/views/widgets/DropDownCustomizado.dart';
import 'package:olx/views/widgets/ItemAnuncio.dart';

class Anuncios extends StatefulWidget {
  @override
  _AnunciosState createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  List<DropdownMenuItem<String>> _listaItensDropCategorias;
  List<DropdownMenuItem<String>> _listaItensDropEstados;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  String _itemSelecionadoEstado;
  String _itemSelecionadoCategoria;

  List<String> itensMenu = [];

  _escolhaMenuItem(String itemEscolhido){

    switch(itemEscolhido){
      case "Meus anúncios" : 
        Navigator.pushNamed(context, RouteGenerator.ROTA_MEUSANUNCIOS);
        break;
      case "Entrar/Cadastrar" :
        Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_LOGIN);
        break;
      case "Deslogar" :
        _deslogarUsuario();
        break;
    }

  }

  _deslogarUsuario() async {

    await auth.signOut();

    //Navigator.pushNamed(context, RouteGenerator.ROTA_LOGIN);
    _verificarUsuarioLogado();

  }

  Future _verificarUsuarioLogado() async {

    User usuarioLogado = await auth.currentUser;

    if(usuarioLogado == null) {
      itensMenu = [
        "Entrar/Cadastrar"
      ];
    } else {
      itensMenu = [
        "Meus anúncios", "Deslogar"
      ];
    }

  }

  _carregarItenDropdown(){

    _listaItensDropCategorias = Configuracoes.getCategorias();

    _listaItensDropEstados = Configuracoes.getEstados();

  }

  Future <Stream<QuerySnapshot>> _adicionarListenerAnuncios() async {

    Stream<QuerySnapshot> stream = db
        .collection("anuncios")
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });

  }

  Future <Stream<QuerySnapshot>> _filtrarAnuncios() async {

    FirebaseFirestore bd = FirebaseFirestore.instance;
    Query query = bd.collection("anuncios");

    if( _itemSelecionadoEstado != null ){
      query = query.where("estado", isEqualTo: _itemSelecionadoEstado);
    }
    if( _itemSelecionadoCategoria != null ){
      query = query.where("categoria", isEqualTo: _itemSelecionadoCategoria);
    }

    Stream<QuerySnapshot> stream = query.snapshots();
    stream.listen((dados){
      _controller.add(dados);
    });

  }

  @override
  void initState() {
    super.initState();
    _carregarItenDropdown();
    _verificarUsuarioLogado();
    _adicionarListenerAnuncios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OLX",
          style: Theme.of(context).textTheme.headline6.copyWith(
              color: Colors.white),),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context){
              return itensMenu.map((String item){
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item)
                );
              }).toList();
            }
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropDownCustomizado(
                    itemSelecionado: _itemSelecionadoEstado,
                    listaItensDrop: _listaItensDropEstados,
                    funcao: (estado) {
                      setState(() {
                        _itemSelecionadoEstado = estado;
                        _filtrarAnuncios();
                      });
                    }),
                ),
                Container(
                  color: Colors.grey[200],
                  width: 2,
                  height: 50,
                ),
                Expanded(
                  child:DropDownCustomizado(
                      itemSelecionado: _itemSelecionadoCategoria,
                      listaItensDrop: _listaItensDropCategorias,
                      funcao: (categoria) {
                        setState(() {
                          _itemSelecionadoCategoria = categoria;
                          _filtrarAnuncios();
                        });
                      }),
                )
              ],
            ),
            StreamBuilder(
              stream: _controller.stream,
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.none :
                  case ConnectionState.waiting :
                    return Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          Text("Carregando anúncios...")
                        ],
                      ),
                    );
                    break;
                  case ConnectionState.active :
                  case ConnectionState.done :

                    QuerySnapshot querySnapshot = snapshot.data;

                    if(querySnapshot.docs.length == 0){
                      return Container(
                        padding: EdgeInsets.all(25),
                        child: Text(
                          "Nenhum anúncio!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      );
                    }

                    return Expanded(
                      child: ListView.builder(
                        itemCount: querySnapshot.docs.length,
                        itemBuilder: (_, indice){

                          List<DocumentSnapshot> anuncios = querySnapshot.docs.toList();
                          DocumentSnapshot documentSnapshot = anuncios[indice];
                          Anuncio anuncio = Anuncio.fromDocumentSnapshot(documentSnapshot);

                          return ItemAnuncio(
                            anuncio: anuncio,
                            onTapItem: (){
                              Navigator.pushNamed(
                                context,
                                RouteGenerator.ROTA_DETALHESANUNCIO,
                                arguments: anuncio
                              );
                            },
                          );

                        }
                      ),
                    );
                }
                return Container();
              }
            )
          ],
        ),
      ),
    );
  }
}

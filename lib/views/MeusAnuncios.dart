import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/models/Anuncio.dart';
import 'package:olx/views/widgets/ItemAnuncio.dart';

import '../RouteGenerator.dart';

class MeusAnuncios extends StatefulWidget {
  @override
  _MeusAnunciosState createState() => _MeusAnunciosState();
}

class _MeusAnunciosState extends State<MeusAnuncios> {

  final FirebaseFirestore db = FirebaseFirestore.instance;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  String _idUsuarioLogado;

  _recuperarUsuarioLogado() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser;
    _idUsuarioLogado = usuarioLogado.uid;

  }


  Future<Stream<QuerySnapshot>> _adicionarListenerAnuncios() async {

    await _recuperarUsuarioLogado();

    Stream<QuerySnapshot> stream = db
      .collection("meus_anuncios")
      .doc(_idUsuarioLogado)
      .collection("anuncios")
      .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });

  }

  _removerAnuncio(String idAnuncio){

    db.collection("meus_anuncios")
      .doc(_idUsuarioLogado)
      .collection("anuncios")
      .doc(idAnuncio)
      .delete().then((_){

        db.collection("anuncios")
          .doc(idAnuncio)
          .delete();

    });

  }

  @override
  void initState() {
    super.initState();

    _adicionarListenerAnuncios();
  }

  @override
  Widget build(BuildContext context) {

    var carregandoDados = new Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          Text("Carregando anúncios...")
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Meus anúncios", style: Theme.of(context).textTheme.headline6.copyWith(
            color: Colors.white),),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text("Adicionar"),
        onPressed: (){
          Navigator.pushNamed(context, RouteGenerator.ROTA_NOVOANUNCIO);
        },
      ),
      body: StreamBuilder(
        stream: _controller.stream,
        builder: (context, snapshot){

          switch(snapshot.connectionState){
            case ConnectionState.none :
            case ConnectionState.waiting :
              return carregandoDados;
              break;
            case ConnectionState.active :
            case ConnectionState.done :

              if(snapshot.hasError){
                return Text("Erro ao carregar dados!");
              }

              QuerySnapshot querySnapshot = snapshot.data;

              return ListView.builder(
                  itemCount: querySnapshot.docs.length,
                  itemBuilder: (_, indice) {

                    List<DocumentSnapshot> anuncios = querySnapshot.docs.toList();
                    DocumentSnapshot documentSnapshot = anuncios[indice];
                    Anuncio anuncio = Anuncio.fromDocumentSnapshot(documentSnapshot);

                    return ItemAnuncio(
                      anuncio: anuncio,
                      onPressedRemover: (){
                        showDialog(
                          context: context,
                          builder: (context){
                            return AlertDialog(
                              title: Text("Confirmar exclusão"),
                              content: Text("Deseja realmente excluir este anúncio?"),
                              actions: [
                                FlatButton(
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    "Cancelar",
                                    style: TextStyle(
                                      color: Colors.grey
                                    ),
                                  )
                                ),
                                FlatButton(
                                    onPressed: (){
                                      _removerAnuncio(anuncio.id);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      "Excluir",
                                      style: TextStyle(
                                          color: Colors.red
                                      ),
                                    )
                                )
                              ],
                            );
                          }
                        );
                      },
                    );
                  }
              );
          }
          return Container();
        },
      )
    );
  }
}

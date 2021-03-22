import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olx/models/Anuncio.dart';
import 'package:olx/utils/Configuracoes.dart';
import 'package:olx/views/widgets/BotaoCustomizado.dart';
import 'package:olx/views/widgets/DropDownFormField.dart';
import 'package:olx/views/widgets/InputCustomizado.dart';
import 'package:validadores/Validador.dart';

class NovoAnuncio extends StatefulWidget {
  @override
  _NovoAnuncioState createState() => _NovoAnuncioState();
}

class _NovoAnuncioState extends State<NovoAnuncio> {

  List<File> _listaImagens = List();
  List<DropdownMenuItem<String>> _listaItensDropEstados = List();
  List<DropdownMenuItem<String>> _listaItensDropCategorias = List();
  final _formKey = GlobalKey<FormState>();
  Anuncio _anuncio;
  BuildContext _dialogContext;
  String _qtdDescricao = "";
  String _itemSelecionadoEstado;
  String _itemSelecionadoCategoria;

  _selecionarImagemGaleria() async {

    final picker = ImagePicker();
    File imagem;

    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if(pickedFile != null){
      setState(() {
        imagem = File(pickedFile.path);
        _listaImagens.add(imagem);
      });
    }

  }

  _salvarAnuncio() async {

    _abrirDialog(_dialogContext);

    await _uploadImagens();

    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser;
    String idUsuarioLogado = usuarioLogado.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("meus_anuncios")
      .doc(idUsuarioLogado)
      .collection("anuncios")
      .doc(_anuncio.id)
      .set(_anuncio.toMap()).then((_) {

        db.collection("anuncios")
          .doc(_anuncio.id)
          .set(_anuncio.toMap()).then((_){

          Navigator.pop(_dialogContext);
          Navigator.pop(context);

        });
    });
  }

  _abrirDialog(BuildContext context){

    showDialog(
      context: context,
      barrierDismissible: false, //nao deixa usuario clicar fora
      builder: (BuildContext context){
       return AlertDialog(
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             CircularProgressIndicator(),
             SizedBox(height: 20,),
             Text("Salvando anúncio...")
           ],
         ),
       );
      }
    );

  }

  Future _uploadImagens() async {

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();

    for(var imagem in _listaImagens){

      String nomeImagem = DateTime.now().microsecondsSinceEpoch.toString();
      Reference arquivo = pastaRaiz
        .child("meus_anuncios")
        .child(_anuncio.id)
        .child(nomeImagem);

      UploadTask uploadTask = arquivo.putFile(imagem);
      String url = await (await uploadTask).ref.getDownloadURL();

      _anuncio.fotos.add(url);

    }

  }

  _carregarItenDropdown(){

    _listaItensDropCategorias = Configuracoes.getCategorias();

    _listaItensDropEstados = Configuracoes.getEstados();

  }

  @override
  void initState() {
    super.initState();

    _carregarItenDropdown();

    _anuncio = Anuncio.gerarId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Novo anúncio", style: Theme.of(context).textTheme.headline6.copyWith(
            color: Colors.white),),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormField<List>(
                  initialValue: _listaImagens,
                  validator: (imagens){
                    if(imagens.length == 0){
                      return "Necessário selecionar uma imagem!";
                    }
                    return null;
                  },
                  builder: (state){
                    return Column(
                      children: [
                        Container(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _listaImagens.length + 1,
                            itemBuilder: (context, indice){
                              if(indice == _listaImagens.length){
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: GestureDetector(
                                    onTap: (){
                                      _selecionarImagemGaleria();
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey[400],
                                      radius: 50,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo,
                                            size: 40,
                                            color: Colors.grey[100],
                                          ),
                                          Text(
                                            "Adicionar",
                                            style: TextStyle(
                                              color: Colors.grey[100]
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                              if(_listaImagens.length > 0){
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: GestureDetector(
                                    onTap: (){
                                      showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          child: Stack(
                                            children:[
                                              SingleChildScrollView(
                                                child: Image.file(_listaImagens[indice]),
                                            ),
                                            Positioned(
                                                bottom: 0,
                                                left: 0,
                                                right: 0,
                                                height: 40,
                                                child: FlatButton(
                                                    child: Text("Excluir"),
                                                    color: Colors.white,
                                                    textColor: Colors.red,
                                                    onPressed: (){
                                                      setState(() {
                                                        _listaImagens.removeAt(indice);
                                                        Navigator.of(context).pop();
                                                      });
                                                    }
                                                )
                                            ),
                                          ]),
                                        )
                                      );
                                    },
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage: FileImage(_listaImagens[indice]),
                                      child: Container(
                                        color: Color.fromRGBO(255, 255, 255, 0.4),
                                        alignment: Alignment.center,
                                        child: Icon(Icons.delete, color: Colors.red),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return Container();
                            }
                          ),
                        ),
                        if(state.hasError)
                          Container(
                            child: Text(
                              "[${state.errorText}]",
                              style: TextStyle(
                                color: Colors.red, fontSize: 14
                              ),
                            ),
                          )
                      ],
                    );
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropDownFormField(
                        value: _itemSelecionadoEstado,
                        listaItensDrop: _listaItensDropEstados,
                        onSaved: (estado){
                          _anuncio.estado = estado;
                        },
                        onChanged: (valor){
                          setState(() {
                            _itemSelecionadoEstado = valor;
                          });
                        },
                      )
                    ),
                    Expanded(
                        child: DropDownFormField(
                          value: _itemSelecionadoCategoria,
                          listaItensDrop: _listaItensDropCategorias,
                          onSaved: (categoria){
                            _anuncio.categoria = categoria;
                          },
                          onChanged: (valor){
                            setState(() {
                              _itemSelecionadoCategoria = valor;
                            });
                          },
                        )
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15, top: 15),
                  child: InputCustomizado(
                    hint: "Título",
                    onSaved: (titulo){
                      _anuncio.titulo = titulo;
                    },
                    textCapitalization: TextCapitalization.sentences,
                    validator: (valor){
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                          .valido(valor);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: InputCustomizado(
                    hint: "Preço",
                    onSaved: (preco){
                      _anuncio.preco = preco;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      RealInputFormatter(centavos: true)
                    ],
                    validator: (valor){
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                          .valido(valor);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: InputCustomizado(
                    hint: "Telefone",
                    onSaved: (telefone){
                      _anuncio.telefone = telefone;
                    },
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TelefoneInputFormatter()
                    ],
                    validator: (valor){
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                          .valido(valor);
                    },
                  ),
                ),
                InputCustomizado(
                  hint: "Descrição (200 caracteres)",
                  onChanged: (carac){
                    setState(() {
                      _qtdDescricao = carac;
                    });
                  },
                  onSaved: (descricao){
                    _anuncio.descricao = descricao;
                  },
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (valor){
                    return Validador()
                        .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                        .maxLength(200, msg: "Máximo 200 caracteres!")
                        .valido(valor);
                  },
                ),
                Container(
                  child: Text((200 - _qtdDescricao.length).toString(),style: TextStyle(color: Theme.of(context).primaryColor),),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(bottom: 15),
                ),
                BotaoCustomizado(
                  texto: "Cadastrar anúncio",
                  onPressed: (){
                    if(_formKey.currentState.validate()){
                      _formKey.currentState.save();
                      _dialogContext = context;
                      _salvarAnuncio();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

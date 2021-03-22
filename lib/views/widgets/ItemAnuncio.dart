import 'package:flutter/material.dart';
import 'package:olx/models/Anuncio.dart';

class ItemAnuncio extends StatelessWidget {

  final Anuncio anuncio;
  final VoidCallback onTapItem;
  final VoidCallback onPressedRemover;


  ItemAnuncio({
    @required this.anuncio,
    this.onTapItem,
    this.onPressedRemover
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onTapItem,
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: Image.network(
                anuncio.fotos[0],
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        anuncio.titulo,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Container(height: 30,),
                      Text("R\$ ${anuncio.preco}"),
                    ],
                  ),
                ),
              ),
            ),
            if (this.onPressedRemover != null) Expanded(
                flex: 1,
                child: FlatButton(
                  color: Colors.red,
                  padding: EdgeInsets.all(10),
                  onPressed: this.onPressedRemover,
                  child: Icon(Icons.delete, color: Colors.white,),
                )
            )
          ],
        ),
      ),
    );
  }
}

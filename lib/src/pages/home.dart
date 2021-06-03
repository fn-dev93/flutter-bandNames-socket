import 'dart:io';

import 'package:band_names/src/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'AC/DC', votes: 5),
    Band(id: '3', name: 'Gus & Roses', votes: 5),
    Band(id: '4', name: 'Black Sabbath', votes: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          'BandName',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, i) => _bandTile(bands[i]),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        child: Icon(Icons.add),
        onPressed: addNewBand,),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        print('direction: $direction');
        print('direction: ${band.id}');
        //TODO: llamaer el borrado en el server
      },
      background: Container(
        padding: EdgeInsets.only(left: 8),
        color: Colors.grey,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle(color: Colors.white),),),),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () {
          print(band.name);
        },
      ),
    );
  }

  addNewBand(){

    final textController = new TextEditingController();

    if (!Platform.isAndroid) {
    
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text('New Band Name'),
        content: TextField(
          controller: textController,
        ),
        actions: [
          MaterialButton(
            child: Text('Add',),
            textColor: Colors.blue,
            elevation: 5,
            onPressed: ()=> addBandToList(textController.text))
        ],
      );
    });
  }
    showCupertinoDialog(context: context, builder: (_)=>CupertinoAlertDialog(
      title: Text('New Band Name'),
      content: CupertinoTextField(
        controller: textController,
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          child: Text('Add'),
          onPressed: ()=> addBandToList(textController.text)),
          CupertinoDialogAction(
          isDestructiveAction: true,
          child: Text('Dismiss'),
          onPressed: ()=> Navigator.pop(context)),
      ],
    ));

  }

  addBandToList(String name){

    if (name.length >1) {
      this.bands.add(new Band(id: DateTime.now().toString(), name: name));
      setState(() {});
    }

    Navigator.pop(context);
  }

}

import 'dart:io';

import 'package:band_names/services/socket_service.dart';
import 'package:band_names/src/models/band.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:provider/provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // Band(id: '1', name: 'Metallica', votes: 5),
    // Band(id: '2', name: 'AC/DC', votes: 5),
    // Band(id: '3', name: 'Gus & Roses', votes: 5),
    // Band(id: '4', name: 'Black Sabbath', votes: 5),
  ];

  @override
  void initState() {
    final checkOnline = Provider.of<SocketService>(context, listen: false);

    checkOnline.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((banda) => Band.fromMap(banda)).toList();

    setState(() {});
  }

  @override
  void dispose() {
    final checkOnline = Provider.of<SocketService>(context, listen: false);

    checkOnline.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkOnline = Provider.of<SocketService>(context).serverStatus;

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (checkOnline == ServerStatus.Online)
                ? Icon(
                    Icons.check_circle,
                    color: Colors.blue[300],
                  )
                : Icon(
                    Icons.offline_bolt,
                    color: Colors.red,
                  ),
          ),
        ],
        title: Text(
          'BandName',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, i) => _bandTile(bands[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        child: Icon(Icons.add),
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) =>
          socketService.socket.emit('delete-band', {'id': band.id}),
      background: Container(
        padding: EdgeInsets.only(left: 8),
        color: Colors.grey,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Delete Band',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
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
          onTap: () => socketService.socket.emit('vote-band', {'id': band.id})),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    if (!Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('New Band Name'),
                content: TextField(
                  controller: textController,
                ),
                actions: [
                  MaterialButton(
                      child: Text(
                        'Add',
                      ),
                      textColor: Colors.blue,
                      elevation: 5,
                      onPressed: () => addBandToList(textController.text))
                ],
              ));
    }
    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text('New Band Name'),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: [
                CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text('Add'),
                    onPressed: () => addBandToList(textController.text)),
                CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: Text('Dismiss'),
                    onPressed: () => Navigator.pop(context)),
              ],
            ));
  }

  addBandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    if (name.length > 1) {
      socketService.socket.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }

  Widget _showGraph(){

    Map<String, double> dataMap = new Map();

      bands.forEach((band) {
        dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
      });

      final List<Color> colorList =[
        Colors.red,
        Colors.yellow,
        Colors.amber,
        Colors.blue,
        Colors.orange,
      ];

      return Container(
        width: double.infinity,
        height: 200,
        child: PieChart(
      dataMap: dataMap,
      animationDuration: Duration(milliseconds: 800),
      // chartLegendSpacing: 32,
      chartRadius: MediaQuery.of(context).size.width / 2.5,
      colorList: colorList,
      initialAngleInDegree: 0,
      chartType: ChartType.disc,
      ringStrokeWidth: 32,
      // centerText: "HYBRID",
      legendOptions: LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.right,
        showLegends: true,
        // legendShape: _BoxShape.circle,
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      chartValuesOptions: ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: false,
        showChartValuesOutside: false,
        decimalPlaces: 1,
      ),
    ));
    }
}

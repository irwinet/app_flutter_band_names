import 'dart:io';

import 'package:app_flutter_band_names/models/band.dart';
import 'package:app_flutter_band_names/services/socker_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';



class HomePage extends StatefulWidget {
   
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    // Band(id: '1', name: 'Metalica', votes: 5),
    // Band(id: '2', name: 'Queen', votes: 0),
    // Band(id: '3', name: 'Bon Jovi', votes: 1),
    // Band(id: '4', name: 'Morat', votes: 3),
    // Band(id: '5', name: 'Aitana', votes: 2),
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {
      
    });
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final serverStatus = Provider.of<SocketService>(context).serverStatus;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('BandNames', style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (serverStatus == ServerStatus.OnLine)
              ? Icon(Icons.check_circle, color: Colors.blue[300],)
              : const Icon(Icons.offline_bolt, color: Colors.red,),
          )
        ],
      ),
      body: Column(
        children: [
          _showGraph(),

          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, i) => _bandTile(bands[i]),        
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: addNewBand,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( _ ) => socketService.socket.emit('delete-band', { 'id': band.id }),
      background: Container(
        padding: const EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle(color: Colors.white),)
        ),
      ),
      child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(band.name.substring(0,2)),
            ),
            title: Text(band.name),
            trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20),),
            onTap: () => socketService.socket.emit('vote-band', { 'id': band.id }),
          ),
    );
  }

  addNewBand(){
    final textController = TextEditingController();
    
    if(Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: ( _ ) => AlertDialog(
            title: const Text('New band name:'),
            content: TextField(
              controller: textController,
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5,
                textColor: Colors.blue,
                child: const Text('Add'),
                onPressed: () => addBandToList(textController.text)
              )
            ],
          )
      );
    }

    showCupertinoDialog(
      context: context, 
      builder: (_) => CupertinoAlertDialog(
          title: const Text('New band name:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Add'),
              onPressed: () => addBandToList(textController.text),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Dismiss'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        )
    );
    
  }

  void addBandToList(String name) {
    // print(name);

    if(name.length > 1){
      // TODO Add
      // this.bands.add(new Band(id: DateTime.now().toString(), name: name, votes: 0));
      // setState(() {
        
      // });
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', { 'name' : name});
    }
    Navigator.pop(context);
  }

  Widget _showGraph(){
    final Map<String, double> dataMap = {};
    final List<Color> colorList = [
      Colors.blueAccent,
      Colors.pinkAccent,
      Colors.yellowAccent,
      Colors.greenAccent
    ];

    bands.forEach((band) {
      dataMap[band.name] = band.votes.toDouble();
    });

    return Container(
      padding: EdgeInsets.only(top: 10),
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        // centerText: "BANDS",
        legendOptions: LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendShape: BoxShape.circle,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 0,
        ),
        // gradientList: ---To add gradient colors---
        // emptyColorGradient: ---Empty Color gradient---
      )
    );
  }

}
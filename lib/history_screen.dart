import 'package:flutter/material.dart';

import 'db_helper.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  List<String> _dates = [];

  @override
  void initState(){
    super.initState();
    _loadDates();
  }

  Future<void> _loadDates() async{
    final dates = await DBHelper.getAllDates();
    setState(() {
      _dates = dates;
    });
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense History "),
      ),
      body: _dates.isEmpty? const Center(child: Text('No history found!'),):ListView.builder(
        itemCount: _dates.length,
        itemBuilder: (context,index){
          return Card(
            child: ListTile(
              title: Text(_dates[index]),
              trailing: const Icon(Icons.arrow_forward),
              onTap: (){
                Navigator.pop(context, _dates[index]);
              },
            ),
          );
        }
        )
    );
  }
}
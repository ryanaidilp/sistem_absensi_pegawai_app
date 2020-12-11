import 'package:auto_size_text/auto_size_text.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/outstation.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/create_outstation_screen.dart';

class OutstationListScreen extends StatefulWidget {
  @override
  _OutstationListScreenState createState() => _OutstationListScreenState();
}

class _OutstationListScreenState extends State<OutstationListScreen> {
  List<Outstation> _outstations = List<Outstation>();
  bool _isLoading = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _fetchOutstationData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var dataRepo = Provider.of<DataRepository>(context, listen: false);
      Map<String, dynamic> _result = await dataRepo.getAllOutstation();
      List<dynamic> outstations = _result['data'];
      List<Outstation> _data =
          outstations.map((json) => Outstation.fromJson(json)).toList();
      setState(() {
        _outstations = _data;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOutstationData();
  }

  Widget _buildBody() {
    if (_isLoading) return Center(child: CircularProgressIndicator());
    if (_outstations.isEmpty)
      return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 150,
                height: 150,
                child: FlareActor(
                  'assets/flare/empty.flr',
                  fit: BoxFit.contain,
                  animation: 'empty',
                  alignment: Alignment.center,
                ),
              ),
              Text('Belum ada Dinas Luar yang diajukan!')
            ]),
      );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemBuilder: (_, index) {
          Outstation outstation = _outstations[index];
          DateTime dueDate = _outstations[index].dueDate;
          DateTime startDate = _outstations[index].startDate;
          return Card(
            elevation: 4.0,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${outstation.title}',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16.0),
                    ),
                    SizedBox(height: 5.0),
                    Row(
                      children: <Widget>[
                        Text(
                          'Status : ',
                          style: TextStyle(fontSize: 12.0),
                        ),
                        Text(
                          '${outstation.isApproved ? 'Disetujui' : 'Belum Disetujui'}',
                          style: TextStyle(
                              fontSize: 12.0,
                              color: outstation.isApproved
                                  ? Colors.green
                                  : Colors.red),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Divider(height: 1.0),
                    SizedBox(height: 5.0),
                    Text(
                      'Masa Berlaku : ',
                      style: TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                    SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16.0,
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          '${startDate.day}/${startDate.month}/${startDate.year} - ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      'Deskripsi : ',
                      style: TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                    AutoSizeText(
                      '${outstation.description}',
                      maxFontSize: 12.0,
                      minFontSize: 10.0,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )),
          );
        },
        itemCount: _outstations.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text('Daftar Dinas Luar'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CreateOutstationScreen()));
          },
        ),
        body: _buildBody());
  }
}

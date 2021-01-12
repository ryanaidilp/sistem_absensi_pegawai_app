import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/outstation.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/create_outstation_screen.dart';
import 'package:spo_balaesang/widgets/employee_proposal_widget.dart';

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
    if (_isLoading)
      return Center(
          child: SpinKitFadingFour(
        size: 45,
        color: Colors.blueAccent,
      ));
    if (_outstations.isEmpty)
      return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: Get.width * 0.5,
                height: Get.height * 0.3,
                child: FlareActor(
                  'assets/flare/not_found.flr',
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
          return EmployeeProposalWidget(
            title: outstation.toString(),
            description: outstation.description,
            dueDate: dueDate,
            startDate: startDate,
            isApproved: outstation.isApproved,
            heroTag: outstation.id.toString(),
            photo: outstation.photo,
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
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.add),
          onPressed: () {
            Get.to(CreateOutstationScreen());
          },
        ),
        body: _buildBody());
  }
}

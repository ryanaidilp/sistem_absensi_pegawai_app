import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/paid_leave.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/create_paid_leave_screen.dart';
import 'package:spo_balaesang/widgets/employee_proposal_widget.dart';

class PaidLeaveListScreen extends StatefulWidget {
  @override
  _PaidLeaveListScreenState createState() => _PaidLeaveListScreenState();
}

class _PaidLeaveListScreenState extends State<PaidLeaveListScreen> {
  List<PaidLeave> _paidLeaves;
  bool _isLoading = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _fetchPaidLeaveData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var dataRepo = Provider.of<DataRepository>(context, listen: false);
      Map<String, dynamic> _result = await dataRepo.getAllPaidLeave();
      List<dynamic> paidLeaves = _result['data'];
      List<PaidLeave> _data =
          paidLeaves.map((json) => PaidLeave.fromJson(json)).toList();
      setState(() {
        _paidLeaves = _data;
      });
    } catch (e) {
      print(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  @override
  void initState() {
    _fetchPaidLeaveData();
    super.initState();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
          child: SpinKitFadingGrid(
        size: 45,
        color: Colors.blueAccent,
      ));
    }

    if (_paidLeaves.isEmpty) {
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
              Text('Belum ada Cuti yang diajukan!')
            ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        itemBuilder: (_, index) => _buildPaidLeaveItem(_paidLeaves[index]),
        itemCount: _paidLeaves.length,
      ),
    );
  }

  Widget _buildPaidLeaveItem(PaidLeave paidLeave) {
    var startDate = paidLeave.startDate;
    var dueDate = paidLeave.dueDate;
    return EmployeeProposalWidget(
      title: paidLeave.title,
      description: paidLeave.description,
      startDate: startDate,
      dueDate: dueDate,
      photo: paidLeave.photo,
      isApproved: paidLeave.isApproved,
      isPaidLeave: true,
      heroTag: paidLeave.id.toString(),
      category: paidLeave.category,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Daftar Cuti'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Get.to(CreatePaidLeaveScreen());
        },
        child: Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }
}

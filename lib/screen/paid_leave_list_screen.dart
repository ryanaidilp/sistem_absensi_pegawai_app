import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/paid_leave.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/change_paid_leave_photo_screen.dart';
import 'package:spo_balaesang/screen/create_paid_leave_screen.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/employee_proposal_widget.dart';

class PaidLeaveListScreen extends StatefulWidget {
  @override
  _PaidLeaveListScreenState createState() => _PaidLeaveListScreenState();
}

class _PaidLeaveListScreenState extends State<PaidLeaveListScreen> {
  List<PaidLeave> _paidLeaves;
  bool _isLoading = false;

  @override
  void setState(void Function() fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _fetchPaidLeaveData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final DataRepository dataRepo =
          Provider.of<DataRepository>(context, listen: false);
      final Map<String, dynamic> _result = await dataRepo.getAllPaidLeave();
      final List<dynamic> paidLeaves = _result['data'] as List<dynamic>;
      final List<PaidLeave> _data = paidLeaves
          .map((json) => PaidLeave.fromJson(json as Map<String, dynamic>))
          .toList();
      setState(() {
        _paidLeaves = _data;
      });
    } catch (e) {
      showErrorDialog({
        'message': 'Kesalahan',
        'errors': [e.toString()]
      });
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
      return const Center(
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
              SizedBox(
                width: Get.width * 0.5,
                height: Get.height * 0.3,
                child: const FlareActor(
                  'assets/flare/not_found.flr',
                  animation: 'empty',
                ),
              ),
              const Text('Belum ada Cuti yang diajukan!')
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
    final startDate = paidLeave.startDate;
    final dueDate = paidLeave.dueDate;
    return EmployeeProposalWidget(
      title: paidLeave.title,
      description: paidLeave.description,
      startDate: startDate,
      dueDate: dueDate,
      approvalStatus: paidLeave.approvalStatus,
      photo: paidLeave.photo,
      isApproved: paidLeave.isApproved,
      isPaidLeave: true,
      updateWidget: ChangePaidLeavePhotoScreen(paidLeave: paidLeave),
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
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }
}

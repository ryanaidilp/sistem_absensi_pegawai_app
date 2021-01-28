import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/outstation.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/change_outstation_photo_screen.dart';
import 'package:spo_balaesang/screen/create_outstation_screen.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/employee_proposal_widget.dart';

class OutstationListScreen extends StatefulWidget {
  @override
  _OutstationListScreenState createState() => _OutstationListScreenState();
}

class _OutstationListScreenState extends State<OutstationListScreen> {
  List<Outstation> _outstations = <Outstation>[];
  bool _isLoading = false;

  @override
  void setState(void Function() fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _fetchOutstationData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      final Map<String, dynamic> _result = await dataRepo.getAllOutstation();
      final List<dynamic> outstations = _result['data'] as List<dynamic>;
      final List<Outstation> _data = outstations
          .map((json) => Outstation.fromJson(json as Map<String, dynamic>))
          .toList();
      setState(() {
        _outstations = _data;
      });
    } catch (e) {
      showErrorDialog({
        'message': 'Kesalahan',
        'errors': {
          'exception': ['Terjadi kesalahan!']
        }
      });
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
    if (_isLoading) {
      return const Center(
          child: SpinKitFadingFour(
        size: 45,
        color: Colors.blueAccent,
      ));
    }
    if (_outstations.isEmpty) {
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
              const Text('Belum ada Dinas Luar yang diajukan!')
            ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemBuilder: (_, index) {
          final Outstation outstation = _outstations[index];
          final DateTime dueDate = _outstations[index].dueDate;
          final DateTime startDate = _outstations[index].startDate;
          return EmployeeProposalWidget(
            title: outstation.title,
            description: outstation.description,
            dueDate: dueDate,
            startDate: startDate,
            approvalStatus: outstation.approvalStatus,
            isApproved: outstation.isApproved,
            heroTag: outstation.id.toString(),
            photo: outstation.photo,
            updateWidget: ChangeOutstationPhotoScreen(outstation: outstation),
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
          title: const Text('Daftar Dinas Luar'),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          onPressed: () {
            Get.to(CreateOutstationScreen());
          },
          child: const Icon(Icons.add),
        ),
        body: _buildBody());
  }
}

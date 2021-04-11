import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/outstation.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/change_outstation_photo_screen.dart';
import 'package:spo_balaesang/screen/create_outstation_screen.dart';
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/employee_proposal_widget.dart';

class OutstationListScreen extends StatefulWidget {
  @override
  _OutstationListScreenState createState() => _OutstationListScreenState();
}

class _OutstationListScreenState extends State<OutstationListScreen> {
  List<Outstation> _outstations = <Outstation>[];
  bool _isLoading = false;
  DateTime _date;

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
      final Map<String, dynamic> _result =
          await dataRepo.getAllOutstation(_date);
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
    _date = DateTime.now();
    _fetchOutstationData();
  }

  Future<void> _selectDate(BuildContext context) async {
    DatePicker.showDatePicker(context,
        initialDateTime: _date,
        minDateTime: DateTime(2021),
        maxDateTime: DateTime(DateTime.now().year + 5), onConfirm: (picked, _) {
      if (picked != null) {
        setState(() {
          _date = picked;
        });
        _fetchOutstationData();
      }
    }, locale: DateTimePickerLocale.id, dateFormat: 'MMMM-y');
  }

  Widget _buildBody() {
    if (_isLoading) {
      return SizedBox(
        height: Get.height * 0.7,
        child: const Center(
            child: SpinKitFadingFour(
          size: 45,
          color: Colors.blueAccent,
        )),
      );
    }
    if (_outstations.isEmpty) {
      return SizedBox(
        height: Get.height * 0.7,
        child: Center(
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
        ),
      );
    }
    return Column(
      children: _outstations.map((Outstation outstation) {
        final DateTime dueDate = outstation.dueDate;
        final DateTime startDate = outstation.startDate;
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
      }).toList(),
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
            Get.to(() => CreateOutstationScreen());
          },
          child: const Icon(Icons.add),
        ),
        body: Container(
          height: Get.height,
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Pilih Tahun & Bulan : ',
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      DateFormat.yMMMM('id_ID').format(_date),
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.blueAccent[400],
                        ),
                        onPressed: () {
                          _selectDate(context);
                        })
                  ],
                ),
                sizedBoxH4,
                dividerT1,
                sizedBoxH4,
                _buildBody()
              ],
            ),
          ),
        ));
  }
}

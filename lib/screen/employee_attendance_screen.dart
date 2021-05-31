import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';
import 'package:spo_balaesang/models/employee.dart';
import 'package:spo_balaesang/models/user.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/report_screen.dart';
import 'package:spo_balaesang/utils/app_const.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  @override
  _EmployeeAttendanceScreenState createState() =>
      _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  List<Employee> _employees;
  bool _isLoading = false;

  @override
  void setState(void Function() fn) {
    if (mounted) super.setState(fn);
  }

  void _setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  Future<void> loadData() async {
    try {
      _setLoading(true);
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      final List<Employee> _jsonEmployees = await dataRepo.getAllEmployee();
      setState(() {
        _employees = _jsonEmployees;
      });
    } catch (e) {} finally {
      _setLoading(false);
    }
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  Widget _buildPnsSection(Employee employee) {
    if (employee.status != 'PNS') {
      return sizedBox;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        sizedBoxH4,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Golongan',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(employee.group ?? '')
          ],
        ),
        sizedBoxH4,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'NIP',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(employee.nip ?? '')
          ],
        ),
      ],
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    return Container(
      width: Get.width,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                employee.name ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              dividerT1,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Jabatan',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(employee.position ?? '')
                ],
              ),
              sizedBoxH4,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Bagian ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(employee.department ?? '')
                ],
              ),
              sizedBoxH4,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Status',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(employee.status ?? '')
                ],
              ),
              _buildPnsSection(employee),
              sizedBoxH4,
              dividerT1,
              Center(
                child: SizedBox(
                  width: Get.width * 0.9,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      onPrimary: Colors.white,
                      primary: Colors.blueAccent,
                    ),
                    onPressed: () {
                      final User user = User.fromJson(employee.toJson());
                      Get.to(() => ReportScreen(user: user, isApproval: true));
                    },
                    child: const Text('Lihat data kehadiran'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
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
          const Text('Data tidak ditemukan :(')
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const SizedBox(
        child: Center(
            child: SpinKitCircle(
          size: 45,
          color: Colors.blueAccent,
        )),
      );
    }

    if (_employees == null || _employees.isEmpty) {
      return SizedBox(
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: Get.width * 0.5,
                  height: Get.height * 0.3,
                  child: const FlareActor(
                    'assets/flare/failure.flr',
                    animation: 'failure',
                  ),
                ),
                const Text('Gagal memuat data pegawai!'),
                sizedBoxH20,
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      primary: Colors.blueAccent,
                      onPrimary: Colors.white),
                  onPressed: loadData,
                  child: const Text('Coba Lagi'),
                )
              ]),
        ),
      );
    }

    return ListView.builder(
      itemBuilder: (context, index) => _buildEmployeeCard(_employees[index]),
      itemCount: _employees?.length ?? 0,
    );
  }

  Future<Employee> _onSearchButtonPressed() async {
    if (_employees == null || _employees.isEmpty) {
      return null;
    }

    return showSearch(
        context: context,
        delegate: SearchPage(
            searchLabel: 'Cari Pegawai',
            barTheme: ThemeData(
              appBarTheme: const AppBarTheme(
                brightness: Brightness.dark,
                color: Colors.blueAccent,
              ),
            ),
            showItemsOnEmpty: true,
            failure: _buildEmptyWidget(),
            builder: (Employee employee) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _buildEmployeeCard(employee),
                ),
            filter: (Employee employee) => [
                  employee.name,
                  employee.status,
                  employee.nip,
                  employee.department
                ],
            items: _employees));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Presensi Pegawai'),
        actions: <Widget>[
          IconButton(
              onPressed: _onSearchButtonPressed,
              icon: const Icon(Icons.search_rounded))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
        child: _buildContent(),
      ),
    );
  }
}

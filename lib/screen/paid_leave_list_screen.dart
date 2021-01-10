import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/paid_leave.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/create_paid_leave_screen.dart';
import 'package:spo_balaesang/screen/image_detail_screen.dart';
import 'package:spo_balaesang/widgets/image_error_widget.dart';

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
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${paidLeave.title}',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
            ),
            SizedBox(height: 5.0),
            Row(
              children: <Widget>[
                Text(
                  'Status     : ',
                  style: TextStyle(fontSize: 12.0),
                ),
                Text(
                  '${paidLeave.isApproved ? 'Disetujui' : 'Belum Disetujui'}',
                  style: TextStyle(
                      fontSize: 12.0,
                      color: paidLeave.isApproved ? Colors.green : Colors.red),
                ),
              ],
            ),
            SizedBox(height: 5.0),
            Row(
              children: <Widget>[
                Text(
                  'Kategori : ',
                  style: TextStyle(fontSize: 12.0),
                ),
                Text(
                  '${paidLeave.category}',
                  style: TextStyle(fontSize: 12.0),
                ),
              ],
            ),
            SizedBox(height: 5.0),
            Divider(thickness: 1.0, color: Colors.black26),
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
              '${paidLeave.description}',
              maxFontSize: 12.0,
              minFontSize: 10.0,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 10.0),
            Text(
              'Bukti Cuti : ',
              style: TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
            Text(
              '*tekan untuk memperbesar',
              style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.black87,
                  fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 5.0),
            InkWell(
              onTap: () {
                Get.to(ImageDetailScreen(
                  imageUrl: paidLeave.photo,
                  tag: paidLeave.id.toString(),
                ));
              },
              child: Hero(
                tag: paidLeave.id.toString(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: CachedNetworkImage(
                    placeholder: (_, __) => Container(
                      child: Stack(
                        children: <Widget>[
                          Image.asset('assets/images/upload_placeholder.png'),
                          Center(
                            child: SizedBox(
                              child: SpinKitFadingGrid(
                                size: 25,
                                color: Colors.blueAccent,
                              ),
                              width: 25.0,
                              height: 25.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    imageUrl: paidLeave.photo,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => ImageErrorWidget(),
                    width: Get.width,
                    height: 250.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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

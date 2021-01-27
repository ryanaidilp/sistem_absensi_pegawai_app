import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RegulationScreen extends StatelessWidget {
  final List<Map<String, dynamic>> _regulations = [
    {
      'title': 'PP Nomor 11 Tahun 2017',
      'description': 'Tentang Manajemen PNS',
      'link':
          'https://peraturan.bpk.go.id/Home/Download/40728/PP%2011%20TAHUN%202017.pdf'
    },
    {
      'title': 'Permenpan No. 6/2018',
      'description': 'Tentang Hari Kerja Dan Jam Kerja PNS',
      'link':
          'https://peraturan.bpk.go.id/Home/Download/123285/Permenpan%20no%206%20Tahun%202018.pdf',
    },
    {
      'title': 'PP Nomor 53 Tahun 2010',
      'description': 'Tentang Disiplin PNS',
      'link':
          'https://peraturan.bpk.go.id/Home/Download/36030/PP%2053%20Tahun%202010.pdf'
    },
    {
      'title': 'Contoh Surat Izin',
      'description': 'Beberapa contoh surat izin resmi sebagai referensi',
      'link': 'https://www.suratresmi.id/contoh-surat-izin-kerja/'
    },
    {
      'title': 'Contoh Surat Izin Sakit',
      'description': 'Referensi saat membuat surat izin sakit',
      'link': 'https://www.ashadin.com/2019/05/surat-izin-sakit-formal-pns.html'
    }
  ];

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: _regulations
              .map((regulation) => Container(
                    margin: const EdgeInsets.only(bottom: 4.0),
                    child: Card(
                      elevation: 4.0,
                      child: ListTile(
                        onTap: () {
                          launch(regulation['link'].toString());
                        },
                        title: Text(
                          regulation['title'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(regulation['description'].toString()),
                        trailing: IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            launch(regulation['link'].toString());
                          },
                        ),
                        dense: true,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Rujukan'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _buildBody(),
    );
  }
}

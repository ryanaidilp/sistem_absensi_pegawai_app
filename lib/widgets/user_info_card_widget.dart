import 'package:flutter/material.dart';

class UserInfoCardWidget extends StatelessWidget {
  const UserInfoCardWidget(
      {this.status,
      this.name,
      this.position,
      this.rank,
      this.group,
      this.nip,
      this.department});

  final String status;
  final String name;
  final String position;
  final String rank;
  final String group;
  final String nip;
  final String department;

  Widget _buildPnsInfoSection() {
    if (status == 'Honorer') {
      return SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'NIP           : ',
            ),
            Expanded(
              child: Text(
                '$nip',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.0),
        Row(
          children: <Widget>[
            Text(
              'Pangkat   : ',
            ),
            Expanded(
              child: Text(
                '${rank?.toUpperCase()}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.0),
        Row(
          children: <Widget>[
            Text(
              'Golongan : ',
            ),
            Expanded(
              child: Text(
                '$group',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Informasi Pegawai : ',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
            ),
            Divider(color: Colors.black38),
            Center(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'Nama       : ',
                      ),
                      Expanded(
                        child: Text(
                          '$name',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    children: <Widget>[
                      Text(
                        'Bagian     : ',
                      ),
                      Expanded(
                        child: Text(
                          '$department',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    children: <Widget>[
                      Text(
                        'Jabatan   : ',
                      ),
                      Expanded(
                        child: Text(
                          '$position',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  _buildPnsInfoSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

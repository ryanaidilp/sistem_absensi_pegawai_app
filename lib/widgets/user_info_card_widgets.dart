import 'package:flutter/material.dart';
import 'package:spo_balaesang/models/user.dart';

class UserInfoCard extends StatelessWidget {
  const UserInfoCard({this.user});
  final User user;

  Widget _buildPnsInfoSection() {
    if (user?.status == 'Honorer') {
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
                '${user?.nip}',
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
                '${user?.rank?.toUpperCase()}',
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
                '${user?.group}',
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Informasi Pegawai : ',
              style: TextStyle(
                fontSize: 16.0,
              ),
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
                          '${user?.name}',
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
                          '${user?.department}',
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
                          '${user?.position}',
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

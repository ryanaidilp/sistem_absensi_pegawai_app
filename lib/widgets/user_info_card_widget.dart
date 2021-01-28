import 'package:flutter/material.dart';
import 'package:spo_balaesang/utils/app_const.dart';

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
      return sizedBox;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Golongan',
              style: TextStyle(color: Colors.grey[700]),
            ),
            Text(
              group ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        sizedBoxH4,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Pangkat',
              style: TextStyle(color: Colors.grey[700]),
            ),
            Text(
              rank?.toUpperCase() ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        sizedBoxH4,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'NIP',
              style: TextStyle(color: Colors.grey[700]),
            ),
            Text(
              nip ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        sizedBoxH4,
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
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700]),
            ),
            const Divider(color: Colors.black38),
            Center(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Nama',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Text(
                        name ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  sizedBoxH4,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Jabatan',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Text(
                        position ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  sizedBoxH4,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Bagian',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Text(
                        department ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  sizedBoxH4,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Status',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Text(
                        status ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  sizedBoxH4,
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

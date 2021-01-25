import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spo_balaesang/utils/view_util.dart';

class EmployeeProposalInfoWidget extends StatelessWidget {
  const EmployeeProposalInfoWidget(
      {this.title, this.label, this.startDate, this.dueDate});
  final String label;
  final DateTime startDate;
  final DateTime dueDate;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Text(
              'Informasi $label',
              style: labelTextStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Judul ', style: labelTextStyle),
                SizedBox(width: 5.0),
                Text(
                  '$title',
                ),
              ],
            ),
            SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Tanggal Mulai ', style: labelTextStyle),
                SizedBox(width: 5.0),
                Text(
                  '${DateFormat.yMMMMEEEEd('id_ID').format(startDate)}',
                ),
              ],
            ),
            SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Tanggal Selesai ', style: labelTextStyle),
                SizedBox(width: 5.0),
                Text(
                  '${DateFormat.yMMMMEEEEd('id_ID').format(dueDate)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

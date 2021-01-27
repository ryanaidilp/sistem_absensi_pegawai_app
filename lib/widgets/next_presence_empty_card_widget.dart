import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spo_balaesang/utils/app_const.dart';

class NextPresenceEmptyCardWidget extends StatelessWidget {
  const NextPresenceEmptyCardWidget(
      {this.topLabel,
      this.trailingLabel,
      this.firstLabel,
      this.firstContent,
      this.secondLabel,
      this.secondContent,
      this.thirdLabel,
      this.thirdContent,
      this.fourthLabel,
      this.fourthContent,
      this.color,
      this.trailingTop});

  final String topLabel;
  final String trailingLabel;
  final String firstLabel;
  final String firstContent;
  final String secondLabel;
  final String secondContent;
  final String thirdLabel;
  final String thirdContent;
  final String fourthLabel;
  final String fourthContent;
  final Color color;
  final Widget trailingTop;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    DateFormat.EEEE().format(DateTime.now()),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  sizedBoxW5,
                  const Text('|'),
                  sizedBoxW5,
                  Text(
                    DateFormat.yMMMd().format(DateTime.now()),
                  ),
                  sizedBoxW5,
                  const Text('|'),
                  sizedBoxW5,
                  Text(topLabel),
                ],
              ),
              const Divider(
                thickness: 1.0,
                color: Colors.black26,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '$firstLabel :',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(firstContent),
                      sizedBoxH10,
                      Text(
                        '$secondLabel :',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      sizedBoxH2,
                      Text(secondContent),
                      sizedBoxH10,
                      Text(
                        '$thirdLabel :',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      sizedBoxH2,
                      Text(
                        thirdContent,
                        style: TextStyle(color: color),
                      ),
                      sizedBoxH10,
                      Text(
                        '$fourthLabel :',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      sizedBoxH2,
                      AutoSizeText(
                        fourthContent,
                        minFontSize: 10.0,
                        maxFontSize: 12.0,
                      )
                    ],
                  ),
                  Expanded(
                    child: Column(children: <Widget>[
                      trailingTop,
                      sizedBoxH2,
                      Text(
                        trailingLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      )
                    ]),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

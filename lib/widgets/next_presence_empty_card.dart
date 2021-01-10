import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NextPresenceEmptyCard extends StatelessWidget {
  const NextPresenceEmptyCard(
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
                  const SizedBox(width: 5.0),
                  const Text('|'),
                  const SizedBox(width: 5.0),
                  Text(
                    DateFormat.yMMMd().format(DateTime.now()),
                  ),
                  const SizedBox(width: 5.0),
                  const Text('|'),
                  const SizedBox(width: 5.0),
                  Text(topLabel),
                ],
              ),
              Divider(
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
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('$firstContent'),
                      const SizedBox(height: 10.0),
                      Text(
                        '$secondLabel :',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2.0),
                      Text('$secondContent'),
                      const SizedBox(height: 10.0),
                      Text(
                        '$thirdLabel :',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        '$thirdContent',
                        style: TextStyle(color: color),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        '$fourthLabel :',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2.0),
                      AutoSizeText(
                        '$fourthContent',
                        minFontSize: 10.0,
                        maxFontSize: 12.0,
                      )
                    ],
                  ),
                  Expanded(
                    child: Column(children: <Widget>[
                      trailingTop,
                      const SizedBox(height: 2.0),
                      Text(
                        '$trailingLabel',
                        style: TextStyle(
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

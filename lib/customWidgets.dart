import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomBanner extends StatelessWidget {
  final text;
  CustomBanner(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.grey[900],
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          this.text,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class CustomText extends StatelessWidget {
  final text;
  CustomText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(this.text, textAlign: TextAlign.center),
    );
  }
}

// ignore: must_be_immutable
class ETACard extends TableRow {
  final bus;
  final time;
  final remark;
  var children;
  ETACard(this.bus, this.time, this.remark) {
    if (this.time == null) {
      this.children = [
        TableCell(child: CustomText(this.bus)),
        TableCell(child: CustomText(this.remark)),
        TableCell(child: CustomText("")),
        TableCell(child: CustomText("- min(s)")),
      ];
      return;
    }
    final now = DateTime.now();
    final etaTime = DateTime.parse(this.time);
    this.children = [
      TableCell(child: CustomText(this.bus)),
      TableCell(
          child: CustomText(
              this.remark.replaceFirst("Delayed journey fromey", "Journey"))),
      TableCell(
          child: CustomText(DateFormat('hh:mm a').format(etaTime.toLocal()))),
      TableCell(
          child: CustomText((now.isBefore(etaTime)
                  ? etaTime
                      .difference(now.subtract(Duration(seconds: 50)))
                      .inMinutes
                      .toString()
                  : "-") +
              " min(s)")),
    ];
  }
}

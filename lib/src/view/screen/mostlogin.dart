import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class MostLoginScreen extends StatefulWidget {
  @override
  _MostLoginScreenState createState() => _MostLoginScreenState();
}

class _MostLoginScreenState extends State<MostLoginScreen> {
  List<_ChartData> chartData = [];

  @override
  void initState() {
    super.initState();

    DateTime time;
    for (int i = 0; i < 24; i++) {
      if (i < 10) {
        time = DateTime.parse('2022-01-01 0${i}:00:00');
      } else {
        time = DateTime.parse('2022-01-01 ${i}:00:00');
      }
      chartData.add(_ChartData(time, i * 5));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(
          maximumLabelWidth: 80,
        ),
        series: <CartesianSeries<_ChartData, DateTime>>[
          ColumnSeries<_ChartData, DateTime>(
            dataSource: chartData,
            xValueMapper: (_ChartData data, _) => data.time,
            yValueMapper: (_ChartData data, _) => data.count,
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.time, this.count);
  final DateTime time;
  final int count;
}
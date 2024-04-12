import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MostLoginScreen extends StatefulWidget {
  @override
  _MostLoginScreenState createState() => _MostLoginScreenState();
}

class _MostLoginScreenState extends State<MostLoginScreen> {
  List<_ChartData> chartData = [];

  @override
  void initState() {
    super.initState();
    _fetchLoginData();
  }

  Future<void> _fetchLoginData() async {
    final QuerySnapshot? loginSnapshot = await FirebaseFirestore.instance.collection('loginActivity').get();
    if (loginSnapshot != null) {
      Map<DateTime, int> loginCountByTime = {};

      // Count login occurrences for each time
      loginSnapshot.docs.forEach((doc) {
        Timestamp? timestamp = doc['timestamp'];
        if (timestamp != null) {
          DateTime loginTime = timestamp.toDate();
          // Truncate minutes and seconds to group logins by hour
          DateTime truncatedTime = DateTime(loginTime.year, loginTime.month, loginTime.day, loginTime.hour);
          loginCountByTime.update(truncatedTime, (value) => value + 1, ifAbsent: () => 1);
        }
      });

      // Prepare data for chart
      loginCountByTime.forEach((time, count) {
        chartData.add(_ChartData(time, count));
      });

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Activity'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: SfCartesianChart(
          primaryXAxis: DateTimeAxis(),
          series: <CartesianSeries<_ChartData, DateTime>>[
            ColumnSeries<_ChartData, DateTime>(
              dataSource: chartData,
              xValueMapper: (_ChartData data, _) => data.time,
              yValueMapper: (_ChartData data, _) => data.count,
              dataLabelSettings: DataLabelSettings(isVisible: true),
            ),
          ],
          tooltipBehavior: TooltipBehavior(enable: true),
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.time, this.count);
  final DateTime time;
  final int count;
}

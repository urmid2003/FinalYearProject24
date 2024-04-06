import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:charts_flutter/flutter.dart' as charts; // Import charts_flutter package

class LoginActivityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Activity'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('loginActivity').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Extract login activity data from the snapshot
          final loginDocs = snapshot.data!.docs;

          // Count the number of logins for each user
          final Map<String, int> userLoginCounts = {};
          for (var doc in loginDocs) {
            String userId = doc['userId'];
            userLoginCounts.update(userId, (value) => value + 1, ifAbsent: () => 1);
          }

          // Create a list of series for the bar graph
          List<charts.Series<UserLoginData, String>> series = [
            charts.Series(
              id: 'LoginActivity',
              data: userLoginCounts.entries.map((entry) => UserLoginData(entry.key, entry.value)).toList(),
              domainFn: (UserLoginData data, _) => data.email,
              measureFn: (UserLoginData data, _) => data.loginCount,
              colorFn: (UserLoginData data, _) => _getUserColor(data.email), // Use custom color function
            )
          ];

          // Create a bar chart with selection behavior
          var chart = charts.BarChart(
            series,
            vertical: true, // Display bars vertically
            animate: true, // Animation for the chart
            behaviors: [
              charts.ChartTitle(
                'Login Activity',
                subTitle: 'Number of logins per user',
                behaviorPosition: charts.BehaviorPosition.top,
                titleStyleSpec: charts.TextStyleSpec(fontSize: 20),
              ),
            ],
            selectionModels: [
              charts.SelectionModelConfig(
                type: charts.SelectionModelType.info,
                changedListener: (model) => _onSelectionChanged(model, context),
              )
            ],
            domainAxis: charts.OrdinalAxisSpec(
              renderSpec: charts.SmallTickRendererSpec(
                labelStyle: charts.TextStyleSpec(fontSize: 14),
              ),
            ),
            primaryMeasureAxis: charts.NumericAxisSpec(
              renderSpec: charts.SmallTickRendererSpec(
                labelStyle: charts.TextStyleSpec(fontSize: 14),
              ),
            ),
          );

          // Display the chart with increased padding
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: chart,
          );
        },
      ),
    );
  }

  void _onSelectionChanged(charts.SelectionModel model, BuildContext context) async {
    final selectedDatum = model.selectedDatum;
    if (selectedDatum.isNotEmpty) {
      final userId = selectedDatum.first.datum.email;
      final email = await _getUserEmail(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email: $email'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<String> _getUserEmail(String userId) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return userSnapshot.data()?['email'] ?? 'Email not found';
    } catch (e) {
      print('Error fetching user email: $e');
      return 'Email not found';
    }
  }

  charts.Color _getUserColor(String email) {
    // Define a list of colors
    final colors = [
      charts.MaterialPalette.blue.shadeDefault,
      charts.MaterialPalette.red.shadeDefault,
      charts.MaterialPalette.green.shadeDefault,
      charts.MaterialPalette.purple.shadeDefault,
      charts.MaterialPalette.yellow.shadeDefault,
    ];

    // Get the index of the color based on the email
    final index = email.codeUnits.fold(0, (sum, codeUnit) => sum + codeUnit) % colors.length;

    return colors[index];
  }
}

// Model class for user login data
class UserLoginData {
  final String email;
  final int loginCount;

  UserLoginData(this.email, this.loginCount);
}
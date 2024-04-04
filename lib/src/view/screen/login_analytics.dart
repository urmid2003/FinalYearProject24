import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
            if (userLoginCounts.containsKey(userId)) {
              userLoginCounts[userId] = userLoginCounts[userId]! + 1;
            } else {
              userLoginCounts[userId] = 1;
            }
          }

          // Sort the users by login count
          List<MapEntry<String, int>> sortedUsers = userLoginCounts.entries.toList();
          sortedUsers.sort((a, b) => b.value.compareTo(a.value));

          // Display the top 3 users with the most logins
          return ListView.builder(
            itemCount: sortedUsers.length > 3 ? 3 : sortedUsers.length,
            itemBuilder: (context, index) {
              final userId = sortedUsers[index].key;
              final loginCount = sortedUsers[index].value;

              // Return a ListTile for each user
              return Card(
                child: ListTile(
                  title: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading...');
                      }
                      if (userSnapshot.hasError) {
                        return Text('Error: ${userSnapshot.error}');
                      }

                      // Extract the username from the user document
                      String username = userSnapshot.data!['username'];
                      return Text('User ID: $userId - Username: $username');
                    },
                  ),
                  subtitle: Text('Login Count: $loginCount'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> logSignInActivity() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Get user ID and email from Firebase Authentication
        String userId = user.uid;
        String? email = user.email;

        // Add a new document to the "loginActivity" collection with current timestamp
        await FirebaseFirestore.instance.collection('loginActivity').add({
          'userId': userId,
          'email': email,
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('Sign-in activity logged successfully.');
      } else {
        print('No user signed in.');
      }
    } catch (e) {
      print('Error logging sign-in activity: $e');
    }
  }
}

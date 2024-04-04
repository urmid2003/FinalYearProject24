import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'signin_screen.dart';

void main() {
  runApp(ProfileScreen());
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  File? _image;
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchCurrentUserData();
  }

  Future<void> fetchCurrentUserData() async {
    if (_auth.currentUser != null) {
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
      final Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('image_url')) {
        setState(() {
          imageUrl = userData['image_url'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                ImagePicker imagePicker = ImagePicker();
                XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
                print('${file?.path}');

                if (file == null) return;

                String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

                Reference referenceRoot = _storage.ref();
                Reference referenceDirImages = referenceRoot.child('images');
                Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

                try {
                  await referenceImageToUpload.putFile(File(file.path));
                  imageUrl = await referenceImageToUpload.getDownloadURL();

                  setState(() {
                    _image = File(file.path);
                  });

                  // Update user document with the new image URL
                  await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
                    'image_url': imageUrl,
                  });
                } catch (error) {
                  print(error);
                }
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _image != null ? FileImage(_image!) as ImageProvider : NetworkImage(imageUrl),
                child: _image == null ? Icon(Icons.photo_library, size: 50) : null,
              ),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('users').doc(_auth.currentUser!.uid).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                var userData = snapshot.data!.data() as Map<String, dynamic>;
                return Column(
                 children: [
                    Card(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: ListTile(
                        title: Text(
                          'Username:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${userData['username']}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: ListTile(
                        title: Text(
                          'Email:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _auth.currentUser!.email!,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _auth.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => SignInScreen(), // Navigate to the sign-in page
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to sign out. Please try again.'),
                    ),
                  );
                }
              },
              child: Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
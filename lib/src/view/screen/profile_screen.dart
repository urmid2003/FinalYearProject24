import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;

Future<void> main() async {
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: 'AIzaSyAJKu77gyC9jKnqY8RtaNZ5423Hf08hXws',
          appId: '1:1033859424853:android:7db7c3931243ac7c92aadc',
          messagingSenderId: '1033859424853',
          projectId: 'signin-8fb6a',
          storageBucket: 'signin-8fb6a.appspot.com'));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Upload to Firebase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageUploadScreen(),
    );
  }
}

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({Key? key}) : super(key: key);
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _image;
  final picker = ImagePicker();
  String _uploadedFileURL = '';

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadImageToFirebase() async {
    if (_image == null) return;

    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('images/${Path.basename(_image!.path)}');
    UploadTask uploadTask = storageReference.putFile(_image!);
    await uploadTask.whenComplete(() async {
      print('File uploaded');
      await storageReference.getDownloadURL().then((fileURL) {
        setState(() {
          _uploadedFileURL = fileURL;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload to Firebase'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image != null
                ? Image.file(
                    _image!,
                    height: 200,
                  )
                : Text('No image selected.'),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: getImage,
              child: Text('Choose Image'),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: uploadImageToFirebase,
              child: Text('Upload Image'),
            ),
            SizedBox(
              height: 20,
            ),
            _uploadedFileURL.isNotEmpty
                ? Text('Uploaded Image URL: $_uploadedFileURL')
                : Container(),
          ],
        ),
      ),
    );
  }
}

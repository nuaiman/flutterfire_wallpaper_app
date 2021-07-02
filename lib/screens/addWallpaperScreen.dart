import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class AddWalpaperScreen extends StatefulWidget {
  @override
  _AddWalpaperScreenState createState() => _AddWalpaperScreenState();
}

class _AddWalpaperScreenState extends State<AddWalpaperScreen> {
  File? _storedImage;
  List<ImageLabel>? detectedLabels;
  // List<String>? results;
  bool _isUplaoding = false;
  List<String>? labelString;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future _takePicture() async {
    final _picker = ImagePicker();
    final _pickedImage =
        await _picker.getImage(source: ImageSource.gallery, imageQuality: 30);

    if (_pickedImage == null) {
      return;
    }

    setState(() {
      _storedImage = File(_pickedImage.path);
      labelImage();
    });
  }

  labelImage() async {
    final inputImage = InputImage.fromFile(_storedImage!);
    final imageLabeler = GoogleMlKit.vision.imageLabeler();
    final List<ImageLabel>? labelList =
        await imageLabeler.processImage(inputImage);

    setState(() {
      detectedLabels = labelList;
    });

    labelString = [];
    for (var i in detectedLabels!) {
      labelString!.add((i.label).toString());
    }
  }

  void _uploadWallpaper() async {
    setState(() {
      _isUplaoding = true;
    });
    User? _user = _firebaseAuth.currentUser;
    String? uid = _user!.uid;
    String? url;

    if (_storedImage != null) {
      final fileName = path.basename(_storedImage!.path);
      final ref =
          _firebaseStorage.ref().child('wallpapers').child(uid).child(fileName);

      await ref.putFile(_storedImage!);
      url = await ref.getDownloadURL();
    }

    await _firebaseFirestore.collection('wallpapers').doc().set({
      'url': url,
      'date': Timestamp.now(),
      'uploadedBy': uid,
      'tags': labelString,
    }).whenComplete(() {
      setState(() {
        _isUplaoding = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _isUplaoding
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                width: double.infinity,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        _takePicture();
                      },
                      child: Container(
                          height: 400,
                          child: _storedImage == null
                              ? Image(
                                  image: AssetImage('assets/bg.png'),
                                )
                              : Image.file(_storedImage!)),
                    ),
                    SizedBox(
                      height: 0,
                    ),
                    Text('Click on image to upload wallpaper'),
                    SizedBox(
                      height: 30,
                    ),
                    detectedLabels != null
                        ? Wrap(
                            children: detectedLabels!.map((tag) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 0),
                                child: Chip(
                                  label: Text(tag.label),
                                ),
                              );
                            }).toList(),
                          )
                        : Container(),
                    SizedBox(height: 40),
                    detectedLabels != null
                        ? Container(
                            padding: EdgeInsets.symmetric(horizontal: 50),
                            width: double.infinity,
                            child: ElevatedButton(
                              child: Text('Upload Wallpaper'),
                              onPressed: _uploadWallpaper,
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
    );
  }
}

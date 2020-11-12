import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PickImageFromDevice extends StatefulWidget {
  @override
  PickImageFromDeviceState createState() => PickImageFromDeviceState();
}

class PickImageFromDeviceState extends State<PickImageFromDevice> {
  File _image;
  final picker = ImagePicker();

  Future getImage(String val) async {
    var status = await Permission.photos.status;
    var pickedFile;
    if (status.isGranted) {
      //for using camera use ImageSource.camera
      if (val == "camera") {
        pickedFile = await picker.getImage(source: ImageSource.camera);
      } else {
        pickedFile = await picker.getImage(source: ImageSource.gallery);
      }
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    } else if (status.isUndetermined) {
      print("Permission undetermined");
      if (val == "camera") {
        pickedFile = await picker.getImage(source: ImageSource.camera);
      } else {
        pickedFile = await picker.getImage(source: ImageSource.gallery);
      }
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
      // We didn't ask for permission yet.
    } else if (status.isDenied) {
      print("Permission denied");
      _showMyDialog();
    } else if (status.isPermanentlyDenied) {
      _showMyDialog();
      print("Permission permenently denied");
    } else if (status.isRestricted) {
      _showMyDialog();
      print("Permission restricted");
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Please allow the permission'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(''),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Don't Allow"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showGalleryOrCameraDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: Text("Take a picture"),
                  onTap: () {
                    Navigator.of(context).pop();
                    getImage("camera");
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                ),
                GestureDetector(
                  child: Text("Choose image from gallery"),
                  onTap: () {
                    Navigator.of(context).pop();
                    getImage("gallery");
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Center(
        child: RaisedButton(
          child: Icon(Icons.camera),
          onPressed: () {
            _showGalleryOrCameraDialog();
          },
        ),
      ),
      Center(
        child: _image == null ? Text('No image selected.') : Image.file(_image),
      )
    ]));
  }
}

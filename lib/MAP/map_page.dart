import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class RoadSafetyApp extends StatefulWidget {
  const RoadSafetyApp({Key? key}) : super(key: key);

  @override
  _RoadSafetyAppState createState() => _RoadSafetyAppState();
}

class _RoadSafetyAppState extends State<RoadSafetyApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? _user;
  late Position _currentPosition;

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();

  @override
  void initState() {
    super.initState();
    _getUser();
    _loadIssues();
  }

  Future<void> _getUser() async {
    _user = _auth.currentUser;
  }

  Future<void> _loadIssues() async {
    try {
      // Load existing issues from Firestore and add markers on the map
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await _firestore.collection('issues').get();
      querySnapshot.docs.forEach((document) {
        var issue = document.data();
        _addMarker(
          issue['latitude'] ?? 0.0,
          issue['longitude'] ?? 0.0,
          issue['description'] ?? '',
        );
      });
    } catch (e) {
      print('Error loading issues: $e');
      // Handle the error, show a snackbar, or provide feedback to the user
    }
  }

  void _addMarker(double latitude, double longitude, String description) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(latitude.toString() + longitude.toString()),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: description,
          ),
        ),
      );
    });
  }

  Future<void> _reportIssue() async {
    // Get the user's current location
    await _getCurrentLocation();

    // Show a dialog to report an issue
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Report Issue'),
          content: Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Short Description'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Open the image picker to select photos
                  List<XFile>? images = await ImagePicker().pickMultiImage();

                  if (images != null && images.isNotEmpty) {
                    // Upload images to Firebase Storage and get the download URLs
                    try {
                      List<String> imageUrls = await _uploadImages(images);

                      // Report the issue to Firestore
                      await _firestore.collection('issues').add({
                        'description': 'Short Description',
                        // Replace with actual description
                        'latitude': _currentPosition.latitude,
                        'longitude': _currentPosition.longitude,
                        'images': imageUrls,
                      });

                      Navigator.pop(context); // Close the dialog
                    } catch (e) {
                      print('Error uploading images: $e');
                      // Handle the error, show a snackbar, or provide feedback to the user
                    }
                  } else {
                    // Inform the user that they need to select at least one image
                    // You can show a snackbar, an alert, or customize as needed
                    print('Please select at least one image.');
                  }
                },
                child: Text('Report Issue'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<String>> _uploadImages(List<XFile> images) async {
    List<String> imageUrls = [];
    for (XFile image in images) {
      // Upload each image to Firebase Storage
      try {
        Reference storageReference = _storage
            .ref()
            .child('issue_images/${DateTime.now().millisecondsSinceEpoch}');
        UploadTask uploadTask = storageReference.putFile(File(image.path!));
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadURL = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(downloadURL);
      } catch (e) {
        print('Error uploading image: $e');
        // Handle the error, show a snackbar, or provide feedback to the user
      }
    }
    return imageUrls;
  }

  Future<Position> _getCurrentLocation() async {
    try {
      await Geolocator.requestPermission();
      _currentPosition = await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting current location: $e');
      // Handle the error, show a snackbar, or provide feedback to the user
    }
    return _currentPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            _getCurrentLocation();
          },
          icon: Icon(Icons.my_location),
        ),
        title: Text('Road Safety App'),
        actions: [
          _user != null
              ? IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              setState(() {
                _user = null;
              });
            },
          )
              : Container(),
        ],
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0),
          zoom: 2,
        ),
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _user != null ? _reportIssue() : _showLoginDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Required'),
          content: Text('Please login to report an issue.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _signIn();
              },
              child: Text('Login'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      setState(() {
        _user = userCredential.user;
      });
    } catch (e) {
      print('Error during sign-in: $e');
      // Handle the error, show a snackbar, or provide feedback to the user
    }
  }
}

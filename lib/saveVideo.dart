import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StoreData {
  Future<String> uploadVideo(String videoplayer) async {
    Reference ref = _storage.ref().child("Videos/${DateTime.now()}.mp4");
    await ref.putFile(File(videoplayer));
    String downloadVideoURL = await ref.getDownloadURL();
    return downloadVideoURL;
  }

  Future<void> saveVideoData(String videoDownloadUrl) async {
    await _firestore.collection("videos").add({
      'url': videoDownloadUrl,
      'timeStamp': FieldValue.serverTimestamp(),
      'name': 'user Video'
    });
  }
}

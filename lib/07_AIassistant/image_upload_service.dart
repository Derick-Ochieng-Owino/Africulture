import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

Future<String?> pickAndUploadImage({ImageSource source = ImageSource.gallery}) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: source);

  if (pickedFile == null) return null;

  final file = File(pickedFile.path);
  final fileName = basename(pickedFile.path);
  final storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');

  final uploadTask = storageRef.putFile(file);
  final snapshot = await uploadTask.whenComplete(() => null);
  final downloadUrl = await snapshot.ref.getDownloadURL();

  return downloadUrl;
}

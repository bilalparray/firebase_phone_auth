import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_app/models/user_model.dart';
import 'package:firebase_auth_app/screens/otp_screen.dart';
import 'package:firebase_auth_app/utils/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _isLoading = false;
  bool get isloading => _isLoading;

  String? _uid;
  String get uid => _uid!;

  UserModel? _userModel;
  UserModel get userModel => _userModel!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; //init firebase
  final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance; //init firebase

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  AuthProvider() {
    checkSignIn();
  }

  void checkSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("is_signedin") ?? false;
    notifyListeners();
  }

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted:
              (PhoneAuthCredential phoneAuthCredential) async {},
          verificationFailed: (error) {
            throw Exception(error.message);
          },
          codeSent: (verificationId, forceResendingToken) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        OtpScreen(verificationId: verificationId)));
          },
          codeAutoRetrievalTimeout: (codeAutoRetrievalTimeout) {});
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
  }

  void verifyOtp(
      {required BuildContext context,
      required String verificationId,
      required userOtp,
      required Function onSuccess}) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential cred = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOtp);

      User? user = (await _firebaseAuth.signInWithCredential(cred)).user;
      if (user != null) {
        _uid = user.uid;
        onSuccess();
      }
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      showSnackBar(context, e.message.toString());
    }
  }

  ///databse operations
  ///
  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection("users").doc(_uid).get();
    if (snapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  void saveUserDataToFireStore(
      {required BuildContext context,
      required UserModel userModel,
      required File profilePic,
      required Function onSuccess}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await storeFileToStorage("userProfilePic/$_uid", profilePic)
          .then((value) => {
                userModel.profilePic = value,
                userModel.createdAt =
                    DateTime.now().millisecondsSinceEpoch.toString(),
                userModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber,
                userModel.uid = _firebaseAuth.currentUser!.uid,
                userModel.email = _firebaseAuth.currentUser!.email,
                userModel.name = _firebaseAuth.currentUser!.displayName,
              });
      _userModel = userModel;

      await _firebaseFirestore
          .collection("users")
          .doc(_uid)
          .set(userModel.toMap())
          .then((value) => onSuccess());
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(
        context,
        e.message.toString(),
      );
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> storeFileToStorage(String ref, File file) async {
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // store data locaaly
  saveUserDataToSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString("user_model", jsonEncode(userModel.toMap()));
  }

  setSignIn() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setBool("is_signedin", true);
    _isSignedIn = true;
    notifyListeners();
  }
}

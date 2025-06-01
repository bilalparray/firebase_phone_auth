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
  bool get isLoading => _isLoading;

  // 1) Make _uid nullable, and its getter return String? instead of String
  String? _uid;
  String? get uid => _uid;

  // 2) Make _userModel nullable, and its getter return UserModel? instead of non-nullable
  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  AuthProvider() {
    _checkSignIn();
  }

  Future<void> _checkSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    _isSignedIn = prefs.getBool("is_signedin") ?? false;
    notifyListeners();
  }

  Future<void> setSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("is_signedin", true);
    _isSignedIn = true;
    notifyListeners();
  }

  /// ─── SIGN IN WITH PHONE ───────────────────────────────────────────────────
  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Automatically signs in on Android devices with auto‐retrieval.
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (error) {
          throw Exception(error.message);
        },
        codeSent: (verificationId, forceResendingToken) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
  }

  /// ─── VERIFY OTP ────────────────────────────────────────────────────────────
  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required VoidCallback onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final creds = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOtp,
      );

      User? user = (await _firebaseAuth.signInWithCredential(creds)).user;
      if (user != null) {
        _uid = user.uid;
        onSuccess();
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ─── CHECK IF USER EXISTS IN FIRESTORE ───────────────────────────────────
  Future<bool> checkExistingUser() async {
    if (_uid == null) return false;
    final snapshot =
        await _firebaseFirestore.collection("users").doc(_uid).get();
    return snapshot.exists;
  }

  /// ─── SAVE USER DATA (NAME, EMAIL, BIO, PROFILE PIC) ────────────────────────
  void saveUserDataToFirebase({
    required BuildContext context,
    required UserModel userModel,
    required File profilePic,
    required VoidCallback onSuccess,
  }) async {
    if (_uid == null) {
      showSnackBar(context, "No authenticated user found.");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 1) Upload image to Firebase Storage.
      final imageUrl = await _uploadFile("profilePic/$_uid", profilePic);
      userModel.profilePic = imageUrl;
      userModel.createdAt = DateTime.now().millisecondsSinceEpoch.toString();
      userModel.phoneNumber = _firebaseAuth.currentUser?.phoneNumber ?? '';
      userModel.uid = _firebaseAuth.currentUser?.uid ?? '';

      // 2) Assign to local _userModel
      _userModel = userModel;

      // 3) Write to Firestore under “users/$_uid”
      await _firebaseFirestore
          .collection("users")
          .doc(_uid)
          .set(userModel.toMap());

      onSuccess();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ─── HELPER: UPLOAD FILE TO STORAGE ───────────────────────────────────────
  Future<String> _uploadFile(String path, File file) async {
    final ref = _firebaseStorage.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// ─── FETCH USER DATA FROM FIRESTORE ────────────────────────────────────────
  Future<void> getDataFromFirestore() async {
    if (_firebaseAuth.currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _firebaseFirestore
          .collection("users")
          .doc(_firebaseAuth.currentUser!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _userModel = UserModel(
          name: data['name'] as String? ?? '',
          email: data['email'] as String? ?? '',
          createdAt: data['createdAt'] as String? ?? '',
          bio: data['bio'] as String? ?? '',
          uid: data['uid'] as String? ?? '',
          profilePic: data['profilePic'] as String? ?? '',
          phoneNumber: data['phoneNumber'] as String? ?? '',
        );
        _uid = _userModel?.uid;
      }
    } catch (_) {
      // (Optional) handle errors here
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ─── SAVE USER DATA TO SHARED PREFERENCES ─────────────────────────────────
  Future<void> saveUserDataToSP() async {
    if (_userModel == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_model", jsonEncode(_userModel!.toMap()));
  }

  /// ─── GET USER DATA FROM SHARED PREFERENCES ─────────────────────────────────
  Future<void> getDataFromSP() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString("user_model") ?? '';
    if (jsonString.isEmpty) return;

    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    _userModel = UserModel.fromMap(map);
    _uid = _userModel?.uid;
    notifyListeners();
  }

  /// ─── SIGN OUT ──────────────────────────────────────────────────────────────
  Future<void> userSignOut() async {
    await _firebaseAuth.signOut();
    _isSignedIn = false;
    _userModel = null;
    _uid = null;
    notifyListeners();

    // Clear SharedPreferences entirely (all keys)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

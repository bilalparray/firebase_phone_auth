import 'package:firebase_auth_app/utils/utils.dart';
import 'package:firebase_auth_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.verificationId});
  final String verificationId;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String? otpValue;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back),
              ),
            ),
            Image.asset('assets/3.png'),
            SizedBox(
              height: 20,
            ),
            const Text(
              "OTP Verification",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter your otp here to get started.",
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black38,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Pinput(
              length: 6,
              showCursor: true,
              defaultPinTheme: PinTheme(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple),
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
              onCompleted: (value) {
                setState(() {
                  otpValue = value;
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: CustomButton(
                  text: "Verify",
                  onPressed: () {
                    if (otpValue != null) {
                      verifyOtp(context, otpValue!);
                    } else {
                      showSnackBar(context, "Please Enter OTP");
                      return;
                    }
                  }),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text("Did not recive code?",
                style: TextStyle(
                  fontSize: 12,
                )),
            const SizedBox(
              height: 15,
            ),
            const Text("Resend new code",
                style: TextStyle(fontSize: 16, color: Colors.purple)),
          ],
        ),
      ),
    )));
  }

  void verifyOtp(BuildContext context, String userOtp) {
    showSnackBar(context, userOtp);
  }
}

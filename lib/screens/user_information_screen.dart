import 'dart:io';

import 'package:firebase_auth_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();
  File? image;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 5),
          child: SingleChildScrollView(
            child: Column(
              children: [
                InkWell(
                  onTap: () {},
                  child: image == null
                      ? const CircleAvatar(
                          backgroundColor: Colors.purple,
                          radius: 50,
                          child: Icon(
                            Icons.account_circle_sharp,
                            size: 50,
                            color: Colors.white,
                          ),
                        )
                      : CircleAvatar(
                          backgroundImage: FileImage(image!),
                          radius: 50,
                        ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      //name
                      textField(
                          hindText: 'Bilal Ahmad',
                          icon: Icons.account_circle_sharp,
                          inputType: TextInputType.name,
                          maxLines: 1,
                          controller: nameController),
                      //email
                      textField(
                          hindText: 'example@gmail.com',
                          icon: Icons.email,
                          inputType: TextInputType.emailAddress,
                          maxLines: 1,
                          controller: emailController),

                      //bio
                      textField(
                          hindText: 'This is a bio',
                          icon: Icons.person,
                          inputType: TextInputType.text,
                          maxLines: 1,
                          controller: bioController),

                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                          height: 50,
                          width: double.infinity,
                          child:
                              CustomButton(text: "Continue", onPressed: () {}))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      )),
    );
  }

  Widget textField({
    required String hindText,
    required IconData icon,
    required TextInputType inputType,
    required int maxLines,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        cursorColor: Colors.purple,
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.purple,
              ),
              child: Icon(
                icon,
                size: 20,
                color: Colors.white,
              ),
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.transparent)),
            hintText: hindText,
            alignLabelWithHint: true,
            fillColor: Colors.purple.shade50,
            filled: true),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutterapp/colors.dart';
import 'package:flutterapp/widgets.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Dashboard.dart';
import 'Login.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confpasswordController = TextEditingController();

  void register() async {
    EasyLoading.show(status: "Loading");
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      print(userCredential.user!.uid);
      // Save user data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
      });

      EasyLoading.showSuccess("Registered Successfully!");
      await Future.delayed(Duration(seconds: 2));

      // Navigate to the Dashboard screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );

      print('Signup successful! User: ${userCredential.user}');
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          EasyLoading.showError("User Already Exist");
          print('Email already in use!');
        } else {
          EasyLoading.showError("Something Went Wrong");
          print('Error: ${e.code}');
        }
      } else {
        EasyLoading.showError("Something Went Wrong");
        print('Error: $e');
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                inputText(
                  controller: _nameController,
                  context: context,
                  label: "Name",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please Enter Name";
                    }
                    return null;
                  },
                ),
                inputText(
                  context: context,
                  label: 'Phone',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter phone number';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                inputText(
                  controller: _emailController,
                  context: context,
                  label: "Email",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter email';
                    }
                    final pattern =
                        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$';

                    // Create a regular expression object
                    final regExp = RegExp(pattern);

                    if (!regExp.hasMatch(value)) {
                      return 'Invalid email address';
                    }

                    return null;
                  },
                ),
                inputText(
                  controller: _passwordController,
                  context: context,
                  label: "Password",
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Enter Password";
                    }

                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                inputText(
                  controller: _confpasswordController,
                  context: context,
                  label: "Confirm Password",
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Enter Password";
                    }

                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                button(
                  context: context,
                  label: "Signup",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      register();
                    }
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already Have an Account? ",
                      style: TextStyle(fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      child: Text(
                        "Login!",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

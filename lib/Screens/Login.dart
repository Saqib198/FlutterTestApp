import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutterapp/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Dashboard.dart';
import 'SignUp.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> loginCheck(String email, String password) async {
    EasyLoading.show(status: "Loading...");
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save email and password in shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('_email', email);
      await prefs.setString('_password', password);
      print(await prefs.getString('_email'));

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard())
      );

      // Login successful, you can access the user information through userCredential.user
      print('Login successful! User: ${userCredential.user}');

    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          EasyLoading.showError("User Not Found");

          print('Email not registered!');
        } else if (e.code == 'wrong-password') {
          EasyLoading.showError("Wrong Password");
          print('Invalid credentials!');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage("assets/logo/logo.png"),
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.3,
                ),
                Text("Welcome to Test App", style: GoogleFonts.comfortaa(fontSize: 18)),
                SizedBox(height: 20),
                inputText(
                  label: "Email",
                  controller: _emailController,
                  context: context,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter email';
                    }
                    final pattern = r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$';

                    // Create a regular expression object
                    final regExp = RegExp(pattern);

                    if (!regExp.hasMatch(value)) {
                      return 'Invalid email address';
                    }

                    return null;
                  },
                ),
                inputText(
                  context: context,
                  label: 'Password',
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Enter Password";
                    }

                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                  controller: _passwordController,
                  obscureText: true,
                ),
                SizedBox(height: 15),
                button(
                  context: context,
                  label: "Login",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      loginCheck(_emailController.text, _passwordController.text);
                    }
                  },
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Doesn't Have an Account?",
                      style: TextStyle(fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Signup()));
                      },
                      child: Text(
                        "Register Now!",
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

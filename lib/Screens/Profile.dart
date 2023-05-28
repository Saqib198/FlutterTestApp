import 'package:bottom_indicator_bar_svg/bottom_indicator_bar_svg.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutterapp/widgets.dart';
import 'package:flutterapp/colors.dart';

import 'Dashboard.dart';
import 'Login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}



class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  bool isLoading = false;
  int currentIndex = 1;
  List<BottomIndicatorNavigationBarItem> items = [
    BottomIndicatorNavigationBarItem(icon: Icons.home, label: Text('Home')),
    BottomIndicatorNavigationBarItem(icon: Icons.person, label: 'Profile'),
  ];
  late String userId;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      getUserData();
    }
  }

  void getUserData() async {
    setState(() {
      isLoading = true; // Show progress indicator
    });
    DocumentSnapshot snapshot =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();
    Map<String, dynamic>? data =
    snapshot.data() as Map<String, dynamic>?;

    if (data != null) {
      setState(() {
        _nameController.text = data['name'];
        _phoneController.text = data['phone'];
        _emailController.text = data['email'];
      });
    }

    setState(() {
      isLoading = false; // Hide progress indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            onPressed: logout,
            icon: Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else
              Column(
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
                  SizedBox(height: 16.0),
                  button(
                    onPressed: updateUser,
                    label: 'Update',
                    context: context,
                  ),
                  SizedBox(height: 8.0),
                  TextButton(
                    onPressed: resetPassword,
                    child: Text('Reset Password'),
                  ),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomIndicatorBar(
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          if (index == 0) {
            // Navigate to the Dashboard screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
            );
          }
        },
        currentIndex: currentIndex,
        items: items,
        iconSize: 30.0,
        barHeight: 70.0,
        activeColor: Colors.white,
        inactiveColor: Colors.white38,
        indicatorColor: Colors.blue,
        backgroundColor: AppColors.primaryColor,
        indicatorHeight: 0,
      ),
    );
  }

  void updateUser() async {
    EasyLoading.show(status: "Updating");
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
      });

      EasyLoading.showSuccess("Profile Updated Successfully!");
    } catch (e) {
      EasyLoading.showError("Failed to update profile");
      print('Error: $e');
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  void resetPassword() async {
    String email = _emailController.text.trim();
    if (email.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Password Reset'),
            content: Text(
                'A password reset link has been sent to your email address.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Password Reset Error'),
            content: Text('Failed to send password reset email.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
        print('Error: $e');
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Password Reset Error'),
          content: Text('Please enter your email address.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

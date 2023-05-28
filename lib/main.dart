import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Firebase/firebase_options.dart';
import 'Screens/Dashboard.dart';
import 'Screens/Login.dart';

Future<void> main() async {

  late final FirebaseApp app;
  late final FirebaseAuth auth;
  WidgetsFlutterBinding.ensureInitialized();
  app= await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instanceFor(app: app);


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {



  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Technical Test',
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.comfortaa().fontFamily,

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add any initialization tasks or delays here
    // For example, you can wait for a few seconds and then navigate to the next screen
    Future.delayed(const Duration(seconds: 2), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = await prefs.getString('_email');
      String? password = await prefs.getString('_password');

      // If email and password exist, navigate to the dashboard
      if (email != null && password != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));
      }



    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image(image: AssetImage("assets/logo/logo.png"),), // Add your splash screen content here
      ),
    );
  }
}



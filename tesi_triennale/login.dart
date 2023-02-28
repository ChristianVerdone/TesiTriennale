import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterfire_ui/auth.dart';

import 'firebase_options.dart';
import 'main.dart';


late final app ;

Future<void> main() async {
   app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Layout basic',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Login(),
    );
  }
}

class Login extends StatefulWidget{
  const Login({Key? key}) : super(key: key);
  @override
  State<Login> createState() => _loginState();
}

class _loginState extends State<Login>{
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot){
        if(snapshot.hasData){
          //signed in
          return HomePage();
        }else{
          return SignInScreen(
            providerConfigs: [
              EmailProviderConfiguration()
            ]
          );
        }
      }
  ) ;

}
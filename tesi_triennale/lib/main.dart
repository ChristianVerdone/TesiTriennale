import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'home.dart';
import 'firebase_options.dart';

late final app ;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'Gestore',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Login(),
    );
  }
}

class Login extends StatefulWidget{
  const Login({super.key});
  @override
  State<Login> createState() => _loginState();
}

class _loginState extends State<Login>{
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    auth.setLanguageCode('it');
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: auth.authStateChanges(),
      builder: (context, snapshot){
        if(snapshot.hasData){
          //signed in
          return const HomePage();
        }else{
          return const SignInScreen(
            providerConfigs: [
              EmailProviderConfiguration()
            ]
          );
        }
      }
  ) ;
}
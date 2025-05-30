import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:recherchelivraisonmedicament/core/services/firebase_options.dart';
import 'package:recherchelivraisonmedicament/routes/app_routes.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Geolocator.requestPermission();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'services/presence_service.dart';
import 'services/presence_service_impl.dart';
import 'services/room_service.dart';
import 'services/room_service_impl.dart';
import 'services/auth_service.dart'; // ✅ Added
import 'screens/main_menu.dart';
import 'localization/strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    TwentyNineApp(
      firebaseService: FirebaseService(),
      presenceService: FirebasePresenceService(),
      roomService: FirestoreRoomService(),
      strings: Strings('en'),
    ),
  );
}

class TwentyNineApp extends StatelessWidget {
  final FirebaseService firebaseService;
  final PresenceService presenceService;
  final RoomService roomService;
  final Strings strings;
  final AuthService? authService; // ✅ Added for test injection

  const TwentyNineApp({
    super.key,
    required this.firebaseService,
    required this.presenceService,
    required this.roomService,
    required this.strings,
    this.authService, // ✅ Optional
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twenty Nine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: MainMenu(
        firebaseService: firebaseService,
        presenceService: presenceService,
        roomService: roomService,
        strings: strings,
        authService: authService, // ✅ Forwarded
      ),
    );
  }
}
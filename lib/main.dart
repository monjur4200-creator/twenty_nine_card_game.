import 'package:flutter/material.dart';
import 'services/firebase_service.dart';
import 'services/presence_service.dart';
import 'services/room_service.dart';
import 'screens/main_menu.dart';

void main() {
  runApp(TwentyNineApp()); // production entry point
}

class TwentyNineApp extends StatelessWidget {
  final FirebaseService firebaseService;
  final PresenceService presenceService;
  final RoomService roomService;

  /// In production you can just call `TwentyNineApp()`.
  /// In tests you can pass fakes:
  ///   `TwentyNineApp(
  ///       firebaseService: fakeService,
  ///       presenceService: fakePresence,
  ///       roomService: fakeRoom,
  ///   )`
  TwentyNineApp({
    super.key,
    FirebaseService? firebaseService,
    PresenceService? presenceService,
    RoomService? roomService,
  })  : firebaseService = firebaseService ?? FirebaseService(),
        presenceService = presenceService ?? PresenceService(),
        roomService = roomService ?? RoomService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twenty Nine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainMenu(
        firebaseService: firebaseService,
        presenceService: presenceService,
        roomService: roomService,
      ),
    );
  }
}
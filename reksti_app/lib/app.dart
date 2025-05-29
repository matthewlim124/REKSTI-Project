// lib/app.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // If you're using it
// Import your initial screen (e.g., login screen or home screen)
import 'package:reksti_app/screens/login_page.dart'; // Adjust path
import 'package:provider/provider.dart';
import 'package:reksti_app/user_provider.dart';
import 'package:reksti_app/screens/login_page.dart';
import 'package:reksti_app/screens/home_page.dart';
import 'package:reksti_app/screens/profile_page.dart';
import 'package:reksti_app/screens/scan_page.dart';

class MyApp extends StatefulWidget {
  final String initialRoute;
  final String? sessionUsername; // Username from previous session if available

  const MyApp({super.key, required this.initialRoute, this.sessionUsername});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // If a user session was detected (based on sessionUsername from main.dart),
    // tell UserProvider to initialize and load data for this user.
    if (widget.sessionUsername != null && widget.sessionUsername!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<UserProvider>(
          context,
          listen: false,
        ).initializeSession(); // initializeSession will use TokenStorage to get username
        print(
          "MyApp initState: User session detected for ${widget.sessionUsername}. UserProvider initializing session.",
        );
      });
    } else {
      print(
        "MyApp initState: No initial user session. UserProvider will load on demand after login.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reksti App', // Your app title
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ), // Example theming
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: widget.initialRoute, // Use the determined initial route
      routes: {
        '/login': (context) => const LoginPage(), // Your actual LoginPage
        '/home': (context) => const HomePage(), // Your actual HomePage
        '/profile': (context) => const ProfilePage(), // Your actual ProfilePage
        '/scan': (context) => const ScanPage(), // Your actual ScanPage
        // Define other routes here
      },
      // If routes are not behaving as expected with initialRoute, you might need a
      // navigator observer or a more robust routing package.
      // For simple cases, initialRoute works well.
    );
  }
}

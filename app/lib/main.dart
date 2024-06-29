import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/tab_screens.dart';
import 'package:flutter_application_1/screens/authentication_screen/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthChecker(),
    );
  }
}

Future<bool> checkLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email');
  final password = prefs.getString('password');
  // Check if both email and password are not null or empty
  return email != null &&
      email.isNotEmpty &&
      password != null &&
      password.isNotEmpty;
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace this with your authentication logic
    bool isAuthenticated = false;

    if (isAuthenticated) {
      return const TabScreens();
    } else {
      return const LoginScreen();
    }
  }
}

// NOTE: CÁI NÀY ĐẺ CHẠY THIỆT, Ở TRÊN ĐỂ DEV CHO TIỆN


// class AuthChecker extends StatelessWidget {
//   const AuthChecker({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<bool>(
//       future: checkLoginStatus(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         } else {
//           final isAuthenticated = snapshot.data ?? false;
//           return isAuthenticated ? const TabScreens() : const LoginScreen();
//         }
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tree/screens/homescreen.dart';
import 'package:tree/screens/loginscreen.dart';

const supabaseUrl = 'https://cgtzecimpepsoyyicwur.supabase.co';
const supabaseAnonKey = 'sb_publishable_NlrOdkMd0Jro46IQiJSelQ_NsYVpO86';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);

  runApp(const FamilyTreeApp());
}

class FamilyTreeApp extends StatelessWidget {
  const FamilyTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Tree',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const AuthGate(),
    );
  }
}

/// Watches Supabase's auth state and shows the right screen —
/// no manual navigation calls needed after login/logout.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

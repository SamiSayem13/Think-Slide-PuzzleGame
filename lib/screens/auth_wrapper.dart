import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/game_loading_screen.dart';
import 'login_screen.dart';
import 'username_setup_screen.dart';
import 'home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthService.localGuestNotifier,
      builder: (context, isLocalGuest, _) {
        if (isLocalGuest) {
          return const HomeScreen();
        }

        return StreamBuilder<User?>(
          stream: AuthService.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const GameLoadingScreen(message: "Initializing...");
            }

            final user = snapshot.data;

            if (user == null) {
              return const LoginScreen();
            }

            // For anonymous users (Guests), we can auto-create a profile if it's missing
            // to ensure they enter the game immediately.
            return FutureBuilder<DocumentSnapshot>(
              future: DatabaseService.getUserData(user.uid),
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState == ConnectionState.waiting) {
                  return const GameLoadingScreen(message: "Loading your world...");
                }

                if (!profileSnapshot.hasData || !profileSnapshot.data!.exists) {
                  return const UsernameSetupScreen();
                }

                // If it's a guest account that has a Firestore document but is missing the 'username' field
                final data = profileSnapshot.data!.data() as Map<String, dynamic>?;
                if (data == null || data['username'] == null || (data['username'] as String).startsWith('Guest_')) {
                   // If they haven't set a real username yet, let them
                   return const UsernameSetupScreen();
                }

                // User has a profile with a proper username.
                DatabaseService.syncProgressToLocal(user.uid);
                return const HomeScreen();
              },
            );
          },
        );
      },
    );
  }
}

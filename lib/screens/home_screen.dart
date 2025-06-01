import 'package:firebase_auth_app/provider/auth_provider.dart';
import 'package:firebase_auth_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final ap = Provider.of<AuthProvider>(context, listen: false);

    // Step 1: Try loading from SharedPreferences
    ap.getDataFromSP().then((_) {
      // If still null after reading from SP, fetch from Firestore
      if (ap.userModel == null) {
        ap.getDataFromFirestore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen here so UI rebuilds whenever isLoading or userModel changes.
    final ap = Provider.of<AuthProvider>(context);

    // 1) Show a loader while any data‐fetch/save operation is in progress
    if (ap.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 2) After loading completes, check if userModel is still null.
    //    If it is, display a “no data” message.
    final user = ap.userModel;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("No user data found"),
        ),
      );
    }

    // 3) userModel is non‐null—display the main Home UI.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text("FlutterPhone Auth"),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              ap.userSignOut().then(
                    (value) => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomeScreen(),
                      ),
                      (route) => false,
                    ),
                  );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile picture (shows placeholder if null/empty)
            if (user.profilePic != null && user.profilePic!.isNotEmpty)
              CircleAvatar(
                backgroundColor: Colors.purple,
                backgroundImage: NetworkImage(user.profilePic!),
                radius: 50,
              )
            else
              const CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 50,
                child: Icon(Icons.person, size: 40),
              ),

            const SizedBox(height: 20),

            // Display Name (fallback to "No Name" if null/empty)
            Text(
              (user.name != null && user.name!.trim().isNotEmpty)
                  ? user.name!
                  : "No Name",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),

            // Phone Number (once logged in with phone‐auth, this should be non‐null)
            Text(
              user.phoneNumber ?? "No Phone",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // Email (fallback to "No Email")
            Text(
              (user.email != null && user.email!.trim().isNotEmpty)
                  ? user.email!
                  : "No Email",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // Bio (fallback to "No Bio")
            Text(
              (user.bio != null && user.bio!.trim().isNotEmpty)
                  ? user.bio!
                  : "No Bio",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

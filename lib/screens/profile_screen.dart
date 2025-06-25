import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../componants/my_textfield.dart';
import '../componants/wave_clipper.dart';
import '../componants/my_button.dart';
import '../componants/my_card.dart';
import '../main.dart'; // Import for the global supabase client

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Fetches user data from Supabase and updates the state.
  void _loadUserData() {
    // A post-frame callback ensures that the context is available
    // and that we're not trying to update state during a build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = supabase.auth.currentUser;
      if (user != null && mounted) {
        setState(() {
          // The username is stored in the user_metadata field.
          _username = user.userMetadata?['username'] ?? 'No username set';
          _email = user.email ?? 'No email found';
        });
      }
    });
  }

  void _showChangePasswordDialog(BuildContext context) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    String? errorMessage;
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Change Password"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyTextfield(
                    controller: newPasswordController,
                    hintText: "New Password",
                    obscureText: true,
                    valMessage: "Enter a new password",
                  ),
                  const SizedBox(height: 15),
                  MyTextfield(
                    controller: confirmPasswordController,
                    hintText: "Confirm New Password",
                    obscureText: true,
                    valMessage: "Confirm your new password",
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("Cancel"),
                ),
                if (isUpdating)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: CircularProgressIndicator(),
                  )
                else
                  TextButton(
                    onPressed: () async {
                      // --- 2. PASSWORD UPDATE LOGIC ---
                      final newPassword = newPasswordController.text.trim();
                      final confirmPassword = confirmPasswordController.text
                          .trim();

                      // --- Validation ---
                      if (newPassword.isEmpty || confirmPassword.isEmpty) {
                        setDialogState(
                          () => errorMessage = "Fields cannot be empty.",
                        );
                        return;
                      }
                      if (newPassword.length < 6) {
                        setDialogState(
                          () => errorMessage =
                              "Password must be at least 6 characters.",
                        );
                        return;
                      }
                      if (newPassword != confirmPassword) {
                        setDialogState(
                          () => errorMessage = "Passwords do not match.",
                        );
                        return;
                      }

                      setDialogState(() {
                        isUpdating = true;
                        errorMessage = null;
                      });

                      try {
                        // --- Supabase Call ---
                        await supabase.auth.updateUser(
                          UserAttributes(password: newPassword),
                        );

                        if (mounted) {
                          Navigator.of(dialogContext).pop(); // Close dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Password updated successfully!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } on AuthException catch (e) {
                        setDialogState(() {
                          isUpdating = false;
                          errorMessage = e.message;
                        });
                      } catch (e) {
                        setDialogState(() {
                          isUpdating = false;
                          errorMessage = "An unexpected error occurred.";
                        });
                      }
                    },
                    child: const Text("Update"),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        fit: StackFit.loose,
        alignment: AlignmentDirectional.topCenter,
        children: [
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 450,
              decoration: const BoxDecoration(color: Colors.teal),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 60, bottom: 20),
                    child: Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.teal[200],
                      child: const Icon(
                        Icons.person,
                        size: 140,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _username,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    _email,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black54,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 40, 15, 10),
                    child: MyButton(
                      button_msg: "Change Password",
                      button_icon: const Icon(Icons.lock_outline),
                      onPressed: () async {
                        _showChangePasswordDialog(context);
                      },
                      bgColor: Colors.teal,
                      fgColor: Colors.white,
                      padding: MediaQuery.of(context).size.width < 500? 10:15,
                      borderRadius: 15,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 40),
                    child: MyButton(
                      button_msg: "Log Out",
                      button_icon: const Icon(Icons.logout),
                      onPressed: () async {
                        await supabase.auth.signOut();
                      },
                      bgColor: Colors.red[50]!,
                      fgColor: Colors.red[700]!,
                      padding: MediaQuery.of(context).size.width < 500? 10:15,
                      borderRadius: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

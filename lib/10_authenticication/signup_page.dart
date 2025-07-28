import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '/11_home/widgets/social_button.dart';
import 'auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> registerUser() async {
    debugPrint("Attempting to register user...");
    debugPrint("Email: ${emailController.text.trim()}");
    debugPrint("Password Length: ${passwordController.text.trim().length}");

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      debugPrint("Registration successful");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Registered Successfully"),
        backgroundColor: Colors.green,
      ));

      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Registration failed";
      debugPrint("FirebaseAuthException: ${e.code}");

      if (e.code == 'weak-password') {
        errorMessage = "Password is too weak.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "Email is already in use.";
      } else {
        errorMessage = e.message ?? errorMessage;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ));
    } catch (e) {
      debugPrint("Unknown registration error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthMethods>(context);

    return Scaffold(
      body: Stack(
        children: [
      // 🌄 Background image
      SizedBox.expand(
      child: Image.asset(
        'assets/back6.jpg', // 👈 Change path to your actual image
        fit: BoxFit.cover,
      ),
    ),

    // 🧼 Optional overlay (for darkening the image)
    Container(
    color: Colors.black.withOpacity(0.2),
    ),

    // ✅ Existing content
    SafeArea(
    child: Padding(
    padding: const EdgeInsets.all(24.0),
    child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: const Text("Sign Up Account",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Center(
                  child: const Text("Enter your personal data to create your account.",
                      style: TextStyle(fontSize: 16, color: Colors.black54)),
                ),
                const SizedBox(height: 24),

                SocialButton(
                  label: "Google",
                  logoPath: "assets/google.png",
                  onPressed: auth.isSigningIn
                      ? null
                      : () {
                    debugPrint("Pressed Google Sign In");
                    auth.signInWithGoogle(context);
                  },
                ),
                const SizedBox(height: 12),
                SocialButton(
                  label: "Apple",
                  logoPath: "assets/apple.png",
                  onPressed: () {
                    debugPrint("Apple Sign In pressed");
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("OR"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          labelText: "First Name",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          debugPrint("First name input: $value");
                          return value!.isEmpty ? "Enter first name" : null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          labelText: "Last Name",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          debugPrint("Last name input: $value");
                          return value!.isEmpty ? "Enter last name" : null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email Address",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    debugPrint("Email input: $value");
                    return value!.isEmpty ? "Please enter email" : null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        debugPrint("Toggled password visibility");
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    debugPrint("Password input: $value");
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    } else if (value.length < 6) {
                      return 'Must contain at least 6 characters.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    debugPrint("Sign Up button pressed");
                    if (_formKey.currentState!.validate()) {
                      registerUser();
                    } else {
                      debugPrint("Form validation failed");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an Account?"),
                    TextButton(
                      onPressed: () {
                        debugPrint("Navigate to login page");
                        Navigator.pushReplacementNamed(context, "/login");
                      },
                      child: const Text("Sign In"),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ]
      ),
    );
  }
}

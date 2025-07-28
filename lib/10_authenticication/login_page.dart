// lib/screens/login_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '/11_home/widgets/social_button.dart';
import 'auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ));
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
                const Text("Welcome Back!",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Enter your login information",
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 24),

                // Social login buttons
                SocialButton(
                  label: "Google",
                  logoPath: "assets/google.png",
                  onPressed: auth.isSigningIn
                      ? null
                      : () => auth.signInWithGoogle(context),
                ),



                const SizedBox(height: 12),
                SocialButton(
                  label: "Apple",
                  logoPath: "assets/apple.png",
                  onPressed: () {}, // TODO: Add Apple login logic
                ),
                const SizedBox(height: 12),
                SocialButton(
                  label: "Facebook",
                  logoPath: "assets/facebook.png",
                  onPressed: () {}, // TODO: Add Facebook login logic
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

                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email Address",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? "Please enter your email" : null,
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
                      onPressed: () => setState(() {
                        _obscureText = !_obscureText;
                      }),
                    ),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? "Please enter your password" : null,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, "/forgot_password"),
                    child: const Text("Forgot Password?"),
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      login();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Sign In",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, "/signup"),
                      child: const Text("Sign Up"),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ],
      ),
    );
  }
}

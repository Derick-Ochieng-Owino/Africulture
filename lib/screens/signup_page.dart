import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../service/auth.dart';
import '../widgets/button.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phonenumberController = TextEditingController();

  Future<void> registerUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Registered Successfully", style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.blueGrey,
      ));

      // Navigate to login page or home page
      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Registration failed";
      if (e.code == 'weak-password') {
        errorMessage = "Password is too weak.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "Email is already in use.";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset("assets/b.png",
              fit: BoxFit.cover,
            ),
          ),

          // Foreground Content with transparent background
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5), // Optional dark overlay
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 40),

                  // Heading
                  const Center(
                    child: Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter your email'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter your password'
                              : null,
                        ),
                        const SizedBox(height: 30),

                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              registerUser();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF273671),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text("Sign Up",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              )
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      "or Log In with",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomButton(
                        onPressed: () {
                          AuthMethods().signInWithGoogle(context);
                        },
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // ✅ center contents
                          children: [
                            const Text(
                              'Continue with',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.orangeAccent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Image.asset("assets/google.png", height: 25),
                          ],
                        ),
                      ),

                      //Facebook
                      const SizedBox(height: 15),
                      CustomButton(
                        onPressed: () {
                          // Facebook sign-in logic
                        },
                        color: Colors.blueGrey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // ✅ center contents
                          children: [
                            const Text(
                              'Continue with',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Image.asset("assets/facebook.png", height: 30),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),
                      CustomButton(
                        onPressed: () {
                          // Apple sign-in logic
                        },
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // ✅ center contents
                          children: [
                            const Text(
                              'Continue with',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Image.asset("assets/apple.png", height: 30),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?",
                              style: TextStyle(color: Colors.white)),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, "/login");
                            },
                            child: const Text("Log In",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ],
                      )
                    ],
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
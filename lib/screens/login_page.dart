import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../service/auth.dart';
import '../pages/home.dart';
import 'package:africulture/widgets/button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "", password = "";

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> userLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.orangeAccent,
        content: Text(message, style: const TextStyle(fontSize: 18.0)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/b.png",
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 20.0,
                          right: 20.0,
                          top: 60.0,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Welcome Back",
                              style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 30.0),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0, horizontal: 30.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: TextFormField(
                                      controller: emailController,
                                      validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Please enter email'
                                          : null,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Email",
                                        hintStyle: TextStyle(
                                            color: Colors.grey, fontSize: 18.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30.0),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0, horizontal: 30.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: TextFormField(
                                      controller: passwordController,
                                      obscureText: true,
                                      validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Please enter password'
                                          : null,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Password",
                                        hintStyle: TextStyle(
                                            color: Colors.grey, fontSize: 18.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30.0),
                                  GestureDetector(
                                    onTap: () {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          email = emailController.text;
                                          password = passwordController.text;
                                        });
                                        userLogin();
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 13.0, horizontal: 30.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF279671),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Sign In",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/forgot_password');
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(height: 40.0),
                            const Text(
                              "or Log In with",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 30.0),


                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 15),
                                CustomButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/phone-signin');
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
                                      Image.asset("assets/phone.png", height: 30),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 15,),
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


                              ],
                            ),

                            const SizedBox(height: 40.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account?",
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(width: 5.0),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/signup');
                                  },
                                  child: const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
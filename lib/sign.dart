import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  String? errorMessage;

  String selectedRole = "user";

  Future<void> signUp() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final uid = credential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF311B92),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.person_add_alt_1,
                  size: 70,
                  color: Color(0xFF673AB7),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 25),

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Register As",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

                RadioListTile<String>(
                  title: const Text("User"),
                  value: "user",
                  groupValue: selectedRole,
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),

                RadioListTile<String>(
                  title: const Text("Admin"),
                  value: "admin",
                  groupValue: selectedRole,
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),

                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF673AB7),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  child: const Text("Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final nameController = TextEditingController();
  final passController = TextEditingController();
  final keyForm = GlobalKey<FormState>();
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _slideController = AnimationController(duration: const Duration(milliseconds: 1400), vsync: this);
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    nameController.dispose();
    passController.dispose();
    super.dispose();
  }

  void login() {
    if (keyForm.currentState!.validate()) {
      Navigator.pushReplacementNamed(context, "/home", arguments: nameController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn)),
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 20 : 40),
                  child: Card(
                    elevation: 20,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFAFAFA), Color(0xFFF5F5F5)],
                        ),
                      ),
                      padding: EdgeInsets.all(isMobile ? 28 : 40),
                      child: Form(
                        key: keyForm,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ScaleTransition(
                              scale: Tween<double>(begin: 0.5, end: 1).animate(CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut)),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF667eea).withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.trending_up, size: 60, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Habit Tracker",
                              style: TextStyle(
                                fontSize: isMobile ? 32 : 36,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF667eea),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Build better habits every day",
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 15,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 40),
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: "Username",
                                prefixIcon: const Icon(
                                  Icons.person_outline,
                                  color: Color(0xFF667eea),
                                ),
                                floatingLabelStyle: const TextStyle(
                                  color: Color(0xFF667eea),
                                  fontWeight: FontWeight.bold,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF667eea),
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF667eea),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: (v) => v!.isEmpty ? "Enter username" : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: passController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFF667eea),
                                ),
                                floatingLabelStyle: const TextStyle(
                                  color: Color(0xFF667eea),
                                  fontWeight: FontWeight.bold,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF667eea),
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF667eea),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: (v) => v!.length < 4 ? "Min 4 characters" : null,
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF764ba2).withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: MaterialButton(
                                  onPressed: login,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Text(
                                    "LOGIN",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

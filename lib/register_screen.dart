import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isPasswordVisible = false;
  String generatedOtp = '';

  // Fungsi untuk menghasilkan OTP
  String generateOTP() {
    var rng = Random();
    String otp = '';
    for (int i = 0; i < 6; i++) {
      otp += rng.nextInt(10).toString();
    }
    return otp;
  }

  // Fungsi untuk mengirim OTP melalui WhatsApp
  Future<void> sendOTPViaWhatsApp(String phoneNumber, String otp) async {
    const String apiUrl = 'https://api.fonnte.com/send';
    const String apiKey = '6F1ZFY+91YEDz@9x@yA4';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': apiKey,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'target': phoneNumber,
          'message': 'Kode otp anda : $otp jangan sebarkan ke teman anda',
          'countryCode': '62',
          'delay': '2',
        },
      );

      if (response.statusCode == 200) {
        print('OTP sent successfully');
      } else {
        print('Failed to send OTP: ${response.body}');
      }
    } catch (e) {
      print('Error sending OTP: $e');
    }
  }


  void _register() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await _saveUserToFirestore(userCredential.user);

      generatedOtp = generateOTP();
      await sendOTPViaWhatsApp(_phoneNumberController.text, generatedOtp);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPScreen(
            phoneNumber: _phoneNumberController.text,
            sentOtp: generatedOtp,
          ),
        ),
      );
    } catch (e) {
      print('Error registering user: $e');
    }
  }

  Future<void> _saveUserToFirestore(User? user) async {
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      await userRef.set({
        'uid': user.uid,
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneNumberController.text,
        'createdAt': DateTime.now(),
      });
      print('User saved to Firestore');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            left: -50,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBE6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -75,
            top: -75,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0xFFFE724C),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 100),
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField('Full name', _fullNameController),
                  const SizedBox(height: 20),
                  _buildTextField('Phone Number', _phoneNumberController),
                  const SizedBox(height: 20),
                  _buildTextField('E-mail', _emailController),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFE724C), width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFE724C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'SIGN UP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: Color(0xFF5B5B5E)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(color: Color(0xFFFE724C)),
                          ),
                        ),
                      ],
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFE724C), width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

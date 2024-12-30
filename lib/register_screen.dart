import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Form and Controller
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  // Firebase Instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late FirebaseDatabase _database;

  // State Variables
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _generatedOtp = '';

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  // Initialize Firebase Database
  void _initializeFirebase() async {
    await Firebase.initializeApp();
    _database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://regist-4905e-default-rtdb.asia-southeast1.firebasedatabase.app',
    );
  }

  // Generate 6-digit OTP
  String _generateOTP() {
    final random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  // Send OTP via WhatsApp
  Future<bool> _sendOTPViaWhatsApp(String phoneNumber, String otp) async {
    const apiUrl = 'https://api.fonnte.com/send';
    const apiKey = '6F1ZFY+91YEDz@9x@yA4';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': apiKey,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'target': phoneNumber,
          'message': 'Kode OTP Anda: $otp. Jangan sebarkan ke siapapun.',
          'countryCode': '62',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      _showErrorDialog('Gagal mengirim OTP: $e');
      return false;
    }
  }

  // User Registration Process
  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create user in Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        // Save user data to Firestore
        await _saveUserToFirestore(user);
        
        // Save user data to Realtime Database
        await _saveUserToRealtimeDatabase(user);

        // Generate and send OTP
        _generatedOtp = _generateOTP();
        final otpSent = await _sendOTPViaWhatsApp(
          _phoneNumberController.text.trim(), 
          _generatedOtp
        );

        if (otpSent) {
          // Navigate to OTP Verification Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                phoneNumber: _phoneNumberController.text.trim(),
                sentOtp: _generatedOtp,
              ),
            ),
          );
        } else {
          _showErrorDialog('Gagal mengirim OTP. Silakan coba lagi.');
        }
      }
    } on FirebaseAuthException catch (e) {
      _handleRegistrationError(e);
    } catch (e) {
      _showErrorDialog('Registrasi gagal. Silakan coba lagi.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Handle Firebase Authentication Errors
  void _handleRegistrationError(FirebaseAuthException e) {
    String errorMessage = 'Terjadi kesalahan';
    switch (e.code) {
      case 'weak-password':
        errorMessage = 'Kata sandi terlalu lemah.';
        break;
      case 'email-already-in-use':
        errorMessage = 'Akun dengan email ini sudah ada.';
        break;
      case 'invalid-email':
        errorMessage = 'Alamat email tidak valid.';
        break;
      default:
        errorMessage = e.message ?? 'Registrasi gagal';
    }
    _showErrorDialog(errorMessage);
  }

  // Save User to Firestore
  Future<void> _saveUserToFirestore(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'fullName': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phoneNumber': _phoneNumberController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Save User to Realtime Database
  Future<void> _saveUserToRealtimeDatabase(User user) async {
    await _database.ref('users/${user.uid}').set({
      'uid': user.uid,
      'fullName': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phoneNumber': _phoneNumberController.text.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Show Error Dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kesalahan'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Oke'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2B961F), Color(0xFFFFEBE6)], // Ganti warna di sini
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.4, 1],
              ),
            ),
          ),

          // Decorative Circles
          ..._buildDecorativeCircles(),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      
                      // Title
                      Text(
                        'Buat Akun',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Full Name Field
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'Nama Lengkap',
                        validator: (value) => _validateField(value, 'Nama lengkap'),
                      ),
                      const SizedBox(height: 20),

                      // Phone Number Field
                      _buildTextField(
                        controller: _phoneNumberController,
                        label: 'Nomor Telepon',
                        keyboardType: TextInputType.phone,
                        validator: (value) => _validatePhoneNumber(value),
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => _validateEmail(value),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      _buildPasswordField(),
                      const SizedBox(height: 30),

                      // Register Button
                      _buildRegisterButton(),
                      const SizedBox(height: 20),

                      // Login Option
                      _buildLoginOption(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Validation Methods
  String? _validateField(String? value, String fieldName) {
    return value == null || value.trim().isEmpty 
      ? 'Harap masukkan $fieldName' 
      : null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Harap masukkan nomor telepon';
    }
    // Indonesian phone number validation
    final phoneRegex = RegExp(r'^(^\+62|62|^0)(\d{9,12})$');
    return phoneRegex.hasMatch(value.trim()) 
      ? null 
      : 'Nomor telepon tidak valid';
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Harap masukkan email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(value.trim()) 
      ? null 
      : 'Email tidak valid';
  }

  // Decorative Circles
  List<Widget> _buildDecorativeCircles() {
    return [
      Positioned(
        left: -80,
        top: -100,
        child: _buildCircle(250, 250, Color(0xFFFFEBE6)),
      ),
      Positioned(
        right: -70,
        top: -120,
        child: _buildCircle(200, 200, Color(0xFF2B961F).withOpacity(0.3)), // Ganti warna di sini
      ),
      Positioned(
        left: -150,
        bottom: -150,
        child: _buildCircle(350, 350, Color(0xFF2B961F).withOpacity(0.1)), // Ganti warna di sini
      ),
      Positioned(
        right: -100,
        bottom: -100,
        child: _buildCircle(300, 300, Color(0xFFFFEBE6).withOpacity(0.5)),
      ),
    ];
  }

  // Circle Widget
  Widget _buildCircle(double width, double height, Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  // Text Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }

  // Password Field
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Kata Sandi',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Harap masukkan kata sandi';
        }
        return value.length < 6 
          ? 'Kata sandi minimal 6 karakter' 
          : null;
      },
    );
  }

  // Register Button
  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _register,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF2B961F), // Ganti warna di sini
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        _isLoading ? 'Mendaftar...' : 'DAFTAR',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // Login Option
  Widget _buildLoginOption() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Sudah punya akun? ',
            style: TextStyle(color: Colors.white),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Masuk',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

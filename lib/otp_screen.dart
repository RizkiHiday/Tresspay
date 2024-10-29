import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // Import login screen

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String sentOtp;

  const OTPScreen({Key? key, required this.phoneNumber, required this.sentOtp}) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  late List<String> otp = List.filled(6, ''); // Array to store OTP digits

  // Function to verify OTP
  void _verifyOTP() async {
    try {
      String enteredOtp = otp.join(); // Combine all OTP digits into one string

      if (enteredOtp == widget.sentOtp) {
        print('OTP verification successful');

        // Redirect to Login Screen after OTP verification
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(), // Navigate to login screen
          ),
        );
      } else {
        print('Invalid OTP');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP')),
        );
      }
    } catch (e) {
      print('Error during OTP verification: $e');
    }
  }

  // OTP Input Widget
  Widget _buildOtpInput(int index) {
    return SizedBox(
      width: 50,
      height: 50,
      child: TextFormField(
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24),
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '',
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.orange),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            otp[index] = value;
            if (index < 5) {
              FocusScope.of(context).nextFocus(); // Move to next field
            } else {
              FocusScope.of(context).unfocus(); // Close keyboard on last input
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Circles
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
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Verification Code',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Sofia Pro',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    text: 'Please type the verification code sent to ',
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                    children: [
                      TextSpan(
                        text: widget.phoneNumber,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) => _buildOtpInput(index)),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Resend OTP function
                  },
                  child: const Text(
                    "I don't receive a code! Please resend",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: Color(0xFFFE724C),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    child: Text(
                      'VERIFY OTP',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white, // Set the text color to white
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

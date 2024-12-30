import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String sentOtp;

  const OTPScreen({
    Key? key,
    required this.phoneNumber,
    required this.sentOtp,
  }) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  // OTP Controllers
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  // Countdown Timer
  int _resendCountdown = 60;
  bool _canResendOTP = false;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // Start Resend OTP Countdown
  void _startResendCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _resendCountdown--;
          if (_resendCountdown > 0) {
            _startResendCountdown();
          } else {
            _canResendOTP = true;
          }
        });
      }
    });
  }

  // Verify OTP
  void _verifyOTP() {
    // Combine OTP digits
    String enteredOtp = _otpControllers
        .map((controller) => controller.text)
        .join();

    // Validate OTP
    if (enteredOtp == widget.sentOtp && enteredOtp.length == 6) {
      _showSuccessDialog();
    } else {
      _showErrorDialog();
    }
  }

  // Success Dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verifikasi Berhasil'),
        content: const Text('OTP telah diverifikasi dengan sukses.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }

  // Error Dialog
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verifikasi Gagal'),
        content: const Text('Kode OTP yang Anda masukkan salah.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  // Resend OTP
  void _resendOTP() {
    if (_canResendOTP) {
      // TODO: Implement OTP resend logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode OTP baru telah dikirim')),
      );

      // Reset countdown
      setState(() {
        _resendCountdown = 60;
        _canResendOTP = false;
      });
      _startResendCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Gradient Background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2B961F), Color(0xFFFFEBE6)],
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
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      minWidth: constraints.maxWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 100),

                          // Title
                          Text(
                            'Verifikasi Kode',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          // Subtitle
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: 'Masukkan kode verifikasi\n'
                                  'yang dikirim ke ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                              children: [
                                TextSpan(
                                  text: widget.phoneNumber,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // OTP Input Fields in a single row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              6,
                              (index) => _buildOtpInputField(index),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Resend OTP
                          _buildResendOTPSection(),
                          const SizedBox(height: 40),

                          // Verify Button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: _buildVerifyButton(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // OTP Input Field
  Widget _buildOtpInputField(int index) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 22,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            // Move focus to next field
            if (index < 5) {
              FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
            } else {
              // Last field, unfocus
              FocusScope.of(context).unfocus();
            }
          } else if (value.isEmpty && index > 0) {
            // Move focus to previous field if current is empty
            FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
          }
        },
      ),
    );
  }

  // Resend OTP Section
  Widget _buildResendOTPSection() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          _canResendOTP
              ? 'Kirim ulang kode'
              : 'Kirim ulang dalam $_resendCountdown detik',
          style: TextStyle(
            color: _canResendOTP ? Colors.white : Colors.white54,
          ),
        ),
        if (_canResendOTP)
          TextButton(
            onPressed: _resendOTP,
            child: const Text(
              'Kirim Ulang',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  // Verify Button
  Widget _buildVerifyButton() {
    return ElevatedButton(
      onPressed: _verifyOTP,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF2B961F),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Verifikasi',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
        child: _buildCircle(200, 200, Color(0xFF2B961F).withOpacity(0.3)),
      ),
      Positioned(
        left: -150,
        bottom: -150,
        child: _buildCircle(350, 350, Color(0xFF2B961F).withOpacity(0.1)),
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
}

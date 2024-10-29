import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final String userId;

  ProfileSettingsScreen({required this.userId});

  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  // TextEditingController for fields
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _genderController = TextEditingController();
  DateTime? _birthDate;

  Future<void> getUserData() async {
    var doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    var data = doc.data();
    if (data != null) {
      setState(() {
        _fullNameController.text = data['fullName'] ?? '';
        _emailController.text = data['email'] ?? '';
        _addressController.text = data['address'] ?? '';
        _phoneController.text = data['phoneNumber'] ?? '';
        _genderController.text = data['gender'] ?? '';
        _birthDate = data['birthDate'] != null ? (data['birthDate'] as Timestamp).toDate() : null;
        _isLoading = false;
      });
    }
  }

  Future<void> saveUserData() async {
    await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
      'fullName': _fullNameController.text,
      'email': _emailController.text,
      'address': _addressController.text,
      'phoneNumber': _phoneController.text,
      'gender': _genderController.text,
      'birthDate': _birthDate != null ? Timestamp.fromDate(_birthDate!) : null,
    });
  }

  Future<void> deleteAccount() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).delete();
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) await user.delete();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete account: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Profile Setting', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Top Decoration
          Positioned(
            left: -50,
            top: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Color(0xFFFFEBE6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -30,
            top: -60,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Color(0xFFFE724C).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Profile Form with SingleChildScrollView
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.pinkAccent,
                              child: Icon(Icons.person, size: 50, color: Colors.white),
                            ),
                            Positioned(
                              bottom: 0,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.camera_alt, color: Colors.black, size: 18),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        _buildTextField(
                          controller: _fullNameController,
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'Enter your email',
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: _addressController,
                          labelText: 'Address',
                          hintText: 'Enter your address',
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _genderController,
                                labelText: 'Gender',
                                hintText: 'Enter your gender',
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _phoneController,
                                labelText: 'Phone Number',
                                hintText: 'Enter your phone number',
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _selectBirthDate(context),
                          child: AbsorbPointer(
                            child: _buildTextField(
                              labelText: 'Birth Date',
                              hintText: 'Select birth date',
                              controller: TextEditingController(
                                text: _birthDate != null
                                    ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                                    : '',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              saveUserData().then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated')));
                                Navigator.pop(context);
                              });
                            }
                          },
                          child: Text('Simpan Perubahan', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFE724C),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.5)),
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Hapus Akun"),
                                content: Text("Serius mau hapus akun kamu?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: Text("Gajadi")),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      deleteAccount();
                                    },
                                    child: Text("Hapus", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          ),
                          child: Text('Hapus Akun', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 196, 23, 23),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.5)),
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                        SizedBox(height: 20), // Extra space to avoid overflow
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Please enter $labelText' : null,
      ),
    );
  }
}

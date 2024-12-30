import 'package:flutter/material.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';  
import 'package:firebase_auth/firebase_auth.dart';  
import 'package:firebase_core/firebase_core.dart';  
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Realtime Database  

class ProfileSettingsScreen extends StatefulWidget {  
  final String userId;  

  ProfileSettingsScreen({required this.userId});  

  @override  
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();  
}  

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {  
  final _formKey = GlobalKey<FormState>();  
  bool _isLoading = true;  

  // TextEditingController untuk field  
  final _fullNameController = TextEditingController();  
  final _emailController = TextEditingController();  
  final _addressController = TextEditingController();  
  final _phoneController = TextEditingController();  
  String? _gender; // Menggunakan String untuk gender  
  DateTime? _birthDate;  

  FirebaseDatabase? _database;  

  @override  
  void initState() {  
    super.initState();  
    // Inisialisasi Firebase terlebih dahulu  
    Firebase.initializeApp().then((value) {  
      _database = FirebaseDatabase.instanceFor(  
        app: Firebase.app(),  
        databaseURL: 'https://regist-4905e-default-rtdb.asia-southeast1.firebasedatabase.app/', // Ganti dengan URL Realtime Database Anda  
      );  
      getUserData();  
    }).catchError((error) {  
      print('Firebase initialization failed: $error');  
    });  
  }  

  // Mengambil data pengguna dari Firebase Firestore dan Realtime Database  
  Future<void> getUserData() async {  
    // Ambil data dari Firestore  
    var firestoreDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();  
    if (firestoreDoc.exists) {  
      var data = firestoreDoc.data()!;  
      setState(() {  
        _fullNameController.text = data['fullName'] ?? '';  
        _emailController.text = data['email'] ?? '';  
        _addressController.text = data['address'] ?? '';  
        _phoneController.text = data['phoneNumber'] ?? '';  
        _gender = data['gender'] ?? ''; // Set gender dari data  
        _birthDate = data['birthDate'] != null ? DateTime.parse(data['birthDate']) : null;  
        _isLoading = false;  
      });  
    } else {  
      print('No user data found in Firestore');  
    }  

    // Ambil data dari Realtime Database  
    var ref = _database?.ref('users/${widget.userId}');  
    if (ref != null) {  
      ref.once().then((DatabaseEvent event) {  
        var data = event.snapshot.value as Map<dynamic, dynamic>?;  
        if (data != null) {  
          setState(() {  
            _fullNameController.text = data['fullName'] ?? '';  
            _emailController.text = data['email'] ?? '';  
            _addressController.text = data['address'] ?? '';  
            _phoneController.text = data['phoneNumber'] ?? '';  
            _gender = data['gender'] ?? ''; // Set gender dari data  
            _birthDate = data['birthDate'] != null ? DateTime.parse(data['birthDate']) : null;  
          });  
        }  
      }).catchError((error) {  
        print('Error getting data from Realtime Database: $error');  
      });  
    }  
  }  

  // Menyimpan data pengguna ke Firebase Firestore dan Firebase Realtime Database  
  Future<void> saveUserData() async {  
    // Simpan ke Firestore  
    await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({  
      'fullName': _fullNameController.text,  
      'email': _emailController.text,  
      'address': _addressController.text,  
      'phoneNumber': _phoneController.text,  
      'gender': _gender, // Simpan gender  
      'birthDate': _birthDate != null ? _birthDate!.toIso8601String() : null,  
    }).catchError((error) {  
      print("Error updating Firestore: $error");  
    });  

    // Simpan ke Realtime Database  
    var ref = _database?.ref('users/${widget.userId}');  
    if (ref != null) {  
      await ref.update({  
        'fullName': _fullNameController.text,  
        'email': _emailController.text,  
        'address': _addressController.text,  
        'phoneNumber': _phoneController.text,  
        'gender': _gender, // Simpan gender  
        'birthDate': _birthDate != null ? _birthDate!.toIso8601String() : null,  
      }).then((_) {  
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated')));  
      }).catchError((error) {  
        print("Error updating Realtime Database: $error");  
      });  
    }  
  }  

  // Menghapus akun pengguna dari Firebase Firestore dan Realtime Database  
  Future<void> deleteAccount() async {  
    try {  
      // Hapus data dari Firestore  
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).delete();  

      // Hapus data dari Realtime Database  
      await _database?.ref('users/${widget.userId}').remove();  

      // Hapus akun dari Firebase Authentication  
      User? user = FirebaseAuth.instance.currentUser;  
      if (user != null) {  
        await user.delete();  
      }  

      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);  
    } catch (e) {  
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete account: $e')));  
    }  
  }  

  // Memilih tanggal lahir  
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
      backgroundColor: Colors.white,  
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
          // Large gradient background  
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
          // Decorative circles as background elements  
          Positioned(  
            left: -80,  
            top: -100,  
            child: Container(  
              width: 250,  
              height: 250,  
              decoration: BoxDecoration(  
                color: Color(0xFFFFEBE6),  
                shape: BoxShape.circle,  
              ),  
            ),  
          ),  
          Positioned(  
            right: -70,  
            top: -120,  
            child: Container(  
              width: 200,  
              height: 200,  
              decoration: BoxDecoration(  
                color: Color(0xFF2B961F).withOpacity(0.3),  
                shape: BoxShape.circle,  
              ),  
            ),  
          ),  
          Positioned(  
            left: -150,  
            bottom: -150,  
            child: Container(  
              width: 350,  
              height: 350,  
              decoration: BoxDecoration(  
                color: Color(0xFF2B961F).withOpacity(0.1),  
                shape: BoxShape.circle,  
              ),  
            ),  
          ),  
          Positioned(  
            right: -100,  
            bottom: -100,  
            child: Container(  
              width: 300,  
              height: 300,  
              decoration: BoxDecoration(  
                color: Color(0xFFFFEBE6).withOpacity(0.5),  
                shape: BoxShape.circle,  
              ),  
            ),  
          ),  
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
                          backgroundColor: Colors.white, // Set background color  
                        ),  
                        SizedBox(height: 16),  
                        _buildTextField(  
                          controller: _emailController,  
                          labelText: 'Email',  
                          hintText: 'Enter your email',  
                          backgroundColor: Colors.white, // Set background color  
                        ),  
                        SizedBox(height: 16),  
                        _buildTextField(  
                          controller: _addressController,  
                          labelText: 'Address',  
                          hintText: 'Enter your address',  
                          backgroundColor: Colors.white, // Set background color  
                        ),  
                        SizedBox(height: 16),  
                        _buildGenderSelection(), // Menambahkan pemilihan gender  
                        SizedBox(height: 16),  
                        _buildTextField(  
                          controller: _phoneController,  
                          labelText: 'Phone Number',  
                          hintText: 'Enter your phone number',  
                          keyboardType: TextInputType.phone,  
                          backgroundColor: Colors.white, // Set background color  
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
                              backgroundColor: Colors.white, // Set background color  
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
                            backgroundColor: Color(0xFF2B961F),  
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
                            backgroundColor: Color.fromARGB(255, 196, 23, 11),  
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.5)),  
                            padding: EdgeInsets.symmetric(vertical: 16.0),  
                            minimumSize: Size(double.infinity, 50),  
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

  Widget _buildTextField({  
    required TextEditingController controller,  
    required String labelText,  
    required String hintText,  
    TextInputType keyboardType = TextInputType.text,  
    Color backgroundColor = Colors.white, // Added background color parameter  
  }) {  
    return TextFormField(  
      controller: controller,  
      keyboardType: keyboardType,  
      decoration: InputDecoration(  
        labelText: labelText,  
        hintText: hintText,  
        filled: true, // Enable filling the background  
        fillColor: backgroundColor, // Set background color  
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),  
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0), // Improved padding  
      ),  
      validator: (value) {  
        if (value == null || value.isEmpty) {  
          return 'This field cannot be empty';  
        }  
        return null;  
      },  
    );  
  }  

  // Widget untuk pemilihan gender  
  Widget _buildGenderSelection() {  
    return Row(  
      mainAxisAlignment: MainAxisAlignment.start,  
      children: [  
        Text('Gender: ', style: TextStyle(fontSize: 16)),  
        Radio<String>(  
          value: 'Laki Laki',  
          groupValue: _gender,  
          onChanged: (value) {  
            setState(() {  
              _gender = value; // Set gender ke Laki Laki  
            });  
          },  
        ),  
        Text('Laki Laki', style: TextStyle(fontSize: 16)),  
        Radio<String>(  
          value: 'Perempuan',  
          groupValue: _gender,  
          onChanged: (value) {  
            setState(() {  
              _gender = value; // Set gender ke Perempuan  
            });  
          },  
        ),  
        Text('Perempuan', style: TextStyle(fontSize: 16)),  
      ],  
    );  
  }  
}
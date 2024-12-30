import 'package:flutter/material.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';  
import 'package:firebase_auth/firebase_auth.dart';  
import 'profile_settings.dart';  
import 'package:registapp/login_screen.dart';  

class ProfileScreen extends StatelessWidget {  
  final FirebaseAuth _auth = FirebaseAuth.instance;  

  Stream<DocumentSnapshot> getUserStream() {  
    String userId = _auth.currentUser!.uid;  
    return FirebaseFirestore.instance.collection('users').doc(userId).snapshots();  
  }  

  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      backgroundColor: Colors.white,  
      appBar: AppBar(  
        backgroundColor: Colors.white,  
        elevation: 0,  
        leading: IconButton(  
          icon: Icon(Icons.arrow_back, color: Colors.black),  
          onPressed: () => Navigator.pop(context),  
        ),  
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
          StreamBuilder<DocumentSnapshot>(  
            stream: getUserStream(),  
            builder: (context, snapshot) {  
              if (snapshot.connectionState == ConnectionState.waiting) {  
                return Center(child: CircularProgressIndicator());  
              }  

              if (!snapshot.hasData || !snapshot.data!.exists) {  
                return Center(child: Text("No profile data found."));  
              }  

              var userData = snapshot.data!.data() as Map<String, dynamic>;  

              return SingleChildScrollView(  
                child: Padding(  
                  padding: const EdgeInsets.all(16.0),  
                  child: Column(  
                    crossAxisAlignment: CrossAxisAlignment.center,  
                    children: [  
                      CircleAvatar(  
                        radius: 50,  
                        backgroundColor: Colors.pinkAccent,  
                        child: Icon(  
                          Icons.person,  
                          size: 50,  
                          color: Colors.white,  
                        ),  
                      ),  
                      SizedBox(height: 16),  
                      Text(  
                        userData['fullName'] ?? 'No Name',  
                        style: TextStyle(  
                          fontSize: 20,  
                          fontWeight: FontWeight.bold,  
                          color: Colors.black,  
                        ),  
                      ),  
                      SizedBox(height: 4),  
                      Text(  
                        userData['email'] ?? 'No Email',  
                        style: TextStyle(  
                          fontSize: 14,  
                          color: Colors.black,  
                        ),  
                      ),  
                      SizedBox(height: 20),  
                      ElevatedButton.icon(  
                        onPressed: () {  
                          Navigator.push(  
                            context,  
                            MaterialPageRoute(  
                              builder: (context) => ProfileSettingsScreen(userId: _auth.currentUser!.uid),  
                            ),  
                          );  
                        },  
                        icon: Icon(Icons.settings, color: Colors.black),  
                        label: Text(  
                          "Edit Profile",  
                          style: TextStyle(color: Colors.black),  
                        ),  
                        style: ElevatedButton.styleFrom(  
                          backgroundColor: Colors.white,  
                          side: BorderSide(color: Colors.black12),  
                          shape: RoundedRectangleBorder(  
                            borderRadius: BorderRadius.circular(10),  
                          ),  
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),  
                          elevation: 0,  
                        ),  
                      ),  
                      SizedBox(height: 20),  
                      Container(  
                        decoration: BoxDecoration(  
                          color: Colors.white,  
                          borderRadius: BorderRadius.circular(15),  
                          boxShadow: [  
                            BoxShadow(  
                              color: Colors.black12,  
                              blurRadius: 10,  
                              spreadRadius: 2,  
                            ),  
                          ],  
                        ),  
                        child: Column(  
                          children: [  
                            _buildProfileOption(Icons.location_on, 'Address'),  
                            _buildProfileOption(Icons.payment, 'Payment method'),  
                            _buildProfileOption(Icons.card_giftcard, 'Voucher'),  
                            _buildProfileOption(Icons.favorite, 'My Wishlist'),  
                            _buildProfileOption(Icons.star, 'Rate this app'),  
                            _buildProfileOption(Icons.logout, 'Log out', onTap: () async {  
                              await _auth.signOut();  
                              Navigator.pushAndRemoveUntil(  
                                context,  
                                MaterialPageRoute(builder: (context) => LoginScreen()),  
                                (route) => false,  
                              );  
                            }),  
                          ],  
                        ),  
                      ),  
                    ],  
                  ),  
                ),  
              );  
            },  
          ),  
        ],  
      ),  
    );  
  }  

  Widget _buildProfileOption(IconData icon, String title, {VoidCallback? onTap}) {  
    return ListTile(  
      leading: Icon(icon, color: Colors.grey),  
      title: Text(  
        title,  
        style: TextStyle(  
          fontSize: 16,  
          color: Colors.black,  
        ),  
      ),  
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),  
      onTap: onTap,  
    );  
  }  
}
import 'package:flutter/material.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';  
import 'dart:async'; // Import for Timer  
import '/navigasi/profile_screen.dart';  
import 'history/history_screen.dart';  
import 'order screen/order1.dart';  

class HomeScreen extends StatefulWidget {  
  final String userId;  

  const HomeScreen({super.key, required this.userId});  

  @override  
  _HomeScreenState createState() => _HomeScreenState();  
}  

class _HomeScreenState extends State<HomeScreen> {  
  Stream<DocumentSnapshot> getUserStream() {  
    return FirebaseFirestore.instance  
        .collection('users')  
        .doc(widget.userId)  
        .snapshots();  
  }  

  String getGreeting() {  
    final hour = DateTime.now().hour;  
    if (hour >= 0 && hour < 12) {  
      return 'Selamat Pagi';  
    } else if (hour >= 12 && hour < 15) {  
      return 'Selamat Siang';  
    } else if (hour >= 15 && hour < 18) {  
      return 'Selamat Sore';  
    } else {  
      return 'Selamat Malam';  
    }  
  }  

  late PageController _promoPageController;  
  int _currentPromoIndex = 0;  
  late Timer _promoTimer;  

  final List<String> _promoImages = [  
    'assets/s1.png',  
    'assets/s2.png',  
    'assets/s3.png',  
    'assets/s4.png',  
    'assets/s5.png',  
    'assets/s6.png',  
  ];  

  @override  
  void initState() {  
    super.initState();  
    _promoPageController = PageController();  
    _startPromoTimer();  
  }  

  void _startPromoTimer() {  
    _promoTimer = Timer.periodic(Duration(seconds: 5), (timer) {  
      if (_currentPromoIndex < _promoImages.length - 1) {  
        _currentPromoIndex++;  
      } else {  
        _currentPromoIndex = 0;  
      }  
      if (_promoPageController.hasClients) {  
        _promoPageController.animateToPage(  
          _currentPromoIndex,  
          duration: Duration(milliseconds: 300),  
          curve: Curves.easeInOut,  
        );  
      }  
    });  
  }  

  @override  
  void dispose() {  
    _promoPageController.dispose();  
    _promoTimer.cancel();  
    super.dispose();  
  }  

  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      backgroundColor: Colors.white,  
      body: SafeArea(  
        child: Container(  
          decoration: BoxDecoration(  
            gradient: LinearGradient(  
              colors: [Color(0xFF2B961F), Color(0xFFFFEBE6)],  
              begin: Alignment.topLeft,  
              end: Alignment.bottomRight,  
              stops: [0.4, 1],  
            ),  
          ),  
          child: Stack(  
            children: [  
              _buildDecorativeCircle(  
                left: -80,  
                top: -100,  
                width: 250,  
                height: 250,  
                color: Color(0xFFFFEBE6),  
              ),  
              _buildDecorativeCircle(  
                right: -70,  
                top: -120,  
                width: 200,  
                height: 200,  
                color: Color(0xFF2B961F).withOpacity(0.3),  
              ),  
              _buildDecorativeCircle(  
                left: -150,  
                bottom: -150,  
                width: 350,  
                height: 350,  
                color: Color(0xFF2B961F).withOpacity(0.1),  
              ),  
              _buildDecorativeCircle(  
                right: -100,  
                bottom: -100,  
                width: 300,  
                height: 300,  
                color: Color(0xFFFFEBE6).withOpacity(0.5),  
              ),  
              Column(  
                crossAxisAlignment: CrossAxisAlignment.center,  
                children: [  
                  StreamBuilder<DocumentSnapshot>(  
                    stream: getUserStream(),  
                    builder: (context, snapshot) {  
                      if (snapshot.connectionState == ConnectionState.waiting) {  
                        return Padding(  
                          padding: const EdgeInsets.all(16.0),  
                          child: Text(  
                            'Loading...',  
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),  
                          ),  
                        );  
                      }  

                      if (!snapshot.hasData || snapshot.hasError) {  
                        return Padding(  
                          padding: const EdgeInsets.all(16.0),  
                          child: Text(  
                            'Error loading user data',  
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),  
                          ),  
                        );  
                      }  

                      var userDoc = snapshot.data!;  
                      var username = userDoc['fullName'] ?? 'User';  
                      var greeting = getGreeting();  

                      return Column(  
                        children: [  
                          CircleAvatar(  
                            radius: 50,  
                            backgroundColor: Colors.grey[300],  
                            backgroundImage: AssetImage('assets/avatar.jpg'),  
                            child: null,  
                          ),  
                          SizedBox(height: 10),  
                          Text(  
                            '$greeting, $username!',  
                            style: TextStyle(  
                              fontSize: 24,  
                              fontWeight: FontWeight.bold,  
                            ),  
                          ),  
                        ],  
                      );  
                    },  
                  ),  
                  SizedBox(height: 20),  
                  Container(  
                    height: 150,  
                    child: PageView.builder(  
                      controller: _promoPageController,  
                      itemCount: _promoImages.length,  
                      itemBuilder: (context, index) {  
                        return _buildPromoCard(_promoImages[index]);  
                      },  
                    ),  
                  ),  
                  SizedBox(height: 30),  
                  Expanded(  
                    child: GridView.count(  
                      crossAxisCount: 2,  
                      mainAxisSpacing: 20,  
                      crossAxisSpacing: 20,  
                      padding: EdgeInsets.all(16.0),  
                      children: [  
                        _buildMenuButton(  
                          imageUrl: "https://img.freepik.com/premium-vector/customer-presses-online-order-button-five-stars-rating-review-with-smartphone-parcel-box_420121-409.jpg?w=740",  
                          label: "Order",  
                          onTap: () {  
                            Navigator.push(  
                              context,  
                              MaterialPageRoute(builder: (context) => KonfirmasiAlamatScreen()),  
                            );  
                          },  
                        ),  
                        _buildMenuButton(  
                          imageUrl: "https://img.freepik.com/free-vector/red-clock-3d-vector-illustration-timer-symbol-social-media-apps-cartoon-style-isolated-white-background-online-communication-digital-marketing-concept_778687-1725.jpg?semt=ais_hybrid",  
                          label: "History",  
                          onTap: () {  
                            Navigator.push(  
                              context,  
                              MaterialPageRoute(builder: (context) => HistoryPage()),  
                            );  
                          },  
                        ),  
                        _buildMenuButton(  
                          imageUrl: "https://img.freepik.com/free-vector/purple-phone-tablet-with-orange-stylus-3d-illustration-drawing-tablet-digital-pen-graphic-designers-3d-style-white-background-technology-entertainment-graphic-design-concept_778687-1654.jpg?semt=ais_hybrid",  
                          label: "Edit",  
                          onTap: () {  
                            Navigator.push(  
                              context,  
                              MaterialPageRoute(builder: (context) => ProfileScreen()),  
                            );  
                          },  
                        ),  
                      ],  
                    ),  
                  ),  
                ],  
              ),  
            ],  
          ),  
        ),  
      ),  
    );  
  }  

  Widget _buildPromoCard(String imageUrl) {  
    return Padding(  
      padding: const EdgeInsets.symmetric(horizontal: 8.0),  
      child: Container(  
        width: 200,  
        decoration: BoxDecoration(  
          color: Colors.grey[200],  
          borderRadius: BorderRadius.circular(10),  
        ),  
        child: ClipRRect(  
          borderRadius: BorderRadius.circular(10),  
          child: Image.asset(  
            imageUrl, // Use AssetImage for local images  
            fit: BoxFit.cover,  
            height: 100,  
            width: double.infinity,  
          ),  
        ),  
      ),  
    );  
  }  

  Widget _buildMenuButton({  
    required String imageUrl,  
    required String label,  
    required VoidCallback onTap,  
  }) {  
    return GestureDetector(  
      onTap: onTap,  
      child: Column(  
        mainAxisAlignment: MainAxisAlignment.center,  
        children: [  
          Container(  
            width: 100,  
            height: 100,  
            decoration: BoxDecoration(  
              color: Colors.green[100],  
              borderRadius: BorderRadius.circular(10),  
            ),  
            child: ClipRRect(  
              borderRadius: BorderRadius.circular(10),  
              child: Image.network(  
                imageUrl,  
                fit: BoxFit.cover,  
              ),  
            ),  
          ),  
          SizedBox(height: 10),  
          Text(  
            label,  
            style: TextStyle(  
              fontSize: 16,  
              fontWeight: FontWeight.bold,  
            ),  
          ),  
        ],  
      ),  
    );  
  }  

  Widget _buildDecorativeCircle({  
    double? left,  
    double? right,  
    double? top,  
    double? bottom,  
    required double width,  
    required double height,  
    required Color color,  
  }) {  
    return Positioned(  
      left: left,  
      right: right,  
      top: top,  
      bottom: bottom,  
      child: Container(  
        width: width,  
        height: height,  
        decoration: BoxDecoration(  
          color: color,  
          shape: BoxShape.circle,  
        ),  
      ),  
    );  
  }  
}
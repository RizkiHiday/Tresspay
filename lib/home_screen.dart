import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'navigasi/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Stream<DocumentSnapshot> getUserStream() {
    return FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Stack(
        children: [
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 120.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          '${getGreeting()}, $username!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCategoryButton('Women', Color(0xFF3A2C27), Icons.woman, true),
                        _buildCategoryButton('Men', Color(0xFFF3F3F3), Icons.man,true),
                        _buildCategoryButton('Accessories', Color(0xFFF3F3F3), Icons.watch,true),
                        _buildCategoryButton('Beauty', Color(0xFFF3F3F3), Icons.brush, true),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: NetworkImage("https://img.freepik.com/free-psd/modern-fashion-lifestyle-banner-template_23-2148924974.jpg?t=st=1730037316~exp=1730040916~hmac=d3337aa941d8be3d29a8324356336f25608dccc2bd817889ccf975eb1a883492&w=1380"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: Text(
                            'Winter Collection 2024',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Feature Products',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Show all',
                          style: TextStyle(
                            color: Color(0xFF9B9B9B),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildProductCard('Sweater', '\$45.00', "https://img.freepik.com/premium-photo/young-beautiful-long-brown-haired-hair-girl-with-blue-eyes-brown-knitted-sweater-looking-camera-beige-background_72389-1809.jpg?w=360"),
                          SizedBox(width: 10),
                          _buildProductCard('Long Sleeve Dress', '\$80.00', "https://img.freepik.com/free-photo/woman-wearing-black-dress-side-view_23-2149884572.jpg?ga=GA1.1.970306379.1729739980&semt=ais_hybrid"),
                          SizedBox(width: 10),
                          _buildProductCard('Sportwear Set', '\$60.00', "https://img.freepik.com/free-photo/man-athletic-wear-posing-stairs-outside_23-2148773868.jpg?ga=GA1.1.970306379.1729739980&semt=ais_hybrid"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // Warna putih untuk navigasi bawah
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black, // Warna hitam untuk item terpilih
        unselectedItemColor: Colors.grey, // Warna abu-abu untuk item tidak terpilih
        onTap: (index) {
          if (index == 2) { // Navigasi ke tab Profil
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String label, Color color, IconData icon, [bool selected = false]) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white, // Latar belakang putih untuk kategori
            shape: BoxShape.circle,
            border: selected ? Border.all(color: Colors.black, width: 2) : null,
          ),
          child: Icon(icon, color: selected ? Colors.black : color, size: 24),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Color(0xFF9D9D9D),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(String name, String price, String imageUrl) {
    return Container(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/navigasi/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Stream to fetch user data from Firestore
  Stream<DocumentSnapshot> getUserStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .snapshots();
  }

  // Function to return a greeting message based on the time of day
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

  // Handle Bottom Navigation Item Tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // If Profile button (index 1) is tapped, navigate to Profile Screen
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar dan Greeting
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

                return Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, size: 60, color: Colors.grey),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Hi, $username!',
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
            // Rekomendasi Promo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Rekomendasi Promo",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPromoCard(
                    "Voucher Cashback",
                    "https://via.placeholder.com/150",
                  ),
                  _buildPromoCard(
                    "Diskon 5%",
                    "https://via.placeholder.com/150",
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // Tombol Menu
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                padding: EdgeInsets.all(16.0),
                children: [
                  _buildMenuButton(
                    icon: Icons.shopping_cart,
                    label: "Order",
                    onTap: () {},
                  ),
                  _buildMenuButton(
                    icon: Icons.track_changes,
                    label: "Track",
                    onTap: () {},
                  ),
                  _buildMenuButton(
                    icon: Icons.history,
                    label: "History",
                    onTap: () {},
                  ),
                  _buildMenuButton(
                    icon: Icons.edit,
                    label: "Edit",
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCard(String title, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(35),
            ),
            child: Icon(icon, size: 36, color: Colors.green),
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
}

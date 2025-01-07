import 'package:flutter/material.dart';  
import 'package:firebase_core/firebase_core.dart';  
import 'package:firebase_database/firebase_database.dart';  
import 'order2.dart'; // Ganti dengan path yang sesuai ke file order2.dart  

class KonfirmasiAlamatScreen extends StatefulWidget {  
  @override  
  _KonfirmasiAlamatScreenState createState() => _KonfirmasiAlamatScreenState();  
}  

class _KonfirmasiAlamatScreenState extends State<KonfirmasiAlamatScreen> {  
  String fullName = "";  
  String phoneNumber = "";  
  String address = "";  

  late FirebaseDatabase database;  
  late DatabaseReference _databaseRef;  

  @override  
  void initState() {  
    super.initState();  
    initializeDatabase();  
  }  

  Future<void> initializeDatabase() async {  
    try {  
      // Inisialisasi Firebase  
      final app = await Firebase.initializeApp();  
      database = FirebaseDatabase.instanceFor(  
        app: app,  
        databaseURL: 'https://regist-4905e-default-rtdb.asia-southeast1.firebasedatabase.app/',  
      );  
      _databaseRef = database.ref('users');  

      // Ambil data dari Firebase  
      await fetchDataFromFirebase();  
    } catch (e) {  
      print("Error initializing database: $e");  
    }  
  }  

  // Fungsi untuk mengambil data dari Firebase  
  Future<void> fetchDataFromFirebase() async {  
    try {  
      final DatabaseEvent event = await _databaseRef.limitToFirst(1).once();  
      final data = event.snapshot.value as Map<dynamic, dynamic>?;  

      if (data != null) {  
        final user = data.values.first;  
        setState(() {  
          fullName = user["fullName"] ?? "";  
          phoneNumber = user["phoneNumber"] ?? "";  
          address = user["address"] ?? "";  
        });  
      }  
    } catch (e) {  
      print("Error fetching data: $e");  
    }  
  }  

  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      appBar: AppBar(  
        backgroundColor: Colors.transparent,  
        elevation: 0,  
        leading: IconButton(  
          icon: const Icon(Icons.arrow_back, color: Colors.black),  
          onPressed: () => Navigator.pop(context),  
        ),  
        title: const Text(  
          'Alamat',  
          style: TextStyle(color: Colors.black),  
        ),  
        centerTitle: true,  
      ),  
      body: Stack(  
        children: [  
          // Placeholder untuk peta  
          Positioned(  
            top: 0,  
            left: 0,  
            right: 0,  
            child: Image.network(  
              'https://img.freepik.com/premium-vector/sao-luis-city-brazil-municipality-vector-map-green-street-map-municipality-area-urban-skyline-panorama-tourism_228947-498.jpg?ga=GA1.1.720069071.1735814487&semt=ais_hybrid',  
              height: 600,  
              fit: BoxFit.cover,  
            ),  
          ),  

          // Bagian konfirmasi alamat  
          Positioned(  
            bottom: 0,  
            left: 0,  
            right: 0,  
            child: Container(  
              padding: const EdgeInsets.all(16.0),  
              decoration: BoxDecoration(  
                color: Colors.white, // Set background color to white  
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),  
                boxShadow: [  
                  BoxShadow(  
                    color: Colors.black.withOpacity(0.1),  
                    blurRadius: 10,  
                  ),  
                ],  
              ),  
              child: Column(  
                crossAxisAlignment: CrossAxisAlignment.start,  
                mainAxisSize: MainAxisSize.min,  
                children: [  
                  _buildInfoRow(Icons.location_pin, address.isNotEmpty ? address : "Memuat..."),  
                  const SizedBox(height: 8),  
                  _buildInfoRow(Icons.person, fullName.isNotEmpty ? fullName : "Memuat..."),  
                  const SizedBox(height: 8),  
                  _buildInfoRow(Icons.phone, phoneNumber.isNotEmpty ? phoneNumber : "Memuat..."),  
                  const SizedBox(height: 16),  
                  ElevatedButton(  
                    onPressed: () {  
                      // Navigasi ke layar konfirmasi pembayaran  
                      Navigator.push(  
                        context,  
                        MaterialPageRoute(  
                          builder: (context) => KonfirmasiPembayaranScreen(),  
                        ),  
                      );  
                    },  
                    style: ElevatedButton.styleFrom(  
                      backgroundColor: Colors.green,  
                      minimumSize: const Size(double.infinity, 50),  
                      shape: RoundedRectangleBorder(  
                        borderRadius: BorderRadius.circular(10),  
                      ),  
                    ),  
                    child: const Text(  
                      'Konfirmasi',  
                      style: TextStyle(fontSize: 16, color: Colors.white), // Set button text color to white  
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

  Widget _buildInfoRow(IconData icon, String text) {  
    return Row(  
      children: [  
        Icon(icon, size: 24, color: Colors.green),  
        const SizedBox(width: 8),  
        Expanded(  
          child: Text(  
            text,  
            style: const TextStyle(fontSize: 16),  
          ),  
        ),  
      ],  
    );  
  }  
}
import 'package:flutter/material.dart';  
import 'package:firebase_core/firebase_core.dart';  
import 'package:firebase_database/firebase_database.dart';  
import 'order3.dart'; // Ganti dengan path yang sesuai ke file order3.dart  

class KonfirmasiPembayaranScreen extends StatefulWidget {  
  @override  
  _KonfirmasiPembayaranScreenState createState() =>  
      _KonfirmasiPembayaranScreenState();  
}  

class _KonfirmasiPembayaranScreenState  
    extends State<KonfirmasiPembayaranScreen> {  
  String address = "Memuat...";  // Data alamat  
  String selectedDay = "Senin";  
  String selectedTime = "09:00 - 10:00";  
  List<String> availableDays = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat"];  
  List<String> availableTimes = [  
    "09:00 - 10:00",  
    "10:00 - 11:00",  
    "11:00 - 12:00",  
    "13:00 - 14:00",  
    "14:00 - 15:00"  
  ];  

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

      // Ambil data alamat dari Firebase  
      await fetchAddressFromFirebase();  
    } catch (e) {  
      print("Error initializing database: $e");  
    }  
  }  

  // Fungsi untuk mengambil data alamat pengguna dari Firebase  
  Future<void> fetchAddressFromFirebase() async {  
    try {  
      final DatabaseEvent event = await _databaseRef.limitToFirst(1).once();  
      final data = event.snapshot.value as Map<dynamic, dynamic>?;  

      if (data != null) {  
        final user = data.values.first;  
        setState(() {  
          address = user["address"] ?? "Alamat tidak tersedia";  
        });  
      }  
    } catch (e) {  
      print("Error fetching address: $e");  
    }  
  }  

  // Fungsi untuk menyimpan detail pesanan ke Firebase  
  Future<void> saveOrderToFirebase() async {  
    try {  
      final newOrderRef = database.ref('orders').push(); // Menyimpan pesanan ke node 'orders'  
      await newOrderRef.set({  
        'address': address,  
        'selectedDay': selectedDay,  
        'selectedTime': selectedTime,  
      });  

      // Menampilkan dialog konfirmasi pesanan  
      showDialog(  
        context: context,  
        builder: (BuildContext context) {  
          return AlertDialog(  
            title: const Text("Pesanan Berhasil"),  
            content: Text(  
                "Pesanan untuk $selectedDay pada $selectedTime berhasil dibuat!"),  
            actions: [  
              TextButton(  
                onPressed: () {  
                  Navigator.pop(context); // Tutup dialog  
                  Navigator.push(  
                    context,  
                    MaterialPageRoute(  
                      builder: (context) => MetodePembayaranScreen(),  
                    ),  
                  );  
                },  
                child: const Text("Lanjutkan ke Pembayaran"),  
              ),  
            ],  
          );  
        },  
      );  
    } catch (e) {  
      print("Error saving order: $e");  
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
          'Detail Pembayaran',  
          style: TextStyle(color: Colors.black),  
        ),  
        centerTitle: true,  
      ),  
      body: Padding(  
        padding: const EdgeInsets.all(16.0),  
        child: Column(  
          crossAxisAlignment: CrossAxisAlignment.start,  
          children: [  
            // Penjemputan Sampah  
            const Text(  
              "Penjemputan Sampah",  
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),  
            ),  
            const SizedBox(height: 8),  
            Container(  
              padding: const EdgeInsets.all(16),  
              decoration: BoxDecoration(  
                color: Colors.grey[200],  
                borderRadius: BorderRadius.circular(10),  
              ),  
              child: Column(  
                crossAxisAlignment: CrossAxisAlignment.start,  
                children: [  
                  Row(  
                    children: [  
                      const Icon(Icons.location_pin, color: Colors.green),  
                      const SizedBox(width: 8),  
                      Expanded(  
                        child: Text(  
                          address,  
                          style: const TextStyle(fontSize: 16),  
                        ),  
                      ),  
                    ],  
                  ),  
                  const SizedBox(height: 8),  
                  // Dropdown untuk memilih hari  
                  Row(  
                    children: [  
                      const Icon(Icons.calendar_today, color: Colors.green),  
                      const SizedBox(width: 8),  
                      Expanded(  
                        child: DropdownButtonFormField<String>(  
                          value: selectedDay,  
                          items: availableDays  
                              .map((day) => DropdownMenuItem(  
                                    value: day,  
                                    child: Text(day),  
                                  ))  
                              .toList(),  
                          onChanged: (value) {  
                            setState(() {  
                              selectedDay = value!;  
                            });  
                          },  
                          decoration: InputDecoration(  
                            filled: true,  
                            fillColor: Colors.white,  
                            border: OutlineInputBorder(  
                              borderRadius: BorderRadius.circular(10),  
                              borderSide: BorderSide.none,  
                            ),  
                            contentPadding: const EdgeInsets.symmetric(  
                                horizontal: 16),  
                          ),  
                        ),  
                      ),  
                    ],  
                  ),  
                  const SizedBox(height: 8),  
                  // Dropdown untuk memilih waktu  
                  Row(  
                    children: [  
                      const Icon(Icons.access_time, color: Colors.green),  
                      const SizedBox(width: 8),  
                      Expanded(  
                        child: DropdownButtonFormField<String>(  
                          value: selectedTime,  
                          items: availableTimes  
                              .map((time) => DropdownMenuItem(  
                                    value: time,  
                                    child: Text(time),  
                                  ))  
                              .toList(),  
                          onChanged: (value) {  
                            setState(() {  
                              selectedTime = value!;  
                            });  
                          },  
                          decoration: InputDecoration(  
                            filled: true,  
                            fillColor: Colors.white,  
                            border: OutlineInputBorder(  
                              borderRadius: BorderRadius.circular(10),  
                              borderSide: BorderSide.none,  
                            ),  
                            contentPadding: const EdgeInsets.symmetric(  
                                horizontal: 16),  
                          ),  
                        ),  
                      ),  
                    ],  
                  ),  
                ],  
              ),  
            ),  
            const SizedBox(height: 16),  

            // Total  
            _buildTotalRow("Total", "Rp 13.000"),  

            const Spacer(),  

            // Tombol Pesan  
            SizedBox(  
              width: double.infinity,  
              child: ElevatedButton(  
                onPressed: () {  
                  // Menyimpan pesanan ke Firebase  
                  saveOrderToFirebase();  
                },  
                style: ElevatedButton.styleFrom(  
                  backgroundColor: Colors.green,  
                  padding: const EdgeInsets.symmetric(vertical: 16),  
                  shape: RoundedRectangleBorder(  
                    borderRadius: BorderRadius.circular(10),  
                  ),  
                ),  
                child: const Text(  
                  "Pesan",  
                  style: TextStyle(fontSize: 16, color: Colors.white), // Set button text color to white  
                ),  
              ),  
            ),  
          ],  
        ),  
      ),  
    );  
  }  

  Widget _buildTotalRow(String label, String value) {  
    return Row(  
      mainAxisAlignment: MainAxisAlignment.spaceBetween,  
      children: [  
        Text(  
          label,  
          style: const TextStyle(fontSize: 16),  
        ),  
        Text(  
          value,  
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),  
        ),  
      ],  
    );  
  }  
}
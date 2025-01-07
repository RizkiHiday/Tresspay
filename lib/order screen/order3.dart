import 'package:flutter/material.dart';  
import 'package:url_launcher/url_launcher.dart';  
import 'package:firebase_core/firebase_core.dart';  
import 'package:firebase_database/firebase_database.dart';  
import 'order4.dart'; // Ganti dengan path yang sesuai ke file order4.dart  

class MetodePembayaranScreen extends StatefulWidget {  
  @override  
  _MetodePembayaranScreenState createState() => _MetodePembayaranScreenState();  
}  

class _MetodePembayaranScreenState extends State<MetodePembayaranScreen> {  
  String selectedPayment = "QRIS"; // Default pilihan pembayaran  
  late FirebaseDatabase database;  
  late DatabaseReference _databaseRef;  

  @override  
  void initState() {  
    super.initState();  
    initializeDatabase();  
  }  

  // Inisialisasi Firebase dan DatabaseReference  
  Future<void> initializeDatabase() async {  
    try {  
      final app = await Firebase.initializeApp();  
      database = FirebaseDatabase.instanceFor(  
        app: app,  
        databaseURL: 'https://regist-4905e-default-rtdb.asia-southeast1.firebasedatabase.app/', // Sesuaikan URL Firebase  
      );  
      _databaseRef = database.ref('paymentMethods');  
    } catch (e) {  
      print("Error initializing database: $e");  
    }  
  }  

  // Fungsi untuk menyimpan metode pembayaran yang dipilih ke Firebase  
  Future<void> savePaymentMethodToFirebase() async {  
    try {  
      final newPaymentRef = _databaseRef.push(); // Menyimpan pembayaran ke node 'paymentMethods'  
      await newPaymentRef.set({  
        'selectedPayment': selectedPayment,  
        'timestamp': DateTime.now().toIso8601String(), // Menyimpan waktu pemilihan  
      });  

      // Menampilkan dialog konfirmasi pembayaran  
      showDialog(  
        context: context,  
        builder: (BuildContext context) {  
          return AlertDialog(  
            title: const Text("Metode Pembayaran Tersimpan"),  
            content: Text("Anda telah memilih metode pembayaran $selectedPayment."),  
            actions: [  
              TextButton(  
                onPressed: () {  
                  Navigator.pop(context); // Tutup dialog  
                  Navigator.push(  
                    context,  
                    MaterialPageRoute(  
                      builder: (context) => PembayaranSuksesScreen(),  
                    ),  
                  );  
                },  
                child: const Text("Lanjutkan"),  
              ),  
            ],  
          );  
        },  
      );  
    } catch (e) {  
      print("Error saving payment method: $e");  
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
          'Metode Pembayaran',  
          style: TextStyle(color: Colors.black),  
        ),  
        centerTitle: true,  
      ),  
      body: Padding(  
        padding: const EdgeInsets.all(16.0),  
        child: Column(  
          crossAxisAlignment: CrossAxisAlignment.start,  
          children: [  
            // Pilihan Metode Pembayaran  
            _buildPaymentOption(  
              icon: Icons.qr_code,  
              title: "QRIS",  
              description: "Scan QR Code untuk pembayaran",  
              value: "QRIS",  
            ),  
            const SizedBox(height: 16),  
            _buildPaymentOption(  
              icon: Icons.attach_money,  
              title: "COD",  
              description: "Bayar di tempat (Cash on Delivery)",  
              value: "COD",  
            ),  
            const Spacer(),  

            // Total dan Tombol Lanjutkan  
            Container(  
              padding: const EdgeInsets.all(16.0),  
              decoration: BoxDecoration(  
                color: Colors.white,  
                boxShadow: [  
                  BoxShadow(  
                    color: Colors.black.withOpacity(0.1),  
                    blurRadius: 10,  
                    offset: const Offset(0, -1),  
                  ),  
                ],  
              ),  
              child: Column(  
                crossAxisAlignment: CrossAxisAlignment.start,  
                children: [  
                  // Total  
                  Row(  
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,  
                    children: const [  
                      Text(  
                        "Total",  
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),  
                      ),  
                      Text(  
                        "Rp 13,000",  
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),  
                      ),  
                    ],  
                  ),  
                  const SizedBox(height: 16),  
                  // Tombol Lanjutkan  
                  SizedBox(  
                    width: double.infinity,  
                    child: ElevatedButton(  
                      onPressed: () async {  
                        // Simpan pilihan pembayaran ke Firebase  
                        await savePaymentMethodToFirebase();  

                        // Proses pembayaran  
                        if (selectedPayment == "QRIS") {  
                          // Membuka link Midtrans jika QRIS dipilih  
                          const midtransLink =  
                              "https://app.sandbox.midtrans.com/payment-links/1735820761454";  
                          if (await canLaunch(midtransLink)) {  
                            await launch(midtransLink);  
                          } else {  
                            ScaffoldMessenger.of(context).showSnackBar(  
                              const SnackBar(  
                                content: Text("Tidak dapat membuka link pembayaran"),  
                              ),  
                            );  
                          }  
                        } else if (selectedPayment == "COD") {  
                          // Langsung ke halaman sukses untuk COD  
                          Navigator.push(  
                            context,  
                            MaterialPageRoute(  
                              builder: (context) => PembayaranSuksesScreen(),  
                            ),  
                          );  
                        }  
                      },  
                      style: ElevatedButton.styleFrom(  
                        backgroundColor: Colors.green,  
                        padding: const EdgeInsets.symmetric(vertical: 16),  
                        shape: RoundedRectangleBorder(  
                          borderRadius: BorderRadius.circular(10),  
                        ),  
                      ),  
                      child: const Text(  
                        "Lanjutkan",  
                        style: TextStyle(fontSize: 16, color: Colors.white), // Set button text color to white  
                      ),  
                    ),  
                  ),  
                ],  
              ),  
            ),  
          ],  
        ),  
      ),  
    );  
  }  

  Widget _buildPaymentOption({  
    required IconData icon,  
    required String title,  
    required String description,  
    required String value,  
  }) {  
    return GestureDetector(  
      onTap: () {  
        setState(() {  
          selectedPayment = value;  
        });  
      },  
      child: Container(  
        padding: const EdgeInsets.all(16),  
        decoration: BoxDecoration(  
          color: Colors.white,  
          borderRadius: BorderRadius.circular(10),  
          border: Border.all(  
            color: selectedPayment == value ? Colors.green : Colors.grey[300]!,  
            width: 2,  
          ),  
        ),  
        child: Row(  
          children: [  
            Icon(icon, size: 40, color: Colors.green),  
            const SizedBox(width: 16),  
            Expanded(  
              child: Column(  
                crossAxisAlignment: CrossAxisAlignment.start,  
                children: [  
                  Text(  
                    title,  
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),  
                  ),  
                  const SizedBox(height: 4),  
                  Text(  
                    description,  
                    style: const TextStyle(fontSize: 14, color: Colors.grey),  
                  ),  
                ],  
              ),  
            ),  
            const SizedBox(width: 16),  
            Icon(  
              selectedPayment == value  
                  ? Icons.radio_button_checked  
                  : Icons.radio_button_off,  
              color: Colors.green,  
            ),  
          ],  
        ),  
      ),  
    );  
  }  
}
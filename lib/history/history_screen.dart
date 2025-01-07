import 'package:flutter/material.dart';  

class HistoryPage extends StatelessWidget {  
  final List<Order> orders = [  
    Order(  
      address: 'Bukit Cengkeh 2 Blok G2. No. 16, Cimanggis, Depok',  
      date: '10 Mei',  
      time: '09:30',  
      status: 'Pick up Berhasil',  
      icon: Icons.local_shipping,  
    ),  
    Order(  
      address: 'Bukit Cengkeh 2 Blok G2. No. 16, Cimanggis, Depok',  
      date: '06 Mei',  
      time: '08:40',  
      status: 'Pick up Berhasil',  
      icon: Icons.local_shipping,  
    ),  
    Order(  
      address: 'Bukit Cengkeh 2 Blok G2. No. 16, Cimanggis, Depok',  
      date: '01 Mei',  
      time: '10:15',  
      status: 'Pick up Gagal',  
      icon: Icons.local_shipping,  
    ),  
    Order(  
      address: 'Bukit Cengkeh 2 Blok G2. No. 16, Cimanggis, Depok',  
      date: '29 April',  
      time: '08:20',  
      status: 'Pick up Berhasil',  
      icon: Icons.local_shipping,  
    ),  
    Order(  
      address: 'Bukit Cengkeh 2 Blok G2. No. 16, Cimanggis, Depok',  
      date: '26 April',  
      time: '09:40',  
      status: 'Pick up Berhasil',  
      icon: Icons.local_shipping,  
    ),  
  ];  

  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      backgroundColor: Colors.white, // Set background color to white  
      appBar: AppBar(  
        title: Text('Riwayat Pesanan'),  
        leading: IconButton(  
          icon: Icon(Icons.arrow_back),  
          onPressed: () {  
            Navigator.pop(context);  
          },  
        ),  
      ),  
      body: ListView.builder(  
        itemCount: orders.length,  
        itemBuilder: (context, index) {  
          final order = orders[index];  
          return Card(  
            margin: EdgeInsets.all(8.0),  
            child: ListTile(  
              leading: Icon(order.icon),  
              title: Text(order.address),  
              subtitle: Column(  
                crossAxisAlignment: CrossAxisAlignment.start,  
                children: [  
                  Text('${order.date} ${order.time}'),  
                  Text(order.status),  
                ],  
              ),  
            ),  
          );  
        },  
      ),  
      bottomNavigationBar: Padding(  
        padding: const EdgeInsets.all(8.0),  
        child: ElevatedButton(  
          onPressed: () {  
            Navigator.pop(context);  
          },  
          child: Text('Back'),  
          style: ElevatedButton.styleFrom(  
            backgroundColor: Colors.green,  
            padding: EdgeInsets.symmetric(vertical: 15),  
            foregroundColor: Colors.white, // Set button text color to white  
          ),  
        ),  
      ),  
    );  
  }  
}  

class Order {  
  final String address;  
  final String date;  
  final String time;  
  final String status;  
  final IconData icon;  

  Order({  
    required this.address,  
    required this.date,  
    required this.time,  
    required this.status,  
    required this.icon,  
  });  
}
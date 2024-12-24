import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    checkAdminStatus();
  }

  Future<void> checkAdminStatus() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists && userDoc.data()?['status'] == 'admin') {
        setState(() {
          isAdmin = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text(
          'Anda belum login.',
          style: TextStyle(fontSize: 20),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Semua Riwayat Pembelian' : 'Riwayat Pembelian'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Modify the query based on admin status
        stream: isAdmin
            ? FirebaseFirestore.instance.collection('history').snapshots()
            : FirebaseFirestore.instance
                .collection('history')
                .where('buyerEmail', isEqualTo: user.email)
                .snapshots(),
        builder: (context, historySnapshot) {
          if (historySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!historySnapshot.hasData || historySnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Tidak ada riwayat pembelian'),
            );
          }

          final histories = historySnapshot.data!.docs;

          return ListView.builder(
            itemCount: histories.length,
            itemBuilder: (context, index) {
              final history = histories[index];
              final String buyerEmail = history['buyerEmail'];
              final int totalPrice = history['totalPrice'];
              final Timestamp timestamp = history['timestamp'];

              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    'Total Harga: Rp ${totalPrice.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]}.',
                        )}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waktu: ${timestamp.toDate().toString().split('.')[0]}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Pembeli: $buyerEmail',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
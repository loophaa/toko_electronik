import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Text(
          'Anda belum login.',
          style: TextStyle(fontSize: 20),
        ),
      );
    }

    final String buyerEmail = user.email!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang Belanja'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://i.ytimg.com/vi/BGuR7k-Y3Dk/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLCybj_gehDtOMM-In7dCKACxPIxFQ',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('buyerEmail', isEqualTo: buyerEmail)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'Keranjang Anda kosong',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              );
            }

            final orders = snapshot.data!.docs;
            int totalPrice = orders.fold(
              0,
              (sum, order) => sum + (order['price'] as int),
            );

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      var order = orders[index];
                      String name = order['productName'];
                      int price = order['price'];

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(name),
                          subtitle: Text('Rp $price'),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    border: Border(
                      top: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Total Harga: Rp $totalPrice',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final batch =
                                FirebaseFirestore.instance.batch();
                            final now = Timestamp.now();

                            // Loop through each order
                            for (var order in orders) {
                              final productRef = FirebaseFirestore.instance
                                  .collection('products')
                                  .doc(order['productId']);

                              // Reduce stock
                              final productSnapshot =
                                  await productRef.get();
                              if (productSnapshot.exists) {
                                final int currentStock =
                                    productSnapshot['stock'] as int;
                                if (currentStock > 0) {
                                  batch.update(productRef,
                                      {'stock': currentStock - 1});
                                }
                              }
                            }

                            // Add history entry
                            final totalPrice = orders.fold(
                                0,
                                (sum, order) =>
                                    sum + (order['price'] as int));
                            final historyRef = FirebaseFirestore.instance
                                .collection('history')
                                .doc();

                            batch.set(historyRef, {
                              'buyerEmail': buyerEmail,
                              'totalPrice': totalPrice,
                              'timestamp': now,
                            });

                            // Commit batch
                            await batch.commit();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Pembelian berhasil!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Gagal melakukan pembelian: ${e.toString()}')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.all(15),
                        ),
                        child: const Text('Beli',
                            style: TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          // Hapus semua item dari keranjang
                          final batch = FirebaseFirestore.instance.batch();
                          for (var order in orders) {
                            batch.delete(order.reference);
                          }
                          await batch.commit();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Keranjang berhasil dibersihkan')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.all(15),
                        ),
                        child: const Text('Bersihkan Keranjang',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

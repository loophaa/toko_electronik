import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'main.dart';

class ProfilePage extends StatelessWidget {
  // Fungsi Logout
  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Logout dari Firebase
      // Arahkan ke LoginPage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()), // Panggil LoginPage
      );
    } catch (e) {
      // Tampilkan error jika logout gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal keluar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        backgroundColor: Colors.blueAccent, // Ubah warna AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // Foto Profil
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150'), // Ganti dengan URL gambar
            ),
            SizedBox(height: 20),
            // Nama Pengguna
            Text(
              'Nama Pengguna',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            // Email Pengguna
            Text(
              'email@example.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),
            // Tombol Edit Profil
            ElevatedButton.icon(
              onPressed: () {
                // Tambahkan logika untuk edit profil
              },
              icon: Icon(Icons.edit),
              label: Text('Edit Profil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
            SizedBox(height: 15),
            // Tombol Logout
            OutlinedButton.icon(
              onPressed: () => _logout(context), // Panggil fungsi logout
              icon: Icon(Icons.logout),
              label: Text('Keluar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: BorderSide(color: Colors.red),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

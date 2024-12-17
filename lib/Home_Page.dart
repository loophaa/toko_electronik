import 'package:flutter/material.dart';
import 'Cart.dart';
import 'History.dart';
import 'Profile.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Daftar halaman untuk navigasi
  final List<Widget> _pages = [
    HomePage(),   // Katalog produk
    CartPage(),   // Halaman keranjang
    HistoryPage(),// Halaman riwayat
    ProfilePage(),// Halaman profil
  ];

  // Fungsi ketika item navigasi diklik
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Katalog Produk'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _pages[_selectedIndex], // Menampilkan halaman sesuai indeks
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Keranjang'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// Katalog Produk
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: 10, // Misalnya, ada 10 produk
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(Icons.shopping_bag, color: Colors.blueAccent),
            title: Text('Produk ${index + 1}'),
            subtitle: Text('Deskripsi Produk ${index + 1}'),
            trailing: ElevatedButton(
              onPressed: () {
                // Aksi ketika tombol beli ditekan
              },
              child: Text('Beli'),
            ),
          ),
        );
      },
    );
  }
}

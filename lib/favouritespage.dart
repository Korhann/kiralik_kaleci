import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/sellerDetails.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  bool isLoading = false;
  List<Map<String, dynamic>> favourites = [];

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid != null && currentUserUid.isNotEmpty) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserUid)
          .collection('favourites')
          .get();

      setState(() {
        favourites = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Favorlilerim', style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorilerim', style: GoogleFonts.inter(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: favourites.length,
        itemBuilder: (context, index) {
          final favourite = favourites[index];
          final sellerFullName = favourite['sellerFullName'] ?? '';
          final city = favourite['city'] ?? 'Unknown';
          final district = favourite['district'] ?? '';
          final imageUrl = (favourite['imageUrls'] != null && favourite['imageUrls'].isNotEmpty)
              ? favourite['imageUrls'][0]
              : 'https://via.placeholder.com/150'; // Default image URL

          return ListTile(
            contentPadding: const EdgeInsets.all(10),
            title: Text(
              "$sellerFullName",
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              "$city , $district",
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w300),
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SellerDetailsPage(
                    sellerDetails: favourite,
                    sellerUid: favourite['sellerUid'] ?? '',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

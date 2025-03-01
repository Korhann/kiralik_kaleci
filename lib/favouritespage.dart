import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/sellerDetails.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  bool isLoading = true;
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: userorseller ? sellerbackground: background,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: userorseller ? sellerbackground: background,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favourites.isEmpty
              ? const Center(child: Text('Henüz favori eklenmedi.'))
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Favorilerim',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: userorseller ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(10),
                    itemCount: favourites.length,
                    itemBuilder: (context, index) {
                      final favourite = favourites[index];
                      final sellerFullName = favourite['sellerFullName'] ?? '';
                      final city = favourite['city'] ?? 'Bilinmiyor';
                      final district = favourite['district'] ?? '';
                      final imageUrl = (favourite['imageUrls'] != null && favourite['imageUrls'].isNotEmpty)
                          ? favourite['imageUrls'][0]
                          : 'https://via.placeholder.com/150';
                
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(15),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            sellerFullName,
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          subtitle: Text(
                            '$city, $district',
                            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[700]),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
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
                        ),
                      );
                    },
                  ),
                ],
              ),
    );
  }
}
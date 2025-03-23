import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/connectivityWithBackButton.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/sellerDetails.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:shimmer/shimmer.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> favourites = [];

  late Future<void> fetchFavourites;

  @override
  void initState() {
    super.initState();
    fetchFavourites = _fetchFavorites();
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
    return ConnectivityWithBackButton(
      child: FutureBuilder(
        future: fetchFavourites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: EdgeInsets.only(top: 50),
              child: FavouritesShimmer()
            );
          }
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
                  showFavouritesText(),
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

                      return showCardFavourite(imageUrl: imageUrl, sellerFullName: sellerFullName, city: city, district: district, favourite: favourite);
                
                    },
                  ),
                ],
              ),
    );
        }
      ),
    );
  }
}
class showFavouritesText extends StatelessWidget {
  const showFavouritesText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Favorilerim',
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: userorseller ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
class showCardFavourite extends StatelessWidget {
  final String imageUrl;
  final String sellerFullName;
  final String city;
  final String district;
  final Map<String,dynamic> favourite;
  const showCardFavourite({
    Key? key,
    required this.imageUrl,
    required this.sellerFullName,
    required this.city,
    required this.district,
    required this.favourite,
  }): super (key: key);

  @override
  Widget build(BuildContext context) {
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
  }
}

class FavouritesShimmer extends StatelessWidget {
  const FavouritesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      itemCount: 5, // Show shimmer for 5 items
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              leading: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              title: Container(
                height: 16,
                width: 120,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 8),
              ),
              subtitle: Container(
                height: 14,
                width: 80,
                color: Colors.white,
              ),
              trailing: Container(
                width: 15,
                height: 15,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

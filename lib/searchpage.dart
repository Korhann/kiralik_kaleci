import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/filterpage.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'sellerDetails.dart';
import 'sharedvalues.dart';

class GetUserData extends StatefulWidget {
  const GetUserData({super.key});

  @override
  State<GetUserData> createState() => _GetUserDataState();
}

class _GetUserDataState extends State<GetUserData> {
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _userStream;

  String? nameFilter;
  String? cityFilter;
  String? districtFilter;
  String? fieldFilter;
  List<String> ?daysFilter;
  int? minFilter = 0;
  int? maxFilter = 0;

  @override
  void initState() {
    super.initState();
    _userStream = _firestore.collection("Users").snapshots();
    userorseller = false;
    }

    @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: background,
    body: StreamBuilder(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Bağlantı hatası"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data!.docs
            .where((doc) => doc.data().containsKey('sellerDetails'))
            .toList();

        return Column(
          children: [
            // Header Section
            Container(
              color: background,
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                children: [
                  Text(
                    "Kalecilerimiz",
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.handshake),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () async {
                        final filters = await Navigator.push(
                          context,
                          _createRoute(FilterPage())
                        );
                        runFilters(filters);
                      },
                      child: Image.asset(
                        'lib/icons/setting.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Empty State
            if (docs.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 70, color: Colors.grey.shade500),
                      const SizedBox(height: 10),
                      Text(
                        'İlgili sonuç bulunamadı',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              // GridView for 2-column layout
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: GridView.builder(
                    physics: ScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 items per row
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7, // Adjust as needed
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var sellerDetails = docs[index]['sellerDetails'];
                      var fullName = sellerDetails['sellerFullName'] ?? "Bilinmeyen";
                      var imageUrl = sellerDetails['imageUrls'][0] ?? "";
                      var city = sellerDetails['city'] ?? "";
                      var district = sellerDetails['district'] ?? "";
                      var sellerUid = docs[index].id;
                  
                      return GestureDetector(
                        onTap: () {
                          sharedValues.sellerUid = sellerUid;
                          _handleCardTap(context, sellerDetails, sellerUid);
                        },
                        child: Card(
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                color: Colors.white,
                                child: Image.network(
                                  imageUrl,
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fullName,
                                        style: GoogleFonts.inter(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        "$city, $district",
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}
  
  void _handleCardTap(BuildContext context, Map<String, dynamic>? sellerDetails, String sellerUid) {
    if (sellerDetails != null) {
      sharedValues.sellerUid = sellerUid;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SellerDetailsPage(sellerDetails: sellerDetails, sellerUid: sellerUid),
        ),
      );
    } else {
      print("Seller details not found");
    }
  }

  void runFilters(final filter) {
    if (filter != null) {
      setState(() {
        nameFilter = filter['nameFilter'];
        cityFilter = filter['cityFilter'];
        districtFilter = filter['districtFilter'];
        daysFilter = filter['daysFilter'];
        fieldFilter = filter['fieldFilter'];
        minFilter = filter['minFilter'];
        maxFilter = filter['maxFilter'];
      });
      applyFilter();
    }
  }

  void applyFilter() async {
  Query<Map<String, dynamic>> filterquery = _firestore.collection('Users');

  if (nameFilter != null && nameFilter!.isNotEmpty) {
    filterquery = filterquery.where('sellerDetails.sellerFullName', isEqualTo: nameFilter);
  }
  if (cityFilter != null && cityFilter!.isNotEmpty) {
    filterquery = filterquery.where('sellerDetails.city', isEqualTo: cityFilter);
  }
  if (districtFilter != null && districtFilter!.isNotEmpty) {
    filterquery = filterquery.where('sellerDetails.district', isEqualTo: districtFilter);
  }
  if (fieldFilter != null && fieldFilter!.isNotEmpty) {
    filterquery = filterquery.where('sellerDetails.fields', arrayContains: fieldFilter);
  }
  if (daysFilter != null && daysFilter!.isNotEmpty) {
    filterquery = filterquery.where('sellerDetails.chosenDays', arrayContainsAny: daysFilter);
  }

  if (minFilter != null && maxFilter != null) {
    filterquery = filterquery.where('sellerDetails.sellerPrice', isGreaterThanOrEqualTo: minFilter);
    filterquery = filterquery.where('sellerDetails.sellerPrice', isLessThanOrEqualTo: maxFilter);
  } else if (minFilter != null) {
    filterquery = filterquery.where('sellerDetails.sellerPrice', isGreaterThanOrEqualTo: minFilter);
  } else if (maxFilter != null) {
    filterquery = filterquery.where('sellerDetails.sellerPrice', isLessThanOrEqualTo: maxFilter);
  } 
  
  // Update the user stream based on the filter query
  setState(() {
    _userStream = filterquery.snapshots();
  });
  }
  Route _createRoute(Widget child) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
}

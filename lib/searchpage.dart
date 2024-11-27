import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/filterpage.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/timer.dart';
import 'sellerDetails.dart';
import 'sharedvalues.dart';

class GetUserData extends StatefulWidget {
  const GetUserData({Key? key}) : super(key: key);

  @override
  State<GetUserData> createState() => _GetUserDataState();
}

class _GetUserDataState extends State<GetUserData> {
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _userStream;

  // NOT: BUNLAR DENEMEK İÇİN
  final String user = FirebaseAuth.instance.currentUser!.uid;

  String? nameFilter;
  String? cityFilter;
  String? districtFilter;
  List<String> ?daysFilter;
  int? minFilter = 0;
  int? maxFilter = 0;

  @override
  void initState() {
    super.initState();
    _userStream = _firestore.collection("Users").snapshots();
    TimerService().startWeeklyRefresh();
    }

    @override
  void dispose() {
    // TODO: implement dispose
    //TimerService().dispose();
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
            return const Text("Bağlantı hatası");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          var docs = snapshot.data!.docs;

          docs = docs.where((doc) => doc.data().containsKey('sellerDetails')).toList();

          if (docs.isEmpty) {
            return Column(
              children: [
                Container(
                  color: background,
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                    children: [
                      Text(
                        'Kalecilerimiz',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        )
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
                                  MaterialPageRoute(
                                    builder: (context) => const FilterPage(),
                                  ),
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
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 70,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            'İlgili sonuç bulunamadı',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.black
                            ),
                          ),
                        )
                      ],
                    )
                  ),
                )
              ],
            );
          }

          return ListView.builder(
            itemCount: (docs.length / 2).ceil(),
            itemBuilder: (context, index) {
              var startIndex = index * 2;
              var endIndex = startIndex + 1;

              if (endIndex >= docs.length) {
                endIndex = docs.length - 1;
              }

              var sellerDetails1 = docs[startIndex]['sellerDetails'];
              var fullName1 = sellerDetails1['sellerFullName'];
              var imageUrls1 = sellerDetails1['imageUrls'];
              var imageUrl1 = imageUrls1[0];
              String city1 = sellerDetails1['city'];
              String district1 = sellerDetails1['district'];
              var sellerUid1 = docs[startIndex].id;

              var sellerDetails2 = docs[endIndex]['sellerDetails'];
              var fullName2 = sellerDetails2['sellerFullName'];
              var imageUrls2 = sellerDetails2['imageUrls'];
              var imageUrl2 = imageUrls2[0];
              String city2 = sellerDetails2['city'];
              String district2 = sellerDetails2['district'];
              var sellerUid2 = docs[endIndex].id;

              return Column(
                children: [
                  if (index == 0)
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
                                  MaterialPageRoute(
                                    builder: (context) => const FilterPage(),
                                  ),
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
                  Container(
                    color: background,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    sharedValues.sellerUid = sellerUid1;
                                    _handleCardTap(context, sellerDetails1, sellerUid1);
                                  },
                                  child: Card(
                                    elevation: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          color: Colors.white,
                                          child: Image.network(
                                            imageUrl1,
                                            height: 190,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        if (fullName1 != null && fullName1.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  fullName1,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "$city1,$district1",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    sharedValues.sellerUid = sellerUid2;
                                    _handleCardTap(context, sellerDetails2, sellerUid2);
                                  },
                                  child: Card(
                                    elevation: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (imageUrl1 != imageUrl2)
                                          Container(
                                            color: Colors.white,
                                            child: Image.network(
                                              imageUrl2,
                                              height: 190,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        if (fullName2 != null && fullName2.isNotEmpty && fullName1 != fullName2)
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  fullName2,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "$city2,$district2",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
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
}

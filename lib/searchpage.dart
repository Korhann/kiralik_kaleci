import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/SellerGridItem.dart';
import 'package:kiralik_kaleci/filterpage.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'sellerDetails.dart';
import 'sharedvalues.dart';


//TODO: BURADA LAZY LOADING KULLANILACAK 

class GetUserData extends StatefulWidget {
  const GetUserData({super.key});

  @override
  State<GetUserData> createState() => _GetUserDataState();
}

class _GetUserDataState extends State<GetUserData> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _userStream;

  String? nameFilter, cityFilter, districtFilter, fieldFilter;
  List<String> daysFilter = [];
  int? minFilter = 0, maxFilter = 0;

  @override
  void initState() {
    super.initState();
    _userStream = _firestore
        .collection("Users")
        .where('sellerDetails', isNotEqualTo: null)
        .snapshots();
    userorseller = false;
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
              _HeaderSection(onFilterTap: _navigateToFilterPage),
              docs.isEmpty ? _EmptyState() : _SellerGrid(docs: docs, onCardTap: _handleCardTap),
            ],
          );
        },
      ),
    );
  }

  void _navigateToFilterPage() async {
    final filters = await Navigator.push(
      context,
      _createRoute(FilterPage(daysFilter: daysFilter)),
    );
    runFilters(filters);
  }

  void _handleCardTap(BuildContext context, Map<String, dynamic> sellerDetails, String sellerUid) {
    sharedValues.sellerUid = sellerUid;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SellerDetailsPage(sellerDetails: sellerDetails, sellerUid: sellerUid),
      ),
    );
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
      print('max filter is $maxFilter');
      print('min filter is $minFilter');
      applyFilter();
    }
  }

  void applyFilter() {
  Query<Map<String, dynamic>> query = _firestore.collection('Users');

  if (nameFilter?.isNotEmpty == true) {
    query = query.where('sellerDetails.sellerFullName', isEqualTo: nameFilter);
  }
  if (cityFilter?.isNotEmpty == true) {
    query = query.where('sellerDetails.city', isEqualTo: cityFilter);
  }
  if (districtFilter?.isNotEmpty == true) {
    query = query.where('sellerDetails.district', isEqualTo: districtFilter);
  }
  if (fieldFilter?.isNotEmpty == true) {
    query = query.where('sellerDetails.fields', arrayContains: fieldFilter);
  }
  if (daysFilter.isNotEmpty) {
    query = query.where('sellerDetails.chosenDays', arrayContainsAny: daysFilter);
  }
  if (minFilter != null && maxFilter != null) {
    query = query
      .where('sellerDetails.sellerPrice', isGreaterThanOrEqualTo: minFilter!)
      .where('sellerDetails.sellerPrice', isLessThanOrEqualTo: maxFilter!);
  } else if (minFilter != null) {
    query = query.where('sellerDetails.sellerPrice', isGreaterThanOrEqualTo: minFilter!);
  } else if (maxFilter != null) {
    query = query.where('sellerDetails.sellerPrice', isLessThanOrEqualTo: maxFilter!);
  }

  setState(() {
    _userStream = query.snapshots();
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

class _HeaderSection extends StatelessWidget {
  final VoidCallback onFilterTap;

  const _HeaderSection({required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      padding: const EdgeInsets.only(top: 15),
      child: Row(
        children: [
          Text(
            "Kalecilerimiz",
            style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.handshake),
          const Spacer(),
          GestureDetector(
            onTap: onFilterTap,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Image.asset('lib/icons/setting.png', width: 20, height: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 70, color: Colors.grey.shade500),
            const SizedBox(height: 10),
            Text(
              'İlgili sonuç bulunamadı',
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class _SellerGrid extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  final Function(BuildContext, Map<String, dynamic>, String) onCardTap;

  const _SellerGrid({required this.docs, required this.onCardTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: GridView.builder(
          physics: const ScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var sellerDetails = docs[index]['sellerDetails'];
            var sellerUid = docs[index].id;

            return SellerGridItem(
              sellerDetails: sellerDetails,
              sellerUid: sellerUid,
              onTap: (uid) => onCardTap(context, sellerDetails, uid),
            );
          },
        ),
      ),
    );
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/SellerGridItem.dart';
import 'package:kiralik_kaleci/appointmentspage.dart';
import 'package:kiralik_kaleci/filterpage.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/shimmers.dart';
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

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserStream();
    userorseller = false;
  }

  Future<void> getUserStream() async {
    try {
      _userStream = _firestore
          .collection("Users")
          .where('sellerDetails', isNotEqualTo: null)
          .snapshots();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SellerGridShimmer();
    }

    return Scaffold(
      backgroundColor: background,
      body: StreamBuilder(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Bağlantı hatası"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SellerGridShimmer();
          }
          var docs = snapshot.data!.docs
              .where((doc) => doc.data().containsKey('sellerDetails'))
              .toList();

          return Column(
            children: [
              _HeaderSection(
                onFilterTap: _navigateToFilterPage,
                onNotificationTap: _navigateToAppsPage,
              ),
              docs.isEmpty
                  ? _EmptyState()
                  : _SellerGrid(
                      docs: docs,
                      onCardTap: _handleCardTap,
                      isLoading: isLoading),
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

  void _navigateToAppsPage() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AppointmentsPage(whereFrom: 'homePage')));
  }

  void _handleCardTap(BuildContext context, Map<String, dynamic> sellerDetails,
      String sellerUid) {
    sharedValues.sellerUid = sellerUid;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SellerDetailsPage(
            sellerDetails: sellerDetails, sellerUid: sellerUid),
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
      applyFilter();
    }
  }

  void applyFilter() {
    Query<Map<String, dynamic>> query = _firestore.collection('Users');

    if (nameFilter?.isNotEmpty == true) {
      query =
          query.where('sellerDetails.sellerFullName', isEqualTo: nameFilter);
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
      query =
          query.where('sellerDetails.chosenDays', arrayContainsAny: daysFilter);
    }
    if (minFilter != null && maxFilter != null) {
      query = query
          .where('sellerDetails.sellerPrice',
              isGreaterThanOrEqualTo: minFilter!)
          .where('sellerDetails.sellerPrice', isLessThanOrEqualTo: maxFilter!);
    } else if (minFilter != null) {
      query = query.where('sellerDetails.sellerPrice',
          isGreaterThanOrEqualTo: minFilter!);
    } else if (maxFilter != null) {
      query = query.where('sellerDetails.sellerPrice',
          isLessThanOrEqualTo: maxFilter!);
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
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final VoidCallback onFilterTap;
  final VoidCallback onNotificationTap;

  const _HeaderSection({required this.onFilterTap, required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      padding: const EdgeInsets.only(top: 15),
      child: Row(
        children: [
          Text(
            "Kalecilerimiz",
            style: GoogleFonts.inter(
                fontSize: 26, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.handshake),
          const Spacer(),

          //todo: Bunu class a çevir performans için :D
          GestureDetector(
            onTap: onNotificationTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.notifications, size: 24, color: Colors.black),
                ),
                StreamBuilder<int>(
                  stream: getUnreadCount(), // Fetch unread notifications
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == 0)
                      return SizedBox();
                    return Positioned(
                      right: 5, // Adjust position
                      top: -3,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          snapshot.data.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onFilterTap,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child:
                  Image.asset('lib/icons/setting.png', width: 20, height: 20),
            ),
          ),
        ],
      ),
    );
  }
  Stream<int> getUnreadCount() {
    final String currentUser = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
      .collection('Users')
      .doc(currentUser)
      .collection('appointmentbuyer')
      .where('appointmentDetails.status', whereIn: ['approved', 'rejected'])
      .where('appointmentDetails.paymentStatus', isEqualTo: 'waiting')  
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
  }  
}




class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Flexible(
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
                  color: Colors.black),
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
  final bool isLoading;

  const _SellerGrid(
      {required this.docs, required this.onCardTap, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Flexible(
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/messagepage.dart';
import 'package:kiralik_kaleci/sharedvalues.dart';
import 'package:kiralik_kaleci/styles/button.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class SellerDetailsPage extends StatefulWidget {
  const SellerDetailsPage({
    Key? key,
    required this.sellerDetails,
    required this.sellerUid,
  }) : super(key: key);

  final Map<String, dynamic> sellerDetails;
  final String sellerUid;

  @override
  State<SellerDetailsPage> createState() => _SellerDetailsPageState();
}

class _SellerDetailsPageState extends State<SellerDetailsPage> {

  // kullanıcı saatleri ile ilgili kısım
  List<String> days = [];
  String? day;
  Map<String, List<String>> hoursByDay = {};
  List<String> orderedDays = [
    'Pazartesi',
    'Salı',
    'Çarşmaba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];


  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    if (widget.sellerUid.isNotEmpty) {
      await _getDaysName(widget.sellerUid);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    var imageUrl = widget.sellerDetails['imageUrls'][0];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: background,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: background,
            child: Column(
              children: [
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: Colors.white,
                      height: 450,
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            child: Stack(
                              children: [
                                Image.network(
                                  imageUrl,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                                Positioned(
                                  top: 15,
                                  right: 25,
                                  child: GestureDetector(
                                    onTap: () {
                                      _addToFavorites(widget.sellerDetails, widget.sellerUid);
                                    },
                                    child: const Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Text(
                                  "${widget.sellerDetails['sellerName']}",
                                  style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "${widget.sellerDetails['sellerLastName']}",
                                  style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 7),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "${widget.sellerDetails['city']} ,${widget.sellerDetails['district']}",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                Text(
                                  "Saatler",
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                  SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Print days horizontally
                                        SizedBox(
                                          height: 150,
                                          width: 300,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: days.length,
                                            itemBuilder: (context, index) {
                                              final day = days[index];
                                              final hours = hoursByDay[day] ?? [];
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      day, 
                                                      style: GoogleFonts.inter(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 7),
                                                    Container(
                                                      height: 120,
                                                      child: SingleChildScrollView(
                                                        scrollDirection: Axis.vertical,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: hours.map((hour) {
                                                            return ClipRRect(
                                                              borderRadius: BorderRadius.circular(10),
                                                              child: Container(
                                                                margin: const EdgeInsets.symmetric(vertical: 3.0),
                                                                padding: const EdgeInsets.all(5),
                                                                color: Colors.cyan,
                                                                child: Text(
                                                                  hour,
                                                                  style: GoogleFonts.inter(
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.w400,
                                                                    color: Colors.black,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    // butona bastıktan sonra ödeme sayfasına atacak
                  },
                  style: buttonPrimary,
                  child: Text(
                    "Ödeme (₺${widget.sellerDetails['sellerPrice']})",
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          Positioned(
            bottom: 80,
            right: 20,
            child: GestureDetector(
              onTap: () {
                // Merhaba diye mesaj yollayacak kaleciye
                // zaten dokunulan satıcının uid sini yolladın, 
                //direkt messagepage.dart sayfasına yönlendirebilirsin kullanıcıyı
                sharedValues.onTapped = true;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      sharedValues.onTapped = false;
                      return const MessagePage();
                    }
                  )
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.white,
                  width: 120,
                  height: 50,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.forward_to_inbox,
                          color: Colors.black,
                          size: 24,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Sohbet",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getDaysName(String userId) async {

    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("Users").doc(userId).get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data.isNotEmpty && data.containsKey('sellerDetails')) {
        Map<String, dynamic> sellerDetails = data['sellerDetails'];
        if (sellerDetails.containsKey('selectedHoursByDay')) {
          Map<String, dynamic> selectedHoursByDay = sellerDetails['selectedHoursByDay'];

          List<String> userDays = orderedDays.where((day) {
          return selectedHoursByDay.containsKey(day) && selectedHoursByDay[day].isNotEmpty;
        }).toList();

          setState(() {
            days.clear();
            days.addAll(userDays);
            hoursByDay.clear(); // Başka bir kullanıcıya tıklayınca temizle
          });

          for (String day in days) {
            if (selectedHoursByDay.containsKey(day)) {
              hoursByDay[day] = (selectedHoursByDay[day] as List).cast<String>();
            }
          }
        }
      }
    }
  }
  void _addToFavorites(Map<String, dynamic> sellerDetails, String sellerUid) {
  final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
  try {
    if (currentUserUid != null && currentUserUid.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserUid)
          .collection('favourites')
          .add(sellerDetails)
          .then((value) {
            print('Seller details added successfully with document ID: ${value.id}');
          })
          .catchError((error) {
            print('Error adding seller details: $error');
          });
    }
  } catch (e) {
    print('Error: $e');
    }
  }
   bool isFavorite(String sellerUid) {
    // bunu sonradan yap unutma
    return true;
  }
}

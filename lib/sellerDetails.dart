import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/messagepage.dart';
import 'package:kiralik_kaleci/paymentpage.dart';
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
  Map<String,bool> hourIsTaken = {};
  Map<String, Color> hourColors = {};
  String? _selectedDay;
  String? _selectedHour;
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
  bool isFavorited = false;
  final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _getData();
    _checkIfFavorited();
  }

  Future<void> _getData() async {
    if (widget.sellerUid.isNotEmpty) {
      await _getDaysName(widget.sellerUid);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkIfFavorited() async {
    final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid != null && currentUserUid.isNotEmpty) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserUid)
          .collection('favourites')
          .where('sellerUid', isEqualTo: widget.sellerUid)
          .get();

      setState(() {
        isFavorited = snapshot.docs.isNotEmpty;
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
        backgroundColor: userorseller ? sellerbackground : background,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: userorseller ? Colors.white: Colors.black),
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: userorseller ? sellerbackground : background,
            child: Column(
              children: [
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: userorseller ? sellergrey: Colors.white,
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
                                      _toggleFavorite(widget.sellerDetails, widget.sellerUid);
                                    },
                                    child: Icon(
                                      Icons.favorite,
                                      color: isFavorited ? Colors.red : Colors.grey,
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
                                  "${widget.sellerDetails['sellerFullName']}",
                                  style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: userorseller ? Colors.white : Colors.black,
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
                                color: userorseller ? Colors.white : Colors.black,
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
                                    color: userorseller ? Colors.white : Colors.black,
                                  ),
                                ),
                                SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Print days horizontally
                                      SizedBox(
                                        height: 150,
                                        width: double.infinity,
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
                                                      color: userorseller ? Colors.white: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 7),
                                                  SizedBox(
                                                    height: 120,
                                                    child: SingleChildScrollView(
                                                      scrollDirection: Axis.vertical,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: hours.map((hour) {
                                                          // todo: dayHourKey ile db den aldığım saatleri karşılaştırıp ona göre rengini değiştirebilirim
                                                          String dayHourKey = '$day $hour';
                                                          return GestureDetector(
                                                            // renk sadece cyan ise seçilebilir
                                                            onTap: hourColors[dayHourKey] == Colors.cyan
                                                            ? () {
                                                              setState(() {
                                                                _selectedDay = day;
                                                                _selectedHour = hour;
                                                                // eğer available ise seçebilirsin, değilse seçemezsin
                                                                if (hourColors[dayHourKey] == Colors.cyan) {
                                                                  hourColors[dayHourKey] = Colors.grey;
                                                                }
                                                              });
                                                            } : null,
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(10),
                                                              child: Container(
                                                                margin: const EdgeInsets.symmetric(vertical: 3.0),
                                                                padding: const EdgeInsets.all(5),
                                                                color: hourColors[dayHourKey] ?? Colors.cyan,
                                                                child: Text(
                                                                  hour,
                                                                  style: GoogleFonts.inter(
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.w400,
                                                                    color: userorseller ? Colors.white : Colors.black,
                                                                  ),
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
                    if (_selectedDay == null && _selectedHour == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Saat ve gün seçiniz'),
                          backgroundColor: Colors.red,
                        )
                      );
                    } else if (widget.sellerUid == currentUserUid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kullanıcı kendini seçemez'),
                          backgroundColor: Colors.red,
                        )
                      );
                    }
                    else {
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentPage(
                          sellerUid: widget.sellerUid,
                          selectedDay: _selectedDay!,
                          selectedHour: _selectedHour!,
                        )
                      ),
                    );
                    }
                  },
                  style: buttonPrimary,
                  child: Text(
                    "Ödeme (₺${widget.sellerDetails['sellerPrice']})",
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: userorseller ? Colors.white : Colors.black,
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
          hoursByDay.clear(); // Clean up for another user
          hourColors.clear(); // Reset hourColors for new data
        });

        // Get the current day
        final now = DateTime.now().toUtc().add(const Duration(hours: 3));
        final int currentDayIndex = now.weekday - 1; // 0 for Monday, 6 for Sunday

        for (int i = 0; i < orderedDays.length; i++) {
          final day = orderedDays[i];
          if (!selectedHoursByDay.containsKey(day)) continue;

          List<dynamic> hourList = selectedHoursByDay[day] as List;
          List<String> hourTitles = [];
          for (var hour in hourList) {
            Map<String, dynamic> hourMap = hour as Map<String, dynamic>;
            String title = hourMap['title'];
            bool istaken = hourMap['istaken'];

            // Determine the color based on istaken and whether the day is past
            String dayHourKey = '$day $title';
            bool isPastDay = i < currentDayIndex;

            // eski false değeri kaldırıp yerine true değerini koyuyor aşşağıda
            if (isPastDay && istaken) {
              await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .update({
                'sellerDetails.selectedHoursByDay.$day':
                FieldValue.arrayUnion([{'title': title, 'istaken': false}])
              });

              await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .update({
                'sellerDetails.selectedHoursByDay.$day':
                FieldValue.arrayRemove([{'title': title, 'istaken': true}])
              });
              istaken = false;
            }

            // If the day is past or the hour is taken, mark as grey
            hourColors[dayHourKey] = (isPastDay || istaken) ? Colors.grey : Colors.cyan;

            // Add the title to display in the UI
            hourTitles.add(title);
          }

          setState(() {
            hoursByDay[day] = hourTitles;
          });
        }
      }
    }
  }
}

  void _toggleFavorite(Map<String, dynamic> sellerDetails, String sellerUid) async {
    final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid != null && currentUserUid.isNotEmpty) {
      if (isFavorited) {
        // Remove from favorites
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUserUid)
            .collection('favourites')
            .where('sellerUid', isEqualTo: sellerUid)
            .get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
        setState(() {
          isFavorited = false;
        });
      } else {
        // Add to favorites
        sellerDetails['sellerUid'] = sellerUid; 
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUserUid)
            .collection('favourites')
            .add(sellerDetails);
        setState(() {
          isFavorited = true;
        });
      }
    }
  }
}

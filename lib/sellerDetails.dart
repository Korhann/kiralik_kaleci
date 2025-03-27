import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/connectivity.dart';
import 'package:kiralik_kaleci/connectivityWithBackButton.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/main.dart';
import 'package:kiralik_kaleci/mainpage.dart';
import 'package:kiralik_kaleci/messagepage.dart';
import 'package:kiralik_kaleci/apptRequest.dart';
import 'package:kiralik_kaleci/selleraddpage.dart';
import 'package:kiralik_kaleci/sellermainpage.dart';
import 'package:kiralik_kaleci/sharedvalues.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:shimmer/shimmer.dart';

class SellerDetailsPage extends StatefulWidget {
  const SellerDetailsPage({
    super.key,
    required this.sellerDetails,
    required this.sellerUid,
  });

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
  String? _selectedField;
  List<String> orderedDays = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  bool isLoading = true;
  bool isFavorited = false;
  final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
  bool isEmpty = false;

  //Stream<QuerySnapshot<Map<String, dynamic>>>? userStream;
  late Future<void> _daysNameFuture;

  @override
  void initState() {
    super.initState();
     _daysNameFuture = _getDaysName(widget.sellerUid);
    _checkIfFavorited();
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

      if (mounted) {
        setState(() {
        isFavorited = snapshot.docs.isNotEmpty;
      });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // eğer kullanıcı hiç ilan açmamış ise
    if (widget.sellerDetails.isEmpty) {
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
        body: SafeArea(
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            color: sellerbackground,
            child: Column(
              children: [
                const SizedBox(height: 30),
                Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Henüz bir ilanınız bulunmamaktadır',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SellerMainPage())
                  );
                },
                style: GlobalStyles.buttonPrimary(),
                child: Text(
                  'İlan ver',
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: userorseller ? Colors.white : Colors.black,
                  ),
                )
              )
            ],
            ),
          ),
        )
      );
    }

    var imageUrl = widget.sellerDetails['imageUrls'][0];
    return ConnectivityWithBackButton(
      child: FutureBuilder(
        future: _daysNameFuture,
        builder: (context,snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerClass();
          }
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
                        height: 400,
                        width: MediaQuery.sizeOf(context).width,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                child: showImage(imageUrl: imageUrl, isFavorited: isFavorited, sellerDetails: widget.sellerDetails, sellerUid: widget.sellerUid)
                              ),
                              const SizedBox(height: 20),
                              
                              showNameSurname(sellerDetails: widget.sellerDetails),
                              
                              const SizedBox(height: 7),
                              
                              showCityDistrict(sellerDetails: widget.sellerDetails),
                              
                              const SizedBox(height: 5),
                              // kullanıcı buradan kaleci seçecek
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 40,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: widget.sellerDetails['fields'].length,
                                    itemBuilder: (context,int index) {
                                      String field = widget.sellerDetails['fields'][index];
                                      bool isSelected = _selectedField == field;
                                      return chooseCard(
                                        field: field,
                                        isSelected: isSelected,
                                        onTap: () {
                                          setState(() {
                                          _selectedField = field;
                                          });
                                        },
                                        userorseller: userorseller
                                      );
                                    },
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
                                          // Print days horizontally using the DayHourListView widget
                                          DayHourListView(
                                            days: days,
                                            hoursByDay: hoursByDay,
                                            hourColors: hourColors,
                                            selectedDay: _selectedDay,
                                            selectedHour: _selectedHour,
                                            userorseller: userorseller,
                                            onDaySelected: (selectedDay) {
                                              setState(() {
                                                _selectedDay = selectedDay;
                                              });
                                            },
                                            onHourSelected: (selectedHour) {
                                              setState(() {
                                                _selectedHour = selectedHour;
                                              });
                                            },
                                            onClearSelection: () {
                                              setState(() {
                                                _selectedDay = null;
                                                _selectedHour = null;
                                                hourColors.forEach((key, value) {
                                                  if (value != Colors.grey.shade600 && value != Colors.green) {
                                                    hourColors[key] = Colors.cyan;
                                                  }
                                                });
                                              });
                                            },
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                    const SizedBox(height: 10,)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: showInfoAppointments()
                  ),
                  const SizedBox(height: 70),
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedDay == null || _selectedHour == null || _selectedField == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Saat, gün ve saha seçiniz'),
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
                          builder: (context) => ApptRequest(
                            sellerUid: widget.sellerUid,
                            selectedDay: _selectedDay!,
                            selectedHour: _selectedHour!,
                            selectedField: _selectedField!,
                          )
                        ),
                      );
                      }
                    },
                    style: GlobalStyles.buttonPrimary(),
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
            ChatButton(sellerUid: widget.sellerUid)
          ],
          )
        );
        }
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

        if (mounted) {
          setState(() {
          days.clear();
          days.addAll(userDays);
          hoursByDay.clear(); // Clean up for another user
          hourColors.clear(); // Reset hourColors for new data
        });
        }

        // Get the current day
        final now = DateTime.now().toUtc().add(const Duration(hours: 3));
        final int currentDayIndex = now.weekday - 1; // 0 pazartesi, 6 pazar
        
        for (int i = 0; i < orderedDays.length; i++) {
          final day = orderedDays[i];
          if (!selectedHoursByDay.containsKey(day)) continue;

          List<dynamic> hourList = selectedHoursByDay[day] as List;
          List<String> hourTitles = [];
          for (var hour in hourList) {
            Map<String, dynamic> hourMap = hour as Map<String, dynamic>;
            String title = hourMap['title'];
            bool istaken = hourMap['istaken'];
            String? takenby = hourMap['takenby'];

            // Determine the color based on istaken and whether the day is past
            String dayHourKey = '$day $title';
            bool isPastDay = i < currentDayIndex;
            
            if (isPastDay) {
              markPastDayAsTaken(userId: userId, day: day, title: title);
            }

            // duruma göre renk belirliyor
            if (istaken) {
              if (takenby == currentUserUid) {
                hourColors[dayHourKey] = Colors.green;
              } else {
                hourColors[dayHourKey] = Colors.grey.shade600;  
              }
            } else {
              hourColors[dayHourKey] = Colors.cyan;
            }
            hourTitles.add(title);
          }
        
        if (mounted) {
          setState(() {
            hoursByDay[day] = hourTitles;
          });
        }
        }
      }
    }
  }
}
Future<void> markPastDayAsTaken({required String userId,required String day,required String title}) async {

  final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
  List<dynamic> data = userDoc.data()?['sellerDetails']['selectedHoursByDay'][day] ?? [];
  List<dynamic> updatedData = data.map((hour) {
      return {
        'title': hour['title'],
        'istaken': true,
        'takenby': 'empty'
      };
  }).toList();

  await FirebaseFirestore.instance.collection('Users').doc(userId).update({
    'sellerDetails.selectedHoursByDay.$day': updatedData
  });
}

}

class showImage extends StatefulWidget {
  final String imageUrl;
  final bool isFavorited; 
  final Map<String, dynamic> sellerDetails;
  final String sellerUid;

  const showImage({
    super.key,
    required this.imageUrl,
    required this.isFavorited,
    required this.sellerDetails,
    required this.sellerUid,
  });

  @override
  State<showImage> createState() => _showImageState();
}

class _showImageState extends State<showImage> {
  late bool _isFavorited; 

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.isFavorited; 
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.network(
          widget.imageUrl,
          height: 180,
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
    return Image.asset(
      'lib/images/imageDefault.jpg',
      fit: BoxFit.contain,
      height: 180,
      width: MediaQuery.of(context).size.width,
    );
  },
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
              color: _isFavorited ? Colors.red : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  void _toggleFavorite(Map<String, dynamic> sellerDetails, String sellerUid) async {
    final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid != null && currentUserUid.isNotEmpty) {
      if (_isFavorited) {
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
          _isFavorited = false;
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
          _isFavorited = true;
        });
      }
    }
  }
}
class showNameSurname extends StatelessWidget {
  final Map<String,dynamic> sellerDetails;
  const showNameSurname({required this.sellerDetails,super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Text(
            "${sellerDetails['sellerFullName']}",
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: userorseller ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
class showCityDistrict extends StatelessWidget {
  final Map<String,dynamic> sellerDetails;
  const showCityDistrict({required this.sellerDetails,super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        "${sellerDetails['city']} ,${sellerDetails['district']}",
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w300,
          color: userorseller ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
class chooseCard extends StatelessWidget {
  final String field;
  final bool isSelected;
  final VoidCallback onTap;
  final bool userorseller;

  const chooseCard({
    super.key,
    required this.field,
    required this.isSelected,
    required this.onTap,
    required this.userorseller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: isSelected ? Colors.grey : green,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                field,
                style: TextStyle(
                  color: userorseller ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class DayHourListView extends StatelessWidget {
  final List<String> days;
  final Map<String, List<String>> hoursByDay;
  final Map<String, Color> hourColors;
  final String? selectedDay;
  final String? selectedHour;
  final bool userorseller;
  final ValueChanged<String> onDaySelected;
  final ValueChanged<String> onHourSelected;
  final VoidCallback onClearSelection;

  const DayHourListView({
    super.key,
    required this.days,
    required this.hoursByDay,
    required this.hourColors,
    required this.selectedDay,
    required this.selectedHour,
    required this.userorseller,
    required this.onDaySelected,
    required this.onHourSelected,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                    color: userorseller ? Colors.white : Colors.black,
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
                        // Generate unique key for each hour
                        String dayHourKey = '$day $hour';
                        bool isSelected = hourColors[dayHourKey] == Colors.grey;
                        bool isDisabled = hourColors[dayHourKey] == Colors.grey.shade600 || hourColors[dayHourKey] == Colors.grey || hourColors[dayHourKey] == Colors.green;

                        return GestureDetector(
                          // Only allow interaction if not disabled
                          onTap: !isDisabled
                              ? () {
                                  onDaySelected(day);
                                  onHourSelected(hour);

                                  hourColors.forEach((key, value) {
                                    if (value != Colors.grey.shade600 && value != Colors.green) {
                                      hourColors[key] = Colors.cyan;
                                    }
                                  });

                                  hourColors[dayHourKey] = Colors.grey;
                                }
                              : null,
                          child: Stack(
                            children: [
                              ClipRRect(
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
                              if (isSelected)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: onClearSelection,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 8,
                                      ),
                                    ),
                                  ),
                                )
                            ],
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
    );
  }
}
class showInfoAppointments extends StatelessWidget {
  const showInfoAppointments({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 10,
                              width: 10,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Randevu saatin',
                            style: TextStyle(
                              color: userorseller ? Colors.white: Colors.black
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 10,
                              width: 10,
                              color: Colors.cyan,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Müsait',
                            style: TextStyle(
                              color: userorseller ? Colors.white: Colors.black
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 10,
                              width: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Alınmış veya geçmiş',
                            style: TextStyle(
                              color: userorseller ? Colors.white : Colors.black
                            ),
                          )
                        ],
                      ),
                    ],
                  );
  }
}
class ChatButton extends StatelessWidget {
  final String sellerUid;
  
  const ChatButton({
    super.key,
    required this.sellerUid,
  });

  @override
  Widget build(BuildContext context) {

    return Positioned(
      bottom: 120,
      right: 20,
      child: GestureDetector(
        onTap: () {
          // Set shared state and navigate to the message page
          sharedValues.onTapped = true;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                sharedValues.onTapped = false;
                return MessagePage();  // Assuming MessagePage is already defined
              },
            ),
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
    );
  }
}

class ShimmerClass extends StatelessWidget {
  const ShimmerClass({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: userorseller ? sellerbackground : background,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: userorseller ? Colors.white : Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 200, width: double.infinity, color: Colors.white), // image placeholder
              const SizedBox(height: 20),
              Container(height: 20, width: 150, color: Colors.white), // name placeholder
              const SizedBox(height: 10),
              Container(height: 20, width: 100, color: Colors.white), // location placeholder
              const SizedBox(height: 30),
              Container(height: 40, width: double.infinity, color: Colors.white), // fields list placeholder
              const SizedBox(height: 20),
              Container(height: 200, width: double.infinity, color: Colors.white), // hours list placeholder
            ],
          ),
        ),
      ),
    );
  }
}




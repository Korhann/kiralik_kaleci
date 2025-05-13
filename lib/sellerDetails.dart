import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/connectivityWithBackButton.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/messagepage.dart';
import 'package:kiralik_kaleci/apptRequest.dart';
import 'package:kiralik_kaleci/responsiveTexts.dart';
import 'package:kiralik_kaleci/sellermainpage.dart';
import 'package:kiralik_kaleci/sharedvalues.dart';
import 'package:kiralik_kaleci/shimmers.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';

class SellerDetailsPage extends StatefulWidget {
  const SellerDetailsPage({
    super.key,
    required this.sellerDetails,
    required this.sellerUid,
    required this.wherFrom
  });

  final Map<String, dynamic> sellerDetails;
  final String sellerUid;
  final String wherFrom;

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
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
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
            width: width,
            color: sellerbackground,
            child: Column(
              children: [
                SizedBox(height: height * 0.030),
                Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Henüz bir ilanınız bulunmamaktadır',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: height * 0.030),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SellerMainPage(index: 2,))
                  );
                },
                style: GlobalStyles.buttonPrimary(context),
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
      child: FutureBuilder<void>(
        future: _daysNameFuture,
        builder: (context,snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            switch (widget.wherFrom){
              case 'fromSomewhere':
                return SellerDetailsDarkShimmer();
              default:
                return SellerDetailsShimmer();
            } 
          }

          final width = MediaQuery.sizeOf(context).width;
          final height = MediaQuery.sizeOf(context).height;

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
            child: Stack(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height
                ),
                child: Container(
                color: userorseller ? sellerbackground : background,
                child: Column(
                  children: [
                    SizedBox(height: height * 0.025),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          color: userorseller ? sellergrey: Colors.white,
                          height: height * 0.65,
                          width: width,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  child: showImage(imageUrl: imageUrl, isFavorited: isFavorited, sellerDetails: widget.sellerDetails, sellerUid: widget.sellerUid, width: width, height: height)
                                ),
                                SizedBox(height: height * 0.020),
                                
                                showNameSurname(sellerDetails: widget.sellerDetails),
                                
                                SizedBox(height: height * 0.007),
                                
                                showCityDistrict(sellerDetails: widget.sellerDetails),
                                
                                SizedBox(height: height * 0.005),
                                
                                SellerFields(
                                  selectedField: _selectedField ?? widget.sellerDetails['fields'][0],
                                  sellerDetails: widget.sellerDetails,
                                  onFieldChanged: (newField) {
                                    setState(() {
                                      _selectedField = newField;
                                    });
                                  }, 
                                  width: width,
                                  ),
                                SizedBox(height: height * 0.010),
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
                                        textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                                      ),
                                      SizedBox(height: height * 0.010),
                                      SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            //todo: Gece saatleri sıkıntılı çalışıyor ve _getDaysName de de aynı kod çalışıyor, hangisi boş anla
                                            StreamBuilder<DocumentSnapshot>(
                                              stream: _stream(),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return const Center(child: CircularProgressIndicator());
                                                }
                                                final userData = snapshot.data!.data() as Map<String, dynamic>;
                                                final selectedHoursByDay = userData['sellerDetails']?['selectedHoursByDay'] as Map<String, dynamic>?;
                                                if (selectedHoursByDay == null) {
                                                  return const Text('Saat bilgisi bulunamadı');
                                                }
                                                
                                                days.clear();
                                                hoursByDay.clear();
                                                hourColors.clear();
                                                
                                                final now = DateTime.now().toUtc().add(const Duration(hours: 3));
                                                final int currentDayIndex = now.weekday - 1;
                                                
                                                for (int i = 0; i < orderedDays.length; i++) {
                                                  final day = orderedDays[i];
                                                  if (!selectedHoursByDay.containsKey(day)) continue;
                                                    List<dynamic> hourList = selectedHoursByDay[day];
                                                    
                                                    if (hourList.isEmpty) continue;
                                                      days.add(day);
                                                      List<String> hourTitles = [];
                                                      for (var hour in hourList) {
                                                        final hourMap = hour as Map<String, dynamic>;
                                                        final String title = hourMap['title'];
                                                        final bool istaken = hourMap['istaken'];
                                                        final String? takenby = hourMap['takenby'];
                                                        final String startTime = title.split('-')[0];
                                                        final String dayHourKey = '$day $title';
                                                        List<String> nightTitles = ['00:00-01:00','01:00-02:00','02:00-03:00'];
                                                        bool isNightHour = nightTitles.contains(title);
              
                                                        dayChecker(i, currentDayIndex, now, startTime, dayHourKey, takenby!, day, title, hourTitles, isNightHour, istaken);
                                                      }
                                                      
                                                  }
                                                  
                                                return DayHourListView(
                                                  width: width,
                                                  heigth: height,
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
                                                );
                                              }),
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
                    ),
                    SizedBox(height: height * 0.015),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: showInfoAppointments(width: width, height: height)
                    ),
                    SizedBox(height: height * 0.030),
                    PaymentButton(
                      selectedDay: _selectedDay,
                      selectedHour: _selectedHour,
                      selectedField: _selectedField,
                      currentUserUid: currentUserUid,
                      sellerUid: widget.sellerUid,
                      sellerDetails: widget.sellerDetails
                    ),
                    SizedBox(height: height * 0.030),
                  ],
                ),
              ),
              ),
              Positioned(
                bottom: 120,
                right: 20,
                child: ChatButton(sellerUid: widget.sellerUid, width: width,height: height,)
              )
            ],
            ),
          )
        );
        }
      ),
    );
  }
  //todo: Olmazsa eski yerine geri al
  void dayChecker(int i, int currentDayIndex, final now, String startTime, String dayHourKey, String takenby, String day, String title, List<String> hourTitles, bool isNightHour, bool istaken) {
    if (isNightHour) {
      bool isPastNightHour = i < currentDayIndex && isPastNightHours(now, startTime);
      if (isPastNightHour) {
        hourColors[dayHourKey] = takenby == currentUserUid ? Colors.green : Colors.grey.shade600; 
        markSingleHourAsTaken(userId: widget.sellerUid, day: day, title: title);
        } else {
          hourColors[dayHourKey] = Colors.cyan;
        }
        hourTitles.add(title);
        hoursByDay[day] = hourTitles;
        } else {
          bool isPastDay = i < currentDayIndex;
          bool sameDay = i == currentDayIndex;
          bool isPastHour = isStartTimePast(now, startTime, isNightHour) && sameDay;
          if (istaken || isPastDay || isPastHour) {
            hourColors[dayHourKey] = takenby == currentUserUid ? Colors.green : Colors.grey.shade600;
            if (isPastDay) {
              markPastDayAsTaken(userId: widget.sellerUid, day: day, title: title);
              } else if (isPastHour) {
                markSingleHourAsTaken(userId: widget.sellerUid, day: day, title: title);
              }
            } else {
              hourColors[dayHourKey] = Colors.cyan;
            }
            hourTitles.add(title);
        }
      hoursByDay[day] = hourTitles;
  }

  Stream<DocumentSnapshot> _stream() {
    return FirebaseFirestore.instance
    .collection('Users')
    .doc(widget.sellerUid)
    .snapshots();
  }

  //todo: Burayada saate göre geçme mantığını uygula
  Future<void> _getDaysName(String userId) async{
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
        // final now = DateTime.now().toUtc().add(const Duration(hours: 3));
        // final int currentDayIndex = now.weekday - 1; // 0 pazartesi, 6 pazar
        
        // for (int i = 0; i < orderedDays.length; i++) {
        //   final day = orderedDays[i];
        //   if (!selectedHoursByDay.containsKey(day)) continue;

        //   List<dynamic> hourList = selectedHoursByDay[day] as List;
        //   List<String> hourTitles = [];
        //   for (var hour in hourList) {
        //     Map<String, dynamic> hourMap = hour as Map<String, dynamic>;
        //     String title = hourMap['title'];
        //     bool istaken = hourMap['istaken'];
        //     String? takenby = hourMap['takenby'];
        //     String startTime = title.split('-')[0].toString();

        //     // Determine the color based on istaken and whether the day is past
        //     List<String> titles = ['00:00-01:00','01:00-02:00','02:00-03:00'];
        //     bool contains = titles.contains(title);
        //     String dayHourKey = '$day $title';
        //     bool isPastDay = i < currentDayIndex;
        //     bool sameDay = i == currentDayIndex;


        //     if (isPastDay) {
        //       // kesinlikle geçmiş olarak işaretle
        //       await markPastDayAsTaken(userId: userId, day: day, title: title);
        //     } else if (sameDay && !contains) {
        //       // saate göre geçme methodu yap
        //       final isPastHour = isStartTimePast(now, startTime);
        //       if (isPastHour) {
        //         await markSingleHourAsTaken(userId: userId, day: day, title: title);
        //       }
        //     }

        //     // duruma göre renk belirliyor
        //     if (istaken) {
        //       if (takenby == currentUserUid) {
        //         hourColors[dayHourKey] = Colors.green;
        //       } else {
        //         hourColors[dayHourKey] = Colors.grey.shade600;  
        //       }
        //     } else {
        //       hourColors[dayHourKey] = Colors.cyan;
        //     }
        //     hourTitles.add(title);
        //   }
        
        // if (mounted) {
        //   setState(() {
        //     hoursByDay[day] = hourTitles;
        //   });
        // }
        // }
      }
    }
  }
}
// TODO: Kontrol et geçmiş saatler ilk açılınca renk değiştiriyor mu diye
Future<void> markPastDayAsTaken({required String userId,required String day,required String title}) async {

  final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
  List<dynamic> data = userDoc.data()?['sellerDetails']['selectedHoursByDay'][day] ?? [];
  bool needsUpdate = false;
  List<dynamic> updatedData = data.map((hour) {
    if (hour['istaken'] == false) {
      needsUpdate = true;
      return {
        'title': hour['title'],
        'istaken': true,
        'takenby': 'empty'
      };
    } else {
      return hour;
    }
  }).toList();

  if (needsUpdate) {
    await FirebaseFirestore.instance.collection('Users').doc(userId).update({
    'sellerDetails.selectedHoursByDay.$day': updatedData
  });
  }
}
}

Future<void> markSingleHourAsTaken({required String userId, required String day, required String title}) async {
  final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
  List<dynamic> data = userDoc.data()?['sellerDetails']['selectedHoursByDay'][day] ?? [];

  List<dynamic> updatedData = data.map((hour) {
    if (hour['title'] == title && hour['istaken'] == false) {
      return {
        'title': hour['title'],
        'istaken': true,
        'takenby': 'empty',
      };
    }
    return hour;
  }).toList();

  await FirebaseFirestore.instance.collection('Users').doc(userId).update({
    'sellerDetails.selectedHoursByDay.$day': updatedData,
  });
}

bool isStartTimePast(DateTime now, String startTime, bool isNightHour) {
  final nowInMinutes = now.hour * 60 + now.minute;

  final parts = startTime.split(':');
  final startHour = int.parse(parts[0]);
  final startMinute = int.parse(parts[1]);
  final startInMinutes = startHour * 60 + startMinute;

  // Gece saati ise ertesi günmüş gibi davranıyor
  if (isNightHour) return false;

  return nowInMinutes >= startInMinutes;
}

bool isPastNightHours(DateTime now, String startTime) {
  final nowInMinutes = now.hour * 60 + now.minute;

  final parts = startTime.split(':');
  final startHour = int.parse(parts[0]);
  final startMinute = int.parse(parts[1]);
  final startInMinutes = startHour * 60 + startMinute;

  return nowInMinutes >= startInMinutes;
}



class SellerFields extends StatefulWidget {
  final String selectedField;
  final Map<String, dynamic> sellerDetails;
  final ValueChanged<String> onFieldChanged;
  final double width;

  const SellerFields({
    super.key,
    required this.selectedField,
    required this.sellerDetails,
    required this.onFieldChanged,
    required this.width
  });

  @override
  State<SellerFields> createState() => _SellerFieldsState();
}

class _SellerFieldsState extends State<SellerFields> {
  String _selectedField = '';

  @override
  void initState() {
    super.initState();
    _selectedField = widget.selectedField;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        width: widget.width,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          borderRadius: BorderRadius.circular(10), // Rounded corners
          border: Border.all(color: Colors.grey.shade300), // Subtle border
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedField,
            isExpanded: true, // Ensures full width
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
            items: widget.sellerDetails['fields'].map<DropdownMenuItem<String>>((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value.toString(),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedField = value;
                });
                widget.onFieldChanged(value);
              }
            },
          ),
        ),
      ),
    );
  }
}



class showImage extends StatefulWidget {
  final String imageUrl;
  final bool isFavorited; 
  final Map<String, dynamic> sellerDetails;
  final String sellerUid;
  final double width;
  final double height;

  const showImage({
    super.key,
    required this.imageUrl,
    required this.isFavorited,
    required this.sellerDetails,
    required this.sellerUid,
    required this.width,
    required this.height
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

    final imageHeight = widget.height * 0.40;

    return Stack(
      children: [
        Image.network(
          widget.imageUrl,
          height: imageHeight,
          width: widget.width,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'lib/images/imageDefault.jpg',
              fit: BoxFit.contain,
              height: imageHeight,
              width: widget.width,
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
              size: widget.width * 0.06,
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
            textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
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
        textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
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
//todo: bottom overflowd 30 pixels
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
  final double width;
  final double heigth;

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
    required this.width,
    required this.heigth
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: heigth,
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
                  textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                ),
                SizedBox(height: heigth * 0.007),
                SizedBox(
                  height: heigth,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: hours.map((hour) {
                        // Generate unique key for each hour
                        String dayHourKey = '$day $hour';
                        bool isSelected = selectedDay == day && selectedHour == hour;
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
                                  color: isSelected ? Colors.grey : hourColors[dayHourKey] ?? Colors.cyan,
                                  child: Text(
                                    hour,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: userorseller ? Colors.white : Colors.black,
                                    ),
                                    textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
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
                                        size: 10,
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
  final double width;
  final double height;
  const showInfoAppointments({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 15,
                              width: 15,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: width*0.020),
                          Text(
                            'Randevu saatin',
                            style: TextStyle(
                              color: userorseller ? Colors.white: Colors.black
                            ),
                            textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                          )
                        ],
                      ),
                      SizedBox(height: height * 0.010),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 15,
                              width: 15,
                              color: Colors.cyan,
                            ),
                          ),
                          SizedBox(width: width * 0.020),
                          Text(
                            'Müsait',
                            style: TextStyle(
                              color: userorseller ? Colors.white: Colors.black
                            ),
                            textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                          )
                        ],
                      ),
                      SizedBox(height: height * 0.010),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 15,
                              width: 15,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(width: width*0.020),
                          Text(
                            'Alınmış veya geçmiş',
                            style: TextStyle(
                              color: userorseller ? Colors.white : Colors.black
                            ),
                            textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                          )
                        ],
                      ),
                    ],
                  );
  }
}
class ChatButton extends StatelessWidget {
  final String sellerUid;
  final double width;
  final double height;
  
  const ChatButton({
    super.key,
    required this.sellerUid,
    required this.width,
    required this.height
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
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
          width: width*0.30,
          height: height*0.05,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.forward_to_inbox,
                  color: Colors.black,
                  size: width*0.06,
                ),
                SizedBox(width: 5),
                Text(
                  "Sohbet",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class PaymentButton extends StatelessWidget {

  final String? selectedDay;
  final String? selectedHour;
  final String? selectedField;
  final String? currentUserUid;
  final String sellerUid;
  final Map<String,dynamic> sellerDetails;

  const PaymentButton({
    super.key,
    required this.selectedDay,
    required this.selectedHour,
    required this.selectedField,
    required this.currentUserUid,
    required this.sellerUid,
    required this.sellerDetails
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
                        onPressed: () {
                          if (selectedDay == null || selectedHour == null || selectedField == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Saat, gün ve saha seçiniz'),
                                backgroundColor: Colors.red,
                              )
                            );
                          } else if (sellerUid == currentUserUid) {
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
                                sellerUid: sellerUid,
                                selectedDay: selectedDay!,
                                selectedHour: selectedHour!,
                                selectedField: selectedField!,
                                selectedPrice: getPriceValue(),
                              )
                            ),
                          );
                          }
                        },
                        style: GlobalStyles.buttonPrimary(context),
                        child: Text(
                          getPrice(),
                          style: GoogleFonts.inter(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: userorseller ? Colors.white : Colors.black,
                          ),
                          textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                        ),
                      );
  }
  String getPrice() {
    if (selectedHour == '00:00-01:00' || selectedHour == '01:00-02:00') {
      return "Ödeme (₺${sellerDetails['sellerPriceMidnight']})";
    } else {
      return "Ödeme (₺${sellerDetails['sellerPrice']})";
    }
  }
  int getPriceValue() {
    if (selectedHour == '00:00-01:00' || selectedHour == '01:00-02:00') {
      return sellerDetails['sellerPriceMidnight'] ?? 0;
    } else {
      return sellerDetails['sellerPrice'] ?? 0;
    }
  }
}






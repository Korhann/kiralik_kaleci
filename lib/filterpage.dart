import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/rangeslider.dart';
import 'package:kiralik_kaleci/styles/button.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {

  // uygulayacağım filtreler
  String? nameFilter;
  String? cityFilter;
  String? districtFilter;
  double? priceFilter;

  double width = 115;
  bool isPressedMonday = false;
  bool isPressedTuesday = false;
  bool isPressedWednesday = false;
  bool isPressedThursday = false;
  bool isPressedFriday = false;
  bool isPressedSaturday = false;
  bool isPressedSunday = false;

  List<String> days = [];
  
  // filtreleri göstermek için
  bool isCleared = false;
  
  @override
  void initState() {
    super.initState();
  }

  void clearAllFilters() {
    setState(() {
      nameFilter = null;
      cityFilter = null;
      districtFilter = null;
      priceFilter = null;
      days.clear();
      isPressedMonday = false;
      isPressedTuesday = false;
      isPressedWednesday = false;
      isPressedThursday = false;
      isPressedFriday = false;
      isPressedSaturday = false;
      isPressedSunday = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        leading: IconButton(
          onPressed: () {
            if (isCleared) {
              Navigator.pop(
              context,
              {
                'nameFilter': nameFilter,
                'cityFilter': cityFilter,
                'districtFilter': districtFilter
              }
            );
            } else {
              Navigator.of(context).pop();
            }
          }, icon: const Icon(Icons.arrow_back, color: Colors.black)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Filtreler',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  child: TextButton(
                    onPressed: () {
                      clearAllFilters();
                      setState(() {
                        isCleared = true;
                      });
                    },
                    child: Text(
                      'Temizle',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.red
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Ad',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Colors.black
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                
                onChanged: (value) {
                  nameFilter = value;
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Şehir',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Colors.black
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                
                onChanged: (value) {
                  cityFilter = value;
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'İlçe',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Colors.black
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                
                onChanged: (value) {
                  districtFilter = value;
                },
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                'Gün Seçiniz',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Colors.black
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // containerlardan oluşan buttonlar yap
                      _dayButton('Pazartesi', isPressedMonday, () { 
                        setState(() {
                          isPressedMonday = !isPressedMonday;
                          days.add('Pazartesi');
                        });
                      }),
                      const SizedBox(width: 5),
                      _dayButton('Salı', isPressedTuesday, () { 
                        setState(() {
                          isPressedTuesday = !isPressedTuesday;
                          days.add('Salı');
                        });
                      }),
                      const SizedBox(width: 5),
                      _dayButton('Çarşamba', isPressedWednesday, () { 
                        setState(() {
                          isPressedWednesday = !isPressedWednesday;
                          days.add('Çarşamba');
                        });
                      }),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _dayButton('Perşembe', isPressedThursday, () { 
                        setState(() {
                          isPressedThursday = !isPressedThursday;
                          days.add('Perşembe');
                        });
                      }),
                      const SizedBox(width: 5),
                      _dayButton('Cuma', isPressedFriday, () { 
                        setState(() {
                          isPressedFriday = !isPressedFriday;
                          days.add('Cuma');
                        });
                      }),
                      const SizedBox(width: 5),
                      _dayButton('Cumartesi', isPressedSaturday, () { 
                        setState(() {
                          isPressedSaturday = !isPressedSaturday;
                          days.add('Cumartesi');
                        });
                      }),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: 
                  _dayButton('Pazar', isPressedSunday, () { 
                        setState(() {
                          isPressedSunday = !isPressedSunday;
                          days.add('Pazar');
                        });
                      }),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                'Fiyat Aralığı',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Colors.black
                ),
              ),
            ),
            const RangeSliderExample(),
            const SizedBox(height: 20),
            // here
            const SizedBox(height: 50),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'nameFilter': nameFilter,
                    'cityFilter': cityFilter,
                    'districtFilter': districtFilter,
                    'daysFilter': days
                  });
                  print('seçilen günler $days');
              },
              style: buttonPrimary, 
              child: Text(
                'Filtrele',
                style: GoogleFonts.roboto(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
  Widget _dayButton(String day, bool isPressed, VoidCallback onPressed) {
    return SizedBox(
      width: width,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPressed ? green : Colors.white,
        ),
        onPressed: onPressed,
        child: Text(
          day,
          style: GoogleFonts.roboto(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

// TODO: Kelime benzerliğinden aramaları gösterme
// TODO: Filtreleri göstermek ve teker teker silebilmek
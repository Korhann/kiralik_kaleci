import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/styles/button.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {

  double width = 115;

  static String? nameFilter;
  static String? cityFilter;
  static String? districtFilter;
  static int ?minFilter;
  static int ?maxFilter;

  static bool isPressedMonday = false;
  static bool isPressedTuesday = false;
  static bool isPressedWednesday = false;
  static bool isPressedThursday = false;
  static bool isPressedFriday = false;
  static bool isPressedSaturday = false;
  static bool isPressedSunday = false;

  static final TextEditingController _nameController = TextEditingController();
  static final TextEditingController _cityController = TextEditingController();
  static final TextEditingController _districtController = TextEditingController();
  static final TextEditingController _minPriceController = TextEditingController();
  static final TextEditingController _maxPriceController = TextEditingController();

  List<String> days = [];
  
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
      minFilter = null;
      maxFilter = null;
      _nameController.clear();
      _cityController.clear();
      _districtController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      clearDays();
    });
  }

  void clearDays() {
    setState(() {
      isPressedMonday = false;
      isPressedTuesday = false;
      isPressedWednesday = false;
      isPressedThursday = false;
      isPressedFriday = false;
      isPressedSaturday = false;
      isPressedSunday = false;
      days.clear();
    });
  }

  void clearSingleFilter(String filterType) {
    setState(() {
      switch (filterType) {
        case 'name':
          nameFilter = null;
          _nameController.clear();
          break;
        case 'city':
          cityFilter = null;
          _cityController.clear();
          break;
        case 'district':
          districtFilter = null;
          _districtController.clear();
          break;
      }
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
                'districtFilter': districtFilter,
                'minFilter':minFilter,
                'maxFilter':maxFilter
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
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      onChanged: (value) {
                        nameFilter = value;
                        _nameController.text = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Ad',
                        labelStyle: GoogleFonts.roboto(fontSize: 18, color: Colors.black),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => clearSingleFilter('name'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cityController,
                      onChanged: (value) {
                        cityFilter = value;
                        _cityController.text = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Şehir',
                        labelStyle: GoogleFonts.roboto(fontSize: 18, color: Colors.black),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => clearSingleFilter('city'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _districtController,
                      onChanged: (value) {
                        districtFilter = value;
                        _districtController.text = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'İlçe',
                        labelStyle: GoogleFonts.roboto(fontSize: 18, color: Colors.black),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => clearSingleFilter('district'),
                        ),
                      ),
                    ),
                  ),
                ],
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
                      _dayButton('Pazartesi', isPressedMonday, () { 
                        setState(() {
                          isPressedMonday = !isPressedMonday;
                          if (isPressedMonday) {
                            days.add('Pazartesi');
                          } else days.remove('Pazartesi');
                        });
                      }),
                      const SizedBox(width: 5),
                      _dayButton('Salı', isPressedTuesday, () { 
                        setState(() {
                          isPressedTuesday = !isPressedTuesday;
                          if (isPressedTuesday) {
                            days.add('Salı');
                          } else days.remove('Salı');
                        });
                      }),
                      const SizedBox(width: 5),
                      _dayButton('Çarşamba', isPressedWednesday, () { 
                        setState(() {
                          isPressedWednesday = !isPressedWednesday;
                          if (isPressedWednesday) {
                            days.add('Çarşamba');
                          } else days.remove('Çarşamba');
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
                          if (isPressedThursday) {
                            days.add('Perşembe');
                          } else days.remove('Perşembe');
                        });
                      }),
                      const SizedBox(width: 5),
                      _dayButton('Cuma', isPressedFriday, () { 
                        setState(() {
                          isPressedFriday = !isPressedFriday;
                          if (isPressedFriday) {
                            days.add('Cuma');
                          } else days.remove('Cuma');
                        });
                      }),
                      const SizedBox(width: 5),
                      _dayButton('Cumartesi', isPressedSaturday, () { 
                        setState(() {
                          isPressedSaturday = !isPressedSaturday;
                          if (isPressedSaturday) {
                            days.add('Cumartesi');
                          } else days.remove('Cumartesi');
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
                  child: _dayButton('Pazar', isPressedSunday, () { 
                    setState(() {
                      isPressedSunday = !isPressedSunday;
                      if (isPressedSunday) {
                        days.add('Pazar');
                      } else days.remove('Pazar');
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
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Colors.white,
                      height: 40,
                      width: 80,
                      child: TextField(
                        controller: _minPriceController,
                        onChanged: (value) {
                          minFilter = int.tryParse(value) ?? 0;
                          _minPriceController.text = value;
                        },
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(10),
                          hintText: 'Min'
                        ),
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 2,
                    width: 15,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                        color: Colors.white,
                        height: 40,
                        width: 80,
                        child: TextField(
                          controller: _maxPriceController,
                          onChanged: (value) {
                            maxFilter = int.tryParse(value) ?? 0;
                            _maxPriceController.text = value; 
                          },
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(10),
                            hintText: 'Max'
                          ),
                          style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.black
                          ),
                        ),
                      ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context, {
                    'nameFilter': nameFilter,
                    'cityFilter': cityFilter,
                    'districtFilter': districtFilter,
                    'daysFilter': days,
                    'minFilter':minFilter,
                    'maxFilter':maxFilter
                  });
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

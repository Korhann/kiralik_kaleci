import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:kiralik_kaleci/football_field.dart';
import 'package:kiralik_kaleci/styles/button.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  static String? fieldFilter;
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

  List<String> cities = [];
  List<String> districts = [];
  List<String> days = [];
  List<dynamic> cityData = [];
  List<String> fields = [];
  
  bool isCleared = false;

  @override
  void initState() {
    super.initState();
    // todo: halısahayı boş bırakınca hatayı veriyor kalkınca çöz
    runMethods();
  }

  // if i dont run fetch cities first there is no element
  void runMethods() async {
    await fetchCities();
    await loadPrefs();
    FootballField.storeFields();
  }

  void clearAllFilters() async{
      // to clear the shared prefs
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('selectedCity');
      await prefs.remove('selectedDistrict');
      await prefs.remove('selectedField');
      setState(() {
      nameFilter = null;
      cityFilter = null;
      districtFilter = null;
      fieldFilter = null;
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
                'fieldFilter':fieldFilter,
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
        child: SingleChildScrollView(
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        clearAllFilters();
                        setState(() {
                          isCleared = true;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Text(
                          'Temizle',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Colors.red
                          ),
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
                          labelText: 'Ad Soyad',
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
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 45,
                      width: 350,
                      color: Colors.white,
                      child: Stack(
                        children: [
                          // Dropdown Button
                          DropdownButton<String>(
                            isExpanded: true,
                            value: cityFilter,
                            items: cities.map((city) => DropdownMenuItem<String>(
                              value: city,
                              child: Text(
                                city,
                                style: GoogleFonts.inter(color: Colors.black),
                              ),
                            )).toList(),
                            onChanged: (value) async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              // Reset district and field filters when city changes
                              await prefs.remove('selectedDistrict');
                              await prefs.remove('selectedField');
                              await prefs.setString('selectedCity', value!);
                              setState(() {
                                // except the city they all have to be emptied
                                cityFilter = value; 
                                districtFilter = null; 
                                fieldFilter = null; 
                                districts.clear(); 
                                fields.clear(); 
                                // Fetch districts for the selected city
                                onCitySelected(value);
                              });
                            },
                            hint: const Text('Şehir seçin'),
                            underline: const SizedBox(),
                          ),
                          // Clear Icon
                          if (cityFilter != null)
                          Positioned(
                            right: 10,
                            top: 0,
                            bottom: 0,
                            child: IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () async {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.remove('selectedCity'); // Clear the selected city from prefs
                                await prefs.remove('selectedDistrict');
                                setState(() {
                                  cityFilter = null;
                                  districtFilter = null;
                                  fieldFilter = null;
                                  //cities.clear(); // Optional: Clear dependent data
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              
  Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Container(
      height: 45,
      width: 350,
      color: Colors.white,
      child: Stack(
        children: [
          // Dropdown Button
          DropdownButton<String>(
            isExpanded: true,
            value: districts.contains(districtFilter) ? districtFilter : null,
            items: districts.map((district) => DropdownMenuItem<String>(
              value: district,
              child: Text(
                district,
                style: GoogleFonts.inter(
                  color: Colors.black,
                ),
              ),
            )).toList(),
            onChanged: (value) async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('selectedDistrict', value!);
              setState(() {
                districtFilter = value;
                fetchFields(value.toString());
                fieldFilter = null;
              });
            },
            hint: const Text('İlçe seçin'),
            underline: const SizedBox(),
          ),
          // Clear Icon
          if (districtFilter != null)
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.remove('selectedDistrict');
                  await prefs.remove('selectedFields');
                  setState(() {
                    districtFilter = null;
                    fieldFilter = null;
                    fields.clear(); // Clear dependent data
                  });
                },
              ),
            ),
        ],
      ),
    ),
  ),
),

const SizedBox(height: 8),

// Field Dropdown with Clear Icon
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Container(
      height: 45,
      width: 350,
      color: Colors.white,
      child: Stack(
        children: [
          // Dropdown Button
          DropdownButton<String>(
            isExpanded: true,
            value: fields.contains(fieldFilter) ? fieldFilter : null,
            items: fields.map((field) => DropdownMenuItem<String>(
              value: field,
              child: Text(
                field,
                style: GoogleFonts.inter(
                  color: Colors.black,
                ),
              ),
            )).toList(),
            onChanged: (value) async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('selectedField', value!);
              setState(() {
                fieldFilter = value;
              });
            },
            hint: const Text('Halı Saha seçin'),
            underline: const SizedBox(),
          ),
          // Clear Icon
          if (fieldFilter != null)
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.remove('selectedField');
                  setState(() {
                    fieldFilter = null;
                  });
                },
              ),
            ),
        ],
      ),
    ),
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
                            } else {
                              days.remove('Pazartesi');
                            }
                          });
                        }),
                        const SizedBox(width: 5),
                        _dayButton('Salı', isPressedTuesday, () { 
                          setState(() {
                            isPressedTuesday = !isPressedTuesday;
                            if (isPressedTuesday) {
                              days.add('Salı');
                            } else {
                              days.remove('Salı');
                            }
                          });
                        }),
                        const SizedBox(width: 5),
                        _dayButton('Çarşamba', isPressedWednesday, () { 
                          setState(() {
                            isPressedWednesday = !isPressedWednesday;
                            if (isPressedWednesday) {
                              days.add('Çarşamba');
                            } else {
                              days.remove('Çarşamba');
                            }
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
                            } else {
                              days.remove('Perşembe');
                            }
                          });
                        }),
                        const SizedBox(width: 5),
                        _dayButton('Cuma', isPressedFriday, () { 
                          setState(() {
                            isPressedFriday = !isPressedFriday;
                            if (isPressedFriday) {
                              days.add('Cuma');
                            } else {
                              days.remove('Cuma');
                            }
                          });
                        }),
                        const SizedBox(width: 5),
                        _dayButton('Cumartesi', isPressedSaturday, () { 
                          setState(() {
                            isPressedSaturday = !isPressedSaturday;
                            if (isPressedSaturday) {
                              days.add('Cumartesi');
                            } else {
                              days.remove('Cumartesi');
                            }
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
                        } else {
                          days.remove('Pazar');
                        }
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
                      'fieldFilter':fieldFilter,
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
      ),
    );
  }

  Future<void> fetchCities() async {
    var response = await http.get(Uri.parse('https://turkiyeapi.dev/api/v1/provinces'));
    if (response.statusCode == 200) {
      final List<dynamic> citiesData = jsonDecode(response.body)['data'];
      List<String> cityNames = citiesData.map((city) => city['name'].toString()).toList();
      if (mounted) {
        setState(() {
          cities = cityNames;
          cityData = citiesData;
        });
      }
    } else {
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
    }
  }
  Future<void> onCitySelected(String selectedCityFilter) async{
    final city = cityData.firstWhere((city) => city['name'] == selectedCityFilter);
    if (city != null) {
      final districtsData = city['districts'];
      if (districtsData != null) {
        final List<String> districtNames = (districtsData as List<dynamic>).map((district) => district['name'].toString()).toList();

        setState(() {
          cityFilter = selectedCityFilter;
          districts = districtNames;
          districtFilter = null; // Reset selected district
        });
      }
    }
  }
  Future<void> fetchFields(String selectedDistrict) async {
  var localDb = await Hive.openBox<FootballField>('football_fields');

  try {
    var field = localDb.values.firstWhere(
      (f) => f.city == cityFilter && f.district == selectedDistrict,
    );
    setState(() {
      fields = field.fieldName.toSet().toList();
      fieldFilter = null;
      
      // Retain the fieldFilter if it is valid for the new fields
      if (!fields.contains(fieldFilter)) {
        fieldFilter = null;
      }
    });
  } catch (e) {
    setState(() {
      fields = [];
      fieldFilter = null;
    });
  }
}


  // to show the user the selected data
  Future<void> loadPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String? savedCity = prefs.getString('selectedCity');
  String? savedDistrict = prefs.getString('selectedDistrict');
  String? savedField = prefs.getString('selectedField');

  if (savedCity != null) {
    // Load districts based on the saved city
    await onCitySelected(savedCity); // Ensure districts are loaded before continuing
  }

  setState(() {
    cityFilter = savedCity;
    districtFilter = savedDistrict;
  });

  if (savedDistrict != null) {
    // Fetch fields for the saved district
    await fetchFields(savedDistrict);
  }

  setState(() {
    fieldFilter = savedField; // Set fieldFilter only after fields are fetched
  });
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

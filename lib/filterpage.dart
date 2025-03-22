import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:kiralik_kaleci/connectivity.dart';
import 'package:kiralik_kaleci/football_field.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:http/http.dart' as http;
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class FilterPage extends StatefulWidget {
  final List<String> daysFilter;
  const FilterPage({
    super.key,
    required this.daysFilter
  });

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  double width = 115;

  static String? nameFilter;
  static String? cityFilter;
  static String? districtFilter;
  static String? fieldFilter;
  static int? minFilter;
  static int? maxFilter;

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
  TextStyle textStyle = GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.grey.shade600);

  late Future<void> _runMethods;

  @override
  void initState() {
    super.initState();
    // todo: halısahayı boş bırakınca hatayı veriyor kalkınca çöz
    _runMethods = runMethods();
    days = widget.daysFilter;
    // çok zaman aldığı için runMethods ta çalıştırmıyorum
    FootballField.storeFields();
  }

  // if i dont run fetch cities first there is no element
  Future<void> runMethods() async {
    await fetchCities();
    await loadPrefs();
  }

  void clearAllFilters() async {
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
    return ConnectivityWrapper(
      child: FutureBuilder(
        future: _runMethods,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return FilterPageShimmer();
          }
        return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          leading: IconButton(
              onPressed: () {
                if (isCleared) {
                  Navigator.pop(
                    context, {
                    'nameFilter': nameFilter,
                    'cityFilter': cityFilter,
                    'districtFilter': districtFilter,
                    'fieldFilter': fieldFilter,
                    'minFilter': minFilter,
                    'maxFilter': maxFilter
                  });
                } else {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.arrow_back, color: Colors.black)),
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
                            color: Colors.black),
                      ),
                    ),
                    Align(
                        alignment: Alignment.centerRight,
                        child: clearFilters(ontap: () {
                          clearAllFilters();
                          setState(() {
                            isCleared = true;
                          });
                        }
                      )
                    )
                  ],
                ),
                const SizedBox(height: 10),
                
                Column(
                  children: [
                    NameInputField(
                      controller: _nameController,
                      onChanged: (value) {
                        setState(() {
                          nameFilter = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
      
                    CityDropdown(
                      selectedCity: cityFilter,
                      cities: cities,
                      onCitySelected: (value) async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString('selectedCity', value!);
                        setState(() {
                          cityFilter = value;
                          districtFilter = null;
                          fieldFilter = null;
                          districts.clear();
                          fields.clear();
                          onCitySelected(value);
                        });
                      },
                      onClear: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.remove('selectedCity');
                        setState(() {
                          cityFilter = null;
                          districtFilter = null;
                          fieldFilter = null;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
      
                    DistrictDropdown(
                      selectedDistrict: districtFilter,
                      districts: districts,
                      onDistrictSelected: (value) async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString('selectedDistrict', value!);
                        setState(() {
                          districtFilter = value;
                          fetchFields(value);
                          fieldFilter = null;
                        });
                      },
                      onClear: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.remove('selectedDistrict');
                        setState(() {
                          districtFilter = null;
                          fieldFilter = null;
                          fields.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
      
                    FieldDropdown(
                      selectedField: fieldFilter,
                      fields: fields,
                      onFieldSelected: (value) async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString('selectedField', value!);
                        setState(() {
                          fieldFilter = value;
                        });
                      },
                      onClear: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.remove('selectedField');
                        setState(() {
                          fieldFilter = null;
                        });
                      },
                    ),
                  ],
                ),
      
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    'Gün Seçiniz',
                    style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(height: 20),
      
                DayPickerFirst(days: days),
      
                const SizedBox(height: 10),
      
                DayPickerSecond(days: days),
      
                const SizedBox(height: 10),
                
                dayPickerThird(days: days),
      
      
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    'Fiyat Aralığı',
                    style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                  ),
                ),
      
                const SizedBox(height: 20),
      
                PriceRanger(
                  minPriceController: _minPriceController,
                  maxPriceController: _maxPriceController,
                  onPriceChanged: updatePriceFilters
                ),
      
                const SizedBox(height: 50),
                Center(
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'nameFilter': nameFilter,
                          'cityFilter': cityFilter,
                          'districtFilter': districtFilter,
                          'fieldFilter': fieldFilter,
                          'daysFilter': days,
                          'minFilter': minFilter,
                          'maxFilter': maxFilter
                        });
                      },
                      style: GlobalStyles.buttonPrimary(),
                      child: Text(
                        'Filtrele',
                        style: GoogleFonts.roboto(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      )),
                ),
              ],
            ),
          ),
        ),
      );
        }
      )
    );
  }

  Future<void> fetchCities() async {
    var response =
        await http.get(Uri.parse('https://turkiyeapi.dev/api/v1/provinces'));
    if (response.statusCode == 200) {
      final List<dynamic> citiesData = jsonDecode(response.body)['data'];
      List<String> cityNames =
          citiesData.map((city) => city['name'].toString()).toList();
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

  Future<void> onCitySelected(String selectedCityFilter) async {
    final city = cityData.firstWhere((city) => city['name'] == selectedCityFilter);
    if (city != null) {
      final districtsData = city['districts'];
      if (districtsData != null) {
        final List<String> districtNames = (districtsData as List<dynamic>)
            .map((district) => district['name'].toString())
            .toList();

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
      await onCitySelected(
          savedCity); // Ensure districts are loaded before continuing
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

  void updatePriceFilters(int min, int max) {
  setState(() {
    minFilter = min;
    maxFilter = max;
  });
}

  // Widget _dayButton(String day, bool isPressed, VoidCallback onPressed) {
  //   return SizedBox(
  //     width: width,
  //     height: 40,
  //     child: ElevatedButton(
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: isPressed ? green : Colors.white,
  //       ),
  //       onPressed: onPressed,
  //       child: Text(
  //         day,
  //         style: GoogleFonts.roboto(
  //           color: Colors.black,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // InputDecoration _inputDecoration(String hintText) {
  //   return InputDecoration(
  //     suffixIcon: IconButton(
  //       icon: const Icon(Icons.clear),
  //       onPressed: () => clearSingleFilter('name'),
  //     ),
  //     hintText: hintText,
  //     hintStyle: textStyle,
  //     fillColor: Colors.white,
  //     enabledBorder: InputBorder.none, // Remove underline when not focused
  //     focusedBorder: InputBorder.none,
  //     filled: true,
  //   );
  // }
}

class clearFilters extends StatelessWidget {
  final VoidCallback? ontap;
  const clearFilters({required this.ontap, super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: ontap,
      child: Padding(
        padding: EdgeInsets.only(right: 10),
        child: Text(
          'Temizle',
          style: GoogleFonts.roboto(
              fontSize: 18, fontWeight: FontWeight.normal, color: Colors.red),
        ),
      ),
    );
  }
}

class NameInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const NameInputField({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: Colors.white,
          width: 350,
          height: 45,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Ad Soyad',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            style: const TextStyle(decoration: TextDecoration.none),
          ),
        ),
      ),
    );
  }
}

class CityDropdown extends StatelessWidget {
  final String? selectedCity;
  final List<String> cities;
  final ValueChanged<String?> onCitySelected;
  final VoidCallback onClear;

  const CityDropdown({
    required this.selectedCity,
    required this.cities,
    required this.onCitySelected,
    required this.onClear,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 45,
          width: 350,
          color: Colors.white,
          child: Stack(
            children: [
              DropdownButton<String>(
                isExpanded: true,
                value: selectedCity,
                items: cities
                    .map((city) => DropdownMenuItem<String>(
                          value: city,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(city,
                                style: GoogleFonts.inter(color: Colors.black)),
                          ),
                        ))
                    .toList(),
                onChanged: onCitySelected,
                hint: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text('Şehir Seçin', style: GoogleFonts.inter()),
                ),
                underline: const SizedBox(),
              ),
              if (selectedCity != null)
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: onClear,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DistrictDropdown extends StatelessWidget {
  final String? selectedDistrict;
  final List<String> districts;
  final ValueChanged<String?> onDistrictSelected;
  final VoidCallback onClear;

  const DistrictDropdown({
    required this.selectedDistrict,
    required this.districts,
    required this.onDistrictSelected,
    required this.onClear,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 45,
          width: 350,
          color: Colors.white,
          child: Stack(
            children: [
              DropdownButton<String>(
                isExpanded: true,
                value: districts.contains(selectedDistrict)
                    ? selectedDistrict
                    : null,
                items: districts
                    .map((district) => DropdownMenuItem<String>(
                          value: district,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(district,
                                style: GoogleFonts.inter(color: Colors.black)),
                          ),
                        ))
                    .toList(),
                onChanged: onDistrictSelected,
                hint: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text('İlçe Seçin', style: GoogleFonts.inter()),
                ),
                underline: const SizedBox(),
              ),
              if (selectedDistrict != null)
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: onClear,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class FieldDropdown extends StatelessWidget {
  final String? selectedField;
  final List<String> fields;
  final ValueChanged<String?> onFieldSelected;
  final VoidCallback onClear;

  const FieldDropdown({
    required this.selectedField,
    required this.fields,
    required this.onFieldSelected,
    required this.onClear,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 45,
          width: 350,
          color: Colors.white,
          child: Stack(
            children: [
              DropdownButton<String>(
                isExpanded: true,
                value: fields.contains(selectedField) ? selectedField : null,
                items: fields
                    .map((field) => DropdownMenuItem<String>(
                          value: field,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(field,
                                style: GoogleFonts.inter(color: Colors.black)),
                          ),
                        ))
                    .toList(),
                onChanged: onFieldSelected,
                hint: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text('Halı Saha Seçin', style: GoogleFonts.inter()),
                ),
                underline: const SizedBox(),
              ),
              if (selectedField != null)
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: onClear,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


class DayPickerFirst extends StatefulWidget {
  final List<String> days;

  const DayPickerFirst({super.key, required this.days});

  @override
  State<DayPickerFirst> createState() => _DayPickerFirstState();
}

class _DayPickerFirstState extends State<DayPickerFirst> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _dayButton('Pazartesi'),
              const SizedBox(width: 5),
              _dayButton('Salı'),
              const SizedBox(width: 5),
              _dayButton('Çarşamba'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dayButton(String day) {
    bool isPressed = widget.days.contains(day);

    return SizedBox(
      width: 115,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPressed ? green : Colors.white,
        ),
        onPressed: () => toggleDay(day),
        child: Text(
          day,
          style: GoogleFonts.roboto(
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void toggleDay(String day) {
    setState(() {
      if (widget.days.contains(day)) {
        widget.days.remove(day);
      } else {
        widget.days.add(day);
      }
    });
  }
}


class DayPickerSecond extends StatefulWidget {
  final List<String> days;
  const DayPickerSecond({required this.days, super.key});

  @override
  State<DayPickerSecond> createState() => DayPickerSecondState();
}

class DayPickerSecondState extends State<DayPickerSecond> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _dayButton('Perşembe'),
              const SizedBox(width: 5),
              _dayButton('Cuma'),
              const SizedBox(width: 5),
              _dayButton('Cumartesi'),
            ],
          ),
        ),
      ),
    );
  }
  Widget _dayButton(String day) {
    bool isPressed = widget.days.contains(day);

    return SizedBox(
      width: 115,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPressed ? green : Colors.white,
        ),
        onPressed: () => toggleDay(day),
        child: Text(
          day,
          style: GoogleFonts.roboto(
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void toggleDay(String day) {
    setState(() {
      if (widget.days.contains(day)) {
        widget.days.remove(day);
      } else {
        widget.days.add(day);
      }
    });
  }
}

class dayPickerThird extends StatefulWidget {
  final List<String> days;
  const dayPickerThird({required this.days, super.key});

  @override
  State<dayPickerThird> createState() => _dayPickerThirdState();
}

class _dayPickerThirdState extends State<dayPickerThird> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _dayButton('Pazar'),
            ],
          ),
        ),
      ),
    );
  }
  Widget _dayButton(String day) {
    bool isPressed = widget.days.contains(day);

    return SizedBox(
      width: 115,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPressed ? green : Colors.white,
        ),
        onPressed: () => toggleDay(day),
        child: Text(
          day,
          style: GoogleFonts.roboto(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
  void toggleDay(String day) {
    setState(() {
      if (widget.days.contains(day)) {
        widget.days.remove(day);
      } else {
        widget.days.add(day);
      }
    });
  }
}

class PriceRanger extends StatefulWidget {
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  final Function(int, int) onPriceChanged; // Callback to send values back

  const PriceRanger({
    required this.minPriceController,
    required this.maxPriceController,
    required this.onPriceChanged,
    super.key,
  });

  @override
  _PriceRangerState createState() => _PriceRangerState();
}

class _PriceRangerState extends State<PriceRanger> {
  int? minFilter;
  int? maxFilter;

  @override
  void initState() {
    super.initState();
    // minFilter = int.tryParse(widget.minPriceController.text);
    // maxFilter = int.tryParse(widget.maxPriceController.text);
  }

  void updateMinFilter(String value) {
  setState(() {
    minFilter = value.isEmpty ? null : int.tryParse(value);
    widget.onPriceChanged(minFilter ?? 0, maxFilter ?? 999999); 
  });
}

  void updateMaxFilter(String value) {
    setState(() {
      maxFilter = value.isEmpty ? null : int.tryParse(value);
      widget.onPriceChanged(minFilter ?? 0, maxFilter ?? 999999);
    });
  }

  @override
  Widget build(BuildContext context) {
    minFilter = int.tryParse(widget.minPriceController.text);
    maxFilter = int.tryParse(widget.maxPriceController.text);
    return Padding(
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
                controller: widget.minPriceController,
                onChanged: updateMinFilter,
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
                    color: Colors.black),
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
                controller: widget.maxPriceController,
                onChanged: updateMaxFilter,
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
                    color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class FilterPageShimmer extends StatelessWidget {
  const FilterPageShimmer({super.key});

  Widget shimmerContainer({
    double height = 20,
    double width = double.infinity,
    double radius = 12,
  }) {
    return Container(
      height: height,
      width: width,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Make sure background is white (or your custom light background color)
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        period: const Duration(milliseconds: 1200),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              shimmerContainer(height: 30, width: 120), // "Filtreler" title
              const SizedBox(height: 30),
              shimmerContainer(height: 50), // Name Input Field
              shimmerContainer(height: 50), // City Dropdown
              shimmerContainer(height: 50), // District Dropdown
              shimmerContainer(height: 50), // Field Dropdown
              const SizedBox(height: 30),
              shimmerContainer(height: 25, width: 140), // Gün Seçiniz
              shimmerContainer(height: 40), // DayPicker 1
              shimmerContainer(height: 40), // DayPicker 2
              shimmerContainer(height: 40), // DayPicker 3
              const SizedBox(height: 30),
              shimmerContainer(height: 25, width: 140), // Fiyat Aralığı
              shimmerContainer(height: 50), // Price Range
              const SizedBox(height: 50),
              Center(
                child: shimmerContainer(height: 50, width: 200), // Button
              ),
            ],
          ),
        ),
      ),
    );
  }
}


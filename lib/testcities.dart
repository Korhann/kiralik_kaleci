import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kiralik_kaleci/styles/colors.dart';

class TestCities extends StatefulWidget {
  const TestCities({super.key});

  @override
  State<TestCities> createState() => _TestCitiesState();
}

class _TestCitiesState extends State<TestCities> {
  List<String> cities = [];
  List<String> districts = [];
  List<dynamic> cityData = [];
  String? selectedCity;
  String? selectedDistrict;

  @override
  void initState() {
    super.initState();
    fetchCities();
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

  void onCitySelected(String selectedCity) {
    final city = cityData.firstWhere((city) => city['name'] == selectedCity);
    if (city != null) {
      final districtsData = city['districts'];
      if (districtsData != null) {
        final List<String> districtNames = 
    (districtsData as List<dynamic>).map((district) => district['name'].toString()).toList();

        setState(() {
          this.selectedCity = selectedCity;
          districts = districtNames;
          selectedDistrict = null; // Reset selected district
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: background,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select City:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                isExpanded: true,
                value: selectedCity,
                items: cities
                    .map((city) => DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    onCitySelected(value);
                  }
                },
                hint: const Text('Choose a city'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select District:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                isExpanded: true,
                value: selectedDistrict,
                items: districts
                    .map((district) => DropdownMenuItem<String>(
                          value: district,
                          child: Text(district),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDistrict = value;
                  });
                },
                hint: const Text('Choose a district'),
              ),
              const SizedBox(height: 24),
              if (selectedCity != null && selectedDistrict != null)
                Text(
                  'Selected City: $selectedCity\nSelected District: $selectedDistrict',
                  style: const TextStyle(fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiralik_kaleci/sellersuccesspage.dart';
import 'package:kiralik_kaleci/styles/button.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/testcities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;


class SellerAddPage extends StatefulWidget {
  const SellerAddPage({super.key});

  @override
  State<SellerAddPage> createState() => _SellerAddPageState();
}

//TODO: Resim eklemek zorunlu olması lazım yoksa getuserinformation page hata veriyor index ten dolayı

class _SellerAddPageState extends State<SellerAddPage> {
  
  // Kullanıcı bilgileri
  TextEditingController sellerFullName = TextEditingController();
  TextEditingController sellerPrice = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // galeriden resim seçmek için
  final ImagePicker imagePicker = ImagePicker();
  List<XFile> imageFileList = [];

  // sıradaki resime geçmek için
  int currentIndex = 0;

  // new dropdown menu
  List<String> cities = [];
  List<String> districts = [];
  List<dynamic> cityData = [];
  String? selectedCity;
  String? selectedDistrict;
  bool isInserted = false;

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  @override
  void dispose() {
    super.dispose();
    // veriyi cloud a yolladıktan sonra hepsini sil
    sellerFullName.dispose();
    sellerPrice.dispose();
  }

  void _clearImageandText() {
    if (mounted) {
      setState(() {
        imageFileList.clear();
        sellerFullName.clear();
        sellerPrice.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sellerbackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Fotoğraf Ekle",
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  color: sellergrey,
                  height: 110,
                  width: double.infinity,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: GestureDetector(
                            child: Container(
                              width: 100,
                              height: 90,
                              color: sellerwhite,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.camera_alt, size: 24),
                                  const SizedBox(height: 2),
                                  Text("Fotoğraf",
                                    style: GoogleFonts.inter(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text("Ekle",
                                      style: GoogleFonts.inter(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            onTap: () {
                              _pickImageFromGallery();
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          width: 100,
                          height: 90,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: imageFileList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: GestureDetector(
                                        child: Image.file(
                                          File(imageFileList[index].path),
                                          fit: BoxFit.fitHeight,
                                        ),
                                        onTap: () {
                                          currentIndex = index;
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: SizedBox(
                                                  width: MediaQuery.of(context).size.width,
                                                  height: MediaQuery.of(context).size.height,
                                                  child: Expanded(
                                                    child: CarouselSlider(
                                                      options: CarouselOptions(
                                                        aspectRatio: 1,
                                                        viewportFraction: 1,
                                                        enableInfiniteScroll:false,
                                                        padEnds: false,
                                                        initialPage:currentIndex,
                                                      ),
                                                      items: imageFileList.map<Widget>(
                                                        (imageFile) {
                                                          return Builder(
                                                            builder: (BuildContext context) {
                                                            return Image.file(File(imageFile.path),
                                                              fit: BoxFit.cover);
                                                          },
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          _removeImage(index);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.red,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Ad Soyad",
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: sellerFullName,
                  validator: (name) {
                    if (name == null || name.isEmpty) {
                      return "Boş Bırakılamaz !";
                    }
                    return null;
                  },
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w300),
                  decoration: InputDecoration(
                      hintText: "İsminizi giriniz",
                      hintStyle: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w300),
                      contentPadding: const EdgeInsets.all(10),
                      fillColor: sellergrey,
                      filled: true),
                ),
                const SizedBox(height: 40),
                
                /*
                Seçilen şehire göre ilçeler updateDistrictOptions() fonksiyonu ile popüle ediliyor
                */
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Şehir",
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: DropdownButton<String>(
                isExpanded: true,
                value: selectedCity,
                items: cities.map((city) => DropdownMenuItem<String>(
                          value: city,
                          child: Text(
                            city,
                            style: GoogleFonts.inter(
                              color: Colors.white
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    onCitySelected(value);
                  }
                },
                hint: const Text('Şehir seçin'),
              ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "İlçe",
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: DropdownButton<String>(
                isExpanded: true,
                value: selectedDistrict,
                items: districts
                    .map((district) => DropdownMenuItem<String>(
                          value: district,
                          child: Text(
                            district,
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              backgroundColor: Colors.white
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDistrict = value;
                  });
                },
                hint: const Text('İlçe seçin'),
              ),
                  ),
                ),
                const SizedBox(height: 20),
                // SAAT BİLGİLERİNİ GİR
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Saatler",
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                          Column(
                            children: [
                              Text(
                                "Pazartesi",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white
                                ),
                              ),
                              const Amenities(day: 'Pazartesi',),
                            ],
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            Text(
                              "Salı",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white
                              ),
                            ),
                            const Amenities(day: 'Salı')
                          ],
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            Text(
                              "Çarşamba",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white
                              ),
                            ),
                            const Amenities(day: 'Çarşamba')
                          ],
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            Text(
                              "Perşembe",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white
                              ),
                            ),
                            const Amenities(day: 'Perşembe',)
                          ],
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            Text(
                              "Cuma",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white
                              ),
                            ),
                            const Amenities(day: 'Cuma')
                          ],
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            Text(
                              "Cumartesi",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white
                              ),
                            ),
                            const Amenities(day: 'Cumartesi')
                          ],
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            Text(
                              "Pazar",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white
                              ),
                            ),
                            const Amenities(day: 'Pazar')
                          ],
                        ),
                        const SizedBox(width: 5),
                      ],
                    ),
                  ),
                ), 
                
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Text(
                        "Fiyat",
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: sellerPrice,
                  keyboardType: TextInputType.number,
                  maxLines: null,
                  textInputAction: TextInputAction.done,
                  validator: (price) {
                    if (price == null || price.isEmpty) {
                      return  "Fiyat bilgisi girmelisiniz!";
                    } else {
                      return null;
                    }
                  },
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: sellergrey,
                      filled: true,
                      suffixText: 'TL',
                      suffixStyle: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                      )
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                      style: buttonPrimary,
                      onPressed: () async {
                        try {
                            await _insertSellerDetails(context);
                            _clearImageandText();
                        } catch (e) {
                          log("error at $e");
                        }
                      },
                      child: Text(
                        "Onayla",
                        style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      )),
                ),
                const SizedBox(height: 30),
              ],
            ),
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

  void _removeImage(int index) {
    setState(() {
      imageFileList.removeAt(index);
    });
  }


  Future _pickImageFromGallery() async {
    final List<XFile> selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      imageFileList.addAll(selectedImages);
    }
  }

  Future<void> _insertSellerDetails(BuildContext context) async {
  if (_formKey.currentState!.validate()) {
    // Show loading dialog
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.green,
            backgroundColor: Colors.grey,
          ),
        );
      }
    );

    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
      if (userId.isNotEmpty) {
        List<String> imageUrls = await _uploadImagesToStorage();

        Map<String, dynamic> formattedData = {};
        _AmenitiesState.selectedHoursByDay.forEach((day, selectedHours) {
          if (selectedHours.isNotEmpty) {
            formattedData[day] = selectedHours.map((hour) => {
                  'title': hour.title,
                  'istaken': false,
                }).toList();
          }
        });

        int? price = int.tryParse(sellerPrice.text);

        Map<String, dynamic> sellerDetails = {
          "sellerFullName": sellerFullName.text,
          "sellerPrice": price,
          "city": selectedCity,
          "district": selectedDistrict,
          "imageUrls": imageUrls,
          'chosenDays': formattedData.keys.toList(),
          "selectedHoursByDay": formattedData,
        };

        await FirebaseFirestore.instance
            .collection("Users")
            .doc(userId)
            .update({"sellerDetails": sellerDetails});

        setState(() {
          _AmenitiesState.selectedHoursByDay.clear();
          isInserted = true;
        });

        // yükleme ekranından çık
        Navigator.of(context).pop();

        // saat seçme ui ını yenilemesi için pushreplacement
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SellerSuccessPage())
        );
      }
    } catch (e) {
      log("error $e");
      Navigator.of(context).pop(); // Close the loading dialog if an error occurs
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("An error occurred: $e"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the error dialog
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }
}   

  Future<List<String>> _uploadImagesToStorage() async {
  List<String> imageUrls = [];

  // Loop through each image file and upload to Firebase Storage
  if (imageFileList.isNotEmpty) {
    for (XFile imageFile in imageFileList) {
    try {
      // kullanıcının seçtiği resim olucaksa bu kod
      File file = File(imageFile.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('images/$fileName.jpg');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      imageUrls.add(imageUrl);
    } catch (e) {
      print("Error uploading image: $e");
      }
    }
  } else {
    // değilse default bir image yükle
    File defaultImage = await getDefaultImageFile();
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref().child('images/default_$fileName.jpg');
    UploadTask uploadTask = ref.putFile(defaultImage);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String defaultImageUrl = await taskSnapshot.ref.getDownloadURL();
    imageUrls.add(defaultImageUrl);
  }

  return imageUrls;
}
  // default resim dosyası path almak için
  Future<File> getDefaultImageFile() async {
    final byteData = await rootBundle.load('lib/images/image1.jpg');
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/image1.jpg');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());
    print('file is $tempFile');
    return tempFile;
  }

}
/*
  BURDAN SONRAKİ TEXTLER KULLANICI İÇİN SAAT SEÇİCİ OLACAK
*/
class CheckContainerModel {
  final String title;
  bool isCheck;

  CheckContainerModel({required this.title, this.isCheck = false});

  CheckContainerModel copyWith({String? title, bool? isCheck}) {
    return CheckContainerModel(
      title: title ?? this.title,
      isCheck: isCheck ?? this.isCheck,
    );
  }
}

class Amenities extends StatefulWidget {
  
  final String day;
  const Amenities({super.key, required this.day});

  @override
  State<StatefulWidget> createState() {
    return _AmenitiesState();
  }
}

class _AmenitiesState extends State<Amenities> {

  static Map<String, List<CheckContainerModel>> selectedHoursByDay = {
    'Pazartesi': [],
    'Salı': [],
    'Çarşamba': [],
    'Perşembe': [],
    'Cuma': [],
    'Cumartesi': [],
    'Pazar': [],
  };

  List<CheckContainerModel> checkContainers = [
    CheckContainerModel(title: '18:00-19:00', isCheck: false),
    CheckContainerModel(title: '19:00-20:00', isCheck: false),
    CheckContainerModel(title: '20:00-21:00', isCheck: false),
    CheckContainerModel(title: '21:00-22:00', isCheck: false),
    CheckContainerModel(title: '22:00-23:00', isCheck: false),
    CheckContainerModel(title: '23:00-00:00', isCheck: false),
    CheckContainerModel(title: '00:00-01:00', isCheck: false),
    CheckContainerModel(title: '01:00-02:00', isCheck: false),
  ];

  List<CheckContainerModel> selectedHours = [];

   @override
  void initState() {
    super.initState();
    // deneme için
    /*
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TestCities()));
    });
    */
    
    
    if (!selectedHoursByDay.containsKey(widget.day)) {
      selectedHoursByDay[widget.day] = [];
    }
  }


  void onCheckTap(CheckContainerModel container) {
    final index = checkContainers.indexWhere(
      (element) => element.title == container.title,
    );
    bool previousIsCheck = checkContainers[index].isCheck;
    checkContainers[index].isCheck = !previousIsCheck;
    if (checkContainers[index].isCheck) {
      selectedHoursByDay[widget.day]!.add(checkContainers[index]);
    } else {
      selectedHoursByDay[widget.day]!.removeWhere(
        (element) => element.title == checkContainers[index].title
      );
    }
    setState(() {});
  }


@override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: checkContainers.map((container) {
      return InkWell(
        splashColor: Colors.cyanAccent,
        onTap: () => onCheckTap(container),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          padding: const EdgeInsets.all(8),
          color: container.isCheck ? const Color.fromRGBO(33, 150, 243, 1) : Colors.white, // seçim rengini yeşil yap
          child: Text(
            container.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: container.isCheck ? Colors.white : Colors.black,
            ),
          ),
        ),
      );
    }).toList(),
  );
  }
}

/*
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
} 
*/
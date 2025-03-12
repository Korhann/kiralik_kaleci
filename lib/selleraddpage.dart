import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:kiralik_kaleci/football_field.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/sellersuccesspage.dart';
import 'package:kiralik_kaleci/showAlert.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
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
  // for inserting to database
  String? selectedCity;
  String? selectedDistrict;
  String? selectedField;
  Set<String> multFields = {};
  String? value1;

  // for selecting the fields according to the districts
  List<String> fields = [];

  String currentUser = FirebaseAuth.instance.currentUser!.uid;
  bool userisSeller = false;

final GlobalKey<_AmenitiesState> mondayKey = GlobalKey();
final GlobalKey<_AmenitiesState> tuesdayKey = GlobalKey();
final GlobalKey<_AmenitiesState> wednesdayKey = GlobalKey();
final GlobalKey<_AmenitiesState> thursdayKey = GlobalKey();
final GlobalKey<_AmenitiesState> fridayKey = GlobalKey();
final GlobalKey<_AmenitiesState> saturdayKey = GlobalKey();
final GlobalKey<_AmenitiesState> sundayKey = GlobalKey();



  @override
  void initState() {
    super.initState();
    fetchCities();
    FootballField.storeFields();
    userorseller = true;
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
        multFields.clear();
        selectedCity = null;
        selectedDistrict = null;
        mondayKey.currentState?.resetSelection();
        tuesdayKey.currentState?.resetSelection();
        wednesdayKey.currentState?.resetSelection();
        thursdayKey.currentState?.resetSelection();
        fridayKey.currentState?.resetSelection();
        saturdayKey.currentState?.resetSelection();
        sundayKey.currentState?.resetSelection();
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sellerbackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: sellerbackground,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 10),
          child: buildButton(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Text(
                        "Fotoğraf Ekle",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600
                          ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "(Opsiyonel)",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                      ),
                    ],
                  )
                ),
                const SizedBox(height: 10),

                // image picker
                PickImageGallery(
                  imageFileList: imageFileList,
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        imageFileList.add(image);
                      });
                    }
                  },
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
                NameField(
                  controller: sellerFullName,
                  // onChanged: (value) {
                  //   setState(() {
                  //     sellerFullName.text = value;
                  //   });
                  // }
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
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        isExpanded: true,
                        value: selectedCity,
                        items: cities.map((city) => DropdownMenuItem<String>(
                          value: city,
                          child: Text(
                            city,
                            style: GoogleFonts.inter(
                              color: Colors.black
                            ),
                          ),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            onCitySelected(value);
                          }
                          multFields.clear();
                        },
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: const Text(
                            'Şehir seçin'
                          ),
                        ),
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            errorStyle: const TextStyle(height: 0),
                          ),
                        validator: (value) {
                          if (value == null) {
                            return '';
                          } else {
                            return null;
                          }
                        },
                      ),
                    const SizedBox(height: 2),
                    if (selectedCity == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 10),
                      child: Text(
                        'Lütfen bir şehir seçin',
                        style: GoogleFonts.inter(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    ],
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
                        fontWeight: FontWeight.w600
                      ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        isExpanded: true,
                        value: selectedDistrict,
                        items: districts.map((district) => DropdownMenuItem<String>(
                            value: district,
                            child: Text(
                              district,
                              style: GoogleFonts.inter(
                                color: Colors.black,
                              ),
                            ),
                        )).toList(),
                      
                        onChanged: (value) {
                          setState(() {
                            selectedDistrict = value;
                            fetchFields(value.toString());
                            multFields.clear();
                          });
                        },
                        hint: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('İlçe seçin'),
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          errorStyle: const TextStyle(height: 0),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return '';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 2),
                      if (selectedDistrict == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 5, left: 10),
                          child: Text(
                            'Lütfen bir ilçe seçin',
                            style: GoogleFonts.inter(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Halı Sahalar",
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // TODO: hint text eklenecek ve seçtiğin halı sahalar kutu halinde gözükecek
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 45,
                        width: 350,
                        color: Colors.white,
                        child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                              return StatefulBuilder(
                                builder: (context, _setState) {
                                return Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: ListView(
                                    children: fields.map((e) {
                                    return CheckboxListTile(
                                      title: Text(e),
                                      value: multFields.contains(e),
                                      onChanged: (isSelected) {
                                        if (isSelected == true) {
                                          multFields.add(e);
                                        } else {
                                          multFields.remove(e);
                                        }
                                        _setState(() {});
                                        setState(() {}); 
                                      },
                                    );
                                }).toList(),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 10),

          SizedBox(
            height: 60,
            width: MediaQuery.of(context).size.width,
            child: ListView.separated(
            separatorBuilder: (context,index) => SizedBox(width: 10),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            shrinkWrap: true,
            itemCount: multFields.length,
            itemBuilder: (BuildContext context, int index) {
              List<String> fieldList = multFields.toList();
              return Stack(
                children: [
                  Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        fieldList[index]
                      )
                    )
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        multFields.remove(fieldList[index]);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                ),
                ],
              );
            },
            ),
          ),
            const SizedBox(height: 5),
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
                              Amenities(key: mondayKey ,day: 'Pazartesi',),
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
                            Amenities(key: tuesdayKey ,day: 'Salı')
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
                            Amenities(key: wednesdayKey ,day: 'Çarşamba')
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
                            Amenities(key: thursdayKey ,day: 'Perşembe',)
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
                            Amenities(key: fridayKey ,day: 'Cuma')
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
                             Amenities(key: saturdayKey ,day: 'Cumartesi')
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
                            Amenities(key: sundayKey ,day: 'Pazar')
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
                          fontWeight: FontWeight.w600
                        ),
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
                      style: GlobalStyles.buttonPrimary(),
                      onPressed: () async {
                        try {
                          if (await InternetConnection().hasInternetAccess) {
                            bool isInserted = await _insertSellerDetails(context);
                            if (isInserted) {
                              _clearImageandText();
                            }
                          } else {
                            Showalert(context: context, text: 'Ooops...').showErrorAlert();
                          }
                        } catch (e) {
                          Showalert(context: context, text: 'Tüm alanları doldurduğunuza emin misiniz?').showErrorAlert();
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


  Future<void> fetchFields(String selectedDistrict) async {
  var localDb = await Hive.openBox<FootballField>('football_fields');

  try {
    // looking if the selectedDistrict is in the districts
    var field = localDb.values.firstWhere(
    (f) => f.city == selectedCity && f.district == selectedDistrict,
  );
  setState(() {
    // adds what is in that specific district
    fields = field.fieldName;
    selectedField = null;
  });
  } catch (e) {
    setState(() {
      fields = [];
      selectedField = null;
    });
    }
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

  // checks if the seller is currently has an active ad
  Future<bool> checkIfUserIsAlreadySeller() async {
  final documentSnapshot = await FirebaseFirestore.instance.collection('Users').doc(currentUser).get();
  userisSeller = documentSnapshot.data()?['sellerDetails'] != null;
  if (userisSeller) {
    return true;
  } else {
    return false;
  }
  }

  Widget buildButton() {
  return FutureBuilder<bool>(
    future: checkIfUserIsAlreadySeller(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }

      if (snapshot.hasData) {
        return Text(
          snapshot.data! ? 'İlanı Düzenle' : 'İlan Ekle',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        );
      }

      return Text('Hata', style: GoogleFonts.inter(fontSize: 20));
    },
  );
}


  // to populate with districts
  void onCitySelected(String selectedCity) {
    final city = cityData.firstWhere((city) => city['name'] == selectedCity);
    if (city != null) {
      final districtsData = city['districts'];
      if (districtsData != null) {
        final List<String> districtNames = (districtsData as List<dynamic>).map((district) => district['name'].toString()).toList();

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
    final List<XFile> selectedImages = await imagePicker.pickMultiImage(imageQuality: 5);
    if (selectedImages.isNotEmpty) {
      imageFileList.addAll(selectedImages);
    }
  }

  Future<bool> _insertSellerDetails(BuildContext context) async {
  if (_formKey.currentState!.validate() && _AmenitiesState.selectedHoursByDay.isNotEmpty && multFields.isNotEmpty) {

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
                  'takenby': 'empty'
                }).toList();
          }
        });

        int? price = int.tryParse(sellerPrice.text);

        Map<String, dynamic> sellerDetails = {
          "sellerFullName": sellerFullName.text,
          "sellerPrice": price,
          "city": selectedCity,
          "district": selectedDistrict,
          'fields': multFields,
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
        });

        // yükleme ekranından çık
        Navigator.of(context).pop();
        
        // saat seçme ui ını yenilemesi için pushreplacement
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => SellerSuccessPage()));
      }
      return true;
    } catch (e) {
      Navigator.of(context).pop(); // Close the loading dialog if an error occurs
      Showalert(context: context, text: 'Ooops...').showErrorAlert();
      return false;
    }
  } else {
    Showalert(context: context, text: 'Tüm alanları doldurduğunuza emin misiniz?').showErrorAlert();
    return false;
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
    // bunu sonradan değiştir
    final byteData = await rootBundle.load('lib/images/imageDefault.jpg');
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/imageDefault.jpg');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());
    Future<File> filePath = testCompressAndGetFile(tempFile,'lib/images/imageDefault.jpg');
    return filePath;
  }

  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, targetPath,
        quality: 88,
        rotate: 180,
      );

    // xfile ı file a çevir
    File photoFile = File(result!.path);
    return photoFile;
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

  // Ensure the list is initialized
  selectedHoursByDay[widget.day] ??= [];

  if (checkContainers[index].isCheck) {
    selectedHoursByDay[widget.day]!.add(checkContainers[index]);
  } else {
    selectedHoursByDay[widget.day]!.removeWhere(
      (element) => element.title == checkContainers[index].title,
    );
  }
  
  setState(() {});
}
  void resetSelection() {
  checkContainers = checkContainers.map((container) {
    return container.copyWith(isCheck: false); // Create a new instance with isCheck = false
  }).toList(); // Convert back to list

  //selectedHoursByDay[widget.day]?.clear(); // Clear the selected list for the day
  if (mounted) {
    setState(() {}); // Refresh the UI
  }
}



@override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: checkContainers.map((container) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          splashColor: Colors.cyanAccent,
          onTap: () => onCheckTap(container),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            padding: const EdgeInsets.all(8),
            color: container.isCheck ? Colors.green : Colors.white, // seçim rengini yeşil yap
            child: Text(
              container.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: container.isCheck ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      );
    }).toList(),
  );
  }
}
class PickImageGallery extends StatefulWidget {
  final List<XFile> imageFileList;
  final VoidCallback onTap;

  const PickImageGallery({
    Key? key,
    required this.imageFileList,
    required this.onTap,
  }) : super(key: key);

  @override
  _PickImageGalleryState createState() => _PickImageGalleryState();
}

class _PickImageGalleryState extends State<PickImageGallery> {
  int currentIndex = 0;

  void _removeImage(int index) {
    setState(() {
      widget.imageFileList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: sellergrey, 
      height: 110,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  width: 100,
                  height: 90,
                  color: Colors.white, 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt, size: 24),
                      const SizedBox(height: 2),
                      Text(
                        "Fotoğraf",
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Ekle",
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              width: 100,
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.imageFileList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                currentIndex = index;
                              });

                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.height,
                                      child: CarouselSlider(
                                        options: CarouselOptions(
                                          aspectRatio: 1,
                                          viewportFraction: 1,
                                          enableInfiniteScroll: false,
                                          padEnds: false,
                                          initialPage: currentIndex,
                                        ),
                                        items: widget.imageFileList.map((imageFile) {
                                          return Builder(
                                            builder: (BuildContext context) {
                                              return Image.file(
                                                File(imageFile.path),
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Image.file(
                              File(widget.imageFileList[index].path),
                              fit: BoxFit.fitHeight,
                            ),
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
    );
  }
}
class NameField extends StatelessWidget {
  final TextEditingController controller;
  // final ValueChanged<String> onChanged;
  const NameField({
    required this.controller,
    // required this.onChanged,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
                  controller: controller,
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
                          fontWeight: FontWeight.w300
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(10),
                      fillColor: sellergrey,
                      filled: true
                  ),
                );
  }
}



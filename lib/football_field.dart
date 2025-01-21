import 'package:hive/hive.dart';
part 'football_field.g.dart';

@HiveType(typeId: 0)
class FootballField {
  @HiveField(0)
  final String city;
  @HiveField(1)
  final String district;
  
  @HiveField(2)
  final List<String> fieldName;

  FootballField({
    required this.city,
    required this.district,
    required this.fieldName
  });

  static Future<void> storeFields() async {
  var box = await Hive.openBox<FootballField>('fields');

  // Clear existing data
  await box.clear();

  // Define data with cities and districts
  final List<FootballField> fields = [
    // ADANA
    FootballField(
      city: 'Adana',
      district: 'Çukurova',
      fieldName: ['Adana Fair Play Halı Saha','Adana Park Arena Halı Saha','Adana Şirin Halı Saha','Adana Star Halı Saha','Adana Rakip Halı Saha','Adana Libero Halı Saha','Elsam Halı Saha','Olimpos Kenan Evren Halı Saha','Adana Olimpos Halı Saha','Adana Akdeniz Halı Saha','Adana Göl Arena Halı Saha'],
    ),
    FootballField(
      city: 'Adana',
      district: 'İmamoğlu',
      fieldName: ['İmamoğlu Çakıroğlu Halı Saha'],
    ),
    FootballField(
      city: 'Adana',
      district: 'Karaisalı',
      fieldName: ['Çeçeli Park Halı Saha'],
    ),
    FootballField(
      city: 'Adana',
      district: 'Kozan',
      fieldName: ['Kozan Ünsal Halı Saha', 'Gültekin Halı Saha'],
    ),
    FootballField(
      city: 'Adana',
      district: 'Sarıçam',
      fieldName: ['Sarıçam Çakıroğlu Halı Saha','Sarıçam Ünsal Halı Saha'],
    ),
    FootballField(
      city: 'Adana',
      district: 'Seyhan',
      fieldName: ['Adana Kelebek Halı Saha','Adana Güler Halı Saha','Seyhan Ayyıldız Halı Saha','Adana Sular Halı Saha','Seyhan Dikili Arena Halı Saha','Volkan Halı Saha','Yeşilyurt Ünsal Halı Saha','Adana Özdemir Halı Saha','Adana Zöhre 2 Halı Saha','Adana Zöhre 1 Halı Saha','Çağdaş Halı Saha'],
    ),
    FootballField(
      city: 'Adana',
      district: 'Yüreğir',
      fieldName: ['Yüreğir Nehir Halı Saha','Adana Afşin Halı Saha','Yüreğir Gençlerbirliği Halı Saha','Solaklı Kartal Halı Saha'],
    ),
    // ADIYAMAN
    FootballField(
      city: 'Adıyaman',
      district: 'Kahta',
      fieldName: ['Adıyaman Kahta Baraj Halı Saha','Kahta Belediye Halı Saha','Kahta Olimpik Halı Saha','Kahta Arıkent Halı Saha','Doğukent Spor Tesisleri Halı Saha','Kahta Narince Halı Saha'],
    ),
    FootballField(
      city: 'Adıyaman',
      district: 'Merkez',
      fieldName: ['Adıyaman Göksu Halı Saha'],
    ),
    FootballField(
      city: 'Adıyaman',
      district: 'Sincik',
      fieldName: ['Sincik Esat Halı Saha'],
    ),
    // AFYONKARAHİSAR
    FootballField(
      city: 'Adıyaman',
      district: 'Bolvadin',
      fieldName: ['Bolvadin Akcan Arena Halı Saha'],
    ),
    FootballField(
      city: 'Ağrı',
      district: 'Merkez',
      fieldName: ['Ağrı Akademi Halı Saha','Ağrı Öğretmenler Lisesi Halı Saha','Ağrı Kral 2 Halı Saha','Ağrı Kral 4 Halı Saha'],
    ),
    // AKSARAY
    FootballField(
      city: 'Aksaray',
      district: 'Merkez',
      fieldName: ['Aksaray Şampiyon Halı Saha','Aksaray Futbol Park Halı Saha','Aksaray Maraton Halı Saha','Aksaray Metropol Halı Saha','Aksaray Golz Halı Saha','Aksaray Fanatik Halı Saha'],
    ),
    // AMASYA
    FootballField(
      city: 'Amasya',
      district: 'Gümüşhacıköy',
      fieldName: ['Amasya Naturel Halı Saha']
    ),
    FootballField(
      city: 'Amasya',
      district: 'Merkez',
      fieldName: ['Amasya Arena Halı Saha','Amasya Çamlık Halı Saha','Amasya Final Halı Saha','Amasya Çırağan Halı Saha','Sporium05 Halı Saha','Ziyaret Halı Saha']
    ),
    FootballField(
      city: 'Amasya',
      district: 'Merzifon',
      fieldName: ['Merzifon Balkaya Halı Saha','Özdilek Halı Saha']
    ),
    FootballField(
      city: 'Amasya',
      district: 'Suluova',
      fieldName: ['Suluova Şerifzade Halı Saha','Suluova Şeref Halı Saha']
    ),
    // ANKARA
    FootballField(
      city: 'Ankara',
      district: 'Altındağ',
      fieldName: ['Ankara Altınpark Halı Saha']
    ),
    FootballField(
      city: 'Ankara',
      district: 'Çankaya',
      fieldName: ['Yüzünce Yıl Saklıbahçe Halı Saha','Dikmen Merkez Halı Saha','100.yıl Kılıçaslan Halı Saha','Atatürk Anadolu Lisesi Halı Saha','Çankaya Halı Saha','Kurtuluş Parkı Halı Saha','Mesa Koru Halı Saha','Doktorlar 1 Halı Saha','Doktorlar 2 Halı Saha','Talatpaşa Halı Saha','Canberk Halı Saha'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Çubuk',
      fieldName: ['Topkapı Halı Saha Çubuk','Saklı Bahçe Halı Saha Çubuk','Çubuk Spor Halı Saha','Esenboğa Halı Saha'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Etimesgut',
      fieldName: ['Şaşmaz Halı Saha Etimesgut'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Gölbaşı',
      fieldName: ['Gölbaşı Şen Halı Saha','Kampüs Arena Halı Saha'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Kahramankazan',
      fieldName: ['Kahramankazan Halı Saha'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Keçiören',
      fieldName: ['Keçiören Halı Saha','Meteoroloji Halı Saha'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Mamak',
      fieldName: ['Ankara Yıldız Arena Halı Saha','Mamak Birlik Halı Saha'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Nallıhan',
      fieldName: ['Çayırhan Diriliş Halı Saha'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Pursaklar',
      fieldName: ['Avrupa Birliği Parkı Halı Saha'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Sincan',
      fieldName: ['Kırmızı Beyaz Spor Halı Saha'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Yenimahalle',
      fieldName: ['Batıkent Futbol Park Halı Saha','Yenimahalle Aybesk Halı Saha','Batıkent Arena Halı Saha','Altınbatı Spor Tesisleri Halı Saha'],
    ),
    // ANTALYA
    FootballField(
      city: 'Antalya',
      district: 'DöşemeAltı',
      fieldName: ['44 Demir Halı Saha'],
    ),
    FootballField(
      city: 'Antalya',
      district: 'Kemer',
      fieldName: ['Çamyuva Meydan Halı Saha','Kemer İdman Yurdu Halı Saha'],
    ),
    FootballField(
      city: 'Antalya',
      district: 'Kepez',
      fieldName: [''],
    ),
  ];

  // Add data to the box
  for (var field in fields) {
    await box.add(field);
  }
}

}
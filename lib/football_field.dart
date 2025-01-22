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
      fieldName: ['Akev Halı Saha','Pınar Halı Saha','Akdeniz Park Halı Saha','Antalya Tellioğlu Halı Saha','Maç 2000 Halı Saha','Olimpik Halı Saha Kepez','Çamlıbel Halı Saha Kepez','Altınova Halı Saha Kepez','Kepez Ostima Halı Saha','Kepez Şahin Halı Saha','Kepez Şelale Halı Saha','Kepez Koçlar Halı Saha','Gaziler Park Halı Saha'],
    ),
    FootballField(
      city: 'Antalya',
      district: 'Konyaaltı',
      fieldName: ['Cüneyt Çakır Halı Saha','Sporland Halı Saha Antalya']
    ),
    FootballField(
      city: 'Antalya',
      district: 'Kumluca',
      fieldName: ['Bey-kum Halı Saha','Kumluca Maraton Halı Saha']
    ),
    FootballField(
      city: 'Antalya',
      district: 'Manavgat',
      fieldName: ['Manavgat Tatava Halı Saha','Manavgat Birlik Halı Saha Antalya','Manavgat Maraton Arena Halı Saha','Manavgat Sorgun Halı Saha']
    ),
    FootballField(
      city: 'Antalya',
      district: 'Muratpaşa',
      fieldName: ['Levent Kartop Halı Saha','Karnaval Halı Saha']
    ),
    FootballField(
      city: 'Antalya',
      district: 'Serik',
      fieldName: ['Serik Ozan Halı Saha','Serik Bildirler Halı Saha']
    ),
    // ARTVİN
    FootballField(
      city: 'Artvin',
      district: 'Merkez',
      fieldName: ['Artvin Yıldırım Halı Saha','Artvin Utku Halı Saha']
    ),
    // AYDIN
    FootballField(
      city: 'Aydın',
      district: 'Buharkent',
      fieldName: ['Park Cafe Halı Saha','Buharkent Atatürk Şehir Parkı Halı Saha']
    ),
    FootballField(
      city: 'Aydın',
      district: 'Didim',
      fieldName: ['Didim Arena Anadolu Halı Saha','Didim Park Halı Saha','Aytepe Halı Saha','Dididm Yiğit Spor Halı Saha','Didim Arena Turizm Halı Saha']
    ),
    FootballField(
      city: 'Aydın',
      district: 'Efeler',
      fieldName: ['Aydın Çeştepe Halı Saha','Aydın Deport Athletics Halı Saha']
    ),
    FootballField(
      city: 'Aydın',
      district: 'İncirliova',
      fieldName: ['İncirliova Görkem Halı Saha','İncirliova Erbeyli Halı Saha']
    ),
    FootballField(
      city: 'Aydın',
      district: 'Kuşadası',
      fieldName: ['Kuşadası Derici Halı Saha','Kuşadası Mutlu Halı Saha','Kuşadası Davutlar Halı Saha']
    ),
    FootballField(
      city: 'Aydın',
      district: 'Nazilli',
      fieldName: ['Nazilli Halı Saha','Nazilli Halı Sahalar','Nazilli Açık Halı Saha','Şehitler Halı Saha','Özkatlar Halı Saha']
    ),
    FootballField(
      city: 'Aydın',
      district: 'Söke',
      fieldName: ['Söke Yaşam Park Kapalı Halı Saha','Söke Fatih Halı Saha','Söke Kolej Halı Saha','Söke Korsanlar Halı Saha']
    ),
    // BALIKESİR
    FootballField(
      city: 'Balıkesir',
      district: 'Altıeylül',
      fieldName: ['Park Halı Saha','Nef Halı Saha','Flaş Halı Saha','Korner Halı Saha Sosyal Tesisleri']
    ),
    FootballField(
      city: 'Balıkesir',
      district: 'Ayvalık',
      fieldName: ['Aymeyo Spor Kompleksi Halı Saha']
    ),
    FootballField(
      city: 'Balıkesir',
      district: 'Bandırma',
      fieldName: ['Nazende Halı Saha','Panormos Halı Saha','Selvi Halı Saha','Duru Halı Saha Livatya','Gelişim Halı Saha','Marmara Halı Saha','Bandırmagücü Melis Halı Saha','Edincik Santra Halı Saha']
    ),
    FootballField(
      city: 'Balıkesir',
      district: 'Burhaniye',
      fieldName: ['Sporium Halı Saha']
    ),
    FootballField(
      city: 'Balıkesir',
      district: 'Edremit',
      fieldName: ['Dağ Halı Saha Edremit','Akçay Vole Halı Saha','Edremit Aki Halı Saha']
    ),
    FootballField(
      city: 'Balıkesir',
      district: 'Gönen',
      fieldName: ['Gönen Sporium Halı Saha']
    ),
    FootballField(
      city: 'Balıkesir',
      district: 'İvrindi',
      fieldName: ['Balıkesir Çakır Halı Saha']
    ),
    FootballField(
      city: 'Balıkesir',
      district: 'Karesi',
      fieldName: ['Karesi Deplasman Halı Saha']
    ),
    // BARTIN
    FootballField(
      city: 'Bartın',
      district: 'Merkez',
      fieldName: ['Santra Halı Saha','Bartın Arena Halı Saha','Yaşam Park Halı Saha','Küre Sporyum Halı Saha','Bartın Güven Halı Saha','Akyemişler Halı Saha']
    ),
    // BATMAN
    FootballField(
      city: 'Batman',
      district: 'Gercüş',
      fieldName: ['Gercüş Arena Halı Saha']
    ),
    FootballField(
      city: 'Batman',
      district: 'Merkez',
      fieldName: ['Batman Arena Halı Saha','MBA Halı Saha','Batman Boğaziçi Halı Saha','Batman Şampiyon Halı Saha','Batman Olimpiyat Halı Saha']
    ),
    // BAYBURT
    FootballField(
      city: 'Bayburt',
      district: 'Merkez',
      fieldName: ['Bayburt Arena Halı Saha']
    ),
    // BİLECİK :)
    FootballField(
      city: 'Bilecik',
      district: 'Osmaneli',
      fieldName: ['Lefke Arena Halı Saha']
    ),
    // BİNGÖL
    FootballField(
      city: 'Bingöl',
      district: 'Merkez',
      fieldName: ['Bingöl Gül Halı Saha','Bingöl Sultan Sarayı Halı Saha','Ahmet Dursun Halı Saha']
    ),
    FootballField(
      city: 'Bingöl',
      district: 'Solhan',
      fieldName: ['Ayça Halı Saha 2']
    ),
    // BOLU
    FootballField(
      city: 'Bolu',
      district: 'Merkez',
      fieldName: ['Soysal Spor Halı Saha','Bolu Olimpik Halı Saha','Ali Baba Halı Saha','Bolu Futbol Park 14 Halı Saha','Bolu Spor Halı Saha']
    ),
    // BUCAK
    FootballField(
      city: 'Burdur',
      district: 'Bucak',
      fieldName: ['Bucak Maraton Arena Halı Saha']
    ),
    FootballField(
      city: 'Burdur',
      district: 'Merkez',
      fieldName: ['Burdur Altıpas Halı Saha','Yeşil Çimen Halı Saha','Burdur Arena Halı Saha','Burdur Spor Park Halı Saha','Burdur Santra Halı Saha']
    ),
    FootballField(
      city: 'Burdur',
      district: 'Tefenni',
      fieldName: ['Tefenni Belediye Halı Saha']
    ),
    // BURSA
    FootballField(
      city: 'Bursa',
      district: 'İnegöl',
      fieldName: ['İnegöl Kafkas Halı Saha','Gençlergücü Halı Saha','İnegöl Zadeler Halı Saha','İnegöl Doğan Halı Saha','İnegöl Kurtuluş Halı Saha','Gümüş Halı Saha İnegöl','Alanyurt Kocatepe Halı Saha','Sanayi Açık Kafkas Halı Saha']
    ),
    FootballField(
      city: 'Bursa',
      district: 'Mudanya',
      fieldName: ['Bursa Timsaha Halı Saha','Çamlık Park Halı Saha Mudanya']
    ),
    FootballField(
      city: 'Bursa',
      district: 'Nilüfer',
      fieldName: ['Ataevler Halı Saha','BPFDD Şükrü Şankaya Futbol Halı Saha','Görükle Oruç Halı Saha','Nilüfer Asya Halı Saha','Çamlıca Halı Saha Nilüfer','Nilüfer Özcan Halı Saha','Nilüfer Egemen Halı Saha','Özlüce Timsaha Halı Saha','Metropol Odunluk Halı Saha','Metropol Doğanköy Halı Saha']
    ),
    FootballField(
      city: 'Bursa',
      district: 'Osmangazi',
      fieldName: ['Altınceylan Timsaha Halı Saha','Bursa Pınarbaşı Halı Saha','As Futbol Park Halı Saha','Bursa Anadolu Lisesi Halı Saha','Osmangazi Arena Halı Saha','Korkut Halı Saha']
    ),
    FootballField(
      city: 'Bursa',
      district: 'Yenişehir',
      fieldName: ['Yenişehir Santra Halı Saha']
    ),
    FootballField(
      city: 'Bursa',
      district: 'Yıldırım',
      fieldName: ['Erikli Halı Saha Yıldırım','Yıldırım Ayyıldız Halı Saha','Atletik Halı Saha','Mimar Sinan Halı Saha','Şükraniye Spor Halı Saha','Mimar Sinan Gençlik ve Spor Halı Saha','Kafe Kafkas Halı Saha']
    ),
    // ÇANAKKALE
    FootballField(
      city: 'Çanakkale',
      district: 'Biga',
      fieldName: ['Havuz Kafe Halı Saha']
    ),
    FootballField(
      city: 'Çanakkale',
      district: 'Gelibolu',
      fieldName: ['Gelibolu Dost Halı Saha','Gelibolu 18 Mart Halı Saha']
    ),
    FootballField(
      city: 'Çanakkale',
      district: 'İmroz',
      fieldName: ['İmroz Halı Saha']
    ),
    FootballField(
      city: 'Çanakkale',
      district: 'Merkez',
      fieldName: ['Çanakkale Teknopark Halı Saha','Dabakoğlu Halı Saha','TRCUP Deniz Halı Saha','Kepez Spor Halı Saha']
    ),
    // ÇANKIRI
    FootballField(
      city: 'Çankırı',
      district: 'Kurşunlu',
      fieldName: ['Kurşunlu Halı Saha']
    ),
    FootballField(
      city: 'Çankırı',
      district: 'Merkez',
      fieldName: ['Çankırı Aksu Halı Saha','Çankırı Sporyum Halı Saha','Çankırı Akasya Halı Saha']
    ),
    // DENİZLİ
    FootballField(city: 'Denizli', district: 'Çivril', fieldName: ['Çivril Arena Halı Saha']),
    FootballField(city: 'Denizli', district: 'Merkezefendi', fieldName: ['Beyazıt Sport Eren Halı Saha','Beyazıt Sport Kolej Halı Saha','Beyazıt Sport Denizli Arena Halı Saha','Denizli Sporium Halı Saha','Berkay 75.yıl Halı Saha Tesisleri','Denizli Koleji Halı Saha','Beyazıt Spor Aydem Beyaz Halı Saha','Mustafa Kaynak Lisesi Halı Saha','Cinkaya Halı Saha','Denizli Aslantepe Spor Tesisleri']),
    FootballField(city: 'Denizli', district: 'Pamukkale', fieldName: ['Denizli Reel Halı Saha']),
    // DİYARBAKIR
    FootballField(
      city: 'Diyarbakır',
      district: 'Bağlar',
      fieldName: ['Diyarbakır Göksü Halı Saha','Miryıldız Halı Saha']
    ),
    FootballField(
      city: 'Diyarbakır',
      district: 'Bismil',
      fieldName: ['Merkez Dolay Halı Saha','Nokta Dolay Halı Saha']
    ),
    FootballField(
      city: 'Diyarbakır',
      district: 'Kayapınar',
      fieldName: ['Club Marduk Halı Saha']
    ),
    FootballField(
      city: 'Diyarbakır',
      district: 'Yenişehir',
      fieldName: ['Diyarbakır Toki Arena Halı Saha','Tulip Anka Park Halı Saha','Özbek Halı Saha']
    ),
    // DÜZCE
    FootballField(
      city: 'Düzce',
      district: 'Cumayeri',
      fieldName: ['Cumayeri Gözde Halı Saha']
    ),
    FootballField(
      city: 'Düzce',
      district: 'Gölkaya',
      fieldName: ['Gölkaya Halı Saha']
    ),
    FootballField(
      city: 'Düzce',
      district: 'Kaynaşlı',
      fieldName: ['Kaynaşlı Akif Demir Halı Saha']
    ),
    FootballField(
      city: 'Düzce',
      district: 'Merkez',
      fieldName: ['Düzce Alpay Halı Saha','Düzce Stadyum Halı Saha','Genç Halı Saha','Düzce Ayyıldız Halı Saha','Fettah Bey Halı Saha','Düzce Zafer Halı Saha','Düzce Elit Halı Saha','Dü Spor Tesisleri']
    ),
    // EDİRNE
    FootballField(
      city: 'Edirne',
      district: 'Keşan',
      fieldName: ['Uygunlar Halı Saha','Uygunlar F.M Çuhacı Halı Saha','Arena Keşan Halı Saha']
    ),
    // ELAZIĞ
    FootballField(
      city: 'Elazığ',
      district: 'Merkez',
      fieldName: ['Elazığ Menekşe Halı Saha','Elazığ LaLiga Halı Saha','Elazığ Fair Play Halı Saha','Elazığ Futbol Times Halı Saha','Elazığ Sporium 23 Halı Saha','Elazığ Amsterdam Halı Saha']
    ),
    // ERZİNCAN
    FootballField(
      city: 'Erzincan',
      district: 'Merkez',
      fieldName: ['Okumuşlar Halı Saha']
    ),
  ];

  // Add data to the box
  for (var field in fields) {
    await box.add(field);
  }
}

}
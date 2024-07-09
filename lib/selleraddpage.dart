import 'dart:developer';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiralik_kaleci/styles/button.dart';
import 'package:kiralik_kaleci/styles/colors.dart';


class SellerAddPage extends StatefulWidget {
  const SellerAddPage({super.key});

  @override
  State<SellerAddPage> createState() => _SellerAddPageState();
}

//TODO: Resim eklemek zorunlu olması lazım yoksa getuserinformation page hata veriyor index ten dolayı

class _SellerAddPageState extends State<SellerAddPage> {
  final int maxWords = 150; // Maximum words allowed
  final int minWords = 30; // Min words allowed
  final TextEditingController _controller = TextEditingController();

  // Kullanıcı bilgileri
  TextEditingController sellerName = TextEditingController();
  TextEditingController sellerLastName = TextEditingController();
  TextEditingController sellerAge = TextEditingController();
  TextEditingController sellerHeight = TextEditingController();
  TextEditingController sellerWeight = TextEditingController();
  TextEditingController sellerPrice = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // galeriden resim seçmek için
  final ImagePicker imagePicker = ImagePicker();
  List<XFile> imageFileList = [];

  // sıradaki resime geçmek için
  int currentIndex = 0;

  // DROPDOWN MENU
  String? selectedCity;
  String? selectedDistrict;
  late SingleValueDropDownController _cnt;
  late SingleValueDropDownController _cnt2;
  List<DropDownValueModel>? districtOptions;


  Map<String, List<DropDownValueModel>> cityDistricts = {
  'Adana': const [
    DropDownValueModel(name: 'Çukurova', value: 'Çukurova'),
    DropDownValueModel(name: 'Sarıçam', value: 'Sarıçam'),
    DropDownValueModel(name: 'Seyhan', value: 'Seyhan'),
    DropDownValueModel(name: 'Yüreğir', value: 'Yüreğir'),
    DropDownValueModel(name: 'Aladağ', value: 'Aladağ'),
    DropDownValueModel(name: 'Ceyhan', value: 'Ceyhan'),
    DropDownValueModel(name: 'Feke', value: 'Feke'),
    DropDownValueModel(name: 'İmamoğlu', value: 'İmamoğlu'),
    DropDownValueModel(name: 'Karaisalı', value: 'Karaisalı'),
    DropDownValueModel(name: 'Karataş', value: 'Karataş'),
    DropDownValueModel(name: 'Kozan', value: 'Kozan'),
    DropDownValueModel(name: 'Pozantı', value: 'Pozantı'),
    DropDownValueModel(name: 'Saimbeyli', value: 'Saimbeyli'),
    DropDownValueModel(name: 'Tufanbeyli', value: 'Tufanbeyli'),
    DropDownValueModel(name: 'Yumurtalık', value: 'Yumurtalık')

  ],
  'Adıyaman': const [
    DropDownValueModel(name: 'Merkez', value: 'Merkez'),
    DropDownValueModel(name: 'Besni', value: 'Besni'),
    DropDownValueModel(name: 'Çelikhan', value: 'Çelikhan'),
    DropDownValueModel(name: 'Gerger', value: 'Gerger'),
    DropDownValueModel(name: 'Gölbaşı', value: 'Gölbaşı'),
    DropDownValueModel(name: 'Kâhta', value: 'Kâhta'),
    DropDownValueModel(name: 'Samsat', value: 'Samsat'),
    DropDownValueModel(name: 'Sincik', value: 'Sincik'),
    DropDownValueModel(name: 'Tut', value: 'Tut')
  ],
  'Afyonkarahisar': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Başmakçı', value: 'Başmakçı'),
  DropDownValueModel(name: 'Bayat', value: 'Bayat'),
  DropDownValueModel(name: 'Bolvadin', value: 'Bolvadin'),
  DropDownValueModel(name: 'Çay', value: 'Çay'),
  DropDownValueModel(name: 'Çobanlar', value: 'Çobanlar'),
  DropDownValueModel(name: 'Dazkırı', value: 'Dazkırı'),
  DropDownValueModel(name: 'Dinar', value: 'Dinar'),
  DropDownValueModel(name: 'Emirdağ', value: 'Emirdağ'),
  DropDownValueModel(name: 'Evciler', value: 'Evciler'),
  DropDownValueModel(name: 'Hocalar', value: 'Hocalar'),
  DropDownValueModel(name: 'İhsaniye', value: 'İhsaniye'),
  DropDownValueModel(name: 'İscehisar', value: 'İscehisar'),
  DropDownValueModel(name: 'Kızılören', value: 'Kızılören'),
  DropDownValueModel(name: 'Sandıklı', value: 'Sandıklı'),
  DropDownValueModel(name: 'Sinanpaşa', value: 'Sinanpaşa'),
  DropDownValueModel(name: 'Sultandağı', value: 'Sultandağı'),
  DropDownValueModel(name: 'Şuhut', value: 'Şuhut')
],
  'Ağrı': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Diyadin', value: 'Diyadin'),
  DropDownValueModel(name: 'Doğubayazıt', value: 'Doğubayazıt'),
  DropDownValueModel(name: 'Eleşkirt', value: 'Eleşkirt'),
  DropDownValueModel(name: 'Hamur', value: 'Hamur'),
  DropDownValueModel(name: 'Patnos', value: 'Patnos'),
  DropDownValueModel(name: 'Taşlıçay', value: 'Taşlıçay'),
  DropDownValueModel(name: 'Tutak', value: 'Tutak')
],
  'Amasya': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Göynücek', value: 'Göynücek'),
  DropDownValueModel(name: 'Gümüşhacıköy', value: 'Gümüşhacıköy'),
  DropDownValueModel(name: 'Hamamözü', value: 'Hamamözü'),
  DropDownValueModel(name: 'Merzifon', value: 'Merzifon'),
  DropDownValueModel(name: 'Suluova', value: 'Suluova'),
  DropDownValueModel(name: 'Taşova', value: 'Taşova')
],
  'Ankara': const [
  DropDownValueModel(name: 'Akyurt', value: 'Akyurt'),
  DropDownValueModel(name: 'Altındağ', value: 'Altındağ'),
  DropDownValueModel(name: 'Ayaş', value: 'Ayaş'),
  DropDownValueModel(name: 'Balâ', value: 'Balâ'),
  DropDownValueModel(name: 'Beypazarı', value: 'Beypazarı'),
  DropDownValueModel(name: 'Çamlıdere', value: 'Çamlıdere'),
  DropDownValueModel(name: 'Çankaya', value: 'Çankaya'),
  DropDownValueModel(name: 'Çubuk', value: 'Çubuk'),
  DropDownValueModel(name: 'Elmadağ', value: 'Elmadağ'),
  DropDownValueModel(name: 'Etimesgut', value: 'Etimesgut'),
  DropDownValueModel(name: 'Evren', value: 'Evren'),
  DropDownValueModel(name: 'Gölbaşı', value: 'Gölbaşı'),
  DropDownValueModel(name: 'Güdül', value: 'Güdül'),
  DropDownValueModel(name: 'Haymana', value: 'Haymana'),
  DropDownValueModel(name: 'Kahramankazan', value: 'Kahramankazan'),
  DropDownValueModel(name: 'Kalecik', value: 'Kalecik'),
  DropDownValueModel(name: 'Keçiören', value: 'Keçiören'),
  DropDownValueModel(name: 'Kızılcahamam', value: 'Kızılcahamam'),
  DropDownValueModel(name: 'Mamak', value: 'Mamak'),
  DropDownValueModel(name: 'Nallıhan', value: 'Nallıhan'),
  DropDownValueModel(name: 'Polatlı', value: 'Polatlı'),
  DropDownValueModel(name: 'Pursaklar', value: 'Pursaklar'),
  DropDownValueModel(name: 'Sincan', value: 'Sincan'),
  DropDownValueModel(name: 'Şereflikoçhisar', value: 'Şereflikoçhisar'),
  DropDownValueModel(name: 'Yenimahalle', value: 'Yenimahalle')
],
  'Antalya': const [
  DropDownValueModel(name: 'Aksu', value: 'Aksu'),
  DropDownValueModel(name: 'Döşemealtı', value: 'Döşemealtı'),
  DropDownValueModel(name: 'Kepez', value: 'Kepez'),
  DropDownValueModel(name: 'Konyaaltı', value: 'Konyaaltı'),
  DropDownValueModel(name: 'Muratpaşa', value: 'Muratpaşa'),
  DropDownValueModel(name: 'Akseki', value: 'Akseki'),
  DropDownValueModel(name: 'Alanya', value: 'Alanya'),
  DropDownValueModel(name: 'Demre', value: 'Demre'),
  DropDownValueModel(name: 'Elmalı', value: 'Elmalı'),
  DropDownValueModel(name: 'Finike', value: 'Finike'),
  DropDownValueModel(name: 'Gazipaşa', value: 'Gazipaşa'),
  DropDownValueModel(name: 'Gündoğmuş', value: 'Gündoğmuş'),
  DropDownValueModel(name: 'İbradı', value: 'İbradı'),
  DropDownValueModel(name: 'Kaş', value: 'Kaş'),
  DropDownValueModel(name: 'Kemer', value: 'Kemer'),
  DropDownValueModel(name: 'Korkuteli', value: 'Korkuteli'),
  DropDownValueModel(name: 'Kumluca', value: 'Kumluca'),
  DropDownValueModel(name: 'Manavgat', value: 'Manavgat'),
  DropDownValueModel(name: 'Serik', value: 'Serik'),
],
  'Artvin': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Ardanuç', value: 'Ardanuç'),
  DropDownValueModel(name: 'Arhavi', value: 'Arhavi'),
  DropDownValueModel(name: 'Borçka', value: 'Borçka'),
  DropDownValueModel(name: 'Hopa', value: 'Hopa'),
  DropDownValueModel(name: 'Kemalpaşa', value: 'Kemalpaşa'),
  DropDownValueModel(name: 'Murgul', value: 'Murgul'),
  DropDownValueModel(name: 'Şavşat', value: 'Şavşat'),
  DropDownValueModel(name: 'Yusufeli', value: 'Yusufeli')
],
  'Aydın': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Bozdoğan', value: 'Bozdoğan'),
  DropDownValueModel(name: 'Buharkent', value: 'Buharkent'),
  DropDownValueModel(name: 'Çine', value: 'Çine'),
  DropDownValueModel(name: 'Didim', value: 'Didim'),
  DropDownValueModel(name: 'Germencik', value: 'Germencik'),
  DropDownValueModel(name: 'İncirliova', value: 'İncirliova'),
  DropDownValueModel(name: 'Karacasu', value: 'Karacasu'),
  DropDownValueModel(name: 'Karpuzlu', value: 'Karpuzlu'),
  DropDownValueModel(name: 'Koçarlı', value: 'Koçarlı'),
  DropDownValueModel(name: 'Köşk', value: 'Köşk'),
  DropDownValueModel(name: 'Kuşadası', value: 'Kuşadası'),
  DropDownValueModel(name: 'Kuyucak', value: 'Kuyucak'),
  DropDownValueModel(name: 'Nazilli', value: 'Nazilli'),
  DropDownValueModel(name: 'Söke', value: 'Söke'),
  DropDownValueModel(name: 'Sultanhisar', value: 'Sultanhisar'),
  DropDownValueModel(name: 'Yenipazar', value: 'Yenipazar')
],
  'Balıkesir': const [
  DropDownValueModel(name: 'Altıeylül', value: 'Altıeylül'),
  DropDownValueModel(name: 'Karesi', value: 'Karesi'),
  DropDownValueModel(name: 'Ayvalık', value: 'Ayvalık'),
  DropDownValueModel(name: 'Balya', value: 'Balya'),
  DropDownValueModel(name: 'Bandırma', value: 'Bandırma'),
  DropDownValueModel(name: 'Bigadiç', value: 'Bigadiç'),
  DropDownValueModel(name: 'Burhaniye', value: 'Burhaniye'),
  DropDownValueModel(name: 'Dursunbey', value: 'Dursunbey'),
  DropDownValueModel(name: 'Edremit', value: 'Edremit'),
  DropDownValueModel(name: 'Erdek', value: 'Erdek'),
  DropDownValueModel(name: 'Gömeç', value: 'Gömeç'),
  DropDownValueModel(name: 'Gönen', value: 'Gönen'),
  DropDownValueModel(name: 'Havran', value: 'Havran'),
  DropDownValueModel(name: 'İvrindi', value: 'İvrindi'),
  DropDownValueModel(name: 'Kepsut', value: 'Kepsut'),
  DropDownValueModel(name: 'Manyas', value: 'Manyas'),
  DropDownValueModel(name: 'Marmara', value: 'Marmara'),
  DropDownValueModel(name: 'Savaştepe', value: 'Savaştepe'),
  DropDownValueModel(name: 'Sındırgı', value: 'Sındırgı'),
  DropDownValueModel(name: 'Susurluk', value: 'Susurluk')
],
  'Bilecik': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Bozüyük', value: 'Bozüyük'),
  DropDownValueModel(name: 'Gölpazarı', value: 'Gölpazarı'),
  DropDownValueModel(name: 'İnhisar', value: 'İnhisar'),
  DropDownValueModel(name: 'Osmaneli', value: 'Osmaneli'),
  DropDownValueModel(name: 'Pazaryeri', value: 'Pazaryeri'),
  DropDownValueModel(name: 'Söğüt', value: 'Söğüt'),
  DropDownValueModel(name: 'Yenipazar', value: 'Yenipazar')
],
  'Bingöl': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Adaklı', value: 'Adaklı'),
  DropDownValueModel(name: 'Genç', value: 'Genç'),
  DropDownValueModel(name: 'Karlıova', value: 'Karlıova'),
  DropDownValueModel(name: 'Kiğı', value: 'Kiğı'),
  DropDownValueModel(name: 'Solhan', value: 'Solhan'),
  DropDownValueModel(name: 'Yayladere', value: 'Yayladere'),
  DropDownValueModel(name: 'Yedisu', value: 'Yedisu')
],
  'Bitlis': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Adilcevaz', value: 'Adilcevaz'),
  DropDownValueModel(name: 'Ahlat', value: 'Ahlat'),
  DropDownValueModel(name: 'Güroymak', value: 'Güroymak'),
  DropDownValueModel(name: 'Hizan', value: 'Hizan'),
  DropDownValueModel(name: 'Mutki', value: 'Mutki'),
  DropDownValueModel(name: 'Tatvan', value: 'Tatvan')
],
  'Bolu': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Dörtdivan', value: 'Dörtdivan'),
  DropDownValueModel(name: 'Gerede', value: 'Gerede'),
  DropDownValueModel(name: 'Göynük', value: 'Göynük'),
  DropDownValueModel(name: 'Kıbrıscık', value: 'Kıbrıscık'),
  DropDownValueModel(name: 'Mengen', value: 'Mengen'),
  DropDownValueModel(name: 'Mudurnu', value: 'Mudurnu'),
  DropDownValueModel(name: 'Seben', value: 'Seben'),
  DropDownValueModel(name: 'Yeniçağa', value: 'Yeniçağa')
],
  'Burdur': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Ağlasun', value: 'Ağlasun'),
  DropDownValueModel(name: 'Altınyayla', value: 'Altınyayla'),
  DropDownValueModel(name: 'Bucak', value: 'Bucak'),
  DropDownValueModel(name: 'Çavdır', value: 'Çavdır'),
  DropDownValueModel(name: 'Çeltikçi', value: 'Çeltikçi'),
  DropDownValueModel(name: 'Gölhisar', value: 'Gölhisar'),
  DropDownValueModel(name: 'Karamanlı', value: 'Karamanlı'),
  DropDownValueModel(name: 'Kemer', value: 'Kemer'),
  DropDownValueModel(name: 'Tefenni', value: 'Tefenni'),
  DropDownValueModel(name: 'Yeşilova', value: 'Yeşilova')
],
  'Bursa': const [
  DropDownValueModel(name: 'Nilüfer', value: 'Nilüfer'),
  DropDownValueModel(name: 'Osmangazi', value: 'Osmangazi'),
  DropDownValueModel(name: 'Gürsu', value: 'Gürsu'),
  DropDownValueModel(name: 'Kestel', value: 'Kestel'),
  DropDownValueModel(name: 'Yıldırım', value: 'Yıldırım'),
  DropDownValueModel(name: 'Büyükorhan', value: 'Büyükorhan'),
  DropDownValueModel(name: 'Gemlik', value: 'Gemlik'),
  DropDownValueModel(name: 'Harmancık', value: 'Harmancık'),
  DropDownValueModel(name: 'İnegöl', value: 'İnegöl'),
  DropDownValueModel(name: 'İznik', value: 'İznik'),
  DropDownValueModel(name: 'Karacabey', value: 'Karacabey'),
  DropDownValueModel(name: 'Keles', value: 'Keles'),
  DropDownValueModel(name: 'Mudanya', value: 'Mudanya'),
  DropDownValueModel(name: 'Mustafakemalpaşa', value: 'Mustafakemalpaşa'),
  DropDownValueModel(name: 'Orhaneli', value: 'Orhaneli'),
  DropDownValueModel(name: 'Orhangazi', value: 'Orhangazi'),
  DropDownValueModel(name: 'Yenişehir', value: 'Yenişehir')
],
  'Çanakkale': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Ayvacık', value: 'Ayvacık'),
  DropDownValueModel(name: 'Bayramiç', value: 'Bayramiç'),
  DropDownValueModel(name: 'Biga', value: 'Biga'),
  DropDownValueModel(name: 'Bozcaada', value: 'Bozcaada'),
  DropDownValueModel(name: 'Çan', value: 'Çan'),
  DropDownValueModel(name: 'Eceabat', value: 'Eceabat'),
  DropDownValueModel(name: 'Ezine', value: 'Ezine'),
  DropDownValueModel(name: 'Gelibolu', value: 'Gelibolu'),
  DropDownValueModel(name: 'Gökçeada', value: 'Gökçeada'),
  DropDownValueModel(name: 'Lapseki', value: 'Lapseki'),
  DropDownValueModel(name: 'Yenice', value: 'Yenice')
],
  'Çankırı': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Atkaracalar', value: 'Atkaracalar'),
  DropDownValueModel(name: 'Bayramören', value: 'Bayramören'),
  DropDownValueModel(name: 'Çerkeş', value: 'Çerkeş'),
  DropDownValueModel(name: 'Eldivan', value: 'Eldivan'),
  DropDownValueModel(name: 'Ilgaz', value: 'Ilgaz'),
  DropDownValueModel(name: 'Kızılırmak', value: 'Kızılırmak'),
  DropDownValueModel(name: 'Korgun', value: 'Korgun'),
  DropDownValueModel(name: 'Kurşunlu', value: 'Kurşunlu'),
  DropDownValueModel(name: 'Orta', value: 'Orta'),
  DropDownValueModel(name: 'Şabanözü', value: 'Şabanözü'),
  DropDownValueModel(name: 'Yapraklı', value: 'Yapraklı')
],
  'Çorum': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Alaca', value: 'Alaca'),
  DropDownValueModel(name: 'Bayat', value: 'Bayat'),
  DropDownValueModel(name: 'Boğazkale', value: 'Boğazkale'),
  DropDownValueModel(name: 'Dodurga', value: 'Dodurga'),
  DropDownValueModel(name: 'İskilip', value: 'İskilip'),
  DropDownValueModel(name: 'Kargı', value: 'Kargı'),
  DropDownValueModel(name: 'Laçin', value: 'Laçin'),
  DropDownValueModel(name: 'Mecitözü', value: 'Mecitözü'),
  DropDownValueModel(name: 'Oğuzlar', value: 'Oğuzlar'),
  DropDownValueModel(name: 'Ortaköy', value: 'Ortaköy'),
  DropDownValueModel(name: 'Osmancık', value: 'Osmancık'),
  DropDownValueModel(name: 'Sungurlu', value: 'Sungurlu'),
  DropDownValueModel(name: 'Uğurludağ', value: 'Uğurludağ')
],
  'Denizli': const [
  DropDownValueModel(name: 'Merkezefendi', value: 'Merkezefendi'),
  DropDownValueModel(name: 'Pamukkale', value: 'Pamukkale'),
  DropDownValueModel(name: 'Acıpayam', value: 'Acıpayam'),
  DropDownValueModel(name: 'Babadağ', value: 'Babadağ'),
  DropDownValueModel(name: 'Baklan', value: 'Baklan'),
  DropDownValueModel(name: 'Bekilli', value: 'Bekilli'),
  DropDownValueModel(name: 'Beyağaç', value: 'Beyağaç'),
  DropDownValueModel(name: 'Bozkurt', value: 'Bozkurt'),
  DropDownValueModel(name: 'Buldan', value: 'Buldan'),
  DropDownValueModel(name: 'Çal', value: 'Çal'),
  DropDownValueModel(name: 'Çameli', value: 'Çameli'),
  DropDownValueModel(name: 'Çardak', value: 'Çardak'),
  DropDownValueModel(name: 'Çivril', value: 'Çivril'),
  DropDownValueModel(name: 'Güney', value: 'Güney'),
  DropDownValueModel(name: 'Honaz', value: 'Honaz'),
  DropDownValueModel(name: 'Kale', value: 'Kale'),
  DropDownValueModel(name: 'Sarayköy', value: 'Sarayköy'),
  DropDownValueModel(name: 'Serinhisar', value: 'Serinhisar'),
  DropDownValueModel(name: 'Tavas', value: 'Tavas')
],
  'Diyarbakır': const [
  DropDownValueModel(name: 'Bağlar', value: 'Bağlar'),
  DropDownValueModel(name: 'Kayapınar', value: 'Kayapınar'),
  DropDownValueModel(name: 'Sur', value: 'Sur'),
  DropDownValueModel(name: 'Yenişehir', value: 'Yenişehir'),
  DropDownValueModel(name: 'Bismil', value: 'Bismil'),
  DropDownValueModel(name: 'Çermik', value: 'Çermik'),
  DropDownValueModel(name: 'Çınar', value: 'Çınar'),
  DropDownValueModel(name: 'Çüngüş', value: 'Çüngüş'),
  DropDownValueModel(name: 'Dicle', value: 'Dicle'),
  DropDownValueModel(name: 'Eğil', value: 'Eğil'),
  DropDownValueModel(name: 'Ergani', value: 'Ergani'),
  DropDownValueModel(name: 'Hani', value: 'Hani'),
  DropDownValueModel(name: 'Hazro', value: 'Hazro'),
  DropDownValueModel(name: 'Kocaköy', value: 'Kocaköy'),
  DropDownValueModel(name: 'Kulp', value: 'Kulp'),
  DropDownValueModel(name: 'Lice', value: 'Lice'),
  DropDownValueModel(name: 'Silvan', value: 'Silvan')
],
  'Edirne': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Enez', value: 'Enez'),
  DropDownValueModel(name: 'Havsa', value: 'Havsa'),
  DropDownValueModel(name: 'İpsala', value: 'İpsala'),
  DropDownValueModel(name: 'Keşan', value: 'Keşan'),
  DropDownValueModel(name: 'Lalapaşa', value: 'Lalapaşa'),
  DropDownValueModel(name: 'Meriç', value: 'Meriç'),
  DropDownValueModel(name: 'Süloğlu', value: 'Süloğlu'),
  DropDownValueModel(name: 'Uzunköprü', value: 'Uzunköprü')
],
  'Elazığ': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Ağın', value: 'Ağın'),
  DropDownValueModel(name: 'Alacakaya', value: 'Alacakaya'),
  DropDownValueModel(name: 'Arıcak', value: 'Arıcak'),
  DropDownValueModel(name: 'Baskil', value: 'Baskil'),
  DropDownValueModel(name: 'Karakoçan', value: 'Karakoçan'),
  DropDownValueModel(name: 'Keban', value: 'Keban'),
  DropDownValueModel(name: 'Kovancılar', value: 'Kovancılar'),
  DropDownValueModel(name: 'Maden', value: 'Maden'),
  DropDownValueModel(name: 'Palu', value: 'Palu'),
  DropDownValueModel(name: 'Sivrice', value: 'Sivrice')
],
  'Erzincan': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Çayırlı', value: 'Çayırlı'),
  DropDownValueModel(name: 'İliç', value: 'İliç'),
  DropDownValueModel(name: 'Kemah', value: 'Kemah'),
  DropDownValueModel(name: 'Kemaliye', value: 'Kemaliye'),
  DropDownValueModel(name: 'Otlukbeli', value: 'Otlukbeli'),
  DropDownValueModel(name: 'Refahiye', value: 'Refahiye'),
  DropDownValueModel(name: 'Tercan', value: 'Tercan'),
  DropDownValueModel(name: 'Üzümlü', value: 'Üzümlü')
],
  'Erzurum': const [
  DropDownValueModel(name: 'Yakutiye', value: 'Yakutiye'),
  DropDownValueModel(name: 'Aziziye', value: 'Aziziye'),
  DropDownValueModel(name: 'Palandöken', value: 'Palandöken'),
  DropDownValueModel(name: 'Aşkale', value: 'Aşkale'),
  DropDownValueModel(name: 'Çat', value: 'Çat'),
  DropDownValueModel(name: 'Hınıs', value: 'Hınıs'),
  DropDownValueModel(name: 'Horasan', value: 'Horasan'),
  DropDownValueModel(name: 'İspir', value: 'İspir'),
  DropDownValueModel(name: 'Karaçoban', value: 'Karaçoban'),
  DropDownValueModel(name: 'Karayazı', value: 'Karayazı'),
  DropDownValueModel(name: 'Köprüköy', value: 'Köprüköy'),
  DropDownValueModel(name: 'Narman', value: 'Narman'),
  DropDownValueModel(name: 'Oltu', value: 'Oltu'),
  DropDownValueModel(name: 'Olur', value: 'Olur'),
  DropDownValueModel(name: 'Pasinler', value: 'Pasinler'),
  DropDownValueModel(name: 'Pazaryolu', value: 'Pazaryolu'),
  DropDownValueModel(name: 'Şenkaya', value: 'Şenkaya'),
  DropDownValueModel(name: 'Tekman', value: 'Tekman'),
  DropDownValueModel(name: 'Tortum', value: 'Tortum'),
  DropDownValueModel(name: 'Uzundere', value: 'Uzundere')
],
  'Eskişehir': const [
  DropDownValueModel(name: 'Odunpazarı', value: 'Odunpazarı'),
  DropDownValueModel(name: 'Tepebaşı', value: 'Tepebaşı'),
  DropDownValueModel(name: 'Alpu', value: 'Alpu'),
  DropDownValueModel(name: 'Beylikova', value: 'Beylikova'),
  DropDownValueModel(name: 'Çifteler', value: 'Çifteler'),
  DropDownValueModel(name: 'Günyüzü', value: 'Günyüzü'),
  DropDownValueModel(name: 'Han', value: 'Han'),
  DropDownValueModel(name: 'İnönü', value: 'İnönü'),
  DropDownValueModel(name: 'Mahmudiye', value: 'Mahmudiye'),
  DropDownValueModel(name: 'Mihalgazi', value: 'Mihalgazi'),
  DropDownValueModel(name: 'Mihalıççık', value: 'Mihalıççık'),
  DropDownValueModel(name: 'Sarıcakaya', value: 'Sarıcakaya'),
  DropDownValueModel(name: 'Seyitgazi', value: 'Seyitgazi'),
  DropDownValueModel(name: 'Sivrihisar', value: 'Sivrihisar')
],
  'Gaziantep': const [
  DropDownValueModel(name: 'Şahinbey', value: 'Şahinbey'),
  DropDownValueModel(name: 'Şehitkamil', value: 'Şehitkamil'),
  DropDownValueModel(name: 'Diğer ilçeler', value: 'Diğer ilçeler'),
  DropDownValueModel(name: 'Araban', value: 'Araban'),
  DropDownValueModel(name: 'İslahiye', value: 'İslahiye'),
  DropDownValueModel(name: 'Karkamış', value: 'Karkamış'),
  DropDownValueModel(name: 'Nizip', value: 'Nizip'),
  DropDownValueModel(name: 'Nurdağı', value: 'Nurdağı'),
  DropDownValueModel(name: 'Oğuzeli', value: 'Oğuzeli'),
  DropDownValueModel(name: 'Yavuzeli', value: 'Yavuzeli')
],
  'Giresun': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Alucra', value: 'Alucra'),
  DropDownValueModel(name: 'Bulancak', value: 'Bulancak'),
  DropDownValueModel(name: 'Çamoluk', value: 'Çamoluk'),
  DropDownValueModel(name: 'Çanakçı', value: 'Çanakçı'),
  DropDownValueModel(name: 'Dereli', value: 'Dereli'),
  DropDownValueModel(name: 'Doğankent', value: 'Doğankent'),
  DropDownValueModel(name: 'Espiye', value: 'Espiye'),
  DropDownValueModel(name: 'Eynesil', value: 'Eynesil'),
  DropDownValueModel(name: 'Görele', value: 'Görele'),
  DropDownValueModel(name: 'Güce', value: 'Güce'),
  DropDownValueModel(name: 'Keşap', value: 'Keşap'),
  DropDownValueModel(name: 'Piraziz', value: 'Piraziz'),
  DropDownValueModel(name: 'Şebinkarahisar', value: 'Şebinkarahisar'),
  DropDownValueModel(name: 'Tirebolu', value: 'Tirebolu'),
  DropDownValueModel(name: 'Yağlıdere', value: 'Yağlıdere')
],
  'Gümüşhane': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Kelkit', value: 'Kelkit'),
  DropDownValueModel(name: 'Köse', value: 'Köse'),
  DropDownValueModel(name: 'Kürtün', value: 'Kürtün'),
  DropDownValueModel(name: 'Şiran', value: 'Şiran'),
  DropDownValueModel(name: 'Torul', value: 'Torul')
],
  'Hakkâri': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Çukurca', value: 'Çukurca'),
  DropDownValueModel(name: 'Derecik', value: 'Derecik'),
  DropDownValueModel(name: 'Şemdinli', value: 'Şemdinli'),
  DropDownValueModel(name: 'Yüksekova', value: 'Yüksekova')
],
  'Hatay': const [
  DropDownValueModel(name: 'Antakya', value: 'Antakya'),
  DropDownValueModel(name: 'Defne', value: 'Defne'),
  DropDownValueModel(name: 'Altınözü', value: 'Altınözü'),
  DropDownValueModel(name: 'Arsuz', value: 'Arsuz'),
  DropDownValueModel(name: 'Belen', value: 'Belen'),
  DropDownValueModel(name: 'Dörtyol', value: 'Dörtyol'),
  DropDownValueModel(name: 'Erzin', value: 'Erzin'),
  DropDownValueModel(name: 'Hassa', value: 'Hassa'),
  DropDownValueModel(name: 'İskenderun', value: 'İskenderun'),
  DropDownValueModel(name: 'Kırıkhan', value: 'Kırıkhan'),
  DropDownValueModel(name: 'Kumlu', value: 'Kumlu'),
  DropDownValueModel(name: 'Payas', value: 'Payas'),
  DropDownValueModel(name: 'Reyhanlı', value: 'Reyhanlı'),
  DropDownValueModel(name: 'Samandağ', value: 'Samandağ'),
  DropDownValueModel(name: 'Yayladağı', value: 'Yayladağı')
],
  'Isparta': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Aksu', value: 'Aksu'),
  DropDownValueModel(name: 'Atabey', value: 'Atabey'),
  DropDownValueModel(name: 'Eğirdir', value: 'Eğirdir'),
  DropDownValueModel(name: 'Gelendost', value: 'Gelendost'),
  DropDownValueModel(name: 'Gönen', value: 'Gönen'),
  DropDownValueModel(name: 'Keçiborlu', value: 'Keçiborlu'),
  DropDownValueModel(name: 'Senirkent', value: 'Senirkent'),
  DropDownValueModel(name: 'Sütçüler', value: 'Sütçüler'),
  DropDownValueModel(name: 'Şarkikaraağaç', value: 'Şarkikaraağaç'),
  DropDownValueModel(name: 'Uluborlu', value: 'Uluborlu'),
  DropDownValueModel(name: 'Yalvaç', value: 'Yalvaç'),
  DropDownValueModel(name: 'Yenişarbademli', value: 'Yenişarbademli')
],
  'Mersin': const [
  DropDownValueModel(name: 'Akdeniz', value: 'Akdeniz'),
  DropDownValueModel(name: 'Mezitli', value: 'Mezitli'),
  DropDownValueModel(name: 'Toroslar', value: 'Toroslar'),
  DropDownValueModel(name: 'Yenişehir', value: 'Yenişehir'),
  DropDownValueModel(name: 'Anamur', value: 'Anamur'),
  DropDownValueModel(name: 'Aydıncık', value: 'Aydıncık'),
  DropDownValueModel(name: 'Bozyazı', value: 'Bozyazı'),
  DropDownValueModel(name: 'Çamlıyayla', value: 'Çamlıyayla'),
  DropDownValueModel(name: 'Erdemli', value: 'Erdemli'),
  DropDownValueModel(name: 'Gülnar', value: 'Gülnar'),
  DropDownValueModel(name: 'Mut', value: 'Mut'),
  DropDownValueModel(name: 'Silifke', value: 'Silifke'),
  DropDownValueModel(name: 'Tarsus', value: 'Tarsus')
],
  'Istanbul': const [
  DropDownValueModel(name: 'Adalar', value: 'Adalar'),
  DropDownValueModel(name: 'Arnavutköy', value: 'Arnavutköy'),
  DropDownValueModel(name: 'Ataşehir', value: 'Ataşehir'),
  DropDownValueModel(name: 'Avcılar', value: 'Avcılar'),
  DropDownValueModel(name: 'Bağcılar', value: 'Bağcılar'),
  DropDownValueModel(name: 'Bahçelievler', value: 'Bahçelievler'),
  DropDownValueModel(name: 'Bakırköy', value: 'Bakırköy'),
  DropDownValueModel(name: 'Başakşehir', value: 'Başakşehir'),
  DropDownValueModel(name: 'Bayrampaşa', value: 'Bayrampaşa'),
  DropDownValueModel(name: 'Beşiktaş', value: 'Beşiktaş'),
  DropDownValueModel(name: 'Beykoz', value: 'Beykoz'),
  DropDownValueModel(name: 'Beylikdüzü', value: 'Beylikdüzü'),
  DropDownValueModel(name: 'Beyoğlu', value: 'Beyoğlu'),
  DropDownValueModel(name: 'Büyükçekmece', value: 'Büyükçekmece'),
  DropDownValueModel(name: 'Çatalca', value: 'Çatalca'),
  DropDownValueModel(name: 'Çekmeköy', value: 'Çekmeköy'),
  DropDownValueModel(name: 'Esenler', value: 'Esenler'),
  DropDownValueModel(name: 'Esenyurt', value: 'Esenyurt'),
  DropDownValueModel(name: 'Eyüpsultan', value: 'Eyüpsultan'),
  DropDownValueModel(name: 'Fatih', value: 'Fatih'),
  DropDownValueModel(name: 'Gaziosmanpaşa', value: 'Gaziosmanpaşa'),
  DropDownValueModel(name: 'Güngören', value: 'Güngören'),
  DropDownValueModel(name: 'Kadıköy', value: 'Kadıköy'),
  DropDownValueModel(name: 'Kağıthane', value: 'Kağıthane'),
  DropDownValueModel(name: 'Kartal', value: 'Kartal'),
  DropDownValueModel(name: 'Küçükçekmece', value: 'Küçükçekmece'),
  DropDownValueModel(name: 'Maltepe', value: 'Maltepe'),
  DropDownValueModel(name: 'Pendik', value: 'Pendik'),
  DropDownValueModel(name: 'Sancaktepe', value: 'Sancaktepe'),
  DropDownValueModel(name: 'Sarıyer', value: 'Sarıyer'),
  DropDownValueModel(name: 'Silivri', value: 'Silivri'),
  DropDownValueModel(name: 'Sultanbeyli', value: 'Sultanbeyli'),
  DropDownValueModel(name: 'Sultangazi', value: 'Sultangazi'),
  DropDownValueModel(name: 'Şile', value: 'Şile'),
  DropDownValueModel(name: 'Şişli', value: 'Şişli'),
  DropDownValueModel(name: 'Tuzla', value: 'Tuzla'),
  DropDownValueModel(name: 'Ümraniye', value: 'Ümraniye'),
  DropDownValueModel(name: 'Üsküdar', value: 'Üsküdar'),
  DropDownValueModel(name: 'Zeytinburnu', value: 'Zeytinburnu'),
],
  'İzmir': const [
  DropDownValueModel(name: 'Balçova', value: 'Balçova'),
  DropDownValueModel(name: 'Bayraklı', value: 'Bayraklı'),
  DropDownValueModel(name: 'Bornova', value: 'Bornova'),
  DropDownValueModel(name: 'Buca', value: 'Buca'),
  DropDownValueModel(name: 'Çiğli', value: 'Çiğli'),
  DropDownValueModel(name: 'Gaziemir', value: 'Gaziemir'),
  DropDownValueModel(name: 'Güzelbahçe', value: 'Güzelbahçe'),
  DropDownValueModel(name: 'Karabağlar', value: 'Karabağlar'),
  DropDownValueModel(name: 'Karşıyaka', value: 'Karşıyaka'),
  DropDownValueModel(name: 'Konak', value: 'Konak'),
  DropDownValueModel(name: 'Narlıdere', value: 'Narlıdere'),
  DropDownValueModel(name: 'Aliağa', value: 'Aliağa'),
  DropDownValueModel(name: 'Bayındır', value: 'Bayındır'),
  DropDownValueModel(name: 'Bergama', value: 'Bergama'),
  DropDownValueModel(name: 'Beydağ', value: 'Beydağ'),
  DropDownValueModel(name: 'Çeşme', value: 'Çeşme'),
  DropDownValueModel(name: 'Dikili', value: 'Dikili'),
  DropDownValueModel(name: 'Foça', value: 'Foça'),
  DropDownValueModel(name: 'Karaburun', value: 'Karaburun'),
  DropDownValueModel(name: 'Kemalpaşa', value: 'Kemalpaşa'),
  DropDownValueModel(name: 'Kınık', value: 'Kınık'),
],
  'Kars': const [
  DropDownValueModel(name: 'Kars', value: 'Kars'),
  DropDownValueModel(name: 'Akyaka', value: 'Akyaka'),
  DropDownValueModel(name: 'Arpaçay', value: 'Arpaçay'),
  DropDownValueModel(name: 'Digor', value: 'Digor'),
  DropDownValueModel(name: 'Kağızman', value: 'Kağızman'),
  DropDownValueModel(name: 'Sarıkamış', value: 'Sarıkamış'),
  DropDownValueModel(name: 'Selim', value: 'Selim'),
  DropDownValueModel(name: 'Susuz', value: 'Susuz'),
],
  'Kastamonu': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Abana', value: 'Abana'),
  DropDownValueModel(name: 'Ağlı', value: 'Ağlı'),
  DropDownValueModel(name: 'Araç', value: 'Araç'),
  DropDownValueModel(name: 'Azdavay', value: 'Azdavay'),
  DropDownValueModel(name: 'Bozkurt', value: 'Bozkurt'),
  DropDownValueModel(name: 'Cide', value: 'Cide'),
  DropDownValueModel(name: 'Çatalzeytin', value: 'Çatalzeytin'),
  DropDownValueModel(name: 'Daday', value: 'Daday'),
  DropDownValueModel(name: 'Devrekâni', value: 'Devrekâni'),
  DropDownValueModel(name: 'Doğanyurt', value: 'Doğanyurt'),
  DropDownValueModel(name: 'Hanönü', value: 'Hanönü'),
  DropDownValueModel(name: 'İhsangazi', value: 'İhsangazi'),
  DropDownValueModel(name: 'İnebolu', value: 'İnebolu'),
  DropDownValueModel(name: 'Küre', value: 'Küre'),
  DropDownValueModel(name: 'Pınarbaşı', value: 'Pınarbaşı'),
  DropDownValueModel(name: 'Seydiler', value: 'Seydiler'),
  DropDownValueModel(name: 'Şenpazar', value: 'Şenpazar'),
  DropDownValueModel(name: 'Taşköprü', value: 'Taşköprü'),
  DropDownValueModel(name: 'Tosya', value: 'Tosya'),
],
  'Kayseri': const [
  DropDownValueModel(name: 'Kocasinan', value: 'Kocasinan'),
  DropDownValueModel(name: 'Melikgazi', value: 'Melikgazi'),
  DropDownValueModel(name: 'Talas', value: 'Talas'),
  DropDownValueModel(name: 'Hacılar', value: 'Hacılar'),
  DropDownValueModel(name: 'İncesu', value: 'İncesu'),
  DropDownValueModel(name: 'Akkışla', value: 'Akkışla'),
  DropDownValueModel(name: 'Bünyan', value: 'Bünyan'),
  DropDownValueModel(name: 'Develi', value: 'Develi'),
  DropDownValueModel(name: 'Felahiye', value: 'Felahiye'),
  DropDownValueModel(name: 'Özvatan', value: 'Özvatan'),
  DropDownValueModel(name: 'Pınarbaşı', value: 'Pınarbaşı'),
  DropDownValueModel(name: 'Sarıoğlan', value: 'Sarıoğlan'),
  DropDownValueModel(name: 'Sarız', value: 'Sarız'),
  DropDownValueModel(name: 'Tomarza', value: 'Tomarza'),
  DropDownValueModel(name: 'Yahyalı', value: 'Yahyalı'),
  DropDownValueModel(name: 'Yeşilhisar', value: 'Yeşilhisar'),
],
  'Kırklareli': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Babaeski', value: 'Babaeski'),
  DropDownValueModel(name: 'Demirköy', value: 'Demirköy'),
  DropDownValueModel(name: 'Kofçaz', value: 'Kofçaz'),
  DropDownValueModel(name: 'Lüleburgaz', value: 'Lüleburgaz'),
  DropDownValueModel(name: 'Pehlivanköy', value: 'Pehlivanköy'),
  DropDownValueModel(name: 'Pınarhisar', value: 'Pınarhisar'),
  DropDownValueModel(name: 'Vize', value: 'Vize'),
],
  'Kırşehir': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Akçakent', value: 'Akçakent'),
  DropDownValueModel(name: 'Akpınar', value: 'Akpınar'),
  DropDownValueModel(name: 'Boztepe', value: 'Boztepe'),
  DropDownValueModel(name: 'Çiçekdağı', value: 'Çiçekdağı'),
  DropDownValueModel(name: 'Kaman', value: 'Kaman'),
  DropDownValueModel(name: 'Mucur', value: 'Mucur'),
],
  'Kocaeli': const [
  DropDownValueModel(name: 'Başiskele', value: 'Başiskele'),
  DropDownValueModel(name: 'İzmit', value: 'İzmit'),
  DropDownValueModel(name: 'Kartepe', value: 'Kartepe'),
  DropDownValueModel(name: 'Derince', value: 'Derince'),
  DropDownValueModel(name: 'Gölcük', value: 'Gölcük'),
  DropDownValueModel(name: 'Körfez', value: 'Körfez'),
  DropDownValueModel(name: 'Çayırova', value: 'Çayırova'),
  DropDownValueModel(name: 'Darıca', value: 'Darıca'),
  DropDownValueModel(name: 'Dilovası', value: 'Dilovası'),
  DropDownValueModel(name: 'Gebze', value: 'Gebze'),
  DropDownValueModel(name: 'Kandıra', value: 'Kandıra'),
  DropDownValueModel(name: 'Karamürsel', value: 'Karamürsel'),
],
  'Konya': const [
  DropDownValueModel(name: 'Akören', value: 'Akören'),
  DropDownValueModel(name: 'Akşehir', value: 'Akşehir'),
  DropDownValueModel(name: 'Altınekin', value: 'Altınekin'),
  DropDownValueModel(name: 'Beyşehir', value: 'Beyşehir'),
  DropDownValueModel(name: 'Bozkır', value: 'Bozkır'),
  DropDownValueModel(name: 'Cihanbeyli', value: 'Cihanbeyli'),
  DropDownValueModel(name: 'Çeltik', value: 'Çeltik'),
  DropDownValueModel(name: 'Çumra', value: 'Çumra'),
  DropDownValueModel(name: 'Derbent', value: 'Derbent'),
  DropDownValueModel(name: 'Derebucak', value: 'Derebucak'),
  DropDownValueModel(name: 'Doğanhisar', value: 'Doğanhisar'),
  DropDownValueModel(name: 'Emirgazi', value: 'Emirgazi'),
  DropDownValueModel(name: 'Ereğli', value: 'Ereğli'),
  DropDownValueModel(name: 'Güneysınır', value: 'Güneysınır'),
  DropDownValueModel(name: 'Hadim', value: 'Hadim'),
  DropDownValueModel(name: 'Halkapınar', value: 'Halkapınar'),
  DropDownValueModel(name: 'Hüyük', value: 'Hüyük'),
  DropDownValueModel(name: 'Ilgın', value: 'Ilgın'),
  DropDownValueModel(name: 'Kadınhanı', value: 'Kadınhanı'),
  DropDownValueModel(name: 'Karapınar', value: 'Karapınar'),
  DropDownValueModel(name: 'Karatay', value: 'Karatay'),
  DropDownValueModel(name: 'Kulu', value: 'Kulu'),
  DropDownValueModel(name: 'Meram', value: 'Meram'),
  DropDownValueModel(name: 'Sarayönü', value: 'Sarayönü'),
  DropDownValueModel(name: 'Selçuklu', value: 'Selçuklu'),
  DropDownValueModel(name: 'Seydişehir', value: 'Seydişehir'),
  DropDownValueModel(name: 'Taşkent', value: 'Taşkent'),
  DropDownValueModel(name: 'Tuzlukçu', value: 'Tuzlukçu'),
  DropDownValueModel(name: 'Yalıhüyük', value: 'Yalıhüyük'),
  DropDownValueModel(name: 'Yunak', value: 'Yunak'),
  ],
  'Kütahya': const [
  DropDownValueModel(name: 'Altıntaş', value: 'Altıntaş'),
  DropDownValueModel(name: 'Aslanapa', value: 'Aslanapa'),
  DropDownValueModel(name: 'Çavdarhisar', value: 'Çavdarhisar'),
  DropDownValueModel(name: 'Domaniç', value: 'Domaniç'),
  DropDownValueModel(name: 'Dumlupınar', value: 'Dumlupınar'),
  DropDownValueModel(name: 'Emet', value: 'Emet'),
  DropDownValueModel(name: 'Gediz', value: 'Gediz'),
  DropDownValueModel(name: 'Hisarcık', value: 'Hisarcık'),
  DropDownValueModel(name: 'Pazarlar', value: 'Pazarlar'),
  DropDownValueModel(name: 'Simav', value: 'Simav'),
  DropDownValueModel(name: 'Şaphane', value: 'Şaphane'),
  DropDownValueModel(name: 'Tavşanlı', value: 'Tavşanlı'),
  ],
  'Malatya': const [
  DropDownValueModel(name: 'Battalgazi', value: 'Battalgazi'),
  DropDownValueModel(name: 'Yeşilyurt', value: 'Yeşilyurt'),
  DropDownValueModel(name: 'Akçadağ', value: 'Akçadağ'),
  DropDownValueModel(name: 'Arapgir', value: 'Arapgir'),
  DropDownValueModel(name: 'Arguvan', value: 'Arguvan'),
  DropDownValueModel(name: 'Darende', value: 'Darende'),
  DropDownValueModel(name: 'Doğanşehir', value: 'Doğanşehir'),
  DropDownValueModel(name: 'Doğanyol', value: 'Doğanyol'),
  DropDownValueModel(name: 'Hekimhan', value: 'Hekimhan'),
  DropDownValueModel(name: 'Kale', value: 'Kale'),
  DropDownValueModel(name: 'Kuluncak', value: 'Kuluncak'),
  DropDownValueModel(name: 'Pütürge', value: 'Pütürge'),
  DropDownValueModel(name: 'Yazıhan', value: 'Yazıhan'),
  ],
  'Manisa': const [
  DropDownValueModel(name: 'Şehzadeler', value: 'Şehzadeler'),
  DropDownValueModel(name: 'Yunusemre', value: 'Yunusemre'),
  DropDownValueModel(name: 'Ahmetli', value: 'Ahmetli'),
  DropDownValueModel(name: 'Akhisar', value: 'Akhisar'),
  DropDownValueModel(name: 'Alaşehir', value: 'Alaşehir'),
  DropDownValueModel(name: 'Demirci', value: 'Demirci'),
  DropDownValueModel(name: 'Gölmarmara', value: 'Gölmarmara'),
  DropDownValueModel(name: 'Gördes', value: 'Gördes'),
  DropDownValueModel(name: 'Kırkağaç', value: 'Kırkağaç'),
  DropDownValueModel(name: 'Köprübaşı', value: 'Köprübaşı'),
  DropDownValueModel(name: 'Kula', value: 'Kula'),
  DropDownValueModel(name: 'Salihli', value: 'Salihli'),
  DropDownValueModel(name: 'Sarıgöl', value: 'Sarıgöl'),
  DropDownValueModel(name: 'Saruhanlı', value: 'Saruhanlı'),
  DropDownValueModel(name: 'Selendi', value: 'Selendi'),
  DropDownValueModel(name: 'Soma', value: 'Soma'),
  DropDownValueModel(name: 'Turgutlu', value: 'Turgutlu'),
  ],
  'Kahramanmaraş': const [
  DropDownValueModel(name: 'Dulkadiroğlu', value: 'Dulkadiroğlu'),
  DropDownValueModel(name: 'Onikişubat', value: 'Onikişubat'),
  DropDownValueModel(name: 'Afşin', value: 'Afşin'),
  DropDownValueModel(name: 'Andırın', value: 'Andırın'),
  DropDownValueModel(name: 'Çağlayancerit', value: 'Çağlayancerit'),
  DropDownValueModel(name: 'Ekinözü', value: 'Ekinözü'),
  DropDownValueModel(name: 'Elbistan', value: 'Elbistan'),
  DropDownValueModel(name: 'Göksun', value: 'Göksun'),
  DropDownValueModel(name: 'Nurhak', value: 'Nurhak'),
  DropDownValueModel(name: 'Pazarcık', value: 'Pazarcık'),
  DropDownValueModel(name: 'Türkoğlu', value: 'Türkoğlu'),
  ],
  'Mardin': const [
  DropDownValueModel(name: 'Artuklu', value: 'Artuklu'),
  DropDownValueModel(name: 'Dargeçit', value: 'Dargeçit'),
  DropDownValueModel(name: 'Derik', value: 'Derik'),
  DropDownValueModel(name: 'Kızıltepe', value: 'Kızıltepe'),
  DropDownValueModel(name: 'Mazıdağı', value: 'Mazıdağı'),
  DropDownValueModel(name: 'Midyat', value: 'Midyat'),
  DropDownValueModel(name: 'Nusaybin', value: 'Nusaybin'),
  DropDownValueModel(name: 'Ömerli', value: 'Ömerli'),
  DropDownValueModel(name: 'Savur', value: 'Savur'),
  DropDownValueModel(name: 'Yeşilli', value: 'Yeşilli'),
  ],
  'Muğla': const [
  DropDownValueModel(name: 'Menteşe', value: 'Menteşe'),
  DropDownValueModel(name: 'Bodrum', value: 'Bodrum'),
  DropDownValueModel(name: 'Dalaman', value: 'Dalaman'),
  DropDownValueModel(name: 'Datça', value: 'Datça'),
  DropDownValueModel(name: 'Fethiye', value: 'Fethiye'),
  DropDownValueModel(name: 'Kavaklıdere', value: 'Kavaklıdere'),
  DropDownValueModel(name: 'Köyceğiz', value: 'Köyceğiz'),
  DropDownValueModel(name: 'Marmaris', value: 'Marmaris'),
  DropDownValueModel(name: 'Milas', value: 'Milas'),
  DropDownValueModel(name: 'Ortaca', value: 'Ortaca'),
  DropDownValueModel(name: 'Seydikemer', value: 'Seydikemer'),
  DropDownValueModel(name: 'Ula', value: 'Ula'),
  DropDownValueModel(name: 'Yatağan', value: 'Yatağan'),
  ],
  'Muş': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Bulanık', value: 'Bulanık'),
  DropDownValueModel(name: 'Hasköy', value: 'Hasköy'),
  DropDownValueModel(name: 'Korkut', value: 'Korkut'),
  DropDownValueModel(name: 'Malazgirt', value: 'Malazgirt'),
  DropDownValueModel(name: 'Varto', value: 'Varto'),
  ],
  'Nevşehir': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Acıgöl', value: 'Acıgöl'),
  DropDownValueModel(name: 'Avanos', value: 'Avanos'),
  DropDownValueModel(name: 'Derinkuyu', value: 'Derinkuyu'),
  DropDownValueModel(name: 'Gülşehir', value: 'Gülşehir'),
  DropDownValueModel(name: 'Hacıbektaş', value: 'Hacıbektaş'),
  DropDownValueModel(name: 'Kozaklı', value: 'Kozaklı'),
  DropDownValueModel(name: 'Ürgüp', value: 'Ürgüp')
  ],
  'Niğde': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Altunhisar', value: 'Altunhisar'),
  DropDownValueModel(name: 'Bor', value: 'Bor'),
  DropDownValueModel(name: 'Çamardı', value: 'Çamardı'),
  DropDownValueModel(name: 'Çiftlik', value: 'Çiftlik'),
  DropDownValueModel(name: 'Ulukışla', value: 'Ulukışla')
],
  'Ordu': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Akkuş', value: 'Akkuş'),
  DropDownValueModel(name: 'Aybastı', value: 'Aybastı'),
  DropDownValueModel(name: 'Çamaş', value: 'Çamaş'),
  DropDownValueModel(name: 'Çatalpınar', value: 'Çatalpınar'),
  DropDownValueModel(name: 'Çaybaşı', value: 'Çaybaşı'),
  DropDownValueModel(name: 'Fatsa', value: 'Fatsa'),
  DropDownValueModel(name: 'Gölköy', value: 'Gölköy'),
  DropDownValueModel(name: 'Gülyalı', value: 'Gülyalı'),
  DropDownValueModel(name: 'Gürgentepe', value: 'Gürgentepe'),
  DropDownValueModel(name: 'İkizce', value: 'İkizce'),
  DropDownValueModel(name: 'Kabadüz', value: 'Kabadüz'),
  DropDownValueModel(name: 'Kabataş', value: 'Kabataş'),
  DropDownValueModel(name: 'Korgan', value: 'Korgan'),
  DropDownValueModel(name: 'Kumru', value: 'Kumru'),
  DropDownValueModel(name: 'Mesudiye', value: 'Mesudiye'),
  DropDownValueModel(name: 'Perşembe', value: 'Perşembe'),
  DropDownValueModel(name: 'Ulubey', value: 'Ulubey'),
  DropDownValueModel(name: 'Ünye', value: 'Ünye')
  ],
  'Rize': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Ardeşen', value: 'Ardeşen'),
  DropDownValueModel(name: 'Çamlıhemşin', value: 'Çamlıhemşin'),
  DropDownValueModel(name: 'Çayeli', value: 'Çayeli'),
  DropDownValueModel(name: 'Derepazarı', value: 'Derepazarı'),
  DropDownValueModel(name: 'Fındıklı', value: 'Fındıklı'),
  DropDownValueModel(name: 'Güneysu', value: 'Güneysu'),
  DropDownValueModel(name: 'Hemşin', value: 'Hemşin'),
  DropDownValueModel(name: 'İkizdere', value: 'İkizdere'),
  DropDownValueModel(name: 'İyidere', value: 'İyidere'),
  DropDownValueModel(name: 'Kalkandere', value: 'Kalkandere'),
  DropDownValueModel(name: 'Pazar', value: 'Pazar'),
],
'Sakarya': const [
  DropDownValueModel(name: 'Adapazarı', value: 'Adapazarı'),
  DropDownValueModel(name: 'Arifiye', value: 'Arifiye'),
  DropDownValueModel(name: 'Erenler', value: 'Erenler'),
  DropDownValueModel(name: 'Serdivan', value: 'Serdivan'),
  DropDownValueModel(name: 'Akyazı', value: 'Akyazı'),
  DropDownValueModel(name: 'Ferizli', value: 'Ferizli'),
  DropDownValueModel(name: 'Geyve', value: 'Geyve'),
  DropDownValueModel(name: 'Hendek', value: 'Hendek'),
  DropDownValueModel(name: 'Karapürçek', value: 'Karapürçek'),
  DropDownValueModel(name: 'Karasu', value: 'Karasu'),
  DropDownValueModel(name: 'Kaynarca', value: 'Kaynarca'),
  DropDownValueModel(name: 'Kocaali', value: 'Kocaali'),
  DropDownValueModel(name: 'Pamukova', value: 'Pamukova'),
  DropDownValueModel(name: 'Sapanca', value: 'Sapanca'),
  DropDownValueModel(name: 'Söğütlü', value: 'Söğütlü'),
  DropDownValueModel(name: 'Taraklı', value: 'Taraklı'),
],
  'Samsun': const [
  DropDownValueModel(name: 'Atakum', value: 'Atakum'),
  DropDownValueModel(name: 'Canik', value: 'Canik'),
  DropDownValueModel(name: 'İlkadım', value: 'İlkadım'),
  DropDownValueModel(name: 'Tekkeköy', value: 'Tekkeköy'),
  DropDownValueModel(name: '19 Mayıs', value: '19 Mayıs'),
  DropDownValueModel(name: 'Alaçam', value: 'Alaçam'),
  DropDownValueModel(name: 'Asarcık', value: 'Asarcık'),
  DropDownValueModel(name: 'Ayvacık', value: 'Ayvacık'),
  DropDownValueModel(name: 'Bafra', value: 'Bafra'),
  DropDownValueModel(name: 'Çarşamba', value: 'Çarşamba'),
  DropDownValueModel(name: 'Havza', value: 'Havza'),
  DropDownValueModel(name: 'Kavak', value: 'Kavak'),
  DropDownValueModel(name: 'Ladik', value: 'Ladik'),
  DropDownValueModel(name: 'Salıpazarı', value: 'Salıpazarı'),
  DropDownValueModel(name: 'Terme', value: 'Terme'),
  DropDownValueModel(name: 'Vezirköprü', value: 'Vezirköprü'),
  DropDownValueModel(name: 'Yakakent', value: 'Yakakent'),
],
  'Siirt': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Baykan', value: 'Baykan'),
  DropDownValueModel(name: 'Eruh', value: 'Eruh'),
  DropDownValueModel(name: 'Kurtalan', value: 'Kurtalan'),
  DropDownValueModel(name: 'Pervari', value: 'Pervari'),
  DropDownValueModel(name: 'Şirvan', value: 'Şirvan'),
  DropDownValueModel(name: 'Tillo', value: 'Tillo'),
],
  'Sinop': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Ayancık', value: 'Ayancık'),
  DropDownValueModel(name: 'Boyabat', value: 'Boyabat'),
  DropDownValueModel(name: 'Dikmen', value: 'Dikmen'),
  DropDownValueModel(name: 'Durağan', value: 'Durağan'),
  DropDownValueModel(name: 'Erfelek', value: 'Erfelek'),
  DropDownValueModel(name: 'Gerze', value: 'Gerze'),
  DropDownValueModel(name: 'Saraydüzü', value: 'Saraydüzü'),
  DropDownValueModel(name: 'Türkeli', value: 'Türkeli'),
],
  'Sivas': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Akıncılar', value: 'Akıncılar'),
  DropDownValueModel(name: 'Altınyayla', value: 'Altınyayla'),
  DropDownValueModel(name: 'Divriği', value: 'Divriği'),
  DropDownValueModel(name: 'Doğanşar', value: 'Doğanşar'),
  DropDownValueModel(name: 'Gemerek', value: 'Gemerek'),
  DropDownValueModel(name: 'Gölova', value: 'Gölova'),
  DropDownValueModel(name: 'Gürün', value: 'Gürün'),
  DropDownValueModel(name: 'Hafik', value: 'Hafik'),
  DropDownValueModel(name: 'İmranlı', value: 'İmranlı'),
  DropDownValueModel(name: 'Kangal', value: 'Kangal'),
  DropDownValueModel(name: 'Koyulhisar', value: 'Koyulhisar'),
  DropDownValueModel(name: 'Suşehri', value: 'Suşehri'),
  DropDownValueModel(name: 'Şarkışla', value: 'Şarkışla'),
  DropDownValueModel(name: 'Ulaş', value: 'Ulaş'),
  DropDownValueModel(name: 'Yıldızeli', value: 'Yıldızeli'),
  DropDownValueModel(name: 'Zara', value: 'Zara'),
],
  'Tekirdağ': const [
  DropDownValueModel(name: 'Süleymanpaşa', value: 'Süleymanpaşa'),
  DropDownValueModel(name: 'Çerkezköy', value: 'Çerkezköy'),
  DropDownValueModel(name: 'Çorlu', value: 'Çorlu'),
  DropDownValueModel(name: 'Ergene', value: 'Ergene'),
  DropDownValueModel(name: 'Hayrabolu', value: 'Hayrabolu'),
  DropDownValueModel(name: 'Kapaklı', value: 'Kapaklı'),
  DropDownValueModel(name: 'Malkara', value: 'Malkara'),
  DropDownValueModel(name: 'Marmaraereğlisi', value: 'Marmaraereğlisi'),
  DropDownValueModel(name: 'Muratlı', value: 'Muratlı'),
  DropDownValueModel(name: 'Saray', value: 'Saray'),
  DropDownValueModel(name: 'Şarköy', value: 'Şarköy'),
  ],
  'Tokat': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Almus', value: 'Almus'),
  DropDownValueModel(name: 'Artova', value: 'Artova'),
  DropDownValueModel(name: 'Başçiftlik', value: 'Başçiftlik'),
  DropDownValueModel(name: 'Erbaa', value: 'Erbaa'),
  DropDownValueModel(name: 'Niksar', value: 'Niksar'),
  DropDownValueModel(name: 'Pazar', value: 'Pazar'),
  DropDownValueModel(name: 'Reşadiye', value: 'Reşadiye'),
  DropDownValueModel(name: 'Sulusaray', value: 'Sulusaray'),
  DropDownValueModel(name: 'Turhal', value: 'Turhal'),
  DropDownValueModel(name: 'Yeşilyurt', value: 'Yeşilyurt'),
  DropDownValueModel(name: 'Zile', value: 'Zile'),
],
  'Trabzon': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Akçaabat', value: 'Akçaabat'),
  DropDownValueModel(name: 'Araklı', value: 'Araklı'),
  DropDownValueModel(name: 'Arsin', value: 'Arsin'),
  DropDownValueModel(name: 'Beşikdüzü', value: 'Beşikdüzü'),
  DropDownValueModel(name: 'Çarşıbaşı', value: 'Çarşıbaşı'),
  DropDownValueModel(name: 'Çaykara', value: 'Çaykara'),
  DropDownValueModel(name: 'Dernekpazarı', value: 'Dernekpazarı'),
  DropDownValueModel(name: 'Düzköy', value: 'Düzköy'),
  DropDownValueModel(name: 'Hayrat', value: 'Hayrat'),
  DropDownValueModel(name: 'Köprübaşı', value: 'Köprübaşı'),
  DropDownValueModel(name: 'Maçka', value: 'Maçka'),
  DropDownValueModel(name: 'Of', value: 'Of'),
  DropDownValueModel(name: 'Sürmene', value: 'Sürmene'),
  DropDownValueModel(name: 'Şalpazarı', value: 'Şalpazarı'),
  DropDownValueModel(name: 'Tonya', value: 'Tonya'),
  DropDownValueModel(name: 'Vakfıkebir', value: 'Vakfıkebir'),
  DropDownValueModel(name: 'Yomra', value: 'Yomra'),
],
  'Tunceli': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Çemişgezek', value: 'Çemişgezek'),
  DropDownValueModel(name: 'Hozat', value: 'Hozat'),
  DropDownValueModel(name: 'Mazgirt', value: 'Mazgirt'),
  DropDownValueModel(name: 'Nazımiye', value: 'Nazımiye'),
  DropDownValueModel(name: 'Ovacık', value: 'Ovacık'),
  DropDownValueModel(name: 'Pertek', value: 'Pertek'),
  DropDownValueModel(name: 'Pülümür', value: 'Pülümür'),
  ],
  'Şanlıurfa': const [
  DropDownValueModel(name: 'Eyyübiye', value: 'Eyyübiye'),
  DropDownValueModel(name: 'Haliliye', value: 'Haliliye'),
  DropDownValueModel(name: 'Karaköprü', value: 'Karaköprü'),
  DropDownValueModel(name: 'Akçakale', value: 'Akçakale'),
  DropDownValueModel(name: 'Birecik', value: 'Birecik'),
  DropDownValueModel(name: 'Bozova', value: 'Bozova'),
  DropDownValueModel(name: 'Ceylanpınar', value: 'Ceylanpınar'),
  DropDownValueModel(name: 'Halfeti', value: 'Halfeti'),
  DropDownValueModel(name: 'Harran', value: 'Harran'),
  DropDownValueModel(name: 'Hilvan', value: 'Hilvan'),
  DropDownValueModel(name: 'Siverek', value: 'Siverek'),
  DropDownValueModel(name: 'Suruç', value: 'Suruç'),
  DropDownValueModel(name: 'Viranşehir', value: 'Viranşehir'),
],
  'Uşak': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Banaz', value: 'Banaz'),
  DropDownValueModel(name: 'Eşme', value: 'Eşme'),
  DropDownValueModel(name: 'Karahallı', value: 'Karahallı'),
  DropDownValueModel(name: 'Sivaslı', value: 'Sivaslı'),
  DropDownValueModel(name: 'Ulubey', value: 'Ulubey'),
],
  'Van': const [
  DropDownValueModel(name: 'Edremit', value: 'Edremit'),
  DropDownValueModel(name: 'İpekyolu', value: 'İpekyolu'),
  DropDownValueModel(name: 'Tuşba', value: 'Tuşba'),
  DropDownValueModel(name: 'Bahçesaray', value: 'Bahçesaray'),
  DropDownValueModel(name: 'Başkale', value: 'Başkale'),
  DropDownValueModel(name: 'Çaldıran', value: 'Çaldıran'),
  DropDownValueModel(name: 'Çatak', value: 'Çatak'),
  DropDownValueModel(name: 'Erciş', value: 'Erciş'),
  DropDownValueModel(name: 'Gevaş', value: 'Gevaş'),
  DropDownValueModel(name: 'Gürpınar', value: 'Gürpınar'),
  DropDownValueModel(name: 'Muradiye', value: 'Muradiye'),
  DropDownValueModel(name: 'Özalp', value: 'Özalp'),
  DropDownValueModel(name: 'Saray', value: 'Saray'),
],
  'Yozgat': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Akdağmadeni', value: 'Akdağmadeni'),
  DropDownValueModel(name: 'Aydıncık', value: 'Aydıncık'),
  DropDownValueModel(name: 'Boğazlıyan', value: 'Boğazlıyan'),
  DropDownValueModel(name: 'Çandır', value: 'Çandır'),
  DropDownValueModel(name: 'Çayıralan', value: 'Çayıralan'),
  DropDownValueModel(name: 'Çekerek', value: 'Çekerek'),
  DropDownValueModel(name: 'Kadışehri', value: 'Kadışehri'),
  DropDownValueModel(name: 'Saraykent', value: 'Saraykent'),
  DropDownValueModel(name: 'Sarıkaya', value: 'Sarıkaya'),
  DropDownValueModel(name: 'Sorgun', value: 'Sorgun'),
  DropDownValueModel(name: 'Şefaatli', value: 'Şefaatli'),
  DropDownValueModel(name: 'Yenifakılı', value: 'Yenifakılı'),
  DropDownValueModel(name: 'Yerköy', value: 'Yerköy'),
],
  'Zonguldak': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Alaplı', value: 'Alaplı'),
  DropDownValueModel(name: 'Çaycuma', value: 'Çaycuma'),
  DropDownValueModel(name: 'Devrek', value: 'Devrek'),
  DropDownValueModel(name: 'Gökçebey', value: 'Gökçebey'),
  DropDownValueModel(name: 'Karadeniz Ereğli', value: 'Karadeniz Ereğli'),
  DropDownValueModel(name: 'Kilimli', value: 'Kilimli'),
  DropDownValueModel(name: 'Kozlu', value: 'Kozlu'),
],
  'Aksaray': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Ağaçören', value: 'Ağaçören'),
  DropDownValueModel(name: 'Eskil', value: 'Eskil'),
  DropDownValueModel(name: 'Gülağaç', value: 'Gülağaç'),
  DropDownValueModel(name: 'Güzelyurt', value: 'Güzelyurt'),
  DropDownValueModel(name: 'Ortaköy', value: 'Ortaköy'),
  DropDownValueModel(name: 'Sarıyahşi', value: 'Sarıyahşi'),
  DropDownValueModel(name: 'Sultanhanı', value: 'Sultanhanı'),
],
  'Bayburt': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Aydıntepe', value: 'Aydıntepe'),
  DropDownValueModel(name: 'Demirözü', value: 'Demirözü'),
],
  'Karaman': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Ayrancı', value: 'Ayrancı'),
  DropDownValueModel(name: 'Başyayla', value: 'Başyayla'),
  DropDownValueModel(name: 'Ermenek', value: 'Ermenek'),
  DropDownValueModel(name: 'Kazımkarabekir', value: 'Kazımkarabekir'),
  DropDownValueModel(name: 'Sarıveliler', value: 'Sarıveliler'),
],
  'Kırıkkale': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Bahşılı', value: 'Bahşılı'),
  DropDownValueModel(name: 'Balışeyh', value: 'Balışeyh'),
  DropDownValueModel(name: 'Çelebi', value: 'Çelebi'),
  DropDownValueModel(name: 'Delice', value: 'Delice'),
  DropDownValueModel(name: 'Karakeçili', value: 'Karakeçili'),
  DropDownValueModel(name: 'Keskin', value: 'Keskin'),
  DropDownValueModel(name: 'Sulakyurt', value: 'Sulakyurt'),
  DropDownValueModel(name: 'Yahşihan', value: 'Yahşihan'),
],
  'Batman': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Beşiri', value: 'Beşiri'),
  DropDownValueModel(name: 'Gercüş', value: 'Gercüş'),
  DropDownValueModel(name: 'Hasankeyf', value: 'Hasankeyf'),
  DropDownValueModel(name: 'Kozluk', value: 'Kozluk'),
  DropDownValueModel(name: 'Sason', value: 'Sason'),
],
  'Şırnak': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Beytüşşebap', value: 'Beytüşşebap'),
  DropDownValueModel(name: 'Cizre', value: 'Cizre'),
  DropDownValueModel(name: 'Güçlükonak', value: 'Güçlükonak'),
  DropDownValueModel(name: 'İdil', value: 'İdil'),
  DropDownValueModel(name: 'Silopi', value: 'Silopi'),
  DropDownValueModel(name: 'Uludere', value: 'Uludere'),
],
  'Bartın': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Amasra', value: 'Amasra'),
  DropDownValueModel(name: 'Kurucaşile', value: 'Kurucaşile'),
  DropDownValueModel(name: 'Ulus', value: 'Ulus'),
],
  'Ardahan': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Çıldır', value: 'Çıldır'),
  DropDownValueModel(name: 'Damal', value: 'Damal'),
  DropDownValueModel(name: 'Göle', value: 'Göle'),
  DropDownValueModel(name: 'Hanak', value: 'Hanak'),
  DropDownValueModel(name: 'Posof', value: 'Posof'),
],
'Iğdır': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Aralık', value: 'Aralık'),
  DropDownValueModel(name: 'Karakoyunlu', value: 'Karakoyunlu'),
  DropDownValueModel(name: 'Tuzluca', value: 'Tuzluca'),
],
  'Yalova': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Altınova', value: 'Altınova'),
  DropDownValueModel(name: 'Armutlu', value: 'Armutlu'),
  DropDownValueModel(name: 'Çınarcık', value: 'Çınarcık'),
  DropDownValueModel(name: 'Çiftlikköy', value: 'Çiftlikköy'),
  DropDownValueModel(name: 'Termal', value: 'Termal'),
],
  'Karabük': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Eflani', value: 'Eflani'),
  DropDownValueModel(name: 'Eskipazar', value: 'Eskipazar'),
  DropDownValueModel(name: 'Ovacık', value: 'Ovacık'),
  DropDownValueModel(name: 'Safranbolu', value: 'Safranbolu'),
  DropDownValueModel(name: 'Yenice', value: 'Yenice'),
],
  'Kilis': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Elbeyli', value: 'Elbeyli'),
  DropDownValueModel(name: 'Musabeyli', value: 'Musabeyli'),
  DropDownValueModel(name: 'Polateli', value: 'Polateli'),
],
  'Osmaniye': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Bahçe', value: 'Bahçe'),
  DropDownValueModel(name: 'Düziçi', value: 'Düziçi'),
  DropDownValueModel(name: 'Hasanbeyli', value: 'Hasanbeyli'),
  DropDownValueModel(name: 'Kadirli', value: 'Kadirli'),
  DropDownValueModel(name: 'Sumbas', value: 'Sumbas'),
  DropDownValueModel(name: 'Toprakkale', value: 'Toprakkale'),
],
  'Düzce': const [
  DropDownValueModel(name: 'Merkez', value: 'Merkez'),
  DropDownValueModel(name: 'Akçakoca', value: 'Akçakoca'),
  DropDownValueModel(name: 'Cumayeri', value: 'Cumayeri'),
  DropDownValueModel(name: 'Çilimli', value: 'Çilimli'),
  DropDownValueModel(name: 'Gölyaka', value: 'Gölyaka'),
  DropDownValueModel(name: 'Gümüşova', value: 'Gümüşova'),
  DropDownValueModel(name: 'Kaynaşlı', value: 'Kaynaşlı'),
  DropDownValueModel(name: 'Yığılca', value: 'Yığılca'),
],
};

// Function to update the dropdown menu options based on the selected city
void updateDistrictOptions(String? city) {
  if (city != null && cityDistricts.containsKey(city)) {
    districtOptions = cityDistricts[city];
    // Update selected district if it's not in the new options
    if (districtOptions != null && !districtOptions!.contains(selectedDistrict)) {
      selectedDistrict = null;
    }
  } else {
    districtOptions = null;
    selectedDistrict = null;
  }
}


  @override
  void initState() {
    super.initState();
    _cnt = SingleValueDropDownController();
    _cnt2 = SingleValueDropDownController();
  }

  @override
  void dispose() {
    super.dispose();
    // veriyi cloud a yolladıktan sonra hepsini sil
    _controller.dispose();
    sellerName.dispose();
    sellerLastName.dispose();
    sellerAge.dispose();
    sellerHeight.dispose();
    sellerWeight.dispose();
    sellerPrice.dispose();
  }

  void _clearImageandText() {
    if (mounted) {
      setState(() {
        imageFileList.clear();
        sellerName.clear();
        sellerLastName.clear();
        sellerAge.clear();
        sellerHeight.clear();
        sellerWeight.clear();
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
                                  Text(
                                    "Fotoğraf",
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
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  child: Expanded(
                                                    child: CarouselSlider(
                                                      options: CarouselOptions(
                                                        aspectRatio: 1,
                                                        viewportFraction: 1,
                                                        enableInfiniteScroll:
                                                            false,
                                                        padEnds: false,
                                                        initialPage:
                                                            currentIndex,
                                                      ),
                                                      items: imageFileList
                                                          .map<Widget>(
                                                              (imageFile) {
                                                        return Builder(
                                                          builder: (BuildContext
                                                              context) {
                                                            return Image.file(
                                                                File(imageFile
                                                                    .path),
                                                                fit: BoxFit
                                                                    .cover);
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
                    "Ad",
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: sellerName,
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
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Soyad",
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: sellerLastName,
                  validator: (lastname) {
                    if (lastname == null || lastname.isEmpty) {
                      return "Boş bırakılamaz !";
                    }
                    return null;
                  },
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w300),
                  decoration: InputDecoration(
                      hintText: "Soyadınızı Giriniz",
                      hintStyle: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w300),
                      fillColor: sellergrey,
                      filled: true,
                      contentPadding: const EdgeInsets.all(10)),
                ),
                const SizedBox(height: 40),
                Container(
                  color: sellergrey,
                  width: double.infinity,
                  height: 100,
                  child: Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            children: [
                              Text(
                                "Yaş",
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  color: Colors.white,
                                  width: 60,
                                  height: 40,
                                  child: TextFormField(
                                    controller: sellerAge,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    validator: (age) {
                                      if (age == null || age.isEmpty) {
                                        return "Boş bırakılamaz !";
                                      }
                                      return null;
                                    },
                                    style: GoogleFonts.inter(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            children: [
                              Text(
                                "Boy",
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  color: Colors.white,
                                  width: 60,
                                  height: 40,
                                  child: TextFormField(
                                    controller: sellerHeight,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    validator: (height) {
                                      if (height == null || height.isEmpty) {
                                        return "Boş bırakılamaz !";
                                      }
                                      return null;
                                    },
                                    style: GoogleFonts.inter(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            children: [
                              Text(
                                "Kilo",
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  color: sellerwhite,
                                  width: 60,
                                  height: 40,
                                  child: TextFormField(
                                    controller: sellerWeight,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    validator: (weight) {
                                      if (weight == null || weight.isEmpty) {
                                        return "Boş bırakılamaz !";
                                      }
                                      return null;
                                    },
                                    style: GoogleFonts.inter(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                    child: DropDownTextField(
                      controller: _cnt,
                      clearOption: false,
                      textFieldDecoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none,
                          hintText: "Şehir seçiniz",
                          hintStyle: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: Colors.white)),
                      validator: (value) {
                        if (value == null) {
                          return "Zorunlu alan";
                        } else {
                          return null;
                        }
                      },
                      dropDownItemCount: 6,
                      dropDownList: cityDistricts.keys.map((city) => DropDownValueModel(name: city, value: city)).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedCity = val.value;
                          updateDistrictOptions(selectedCity);
                        });
                      },
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
                    child: DropDownTextField(
                      controller: _cnt2,
                      clearOption: false,
                      // inital value yoktu onu ekledim
                      //initialValue: selectedDistrict,
                      textFieldDecoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none,
                          hintText: "İlçe seçiniz",
                          hintStyle: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: Colors.white)),
                      validator: (value) {
                        if (value == null) {
                          return "Zorunlu alan";
                        } else {
                          return null;
                        }
                      },
                      dropDownItemCount: 6,
                      dropDownList: districtOptions ?? [],
                      onChanged: (val2) {
                        setState(() {
                          selectedDistrict = val2.value;
                        });
                      },
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
                          await _insertSellerDetails();
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
/*
  int _countWords(String text) {
    // Split the text by whitespace and count the words
    return text.trim().split(RegExp(r'\s+')).length;
  }
*/

  void _removeImage(int index) {
    setState(() {
      imageFileList.removeAt(index);
    });
  }

  String _trimToMaxWords(String text) {
    // Trim the text to the maximum number of words
    List<String> words = text.trim().split(RegExp(r'\s+'));
    return words.take(maxWords).join(' ');
  }

  Future _pickImageFromGallery() async {
    final List<XFile> selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      imageFileList.addAll(selectedImages);
    }
    setState(() {});
  }

  Future<void> _insertSellerDetails() async {
    // Bilgiler eksiksiz ise verileri firestore a gönder
    if (_formKey.currentState!.validate()) {
      try {
        String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
        if (userId.isNotEmpty) {
          List<String> imageUrls = await _uploadImagesToStorage();
          
          // burası saatleri yüklemek için
          Map<String,dynamic> formattedData= {};
          // day = key in the selectedHoursByday (e.g: Pazartesi,Salı,Çarşamba..)
          // selectedHours = list of 'CheckContainerModel' associated to each day
          _AmenitiesState.selectedHoursByDay.forEach((day, selectedHours) { 
            if (selectedHours.isNotEmpty) {
              formattedData[day] = selectedHours.map((hour) => hour.title).toList();
            }
          }); 
          print('THE DATA IS $formattedData');

          Map<String, dynamic> sellerDetails = {
            "sellerName": sellerName.text,
            "sellerLastName": sellerLastName.text,
            "sellerAge": sellerAge.text,
            "sellerHeight": sellerHeight.text,
            "sellerWeight": sellerWeight.text,
            "sellerPrice": sellerPrice.text,
            "city": selectedCity,
            "district": selectedDistrict,
            "imageUrls": imageUrls,
            "selectedHoursByDay": formattedData
          };
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(userId)
              .update({"sellerDetails": sellerDetails});
        }
        _AmenitiesState.selectedHoursByDay.clear();
      } catch (e) {
        log("error $e");
        // Show error message to the user
      }
    }
  }

  Future<List<String>> _uploadImagesToStorage() async {
    List<String> imageUrls = [];

    // Loop through each image file and upload to Firebase Storage
    for (XFile imageFile in imageFileList) {
      try {
        
        File file = File(imageFile.path);
        String fileName = DateTime.now().millisecondsSinceEpoch.toString(); // Unique file name

        Reference ref = FirebaseStorage.instance.ref().child('images/$fileName.jpg');
        UploadTask uploadTask = ref.putFile(file);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        String imageUrl = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      } catch (e) {
        print("Error uploading image: $e");
      }
    }

    return imageUrls;
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
  const Amenities({Key? key, required this.day}) : super(key: key);

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
    crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start (left side)
    children: checkContainers.map((container) {
      return InkWell(
        splashColor: Colors.cyanAccent,
        onTap: () => onCheckTap(container),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          padding: const EdgeInsets.all(8),
          color: container.isCheck ? const Color.fromRGBO(33, 150, 243, 1) : Colors.white,
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
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class DeliveryAndReturnPage extends StatelessWidget {
  const DeliveryAndReturnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: userorseller ? sellerbackground: background,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: userorseller ? Colors.white: Colors.black)
        ),
      ),
      backgroundColor: userorseller ? sellerbackground: background,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Teslimat ve İade Koşulları',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: userorseller ? Colors.white: Colors.black
                      ),
                    ),
                    const SizedBox(height: 20,),

                    // Hizmet Kapsamı
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1.Hizmet Teslimatı',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          'Kiraladığınız kaleci hizmeti, rezervasyon sırasında belirttiğiniz tarih, saat ve lokasyonda hazır bulunur. Hizmetin zamanında teslim edilmesi, kiralama sürecinde verilen bilgilere bağlıdır.'
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Hizmet Kapsamı
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '2.Hizmet Kapsamı',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          '- Kiralanan kaleci, yalnızca rezervasyon sırasında belirtilen maç veya etkinlik süresi boyunca hizmet verir. \n- Teslimat, hizmet başlangıcını kapsar ve hizmetin tamamlanmasıyla sona erer.'
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Ekstra Gecikmeler
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '3.Ekstra Gecikmeler',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          'Mücbir sebeplerden (örneğin, hava koşulları, trafik veya diğer beklenmedik durumlar) dolayı oluşabilecek gecikmelerde, müşteri bilgilendirilir ve alternatif çözümler sunulur.'
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    // İade koşulları giriş
                    Text(
                      'İade Koşulları',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: userorseller ? Colors.white: Colors.black
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Rezervasyon İptali
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1.Rezervasyon İptali',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          '- Rezervasyonunuzu, hizmet başlangıç saatinden 24 saat öncesine kadar iptal etmeniz durumunda ödediğiniz ücret size eksiksiz iade edilir.\n- 24 saatten daha az bir süre kala yapılan iptallerde, ödenen ücretin %50’si kesinti yapılır.'
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Hizmet Memnuniyetsizliği
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '2.Hizmet Memnuniyestsizliği',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          '- Kaleci hizmetinden memnun kalmamanız durumunda, etkinlik tamamlandıktan sonra en geç 48 saat içinde uygulama destek birimine durumu bildirebilirsiniz.\n- Şikâyetler değerlendirilir ve haklı bulunması durumunda ücretin tamamı veya bir kısmı iade edilebilir.'
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    // İade Süreci
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '3.İade Süreci',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          'İade işlemleri, ödeme yaptığınız yönteme göre gerçekleştirilir: \n-Kredi Kartı: İşleminiz iptal edilmesinden sonra 7 iş günü içinde iade gerçekleştirilir. \n- Bankanızın süreçleri nedeniyle bu süre uzayabilir. Banka Havalesi/EFT: İadeniz, en geç 5 iş günü içinde belirttiğiniz hesap numarasına yapılır.'
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    Text(
                      'Cayma Hakkı',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: userorseller ? Colors.white: Colors.black
                      ),
                    ),
                    const SizedBox(height: 15,),

                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kullanıcı, rezervasyon onayını verdiği tarihten itibaren 14 gün içinde ve hizmetin başlamasından önce cayma hakkını kullanabilir. Cayma hakkı kullanımı için, aşağıdaki iletişim kanallarımızdan bize ulaşabilirsiniz.'
                        ),
                        SizedBox(height: 5,),
                        Text(
                          'İletişim Bilgileri: \n- E-Posta: kiraliikkalecii@gmail.com \n- Telefon: +90 541 522 14 89'
                        )
                      ],
                    ),
                    const SizedBox(height: 80)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'fatura_olustur_screen.dart';
class MusteriDetayScreen extends StatefulWidget {

  final int kullaniciId;

  const MusteriDetayScreen({
    super.key,
    required this.kullaniciId,
  });

  @override
  State<MusteriDetayScreen> createState() =>
      _MusteriDetayScreenState();
}

class _MusteriDetayScreenState
    extends State<MusteriDetayScreen> {

  final supabase = Supabase.instance.client;

  Map<String, dynamic>? musteri;

  List<dynamic> faturalar = [];

  bool loading = true;

  @override
  void initState() {

    super.initState();

    verileriGetir();
  }

  Future<void> verileriGetir() async {

    try {

      final kullaniciResponse =
          await supabase

          .from('kullanici')

          .select()

          .eq(
            'kullanici_id',
            widget.kullaniciId,
          )

          .single();

      final faturalarResponse =
          await supabase.rpc(

        'kullanici_faturalari_getir',

        params: {
          'p_kullanici_id':
              widget.kullaniciId,
        },
      );

      setState(() {

        musteri = kullaniciResponse;

        faturalar = faturalarResponse;

        loading = false;
      });

    } catch (e) {

      debugPrint(e.toString());

      setState(() {
        loading = false;
      });
    }
  }

  Color durumRenk(String durum) {

    if (durum == 'Odendi') {

      return Colors.green;
    }

    if (durum == 'Gecikmis') {

      return Colors.red;
    }

    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {

      return const Scaffold(

        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F6FA),

      appBar: AppBar(

        elevation: 0,

        backgroundColor:
            const Color(0xFF2D1457),

        title: const Text(

          'Müşteri Detayı',

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        leading: IconButton(

          onPressed: () {

            Navigator.pop(context);

          },

          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),

        actions: [

          IconButton(

           onPressed: () {

  Navigator.push(

    context,

    MaterialPageRoute(

      builder: (context) =>

          FaturaOlusturScreen(

        kullaniciId:
            widget.kullaniciId,
      ),
    ),
  );
},

            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(18),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(22),
              ),

              child: Column(

                children: [

                  Row(

                    children: [

                      const CircleAvatar(

                        radius: 30,

                        backgroundColor:
                            Color(0xFF673AB7),

                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Text(

                              '${musteri!['ad']} ${musteri!['soyad']}',

                              style: const TextStyle(

                                fontSize: 22,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              musteri!['tel_no'] ?? '',
                            ),

                            Text(
                              musteri!['email'] ?? '',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Container(

                    padding:
                        const EdgeInsets.all(14),

                    decoration: BoxDecoration(

                      color:
                          Colors.grey.shade100,

                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),

                    child: Row(

                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,

                      children: [

                        Column(

                          children: [

                            const Text(

                              'Toplam Fatura',

                              style: TextStyle(
                                color:
                                    Colors.black54,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(

                              '${faturalar.length}',

                              style: const TextStyle(

                                fontSize: 22,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        Column(

                          children: [

                            const Text(

                              'Aktif Borç',

                              style: TextStyle(
                                color:
                                    Colors.black54,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(

                              '₺ ${faturalar.where((f) => f['durum'] != 'Odendi').fold(0.0, (toplam, item) => toplam + double.parse(item['toplam_tutar'].toString())).toStringAsFixed(2)}',

                              style: const TextStyle(

                                fontSize: 22,

                                fontWeight:
                                    FontWeight.bold,

                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(18),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(22),
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(

                    'Faturalar',

                    style: TextStyle(

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  ...faturalar.map((fatura) {

                    return Container(

                      margin:
                          const EdgeInsets.only(
                        bottom: 14,
                      ),

                      padding:
                          const EdgeInsets.all(14),

                      decoration: BoxDecoration(

                        color:
                            Colors.grey.shade50,

                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),

                      child: Row(

                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,

                        children: [

                          Column(

                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              Text(

                                'FAT-${fatura['fatura_id']}',

                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                fatura['fatura_tarihi'],
                              ),
                            ],
                          ),

                          Column(

                            crossAxisAlignment:
                                CrossAxisAlignment.end,

                            children: [

                              Text(

                                '₺ ${fatura['toplam_tutar']}',

                                style: const TextStyle(

                                  fontWeight:
                                      FontWeight.bold,

                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(

                                fatura['durum'],

                                style: TextStyle(

                                  color: durumRenk(
                                    fatura['durum'],
                                  ),

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(

              width: double.infinity,

              height: 55,

           
            ),
          ],
        ),
      ),
    );
  }
}
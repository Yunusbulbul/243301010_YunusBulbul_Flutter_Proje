import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'musteri_detay_screen.dart';

class MusterilerScreen extends StatefulWidget {

  final int firmaId;

  const MusterilerScreen({
    super.key,
    required this.firmaId,
  });

  @override
  State<MusterilerScreen> createState() =>
      _MusterilerScreenState();
}

class _MusterilerScreenState
    extends State<MusterilerScreen> {

  final supabase = Supabase.instance.client;

  List<dynamic> musteriler = [];

  List<dynamic> filtreliMusteriler = [];

  bool loading = true;

  final aramaController =
      TextEditingController();

  @override
  void initState() {

    super.initState();

    musterileriGetir();
  }

  Future<void> musterileriGetir() async {

    try {

      final response = await supabase.rpc(

        'firma_musterileri',

        params: {
          'p_firma_id': widget.firmaId,
        },
      );

      List<dynamic> geciciListe = [];

      for (var musteri in response) {

        final borcResponse =
            await supabase.rpc(

          'kullanici_toplam_borc',

          params: {
            'p_kullanici_id':
                musteri['kullanici_id'],
          },
        );

        double borc = 0;

        if (borcResponse.isNotEmpty) {

          borc = double.parse(

            borcResponse.first[
                    'toplam_borc']
                .toString(),
          );
        }

        geciciListe.add({

          ...musteri,

          'toplam_borc': borc,
        });
      }

      setState(() {

        musteriler = geciciListe;

        filtreliMusteriler =
            geciciListe;

        loading = false;
      });

    } catch (e) {

      debugPrint(e.toString());

      setState(() {
        loading = false;
      });
    }
  }

  void filtrele(String value) {

    setState(() {

      filtreliMusteriler =
          musteriler.where((musteri) {

        final adSoyad =

            '${musteri['ad']} ${musteri['soyad']}'
                .toLowerCase();

        return adSoyad.contains(
          value.toLowerCase(),
        );

      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F6FA),


      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : Padding(

              padding:
                  const EdgeInsets.all(16),

              child: Column(

                children: [

                  Container(

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),

                    decoration: BoxDecoration(

                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),

                    child: TextField(

                      controller:
                          aramaController,

                      onChanged: filtrele,

                      decoration:
                          const InputDecoration(

                        border:
                            InputBorder.none,

                        icon: Icon(
                          Icons.search,
                        ),

                        hintText:
                            'Müşteri ara...',
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Expanded(

                    child: ListView.builder(

                      itemCount:
                          filtreliMusteriler
                              .length,

                      itemBuilder:
                          (context, index) {

                        final musteri =
                            filtreliMusteriler[
                                index];

                        final borc =
                            double.parse(

                          musteri[
                                  'toplam_borc']
                              .toString(),
                        );

                       return GestureDetector(

  onTap: () {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (context) =>

            MusteriDetayScreen(

          kullaniciId:
              musteri['kullanici_id'],
        ),
      ),
    );
  },

  child: Container(

                          margin:
                              const EdgeInsets.only(
                            bottom: 14,
                          ),

                          padding:
                              const EdgeInsets.all(
                            14,
                          ),

                          decoration:
                              BoxDecoration(

                            color: Colors.white,

                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
                          ),

                          child: Row(

                            children: [

                              CircleAvatar(

                                radius: 28,

                                backgroundColor:

                                    borc == 0

                                        ? Colors.green

                                        : borc > 700

                                            ? Colors.red

                                            : Colors.deepPurple,

                                child: Icon(

                                  borc == 0

                                      ? Icons.check

                                      : borc > 700

                                          ? Icons.warning

                                          : Icons.person,

                                  color:
                                      Colors.white,
                                ),
                              ),

                              const SizedBox(
                                  width: 14),

                              Expanded(

                                child: Column(

                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [

                                    Text(

                                      '${musteri['ad']} ${musteri['soyad']}',

                                      style:
                                          const TextStyle(
                                        fontSize:
                                            17,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),

                                    const SizedBox(
                                        height: 4),

                                    Text(

                                      musteri[
                                              'tel_no'] ??
                                          '',

                                      style:
                                          const TextStyle(
                                        color:
                                            Colors
                                                .black54,
                                      ),
                                    ),

                                    const SizedBox(
                                        height: 6),

                                    Text(

                                      'Aktif Borç: ₺ ${borc.toStringAsFixed(2)}',

                                      style:
                                          TextStyle(

                                        color:
                                            borc == 0

                                                ? Colors.green

                                                : Colors.red,

                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Icon(
                                Icons.chevron_right,
                                size: 30,
                                color:
                                    Colors.black54,
                              ),
                            ],
                          ),
  ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
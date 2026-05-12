
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NakitOdemeScreen extends StatefulWidget {

  final int firmaId;

  const NakitOdemeScreen({
    super.key,
    required this.firmaId,
  });

  @override
  State<NakitOdemeScreen> createState() =>
      _NakitOdemeScreenState();
}

class _NakitOdemeScreenState
    extends State<NakitOdemeScreen> {

  final supabase = Supabase.instance.client;

  List<dynamic> faturalar = [];
List<dynamic> filtreliFaturalar = [];
  bool loading = true;

  @override
  void initState() {

    super.initState();

    faturalariGetir();
  }

  Future<void> faturalariGetir() async {

    try {
final response =

    await supabase

    .from('fatura_detay')

    .select()

    .eq(
      'firma_id',
      widget.firmaId,
    )

    .neq(
      'durum',
      'Odendi',
    )

    .order(
      'fatura_tarihi',
      ascending: false,
    );
      setState(() {

        faturalar = response;
filtreliFaturalar = response;
        loading = false;
      });

    } catch (e) {

      debugPrint(e.toString());

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> nakitOdemeYap(
    Map<String, dynamic> fatura,
  ) async {

    try {

      await supabase

          .from('odeme')

          .insert({

        'fatura_id':
            fatura['fatura_id'],

        'odeme_tarihi':
            DateTime.now()
                .toIso8601String(),

        'odeme_turu': 'Nakit',

        'odeme_tutari':
            fatura['toplam_tutar'],
      });

      await supabase

          .from('fatura')

          .update({

        'durum': 'Odendi',

      }).eq(

        'fatura_id',

        fatura['fatura_id'],
      );

      ScaffoldMessenger.of(context)

          .showSnackBar(

        const SnackBar(

          content: Text(
            'Nakit ödeme alındı',
          ),
        ),
      );

      faturalariGetir();

    } catch (e) {

      ScaffoldMessenger.of(context)

          .showSnackBar(

        SnackBar(
          content: Text('$e'),
        ),
      );
    }
  }
void filtrele(String value) {

  setState(() {

    filtreliFaturalar = faturalar

        .where((fatura) {

      final adSoyad =

          '${fatura['ad']} ${fatura['soyad']}'
              .toLowerCase();

      return adSoyad.contains(
        value.toLowerCase(),
      );

    }).toList();
  });
}
  @override
  Widget build(BuildContext context) {

    return loading

        ? const Center(
            child:
                CircularProgressIndicator(),
          )
: Column(

    children: [

      Padding(

        padding:
            const EdgeInsets.all(16),

        child: TextField(

          onChanged: filtrele,

          decoration: InputDecoration(

            hintText:
                'Müşteri ara...',

            prefixIcon:
                const Icon(Icons.search),

            filled: true,

            fillColor: Colors.white,

            border:
                OutlineInputBorder(

              borderRadius:
                  BorderRadius.circular(
                18,
              ),

              borderSide:
                  BorderSide.none,
            ),
          ),
        ),
      ),

      Expanded(
        child: ListView.builder(

            padding:
                const EdgeInsets.all(16),
itemCount:
    filtreliFaturalar.length,

            itemBuilder:
                (context, index) {
final fatura =
    filtreliFaturalar[index];

              return Container(

                margin:
                    const EdgeInsets.only(
                  bottom: 16,
                ),

                padding:
                    const EdgeInsets.all(16),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(

                      'Fatura #${fatura['fatura_id']}',

                      style:
                          const TextStyle(

                        fontSize: 20,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),

Text(

  '${fatura['ad']} ${fatura['soyad']}',

  style: const TextStyle(

    fontSize: 16,

    color: Colors.black54,
  ),
),

                    const SizedBox(height: 8),

                    Text(
                      'Tüketim: ${fatura['tuketim_miktari']} m³',
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Tutar: ₺ ${fatura['toplam_tutar']}',
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Durum: ${fatura['durum']}',
                    ),

                    const SizedBox(height: 20),

                    SizedBox(

                      width: double.infinity,

                      height: 52,

                      child: ElevatedButton(

                        onPressed: () {

                          nakitOdemeYap(
                            fatura,
                          );
                        },

                        style:
                            ElevatedButton.styleFrom(

                          backgroundColor:
                              Colors.green,

                          shape:
                              RoundedRectangleBorder(

                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                        ),

                        child: const Text(

                          'Nakit Ödendi',

                          style: TextStyle(

                            fontSize: 18,

                            color: Colors.white,

                            fontWeight:
                                FontWeight.bold,
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
    ],
          );
  }
}


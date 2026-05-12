import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FaturaOlusturScreen extends StatefulWidget {

  final int kullaniciId;

  const FaturaOlusturScreen({
    super.key,
    required this.kullaniciId,
  });

  @override
  State<FaturaOlusturScreen> createState() =>
      _FaturaOlusturScreenState();
}

class _FaturaOlusturScreenState
    extends State<FaturaOlusturScreen> {

  final supabase = Supabase.instance.client;

  Map<String, dynamic>? musteri;
  Map<String, dynamic>? sonTuketim;
  Map<String, dynamic>? firma;

  final sonEndeksController =
      TextEditingController();

  double tuketim = 0;
  double tahminiTutar = 0;
bool loading = false;
 

  @override
  void initState() {

    super.initState();

    verileriGetir(
      
    );
  }

  Future<void> verileriGetir() async {

    try {

      final kullanici =
          await supabase

          .from('kullanici')

          .select()

          .eq(
            'kullanici_id',
            widget.kullaniciId,
          )

          .single();

      final abonelik =
          await supabase

          .from('abonelik')

          .select()

          .eq(
            'kullanici_id',
            widget.kullaniciId,
          )

          .single();

      final firmaData =
          await supabase

          .from('firma')

          .select()

          .eq(
            'firma_id',
            abonelik['firma_id'],
          )

          .single();

      final tuketimData =
          await supabase

          .from('tuketim')

          .select()

          .eq(
            'abone_id',
            abonelik['abone_id'],
          )

          .order(
               'tuketim_id',
            ascending: false,
          )

          .limit(1)

          .single();

      setState(() {

        musteri = kullanici;

        sonTuketim = tuketimData;

        firma = firmaData;

        loading = false;
      });

    } catch (e) {

      debugPrint(e.toString());

      setState(() {
        loading = false;
      });
    }
  }

  void hesapla() {
final yeniEndeks =
    double.tryParse(
          sonEndeksController.text,
        ) ??
        0;

final ilkEndeks =
    double.parse(
      sonTuketim!['son_endeks']
          .toString(),
    );



    setState(() {

      tuketim =
          yeniEndeks - ilkEndeks;

      tahminiTutar =
          tuketim *
              double.parse(
                firma!['birim_fiyat']
                    .toString(),
              );
    });
  }

  Future<void> faturaOlustur() async {
final yeniEndeks =
    double.tryParse(
          sonEndeksController.text,
        ) ??
        0;

final ilkEndeks =
    double.parse(
      sonTuketim!['son_endeks']
          .toString(),
    );

if (yeniEndeks < ilkEndeks) {

  ScaffoldMessenger.of(context)

      .showSnackBar(

    const SnackBar(

      content: Text(
        'Son endeks ilk endeksten küçük olamaz',
      ),
    ),
  );

  return;
}
    try {
setState(() {
  loading = true;
});

      final abonelik =
          await supabase

          .from('abonelik')

          .select()

          .eq(
            'kullanici_id',
            widget.kullaniciId,
          )

          .single();

      final yeniTuketim =
          await supabase

          .from('tuketim')

          .insert({

        'abone_id':
            abonelik['abone_id'],

        'tuketim_tarihi':
            DateTime.now()
                .toIso8601String(),

        'ilk_endeks':
            sonTuketim!['son_endeks'],

        'son_endeks':
            double.parse(
              sonEndeksController.text,
            ),

        

      })
      

          .select()

          .single();

   final yeniFatura =
    await supabase

    .from('fatura')

    .insert({

  'tuketim_id':
      yeniTuketim['tuketim_id'],

  'fatura_tarihi':
      DateTime.now()
          .toIso8601String(),

  'sonodeme_tarihi':

      DateTime.now()

          .add(
            const Duration(days: 15),
          )

          .toIso8601String(),

  'durum': 'Odenmedi',
'birim_fiyat':

    double.parse(
      firma!['birim_fiyat']
          .toString(),
    ),
})

    .select()

    .single();

ScaffoldMessenger.of(context)

    .showSnackBar(

  const SnackBar(

    content: Text(
      'Fatura oluşturuldu',
    ),
  ),
);
await verileriGetir();

sonEndeksController.clear();

setState(() {

  tuketim = 0;

  tahminiTutar = 0;
});

      ScaffoldMessenger.of(context)

          .showSnackBar(

        const SnackBar(

          content:
              Text('Fatura oluşturuldu'),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context)

          .showSnackBar(

        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
    finally {

  setState(() {
    loading = false;
  });
}
  }

  Widget bilgiKutusu(
    String title,
    String value,
  ) {

    return Container(

      width: double.infinity,

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color:
            const Color(0xFFFFF8F0),

        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Column(

        children: [

          Text(

            title,

            style: const TextStyle(
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 10),

          Text(

            value,

            style: const TextStyle(

              fontSize: 34,

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {

      return const Scaffold(

        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }
if (sonTuketim == null || firma == null) {

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

        backgroundColor:
            const Color(0xFF2D1457),

        title: const Text(

          'Fatura Oluştur',

          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            Container(

              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Row(

                children: [

                  const CircleAvatar(

                    radius: 28,

                    backgroundColor:
                        Color(0xFF512DA8),

                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(

                        '${musteri!['ad']} ${musteri!['soyad']}',

                        style: const TextStyle(

                          fontSize: 20,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        musteri!['tc_no'],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            bilgiKutusu(

              'İlk Endeks',

              sonTuketim!['son_endeks']
                  .toString(),
            ),

            const SizedBox(height: 20),

            TextField(

              controller:
                  sonEndeksController,

              keyboardType:
                  TextInputType.number,

              onChanged: (value) {
                hesapla();
              },

              decoration: InputDecoration(

                labelText:
                    'Yeni Son Endeks',

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            bilgiKutusu(
              'Tüketim (m³)',
              tuketim.toStringAsFixed(2),
            ),

            const SizedBox(height: 20),

            bilgiKutusu(

              'Birim Fiyat (₺)',

              firma!['birim_fiyat']
                  .toString(),
            ),

            const SizedBox(height: 20),

            bilgiKutusu(

              'Tahmini Tutar (₺)',

              tahminiTutar
                  .toStringAsFixed(2),
            ),

            const SizedBox(height: 30),

            SizedBox(

              width: double.infinity,

              height: 58,

              child: ElevatedButton(

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      const Color(
                    0xFFFF9800,
                  ),

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                ),

               onPressed:

    loading

        ? null

        : faturaOlustur,

      child:

    loading

        ? const SizedBox(

            height: 22,
            width: 22,

            child:
                CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )

        : const Text(
            'Fatura Oluştur',
          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
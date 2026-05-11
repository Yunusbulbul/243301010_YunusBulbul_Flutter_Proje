import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'fatura_olustur_screen.dart';

class FaturaMusteriSecScreen

    extends StatefulWidget {
final int firmaId;
  const FaturaMusteriSecScreen({
    super.key,
    required this.firmaId,  
  });

  @override
  State<FaturaMusteriSecScreen>
      createState() =>
          _FaturaMusteriSecScreenState();
}

class _FaturaMusteriSecScreenState
    extends State<FaturaMusteriSecScreen> {

  final supabase = Supabase.instance.client;

  List<dynamic> musteriler = [];

  bool loading = true;

  @override
  void initState() {

    super.initState();

    musterileriGetir();
  }

  Future<void> musterileriGetir() async {

    try {

         final response =
    await supabase.rpc(

  'firma_musterileri_getir',

  params: {

    'p_firma_id':
        widget.firmaId,
  },
);

      setState(() {

        musteriler = response;

        loading = false;
      });

    } catch (e) {

      debugPrint(e.toString());

      setState(() {
        loading = false;
      });
    }
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

          : ListView.builder(

              padding:
                  const EdgeInsets.all(16),

              itemCount:
                  musteriler.length,

              itemBuilder:
                  (context, index) {

                final musteri =
                    musteriler[index];

                return GestureDetector(

                  onTap: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (context) =>

                            FaturaOlusturScreen(

                          kullaniciId:
                              musteri[
                                  'kullanici_id'],
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
                      16,
                    ),

                    decoration: BoxDecoration(

                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                    ),

                    child: Row(

                      children: [

                        const CircleAvatar(

                          radius: 26,

                          backgroundColor:
                              Color(0xFF673AB7),

                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(

                          child: Column(

                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              Text(

                                '${musteri['ad']} ${musteri['soyad']}',

                                style:
                                    const TextStyle(

                                  fontSize: 18,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                  height: 4),

                              Text(
                                musteri['tc_no'],
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
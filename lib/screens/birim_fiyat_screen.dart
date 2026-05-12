import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BirimFiyatScreen extends StatefulWidget {

  final int firmaId;

  const BirimFiyatScreen({
    super.key,
    required this.firmaId,
  });

  @override
  State<BirimFiyatScreen> createState() =>
      _BirimFiyatScreenState();
}

class _BirimFiyatScreenState
    extends State<BirimFiyatScreen> {

  final supabase =
      Supabase.instance.client;

  final fiyatController =
      TextEditingController();

  bool loading = true;

  @override
  void initState() {

    super.initState();

    fiyatGetir();
  }

  Future<void> fiyatGetir() async {

    final response =

        await supabase

        .from('firma')

        .select('birim_fiyat')

        .eq(
          'firma_id',
          widget.firmaId,
        )

        .single();

    fiyatController.text =

        response['birim_fiyat']
            .toString();

    setState(() {
      loading = false;
    });
  }

  Future<void> fiyatKaydet() async {

    await supabase

        .from('firma')

        .update({

      'birim_fiyat':

          double.parse(
        fiyatController.text,
      ),
    })

        .eq(
          'firma_id',
          widget.firmaId,
        );

    if (mounted) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            'Birim fiyat güncellendi',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {

      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(

      onRefresh: fiyatGetir,

      child:
          SingleChildScrollView(

        physics:
            const AlwaysScrollableScrollPhysics(),

        padding:
            const EdgeInsets.all(
          16,
        ),

        child: Container(

          padding:
              const EdgeInsets.all(
            20,
          ),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
                BorderRadius.circular(
              24,
            ),
          ),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const Text(

                "Su Birim Fiyatı",

                style: TextStyle(

                  fontSize: 24,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              TextField(

                controller:
                    fiyatController,

                keyboardType:
                    TextInputType.number,

                decoration:
                    InputDecoration(

                  labelText:
                      "1 m³ fiyatı",

                  suffixText: "₺",

                  border:
                      OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              SizedBox(

                width: double.infinity,

                height: 55,

                child: ElevatedButton(

                  onPressed:
                      fiyatKaydet,

                  style:
                      ElevatedButton.styleFrom(

                    backgroundColor:
                        const Color(
                      0xFF2D1457,
                    ),

                    shape:
                        RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                    ),
                  ),

                  child: const Text(

                    "Kaydet",

                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
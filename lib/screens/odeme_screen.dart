import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OdemeScreen extends StatefulWidget {

  final Map<String, dynamic>? fatura;
final List<dynamic>? faturalar;
  final VoidCallback? odemeBasarili;

  const OdemeScreen({
    super.key,
    this.fatura,
      this.faturalar,
    this.odemeBasarili,
  });

  @override
  State<OdemeScreen> createState() => _OdemeScreenState();
}

class _OdemeScreenState extends State<OdemeScreen> {

  final supabase = Supabase.instance.client;

  final kartNoController = TextEditingController();
  final adSoyadController = TextEditingController();
  final cvvController = TextEditingController();
  final tarihController = TextEditingController();

  bool loading = false;
Map<String, dynamic>? seciliFatura;
  Future<void> odemeYap() async {

    final kartNo = kartNoController.text.replaceAll(' ', '');

    if (kartNo.length != 16) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kart numarası 16 haneli olmalıdır'),
        ),
      );

      return;
    }

    if (cvvController.text.length != 3) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CVV 3 haneli olmalıdır'),
        ),
      );

      return;
    }

    try {
      final mevcutOdeme = await supabase
    .from('odeme')
    .select()
    .eq(
      'fatura_id',
      seciliFatura!['fatura_id'],
    );

if (mevcutOdeme.isNotEmpty) {

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Bu fatura zaten ödenmiş',
      ),
    ),
  );

  setState(() {
    loading = false;
  });

  return;
}

      setState(() {
        loading = true;
      });

      await supabase
          .from('odeme')
          .insert({


        'odeme_tarihi': DateTime.now().toIso8601String(),

        'odeme_turu': 'Kart',

'fatura_id': seciliFatura!['fatura_id'],

'odeme_tutari': seciliFatura!['toplam_tutar'],
      });

      await supabase
          .from('fatura')
          .update({
        'durum': 'Odendi',
      })
          .eq(
        'fatura_id',
        seciliFatura!['fatura_id'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ödeme başarılı'),
        ),
      );
setState(() {

  seciliFatura = null;

});
      widget.odemeBasarili?.call();

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
        ),
      );

    } finally {

      setState(() {
        loading = false;
      });
    }
  }

  Widget textField({
  required String label,
  required TextEditingController controller,
  TextInputType type = TextInputType.text,
  int? maxLength,
  Function(String)? onChanged,
}) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: TextField(
onChanged: onChanged,
        controller: controller,

        keyboardType: type,

        maxLength: maxLength,

        decoration: InputDecoration(

          labelText: label,

          counterText: '',

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {

  final odenmemisFaturalar = widget.faturalar
      ?.where((f) => f['durum'] != 'Odendi')
      .toList() ?? [];

  return SingleChildScrollView(

    padding: const EdgeInsets.all(16),

    child: Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const Text(
          'Ödenmemiş Faturalar',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        ...odenmemisFaturalar.map((fatura) {

          final seciliMi =
              seciliFatura?['fatura_id'] ==
                  fatura['fatura_id'];

          return GestureDetector(

            onTap: () {

              setState(() {

                seciliFatura = fatura;

              });
            },

            child: Container(

              margin: const EdgeInsets.only(bottom: 12),

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: seciliMi
                    ? Colors.blue.shade100
                    : Colors.white,

                borderRadius: BorderRadius.circular(16),

                border: Border.all(
                  color: Colors.blue.shade200,
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
                        'Fatura #${fatura['fatura_id']}',

                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        fatura['durum'],
                      ),
                    ],
                  ),

                  Text(

                    '${fatura['toplam_tutar']} ₺',

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 20),

        Container(

          width: double.infinity,

          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: const Color(0xFF1565A9),
            borderRadius: BorderRadius.circular(20),
          ),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const Text(
                'Ödenecek Tutar',

                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 12),

              Text(

                seciliFatura == null
                    ? '0 ₺'
                    : '${seciliFatura!['toplam_tutar']} ₺',

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        textField(
          label: 'Kart Numarası',
          controller: kartNoController,
          type: TextInputType.number,
          maxLength: 16,
        ),

        textField(
          label: 'Kart Sahibi',
          controller: adSoyadController,
        ),

        Row(
          children: [

            Expanded(
              child: textField(
                label: 'SKT',
                controller: tarihController,
                maxLength: 5,

                onChanged: (value) {

                  if (value.length == 2 &&
                      !value.contains('/')) {

                    tarihController.text = '$value/';

                    tarihController.selection =
                        TextSelection.fromPosition(

                      TextPosition(
                        offset: tarihController.text.length,
                      ),
                    );
                  }
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: textField(
                label: 'CVV',
                controller: cvvController,
                type: TextInputType.number,
                maxLength: 3,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        SizedBox(

          width: double.infinity,
          height: 55,

          child: ElevatedButton(

            onPressed: loading
                ? null
                : () {

                    if (seciliFatura == null) {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(

                        const SnackBar(
                          content: Text(
                            'Lütfen fatura seçin',
                          ),
                        ),
                      );

                      return;
                    }

                    odemeYap();
                  },

            child: loading

                ? const CircularProgressIndicator()

                : const Text(
                    'Ödemeyi Tamamla',
                    style: TextStyle(fontSize: 18),
                  ),
          ),
        ),

        const SizedBox(height: 120),
      ],
    ),
  );
}
}
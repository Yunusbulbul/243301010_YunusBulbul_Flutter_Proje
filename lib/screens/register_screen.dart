import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final supabase = Supabase.instance.client;

  final adController = TextEditingController();
  final soyadController = TextEditingController();
  final emailController = TextEditingController();
  final sifreController = TextEditingController();
  final tcController = TextEditingController();
  final telefonController = TextEditingController();

  List<dynamic> firmalar = [];

  int? secilenFirmaId;

  @override
  void initState() {
    super.initState();
    firmalariGetir();
  }

  Future<void> firmalariGetir() async {

    final response = await supabase
        .from('firma')
        .select();

    setState(() {
      firmalar = response;
    });
  }

  Future<void> kayitOl() async {

    try {

      final kullanici = await supabase
          .from('kullanici')
          .insert({

        'tc_no': tcController.text,
        'email': emailController.text,
        'sifre': sifreController.text,
        'tel_no': telefonController.text,
        'ad': adController.text,
        'soyad': soyadController.text,

      })
          .select()
          .single();

      await supabase
          .from('abonelik')
          .insert({

        'kullanici_id': kullanici['kullanici_id'],
        'firma_id': secilenFirmaId,
        'baslama_tarihi': DateTime.now().toIso8601String(),

      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt başarılı'),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
        ),
      );
    }
  }

  Widget textField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
  }) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: TextField(
        controller: controller,
        obscureText: obscure,

        decoration: InputDecoration(
          labelText: label,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Kayıt Ol'),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            textField(
              controller: adController,
              label: 'Ad',
            ),

            textField(
              controller: soyadController,
              label: 'Soyad',
            ),

           Padding(
  padding: const EdgeInsets.only(bottom: 14),

  child: TextField(
    controller: tcController,

    keyboardType: TextInputType.number,

    maxLength: 11,

    decoration: InputDecoration(
      labelText: 'TC No',

      counterText: '',

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  ),
),

            textField(
              controller: emailController,
              label: 'E-Mail',
            ),

            textField(
              controller: sifreController,
              label: 'Şifre',
              obscure: true,
            ),

           Padding(
  padding: const EdgeInsets.only(bottom: 14),

  child: TextField(
    controller: telefonController,

    keyboardType: TextInputType.phone,

    maxLength: 10,

    decoration: InputDecoration(
      labelText: 'Telefon Numarası',

      hintText: '5XXXXXXXXX',

      prefixText: '+90 ',

      counterText: '',

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  ),
),

            const SizedBox(height: 10),

            DropdownButtonFormField<int>(

              value: secilenFirmaId,

              decoration: InputDecoration(
                labelText: 'Firma Seç',

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              items: firmalar.map<DropdownMenuItem<int>>((firma) {

                return DropdownMenuItem<int>(
                  value: firma['firma_id'],
                  child: Text(firma['firma_ad']),
                );

              }).toList(),

              onChanged: (value) {

                setState(() {
                  secilenFirmaId = value;
                });

              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(

                onPressed: kayitOl,

                child: const Text(
                  'Kayıt Ol',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
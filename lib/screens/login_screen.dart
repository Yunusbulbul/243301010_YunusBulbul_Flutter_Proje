import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_colors.dart';
import 'fatura_screen.dart';
class LoginScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  final bool darkMode;
  const LoginScreen({
    super.key,
    this.onThemeChanged,
       this.darkMode = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isCustomerSelected = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
Future<void> login() async {
  try {
    final response = await Supabase.instance.client
        .from('kullanici')
        .select()
        .eq('email', emailController.text.trim())
        .eq('sifre', passwordController.text.trim());

    if (response.isNotEmpty) {
      final kullanici = response.first;
await Supabase.instance.client.from('giris_loglari').insert({
  'kullanici_id': kullanici['kullanici_id'],
});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Giriş başarılı")),
      );

     Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => FaturalarScreen(
      kullaniciId: kullanici['kullanici_id'],

    ),
  ),
);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email veya şifre yanlış")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Hata: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Fatura Takip',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              SizedBox(height: 30),

              Icon(
                Icons.water_drop_outlined,
                size: 80,
                color: AppColors.primary,
              ),

              SizedBox(height: 12),

              Text(
                'FATURA TAKİP',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),

              SizedBox(height: 30),

              // SEÇİM
              Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isCustomerSelected = true;
                          });
                        },
                        child: Container(
                          color: isCustomerSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          child: Center(
                            child: Text(
                              'Müşteri',
                              style: TextStyle(
                                color: isCustomerSelected
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isCustomerSelected = false;
                          });
                        },
                        child: Container(
                          color: !isCustomerSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          child: Center(
                            child: Text(
                              'Yönetici',
                              style: TextStyle(
                                color: !isCustomerSelected
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    // EMAIL
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: isCustomerSelected
                            ? "ornek@mail.com"
                            : "kullanici adi",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // ŞİFRE
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "******",
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // GİRİŞ BUTONU
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                        ),
                        child: Text(
                          "Giriş Yap",
                          style: TextStyle(fontSize: 18 , color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
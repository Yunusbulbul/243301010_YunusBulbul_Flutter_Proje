import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isCustomerSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primary,
        title: Text('Fatura Takip',
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
              SizedBox(height: 10),


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

              SizedBox(height: 4),

              Text(
                'Su faturalarınızı kolayca takip edin ',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),

              SizedBox(height: 30),

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
                          decoration: BoxDecoration(
                            color: isCustomerSelected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
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
                          decoration: BoxDecoration(
                            color: !isCustomerSelected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                          child: Center(
                            child: Text(
                              'Kurum',
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
    border: Border.all(color: AppColors.border),
  ),
  child: Column(
    children: [
      TextField(
        decoration: InputDecoration(
          hintText: "ornek@mail.com",
          prefixIcon: Icon(Icons.mail_outline),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      SizedBox(height: 16),
      SizedBox(height: 16),

TextField(
  obscureText: true,
  decoration: InputDecoration(
    hintText: "******",
    prefixIcon: Icon(Icons.lock_outline),
    suffixIcon: Icon(Icons.visibility_off),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),
Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: () {},
    child: Text("Şifremi Unuttum"),
  ),
),
  SizedBox(height: 10),

SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    onPressed: () {},
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: Text(
      "Giriş Yap",
      style: TextStyle(fontSize: 18, color: Colors.white),
    ),
  ),
),
   SizedBox(height: 20),

SizedBox(
  width: double.infinity,
  height: 50,
  child: OutlinedButton(
    onPressed: () {},
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: AppColors.primaryDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: Text(
      "Kayıt Ol",
      style: TextStyle(color: AppColors.primaryDark),
    ),
  ),
),
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
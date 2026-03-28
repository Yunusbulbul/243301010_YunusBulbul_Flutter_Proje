import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}
//deneme
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold( 
        appBar: AppBar(
        title: Text("Fatura Takip"),
       backgroundColor: Colors.red,
        ),
        body: Center(
          child:Column( 
            children: [
              Align(
                alignment: Alignment.topLeft,
              
           child: CircleAvatar(
          backgroundImage: NetworkImage("https://www.pngall.com/wp-content/uploads/5/Avatar-Facebook-PNG-High-Quality-Image.png"),
          radius: 50,
          )
              ),
          SizedBox(
            height: 20, 
          ),
          Align(
            alignment: Alignment.center, 
            child: Text("Fatura Takip Uygulamaı  "),
          ),
            ],
          

        ),
        )
        )
    );
  }
  }
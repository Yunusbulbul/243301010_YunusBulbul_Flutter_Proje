import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalizScreen extends StatefulWidget {
  final int kullaniciId;

  const AnalizScreen({
    super.key,
    required this.kullaniciId,
  });

  @override
  State<AnalizScreen> createState() => _AnalizScreenState();
}

class _AnalizScreenState extends State<AnalizScreen> {

  final supabase = Supabase.instance.client;

  List<FlSpot> grafikVerileri = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    verileriGetir();
  }

  Future<void> verileriGetir() async {

    final response = await supabase
        .from('faturalar')
        .select()
        .eq('kullanici_id', widget.kullaniciId)
        .order('fatura_tarihi');

    List<FlSpot> spots = [];

    for (int i = 0; i < response.length; i++) {

      final veri = response[i];

      spots.add(
        FlSpot(
          i.toDouble(),
          double.parse(
            veri['tutar'].toString(),
          ),
        ),
      );
    }

    setState(() {
      grafikVerileri = spots;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(20),

      child: LineChart(

        LineChartData(

          gridData: const FlGridData(
            show: false,
          ),

          borderData: FlBorderData(
            show: false,
          ),

          titlesData: const FlTitlesData(
            show: false,
          ),

          lineBarsData: [

            LineChartBarData(

              isCurved: true,

              dotData: const FlDotData(
                show: true,
              ),

              spots: grafikVerileri,

            ),

          ],

        ),

      ),
    );
  }
}
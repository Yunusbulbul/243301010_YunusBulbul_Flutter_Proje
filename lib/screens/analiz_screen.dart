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
final aylar = [
  "Oca",
  "Şub",
  "Mar",
  "Nis",
  "May",
  "Haz",
  "Tem",
  "Ağu",
  "Eyl",
  "Eki",
  "Kas",
  "Ara",
];
  final supabase = Supabase.instance.client;

 List<FlSpot> tuketimSpots = [];
List<FlSpot> fiyatSpots = [];
List<FlSpot> tutarSpots = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    verileriGetir();
  }
Future<void> verileriGetir() async {
  try {

    print("ANALIZ BASLADI");

   final response = await supabase.rpc(
  'kullanici_fatura_analiz',
      params: {
        'p_kullanici_id': widget.kullaniciId,
      },
    );

    print("RESPONSE:");
    print(response);
print(response.first.keys);
List<FlSpot> yeniTuketimSpots = [];
List<FlSpot> yeniFiyatSpots = [];
List<FlSpot> yeniTutarSpots = [];

for (int i = 0; i < response.length; i++) {

  final veri = response[i];

  yeniTuketimSpots.add(
    FlSpot(
      i.toDouble(),
      (veri['tuketim_miktari'] as num).toDouble(),
    ),
  );

  yeniFiyatSpots.add(
    FlSpot(
      i.toDouble(),
      (veri['birim_fiyat'] as num).toDouble(),
    ),
  );

  yeniTutarSpots.add(
    FlSpot(
      i.toDouble(),
      (veri['toplam_tutar'] as num).toDouble(),
    ),
  );
}

setState(() {

  tuketimSpots = yeniTuketimSpots;

  fiyatSpots = yeniFiyatSpots;

  tutarSpots = yeniTutarSpots;

  isLoading = false;
});

  } catch (e) {

    print("ANALIZ HATASI:");
    print(e);

    setState(() {
      isLoading = false;
    });
  }
}
  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (tutarSpots.isEmpty) {
  return const Center(
    child: Text(
      "Analiz verisi bulunamadı",
      style: TextStyle(fontSize: 18),
    ),
  );
}

return SingleChildScrollView(
  padding: const EdgeInsets.all(16),

  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,

    children: [

      const Text(
        "Fatura Analizi",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 20),

      Row(
        children: [

          Expanded(
            child: _infoCard(
              "Toplam Fatura",
              "${tutarSpots.length}",
              Icons.receipt_long,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: _infoCard(
              "Analiz",
              "Aktif",
              Icons.analytics,
            ),
          ),

        ],
      ),

      const SizedBox(height: 24),

      _chartCard(
        title: "Tüketim Grafiği",
        spots: tuketimSpots,
      ),

      const SizedBox(height: 20),

      _chartCard(
        title: "Birim Fiyat Grafiği",
        spots: fiyatSpots,
      ),

      const SizedBox(height: 20),

      _chartCard(
        title: "Fatura Tutarı",
        spots: tutarSpots,
      ),

      const SizedBox(height: 100),

    ],
  ),
);

  }Widget _infoCard(
  String title,
  String value,
  IconData icon,
) {

  return Container(
    padding: const EdgeInsets.all(16),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),

      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
        ),
      ],
    ),

    child: Column(
      children: [

        Icon(
          icon,
          size: 34,
          color: Colors.blue,
        ),

        const SizedBox(height: 10),

        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(title),
      ],
    ),
  );
}Widget _chartCard({
  required String title,
  required List<FlSpot> spots,
}) {

  return Container(
    margin: const EdgeInsets.only(bottom: 24),
    padding: const EdgeInsets.all(16),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),

      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
        ),
      ],
    ),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 250,

          child: LineChart(

            LineChartData(

              minY: 0,
maxY: spots
        .map((e) => e.y)
        .reduce((a, b) => a > b ? a : b) + 20,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
              ),

              borderData: FlBorderData(
                show: true,
              ),

              titlesData: FlTitlesData(

                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                  ),
                ),

                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                bottomTitles: AxisTitles(

                  sideTitles: SideTitles(

                    showTitles: true,

                    getTitlesWidget: (value, meta) {
if (value % 1 != 0) {
  return const Text('');
}

int index = value.toInt();

if (index >= 0 && index < aylar.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),

                          child: Text(
                            aylar[index],
                            style: const TextStyle(fontSize: 11),
                          ),
                        );
                      }

                      return const Text('');
                    },
                  ),
                ),
              ),

              lineBarsData: [

                LineChartBarData(

                  spots: spots,

                  isCurved: false,

                  barWidth: 3,

                  dotData: const FlDotData(
                    show: true,
                  ),

                ),

              ],

            ),

          ),

        ),

      ],
    ),
  );
}
}
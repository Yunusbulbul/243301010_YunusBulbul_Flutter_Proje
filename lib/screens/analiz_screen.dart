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
  State<AnalizScreen> createState() =>
      _AnalizScreenState();
}

class _AnalizScreenState
    extends State<AnalizScreen> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  int seciliPeriyot = 6;

  List<dynamic> faturalar = [];

  List<String> aylar = [];

  List<FlSpot> tuketimSpots = [];

  List<BarChartGroupData>
      tutarBars = [];

  double toplamTuketim = 0;

  double toplamOdeme = 0;

  int odenenFatura = 0;

  int odenmeyenFatura = 0;

  double maxTuketimY = 50;

  double maxTutarY = 100;

  @override
  void initState() {

    super.initState();

    verileriGetir();
  }

  Future<void> verileriGetir() async {

    setState(() {
      loading = true;
    });

    try {

      final response =
          await supabase.rpc(

        'kullanici_faturalari_getir',

        params: {
          'p_kullanici_id':
              widget.kullaniciId,
        },
      );

      final simdi = DateTime.now();

      final filtreli = response.where((f) {

        final tarih = DateTime.parse(
          f['fatura_tarihi'],
        );

        final filtreTarihi = DateTime(
  simdi.year,
  simdi.month - seciliPeriyot,
);

return tarih.isAfter(
  filtreTarihi,
);

      }).toList();

      filtreli.sort((a, b) {

        return DateTime.parse(
          a['fatura_tarihi'],
        ).compareTo(

          DateTime.parse(
            b['fatura_tarihi'],
          ),
        );
      });

      List<FlSpot>
          yeniTuketim = [];

      List<BarChartGroupData>
          yeniTutar = [];

      List<String>
          yeniAylar = [];

      double tuketimToplam = 0;

      double odemeToplam = 0;

      int odendi = 0;

      int odenmedi = 0;

      double maxTuketim = 0;

      double maxTutar = 0;

      for (int i = 0;
          i < filtreli.length;
          i++) {

        final veri = filtreli[i];

        final tarih = DateTime.parse(
          veri['fatura_tarihi'],
        );

        final ay =
            '${tarih.month}/${tarih.year}';

        yeniAylar.add(ay);

        final tuketim =
            (veri['tuketim_miktari']
                    as num)
                .toDouble();

        final tutar =
            (veri['toplam_tutar']
                    as num)
                .toDouble();

        tuketimToplam += tuketim;

        odemeToplam += tutar;

        if (veri['durum'] ==
            'Odendi') {

          odendi++;

        } else {

          odenmedi++;
        }

        if (tuketim > maxTuketim) {
          maxTuketim = tuketim;
        }

        if (tutar > maxTutar) {
          maxTutar = tutar;
        }

        yeniTuketim.add(

          FlSpot(
            i.toDouble(),
            tuketim,
          ),
        );

        yeniTutar.add(

          BarChartGroupData(

            x: i,

            barRods: [

              BarChartRodData(
                toY: tutar,
                width: 18,
                borderRadius:
                    BorderRadius.circular(
                  6,
                ),
              ),
            ],
          ),
        );
      }

      setState(() {

        faturalar = filtreli;

        aylar = yeniAylar;

        tuketimSpots =
            yeniTuketim;

        tutarBars =
            yeniTutar;

        toplamTuketim =
            tuketimToplam;

        toplamOdeme =
            odemeToplam;

        odenenFatura =
            odendi;

        odenmeyenFatura =
            odenmedi;

        maxTuketimY =
            maxTuketim * 1.3;

        maxTutarY =
            maxTutar * 1.3;

        loading = false;
      });

    } catch (e) {

      debugPrint(e.toString());

      setState(() {
        loading = false;
      });
    }
  }

  Widget ustKart(
    String baslik,
    String deger,
    IconData icon,
  ) {

    return Expanded(

      child: Container(

        padding:
            const EdgeInsets.all(16),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
            20,
          ),
        ),

        child: Column(

          children: [

            Icon(
              icon,
              size: 34,
              color:
                  const Color(0xFF2D1457),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(

              deger,

              style: const TextStyle(

                fontSize: 22,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              baslik,
            ),
          ],
        ),
      ),
    );
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

      onRefresh: verileriGetir,

      child: SingleChildScrollView(

        physics:
            const AlwaysScrollableScrollPhysics(),

        padding:
            const EdgeInsets.all(
          16,
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(

              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                const Text(

                  "Fatura Analizi",

                  style: TextStyle(

                    fontSize: 28,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                DropdownButton<int>(

                  value:
                      seciliPeriyot,

                  items: const [

                    DropdownMenuItem(
                      value: 3,
                      child: Text(
                        "3 Ay",
                      ),
                    ),

                    DropdownMenuItem(
                      value: 6,
                      child: Text(
                        "6 Ay",
                      ),
                    ),

                    DropdownMenuItem(
                      value: 12,
                      child: Text(
                        "12 Ay",
                      ),
                    ),
                  ],

                  onChanged: (value) {

                    setState(() {

                      seciliPeriyot =
                          value!;
                    });

                    verileriGetir();
                  },
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            Row(

              children: [

                ustKart(
                  "Toplam Tüketim",
                  toplamTuketim
                      .toStringAsFixed(0),
                  Icons.water_drop,
                ),

                const SizedBox(
                  width: 12,
                ),

                ustKart(
                  "Toplam Ödeme",
                  '₺ ${toplamOdeme.toStringAsFixed(0)}',
                  Icons.payments,
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            Row(

              children: [

                ustKart(
                  "Ödenen",
                  odenenFatura
                      .toString(),
                  Icons.check_circle,
                ),

                const SizedBox(
                  width: 12,
                ),

                ustKart(
                  "Bekleyen",
                  odenmeyenFatura
                      .toString(),
                  Icons.warning,
                ),
              ],
            ),

            const SizedBox(
              height: 24,
            ),

            Container(

              padding:
                  const EdgeInsets.all(
                18,
              ),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(

                    "Tüketim Grafiği",

                    style: TextStyle(

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  SizedBox(

                    height: 320,

                    child: LineChart(

                      LineChartData(
clipData: const FlClipData.none(),
                        minY: 0,

                        maxY:
                            maxTuketimY,

                        lineBarsData: [

                          LineChartBarData(

                            spots:
                                tuketimSpots,

                            isCurved: true,

                            barWidth: 4,

                            dotData:
                                const FlDotData(
                              show: true,
                            ),
                          ),
                        ],

                        titlesData:
                            FlTitlesData(

                          rightTitles:
                              const AxisTitles(
                            sideTitles:
                                SideTitles(
                                  
                              showTitles:
                                  false,
                                  reservedSize: 50,
                            ),
                          ),

                          topTitles:
                              const AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles:
                                  false,
                            ),
                          ),

                          bottomTitles:
                              AxisTitles(

                            sideTitles:
                                SideTitles(

                              showTitles:
                                  true,

                              getTitlesWidget:
                                  (value, meta) {
if (value < 0) {
  return const SizedBox();
}
                                final index =
                                    value
                                        .toInt();

                                if (index <
                                        0 ||
                                    index >=
                                        aylar.length) {

                                  return const SizedBox();
                                }

                                return Transform.rotate(

  angle: -0.45,

  child: Text(

    aylar[index],

    style: const TextStyle(
      fontSize: 10,
    ),
  ),
);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            Container(

              padding:
                  const EdgeInsets.all(
                18,
              ),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(

                    "Aylık Fatura Tutarları",

                    style: TextStyle(

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  SizedBox(

                    height: 300,

                    child: BarChart(

                      BarChartData(

                        maxY:
                            maxTutarY,

                        barGroups:
                            tutarBars,

                        titlesData:
                            FlTitlesData(

                          rightTitles:
                              const AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles:
                                  false,
                            ),
                          ),

                          topTitles:
                              const AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles:
                                  false,
                            ),
                          ),

                          bottomTitles:
                              AxisTitles(

                            sideTitles:
                                SideTitles(

                              showTitles:
                                  true,

                              getTitlesWidget:
                                  (value, meta) {

                                final index =
                                    value
                                        .toInt();

                                if (index <
                                        0 ||
                                    index >=
                                        aylar.length) {

                                  return const SizedBox();
                                }

                                return Transform.rotate(

                                  angle: -0.7,

                                  child: Text(

                                    aylar[
                                        index],

                                    style:
                                        const TextStyle(
                                      fontSize:
                                          10,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            Container(

              padding:
                  const EdgeInsets.all(
                18,
              ),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(

                    "Ödeme Durumu",

                    style: TextStyle(

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  SizedBox(

                    height: 250,

                    child: PieChart(

                      PieChartData(

                        sections: [

                         PieChartSectionData(

  value:
      odenenFatura
          .toDouble(),

  title:
      "Ödendi\n$odenenFatura",

  color: Colors.green,

  radius: 80,

  titleStyle: const TextStyle(

    color: Colors.white,

    fontWeight: FontWeight.bold,
  ),
),

                   PieChartSectionData(

  value:
      odenmeyenFatura
          .toDouble(),

  title:
      "Bekliyor\n$odenmeyenFatura",

  color: Colors.red,

  radius: 80,

  titleStyle: const TextStyle(

    color: Colors.white,

    fontWeight: FontWeight.bold,
  ),
),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 120,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminAnalizScreen extends StatefulWidget {

  final int firmaId;

  const AdminAnalizScreen({
    super.key,
    required this.firmaId,
  });

  @override
  State<AdminAnalizScreen> createState() =>
      _AdminAnalizScreenState();
}

class _AdminAnalizScreenState
    extends State<AdminAnalizScreen> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  int seciliAy = 6;

  double toplamTuketim = 0;

  double toplamTahsilat = 0;

  int odenmeyenSayisi = 0;

  int odenenSayisi = 0;

  double maxTuketimY = 100;

  double maxTahsilatY = 100;

  List<FlSpot> tuketimSpots = [];

  List<BarChartGroupData> tahsilatBars = [];

  List<PieChartSectionData> pastaData = [];

  List<String> grafikAylar = [];

  List<dynamic> enCokTuketenler = [];

  @override
  void initState() {

    super.initState();

    analizGetir();
  }

  Future<void> analizGetir() async {

    setState(() {
      loading = true;
    });

    try {

      final baslangicTarihi =

          DateTime.now().subtract(
        Duration(days: seciliAy * 30),
      );

      final response =

          await supabase

          .from('fatura_detay')

          .select()

          .eq(
            'firma_id',
            widget.firmaId,
          )

          .gte(
            'fatura_tarihi',
            baslangicTarihi
                .toIso8601String(),
          );

      final now = DateTime.now();

      Map<String, double> aylikTuketim = {};

      Map<String, double> aylikTahsilat = {};

      List<String> aySirasi = [];

      double tuketimToplam = 0;

      double tahsilatToplam = 0;

      int odenmeyen = 0;

      int odendi = 0;

      for (int i = seciliAy - 1; i >= 0; i--) {

        final tarih = DateTime(
          now.year,
          now.month - i,
        );

        final ayText =

            "${tarih.month}"
            "/"
            "${tarih.year}";

        aySirasi.add(ayText);

        aylikTuketim[ayText] = 0;

        aylikTahsilat[ayText] = 0;
      }

      for (var item in response) {

        final tarih = DateTime.parse(
          item['fatura_tarihi'],
        );

        final key =

            "${tarih.month}"
            "/"
            "${tarih.year}";

        if (!aylikTuketim.containsKey(key)) {
          continue;
        }

        final tuketim =
            (item['tuketim_miktari'] ?? 0)
                .toDouble();

        final tutar =
            (item['toplam_tutar'] ?? 0)
                .toDouble();

        aylikTuketim[key] =
            aylikTuketim[key]! +
                tuketim;

        tuketimToplam += tuketim;

        if (item['durum'] == 'Odendi') {

          aylikTahsilat[key] =
              aylikTahsilat[key]! +
                  tutar;

          tahsilatToplam += tutar;

          odendi++;

        } else {

          odenmeyen++;
        }
      }

      List<FlSpot> lineData = [];

      List<BarChartGroupData> barData = [];

      double enBuyukTuketim = 0;

      double enBuyukTahsilat = 0;

      for (int i = 0; i < aySirasi.length; i++) {

        final key = aySirasi[i];

        final tuketimDeger =
            aylikTuketim[key]!;

        final tahsilatDeger =
            aylikTahsilat[key]!;

        if (tuketimDeger >
            enBuyukTuketim) {

          enBuyukTuketim =
              tuketimDeger;
        }

        if (tahsilatDeger >
            enBuyukTahsilat) {

          enBuyukTahsilat =
              tahsilatDeger;
        }

        lineData.add(

          FlSpot(
            i.toDouble(),
            tuketimDeger,
          ),
        );

        barData.add(

          BarChartGroupData(

            x: i,

            barRods: [

              BarChartRodData(

                toY:
                    tahsilatDeger,

                width: 22,

                borderRadius:
                    BorderRadius.circular(
                  8,
                ),

                color:
                    Colors.deepPurple,
              ),
            ],
          ),
        );
      }

      final enCokResponse =

          await supabase

          .from('fatura_detay')

          .select()

          .eq(
            'firma_id',
            widget.firmaId,
          )

          .order(
            'tuketim_miktari',
            ascending: false,
          )

          .limit(5);

      setState(() {

        toplamTuketim =
            tuketimToplam;

        toplamTahsilat =
            tahsilatToplam;

        odenmeyenSayisi =
            odenmeyen;

        odenenSayisi =
            odendi;

        tuketimSpots =
            lineData;

        tahsilatBars =
            barData;

        grafikAylar =
            aySirasi;

        maxTuketimY =
            enBuyukTuketim * 1.25;

        maxTahsilatY =
            enBuyukTahsilat * 1.25;

        pastaData = [

          PieChartSectionData(

            value:
                odenenSayisi.toDouble(),

            title:
                'Ödendi\n$odenenSayisi',

            color: Colors.green,

            radius: 75,

            titleStyle:
                const TextStyle(

              color: Colors.white,

              fontWeight:
                  FontWeight.bold,

              fontSize: 15,
            ),
          ),

          PieChartSectionData(

            value:
                odenmeyenSayisi.toDouble(),

            title:
                'Bekliyor\n$odenmeyenSayisi',

            color: Colors.red,

            radius: 75,

            titleStyle:
                const TextStyle(

              color: Colors.white,

              fontWeight:
                  FontWeight.bold,

              fontSize: 15,
            ),
          ),
        ];

        enCokTuketenler =
            enCokResponse;

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
    String title,
    String value,
    IconData icon,
    Color color,
  ) {

    return Expanded(

      child: Container(

        height: 160,

        margin:
            const EdgeInsets.all(6),

        padding:
            const EdgeInsets.all(18),

        decoration: BoxDecoration(

          color: color,

          borderRadius:
              BorderRadius.circular(
            24,
          ),
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            CircleAvatar(

              radius: 24,

              backgroundColor:
                  Colors.white24,

              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),

            const Spacer(),

            Text(

              title,

              style:
                  const TextStyle(

                color: Colors.white70,

                fontSize: 16,
              ),
            ),

            const SizedBox(height: 12),

            Text(

              value,

              style:
                  const TextStyle(

                color: Colors.white,

                fontSize: 22,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget grafikKutusu({
    required String title,
    required Widget child,
    required double height,
  }) {

    return Container(

      margin:
          const EdgeInsets.only(
        bottom: 28,
      ),

      padding:
          const EdgeInsets.all(18),

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

          Text(

            title,

            style:
                const TextStyle(

              fontSize: 22,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(

            height: height,

            child: child,
          ),
        ],
      ),
    );
  }

  Widget altTitleWidgets(
    double value,
    TitleMeta meta,
  ) {

    final index = value.toInt();

    if (index < 0 ||
        index >= grafikAylar.length) {

      return const SizedBox();
    }

    return SideTitleWidget(

      meta: meta,

      child: Transform.rotate(

        angle: -0.8,

        child: Text(

          grafikAylar[index],

          style: const TextStyle(
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return loading

        ? const Center(
            child:
                CircularProgressIndicator(),
          )

        : RefreshIndicator(

            onRefresh: analizGetir,

            child:
                SingleChildScrollView(

              physics:
                  const AlwaysScrollableScrollPhysics(),

              padding:
                  const EdgeInsets.all(
                16,
              ),

              child: Column(

                children: [

                  Row(

                    children: [

                      ustKart(

                        "Toplam Tüketim",

                        "${toplamTuketim.toStringAsFixed(0)} m³",

                        Icons.water_drop,

                        Colors.deepPurple,
                      ),

                      ustKart(

                        "Tahsilat",

                        "₺ ${toplamTahsilat.toStringAsFixed(0)}",

                        Icons.payments,

                        Colors.green,
                      ),
                    ],
                  ),

                  Row(

                    children: [

                      ustKart(

                        "Ödenmeyen",

                        "$odenmeyenSayisi",

                        Icons.warning,

                        Colors.red,
                      ),

                      ustKart(

                        "Periyot",

                        "$seciliAy Ay",

                        Icons.calendar_month,

                        Colors.orange,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(

                    mainAxisAlignment:
                        MainAxisAlignment.end,

                    children: [

                      DropdownButton<int>(

                        value: seciliAy,

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

                          seciliAy = value!;

                          analizGetir();
                        },
                      ),
                    ],
                  ),

                  grafikKutusu(

                    title:
                        "Aylık Tüketim Analizi",

                    height: 300,

                    child: LineChart(

                      LineChartData(

                        minY: 0,

                        maxY: maxTuketimY,

                        borderData:
                            FlBorderData(
                          show: false,
                        ),

                        gridData:
                            const FlGridData(
                          show: true,
                        ),

                        titlesData:
                            FlTitlesData(

                          topTitles:
                              const AxisTitles(

                            sideTitles:
                                SideTitles(
                              showTitles: false,
                            ),
                          ),

                          rightTitles:
                              const AxisTitles(

                            sideTitles:
                                SideTitles(
                              showTitles: false,
                            ),
                          ),

                          bottomTitles:
                              AxisTitles(

                            sideTitles:
                                SideTitles(

                              showTitles: true,

                              reservedSize:
                                  60,

                              interval: 1,

                              getTitlesWidget:
                                  altTitleWidgets,
                            ),
                          ),
                        ),

                        lineBarsData: [

                          LineChartBarData(

                            spots:
                                tuketimSpots,

                            isCurved: true,

                            preventCurveOverShooting:
                                true,

                            color:
                                Colors.deepPurple,

                            barWidth: 4,

                            belowBarData:
                                BarAreaData(
                              show: true,
                              color: Colors.deepPurple.withOpacity(0.12),
                            ),

                            dotData:
                                const FlDotData(
                              show: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  grafikKutusu(

                    title:
                        "Aylık Tahsilat",

                    height: 300,

                    child: BarChart(

                      BarChartData(

                        minY: 0,

                        maxY: maxTahsilatY,

                        borderData:
                            FlBorderData(
                          show: false,
                        ),

                        gridData:
                            const FlGridData(
                          show: true,
                        ),

                        titlesData:
                            FlTitlesData(

                          topTitles:
                              const AxisTitles(

                            sideTitles:
                                SideTitles(
                              showTitles: false,
                            ),
                          ),

                          rightTitles:
                              const AxisTitles(

                            sideTitles:
                                SideTitles(
                              showTitles: false,
                            ),
                          ),

                          bottomTitles:
                              AxisTitles(

                            sideTitles:
                                SideTitles(

                              showTitles: true,

                              reservedSize:
                                  60,

                              interval: 1,

                              getTitlesWidget:
                                  altTitleWidgets,
                            ),
                          ),
                        ),

                        barGroups:
                            tahsilatBars,
                      ),
                    ),
                  ),

                  grafikKutusu(

                    title:
                        "Ödeme Durumu",

                    height: 320,

                    child: Column(

                      children: [

                        Expanded(

                          child: PieChart(

                            PieChartData(

                              sections:
                                  pastaData,

                              centerSpaceRadius:
                                  55,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        Row(

                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [

                            Container(

                              width: 16,

                              height: 16,

                              color: Colors.green,
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            const Text(
                              "Ödendi",
                            ),

                            const SizedBox(
                              width: 24,
                            ),

                            Container(

                              width: 16,

                              height: 16,

                              color: Colors.red,
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            const Text(
                              "Bekleyen",
                            ),
                          ],
                        ),
                      ],
                    ),
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
                        24,
                      ),
                    ),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        const Text(

                          "En Çok Tüketenler",

                          style: TextStyle(

                            fontSize: 22,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        ...enCokTuketenler.map(

                          (musteri) {

                            return Container(

                              margin:
                                  const EdgeInsets.only(
                                bottom: 14,
                              ),

                              child: Row(

                                children: [

                                  const CircleAvatar(

                                    radius: 24,

                                    backgroundColor:
                                        Colors.deepPurple,

                                    child: Icon(

                                      Icons.person,

                                      color:
                                          Colors.white,
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 14,
                                  ),

                                  Expanded(

                                    child: Column(

                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [

                                        Text(

                                          '${musteri['ad']} ${musteri['soyad']}',

                                          style:
                                              const TextStyle(

                                            fontSize: 17,

                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(
                                          height: 4,
                                        ),

                                        Text(

                                          '${musteri['tuketim_miktari']} m³ kullanım',
                                        ),
                                      ],
                                    ),
                                  ),

                                  Text(

                                    '₺ ${musteri['toplam_tutar']}',

                                    style:
                                        const TextStyle(

                                      color:
                                          Colors.deepPurple,

                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}


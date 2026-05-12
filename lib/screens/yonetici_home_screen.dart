import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'musteriler_screen.dart';
import 'admin_analiz_screen.dart';
import 'fatura_musteri_sec_screen.dart';
import 'login_screen.dart';
import 'nakit_odeme_screen.dart';
import 'birim_fiyat_screen.dart';
class YoneticiHomeScreen extends StatefulWidget {

  final int yoneticiId;
  final int firmaId;

  const YoneticiHomeScreen({
    super.key,
    required this.yoneticiId,
    required this.firmaId,
  });

  @override
  State<YoneticiHomeScreen> createState() =>
      _YoneticiHomeScreenState();
}

class _YoneticiHomeScreenState
    extends State<YoneticiHomeScreen> {

  final supabase = Supabase.instance.client;
String seciliMenu = 'Dashboard';
int seciliIndex = 0;
int? seciliKullaniciId;
  final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  Map<String, dynamic>? dashboardData;

  List<dynamic> sonFaturalar = [];
List<BarChartGroupData>
    gelirGrafik = [];

List<String> grafikAylar = [];

double maxGelirY = 100;
  bool loading = true;

  @override
  void initState() {

    super.initState();

    verileriGetir();
  }

  Future<void> verileriGetir() async {

    try {

      final dashboardResponse =
          await supabase.rpc(

        'yonetici_dashboard_ozet',

        params: {
          'p_firma_id': widget.firmaId,
        },
      );

      final faturalarResponse =
    await supabase.rpc(

  'yonetici_son_faturalar',

  params: {
    'p_firma_id': widget.firmaId,
  },
);

final gelirResponse =
    await supabase

        .from('fatura_detay')

        .select()

        .eq(
          'firma_id',
          widget.firmaId,
        )

        .gte(
          'fatura_tarihi',

          DateTime.now()

              .subtract(
                const Duration(
                  days: 180,
                ),
              )

              .toIso8601String(),
        );
    await supabase

        .from('fatura_detay')

        .select()

        .eq(
          'firma_id',
          widget.firmaId,
        )

        .gte(
          'fatura_tarihi',

          DateTime.now()

              .subtract(
                const Duration(
                  days: 180,
                ),
              )

              .toIso8601String(),
        );
          await supabase.rpc(

        'yonetici_son_faturalar',

        params: {
          'p_firma_id': widget.firmaId,
        },
      );
Map<String, double>
    aylikGelir = {};

List<String> aylar = [];

final now = DateTime.now();

for (int i = 5; i >= 0; i--) {

  final tarih = DateTime(
    now.year,
    now.month - i,
  );

  final key =
      '${tarih.month}/${tarih.year}';

  aylar.add(key);

  aylikGelir[key] = 0;
}

for (var item in gelirResponse) {

  final tarih = DateTime.parse(
    item['fatura_tarihi'],
  );

  final key =
      '${tarih.month}/${tarih.year}';

  if (!aylikGelir.containsKey(key)) {
    continue;
  }

  if (item['durum'] == 'Odendi') {

    aylikGelir[key] =

        aylikGelir[key]! +

            (item['toplam_tutar'] ?? 0)
                .toDouble();
  }
}

List<BarChartGroupData>
    grafikData = [];

double enBuyuk = 0;

for (int i = 0; i < aylar.length; i++) {

  final gelir =
      aylikGelir[aylar[i]]!;

  if (gelir > enBuyuk) {
    enBuyuk = gelir;
  }

  grafikData.add(
    barItem(i, gelir),
  );
}
      setState(() {

        dashboardData =
            dashboardResponse.first;

        sonFaturalar =
            faturalarResponse;
gelirGrafik =
    grafikData;

grafikAylar =
    aylar;

maxGelirY =
    enBuyuk * 1.25;
        loading = false;
      });

    } catch (e) {

      debugPrint(e.toString());

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {

      return const Scaffold(

        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      key: scaffoldKey,

      backgroundColor:
          const Color(0xFFF5F6FA),

      drawer: drawerMenu(),

      appBar: AppBar(

        elevation: 0,

        backgroundColor: Colors.white,

        leading: IconButton(

          onPressed: () {

            scaffoldKey.currentState
                ?.openDrawer();

          },

          icon: const Icon(
            Icons.menu,
            color: Colors.black,
          ),
        ),

        title: Text(

  seciliMenu,

  style: const TextStyle(

    color: Colors.black,

    fontWeight: FontWeight.bold,
  ),
),
        actions: [

          IconButton(

            onPressed: () {},

            icon: const Icon(
              Icons.notifications_none,
              color: Colors.black,
            ),
          ),

          Padding(

            padding:
                const EdgeInsets.only(
              right: 16,
            ),

            child: Row(

              children: [

                const CircleAvatar(

                  radius: 18,

                  backgroundColor:
                      Color(0xFF2D1457),

                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 8),

                Column(

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: const [

                    Text(
                      "Yönetici",

                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),

                    Text(
                      "Admin",

                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),

     body:

  

seciliIndex == 0

    ? dashboardBody()

    : seciliIndex == 1

        ? MusterilerScreen(
            firmaId:
                widget.firmaId,
          )

        : seciliIndex == 2

            ? FaturaMusteriSecScreen(
                firmaId:
                    widget.firmaId,
              )

            : seciliIndex == 3

                ? NakitOdemeScreen(
                    firmaId:
                        widget.firmaId,
                  )
    : seciliIndex == 4

        ? AdminAnalizScreen(
            firmaId:
                widget.firmaId,
          )
: seciliIndex == 5

    ? BirimFiyatScreen(
        firmaId: widget.firmaId,
      )
                : dashboardBody()

    );    
  }

  Widget dashboardCard({

    required String title,

    required String value,

    required String subtitle,

    required Color color,

    required IconData icon,
  }) {

    return Container(

      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: color,

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          CircleAvatar(

            radius: 18,

            backgroundColor:
                Colors.white.withOpacity(0.2),

            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 18),

          Text(

            title,

            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 8),

          Text(

            value,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(

            subtitle,

            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
BarChartGroupData barItem(
  int x,
  double y,
) {

  return BarChartGroupData(

    x: x,

    barRods: [

      BarChartRodData(

        toY: y,

        width: 24,

        borderRadius:
            BorderRadius.circular(8),

        color: const Color(0xFFFFA726),
      ),
    ],
  );
}
  Drawer drawerMenu() {

    return Drawer(

      backgroundColor:
          const Color(0xFF2D1457),

      child: SafeArea(

        child: Padding(

          padding:
              const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const Row(

                children: [

                  Icon(
                    Icons.water_drop,
                    color: Colors.orange,
                    size: 36,
                  ),

                  SizedBox(width: 12),

                  Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(

                        "FATURA TAKİP",

                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),

                      Text(

                        "YÖNETİCİ PANELİ",

                        style: TextStyle(
                          color:
                              Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              drawerItem(
                Icons.dashboard,
                "Dashboard",
               seciliMenu == "Dashboard",
              ()async {

  setState(() {

    seciliMenu = "Dashboard";
    seciliIndex = 0;

  });
  await verileriGetir();
  Navigator.pop(context);
},
              ),

              drawerItem(
                Icons.people,
                "Müşteriler",
               seciliMenu == "Müşteriler",
                () {
setState(() {
  seciliMenu = "Müşteriler";
});
  setState(() {

  seciliMenu = "Müşteriler";
  seciliIndex = 1;

});

Navigator.pop(context);
  },
),

drawerItem(

  Icons.edit_note,

  "Fatura Oluştur",

  seciliMenu ==
      "Fatura Oluştur",

  () {

    setState(() {

      seciliMenu =
          "Fatura Oluştur";

      seciliIndex = 2;
    });

    Navigator.pop(context);
  },

              ),

           drawerItem(

  Icons.payments,

  "Ödemeler",

  seciliMenu == "Ödemeler",

  () {

    setState(() {

      seciliMenu = "Ödemeler";

      seciliIndex = 3;
    });

    Navigator.pop(context);
  },
),
drawerItem(

  Icons.bar_chart,

  "Analiz",

  seciliMenu == "Analiz",

  () {

    setState(() {

      seciliMenu = "Analiz";

      seciliIndex = 4;
    });
Navigator.pop(context);

Future.delayed(

  const Duration(milliseconds: 200),

  () {

    if (mounted) {

      setState(() {});
    }
  },
);

return;
  
  },
),drawerItem(

  Icons.water_drop,

  "Birim Fiyat",

  seciliMenu == "Birim Fiyat",

  () {

    setState(() {

      seciliMenu =
          "Birim Fiyat";

      seciliIndex = 5;
    });

    Navigator.pop(context);
  },
),

              const Spacer(),

              drawerItem(
                Icons.logout,
                "Çıkış Yap",
                false,
               () async {

  await Supabase.instance.client.auth.signOut();

  if (context.mounted) {

    Navigator.pushAndRemoveUntil(

      context,

      MaterialPageRoute(

        builder: (context) => const LoginScreen(),
      ),

      (route) => false,
    );
  }
},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget drawerItem(
    IconData icon,
    String title,
    bool selected,
      VoidCallback onTap,
  ) {

    return GestureDetector(

  onTap: onTap,

  child: Container(

      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),

      decoration: BoxDecoration(

        color: selected
            ? Colors.white
            : Colors.transparent,

        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Row(

        children: [

          Icon(

            icon,

            color: selected
                ? const Color(0xFF2D1457)
                : Colors.white,
          ),

          const SizedBox(width: 14),

          Text(

            title,

            style: TextStyle(

              color: selected
                  ? const Color(0xFF2D1457)
                  : Colors.white,

              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
  ),
    );
    
  }
 Widget dashboardBody() {

 return RefreshIndicator(
  onRefresh: () async {

  await verileriGetir();

  setState(() {});
},
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(16),

    child: Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Row(

          children: [

            Expanded(

              child: dashboardCard(

                title: "Toplam Müşteri",

                value:
                    '${dashboardData?['toplam_musteri'] ?? 0}',

                subtitle: "Aktif abone",

                color:
                    const Color(0xFFFFA726),

                icon: Icons.people,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(

              child: dashboardCard(

                title: "Gelir",

                value:
                    '₺ ${dashboardData?['aylik_gelir'] ?? 0}',

                subtitle: "Toplam ödeme",

                color:
                    const Color(0xFF4CAF50),

                icon: Icons.payments,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(

          children: [

            Expanded(

              child: dashboardCard(

                title: "Ödenmeyen",

                value:
                    '${dashboardData?['odenmeyen_fatura'] ?? 0}',

                subtitle: "Bekleyen fatura",

                color:
                    const Color(0xFFE53935),

                icon:
                    Icons.receipt_long,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(

              child: dashboardCard(

                title: "Tüketim",

                value:
                    '${dashboardData?['toplam_tuketim'] ?? 0} m³',

                subtitle:
                    "Toplam kullanım",

                color:
                    const Color(0xFF7E57C2),

                icon:
                    Icons.water_drop,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Container(

          width: double.infinity,

          padding:
              const EdgeInsets.all(16),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
                BorderRadius.circular(20),
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

                    "Aylık Gelir",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Container(

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),

                    decoration:
                        BoxDecoration(

                      color:
                          Colors.grey.shade200,

                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),

                    child:
                        const Text("6 Ay"),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(

                height: 250,

                child: BarChart(

                  BarChartData(

                    alignment:
                        BarChartAlignment.spaceAround,
maxY: maxGelirY,

                    gridData:
                        FlGridData(show: true),

                    borderData:
                        FlBorderData(show: false),

                    titlesData:
                        FlTitlesData(

                      topTitles:
                          AxisTitles(
                        sideTitles:
                            SideTitles(
                          showTitles:
                              false,
                        ),
                      ),

                      rightTitles:
                          AxisTitles(
                        sideTitles:
                            SideTitles(
                          showTitles:
                              false,
                        ),
                      ),

                      leftTitles:
                          AxisTitles(

                        sideTitles:
                            SideTitles(

                          showTitles:
                              true,

                          reservedSize:
                              42,

                          getTitlesWidget:
                              (value, meta) {

                            return Text(

                              '${(value / 1000).toInt()}K',

                              style:
                                  const TextStyle(
                                fontSize: 11,
                              ),
                            );
                          },
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
final index = value.toInt();

if (index < 0 ||
    index >= grafikAylar.length) {

  return const SizedBox();
}

return Padding(

  padding:
      const EdgeInsets.only(
    top: 10,
  ),

  child: Transform.rotate(

    angle: -0.7,

    child: Text(

      grafikAylar[index],

      style: const TextStyle(
        fontSize: 10,
      ),
    ),
  ),
);
return Padding(

  padding:
      const EdgeInsets.only(
    top: 10,
  ),

  child: Transform.rotate(

    angle: -0.7,

    child: Text(

      grafikAylar[index],

      style: const TextStyle(
        fontSize: 10,
      ),
    ),
  ),
);
                          },
                        ),
                      ),
                    ),

             barGroups: gelirGrafik,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Container(

          width: double.infinity,

          padding:
              const EdgeInsets.all(16),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
                BorderRadius.circular(20),
          ),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const Text(

                "Son 5 Ödenmeyen Fatura",

                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              ...sonFaturalar.map((fatura) {

                return Padding(

                  padding:
                      const EdgeInsets.only(
                    bottom: 14,
                  ),

                  child: Row(

                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [

                      Text(
                        '${fatura['ad']} ${fatura['soyad']}',
                      ),

                      Text(
                        '₺ ${fatura['toplam_tutar']}',
                      ),

                      Text(

                        fatura['durum'],

                        style: TextStyle(

                          color:
                              fatura['durum'] ==
                                      'Gecikmis'

                                  ? Colors.red

                                  : Colors.orange,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    ),
    ),
);
}
      
}
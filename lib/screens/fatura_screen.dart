import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_screen.dart';
import 'analiz_screen.dart';
import 'odeme_screen.dart';
class FaturalarScreen extends StatefulWidget {
  final int? kullaniciId;

  const FaturalarScreen({super.key, this.kullaniciId
});

  @override
  State<FaturalarScreen> createState() => _FaturalarScreenState();
}

class _FaturalarScreenState extends State<FaturalarScreen> {
  
  final supabase = Supabase.instance.client;
  int selectedIndex = 0;
  bool isLoading = true;
 Map<String, dynamic>? secilenFatura;
  String hataMesaji = '';
  List<dynamic> faturalar = [];

  @override
  void initState() {
    super.initState();
    faturalariGetir();
  }

  Future<void> faturalariGetir() async {
    setState(() {
      isLoading = true;
      hataMesaji = '';
    });

    try {
      dynamic response;

      if (widget.kullaniciId != null) {
        response = await supabase.rpc(
          'kullanici_faturalari_getir',
          params: {'p_kullanici_id': widget.kullaniciId},
        );
      } else {
        response = await supabase
            .from('fatura_detay')
            .select()
            .order('fatura_tarihi', ascending: false);
      }

      setState(() {
        faturalar = response as List<dynamic>;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hataMesaji = e.toString();
        isLoading = false;
      });
    }
  }

  Color durumRenk(String durum) {
    switch (durum) {
      case 'Odendi':
        return Colors.green;
      case 'Gecikmis':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  String formatTarih(dynamic tarih) {
    if (tarih == null) return '-';
    final text = tarih.toString();
    if (text.length >= 10) {
      final parcalar = text.substring(0, 10).split('-');
      if (parcalar.length == 3) {
        return '${parcalar[2]}.${parcalar[1]}.${parcalar[0]}';
      }
    }
    return text;
  }

  Future<void> odemeYap(Map<String, dynamic> fatura) async {
    final faturaId = fatura['fatura_id'];
    final toplamTutar = (fatura['toplam_tutar'] ?? 0).toDouble();

    try {
      await supabase.from('odeme').insert({
        'fatura_id': faturaId,
        'odeme_tarihi': DateTime.now().toIso8601String().split('T').first,
        'odeme_turu': 'Kart',
        'odeme_tutari': toplamTutar,
      });

      await supabase
          .from('fatura')
          .update({'durum': 'Odendi'})
          .eq('fatura_id', faturaId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ödeme başarılı')),
      );

      await faturalariGetir();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ödeme hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 202, 202, 202),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 249, 250, 251),
        elevation: 0,
        //centerTitle: true,
        title: const Text(
          'Fatura Takip',
          style: TextStyle(
            color: Color(0xFF1565A9),
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
     actions: [
  Padding(
    padding: const EdgeInsets.only(right: 10),
    child: InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () {
        if (widget.kullaniciId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(
                kullaniciId: widget.kullaniciId!,
               
              ),
            ),
          );
        }
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFF1565A9),
        child: const Icon(
          Icons.person,
          color: Colors.white,
          size: 22,
        ),
      ),
    ),
  ),
],
      ),
     body: IndexedStack(
  index: selectedIndex,
  children: [
    _faturalarBody(),
   OdemeScreen(

  fatura: secilenFatura,

  faturalar: faturalar,

  odemeBasarili: () async {

    await faturalariGetir();

    setState(() {
      selectedIndex = 0;
    });
  },
),
    AnalizScreen(
  kullaniciId: widget.kullaniciId!,
),
  ],
),
     bottomNavigationBar: Container(
  height: 84,
  decoration: const BoxDecoration(
    color: Color(0xFF0B4574),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(30),
      topRight: Radius.circular(30),
    ),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      _BottomNavItem(
        icon: Icons.receipt_long,
        label: 'Faturalar',
        onTap: () {setState(() {
      selectedIndex = 0;
      Map<String, dynamic>? secilenFatura;
    });},
      ),
      _BottomNavItem(
  icon: Icons.credit_card,
  label: 'Ödeme',
  onTap: () {

    setState(() {

      selectedIndex = 1;

    });
  },
),
      _BottomNavItem(
        icon: Icons.bar_chart,
        label: 'Analiz',
        onTap: () {  setState(() {
    selectedIndex = 2;
  });},
      ),
 
          
    ],
  ),
),
    );
  }
  Widget _faturalarBody() {
  return RefreshIndicator(
    onRefresh: faturalariGetir,
    child: isLoading
        ? const Center(child: CircularProgressIndicator())
        : hataMesaji.isNotEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(child: Text(hataMesaji)),
                ],
              )
            : faturalar.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          'Gösterilecek fatura bulunamadı',
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: faturalar.length,
                    itemBuilder: (context, index) {
                      final fatura =
                          faturalar[index] as Map<String, dynamic>;

                      return FaturaCard(
                        fatura: fatura,
                        formatTarih: formatTarih,
                        durumRenk: durumRenk,
                       onOde: () {

  setState(() {

    secilenFatura = fatura;

    selectedIndex = 1;

  });
},
                      );
                    },
                  ),
  );
}
}
class FaturaCard extends StatelessWidget {
  final Map<String, dynamic> fatura;
  final String Function(dynamic) formatTarih;
  final Color Function(String) durumRenk;
  final VoidCallback onOde;

  const FaturaCard({
    super.key,
    required this.fatura,
    required this.formatTarih,
    required this.durumRenk,
    required this.onOde,
  });

  @override
  Widget build(BuildContext context) {
    final durum = (fatura['durum'] ?? 'Odenmedi').toString();
    final odendiMi = durum == 'Odendi';
    final sonOdemeTarihi = formatTarih(fatura['sonodeme_tarihi']);
    final faturaTarihi = formatTarih(fatura['fatura_tarihi']);
    final tutar = ((fatura['toplam_tutar'] ?? 0) as num).toStringAsFixed(2);
    final faturaNo = fatura['fatura_id']?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fatura No: $faturaNo',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fatura Tarihi: $faturaTarihi',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.black),
              children: [
                const TextSpan(text: 'Son Ödeme Tarihi: '),
                TextSpan(
                  text: sonOdemeTarihi,
                  style: TextStyle(
                    color: durum == 'Gecikmis' ? Colors.red[700] : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Fatura Tutarı: $tutar TL',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0E4D87),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Fatura Durumu: ',
                style: TextStyle(fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: durumRenk(durum),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  durum,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              odendiMi
                  ? TextButton(
                      onPressed: () {},
                      child: const Text(
                        '',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : SizedBox(
                      width: 110,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: onOde,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C73B3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Öde',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
});

  @override
  Widget build(BuildContext context) {
    return InkWell(
  onTap: onTap,
  child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
       ),
      ],
    ),
  );
}
}
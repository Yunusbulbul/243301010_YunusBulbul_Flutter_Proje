import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int kullaniciId;


  const ProfileScreen({
    super.key,
    required this.kullaniciId,
  
  });
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? kullanici;
  List<dynamic> sonGirisler = [];

  bool yukleniyor = true;


  @override
  void initState() {
    super.initState();
    profilBilgileriniGetir();
  }

  Future<void> profilBilgileriniGetir() async {
    try {
      final kullaniciData = await supabase
          .from('kullanici')
          .select()
          .eq('kullanici_id', widget.kullaniciId)
          .single();

      final logData = await supabase
          .from('giris_loglari')
          .select()
          .eq('kullanici_id', widget.kullaniciId)
          .order('giris_tarihi', ascending: false)
          ;

      setState(() {
        kullanici = kullaniciData;
        sonGirisler = logData;
        yukleniyor = false;
      });
    } catch (e) {
      setState(() {
        yukleniyor = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil bilgileri alınamadı: $e')),
      );
    }
  }

  String formatTarih(dynamic tarih) {
    if (tarih == null) return '-';

    final date = DateTime.tryParse(tarih.toString());
    if (date == null) return tarih.toString();

    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  void sonGirisleriGoster() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        if (sonGirisler.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Son giriş kaydı bulunamadı.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sonGirisler.length,
          itemBuilder: (context, index) {
            final log = sonGirisler[index];

            return ListTile(
              leading: const Icon(Icons.history),
              title: Text('Giriş'),
              subtitle: Text(formatTarih(log['giris_tarihi'])),
            );
          },
        );
      },
    );
  }

  void cikisYap() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
  final bgColor = const Color(0xFFF2F5FA);
final cardColor = Colors.white;
final textColor = Colors.black;

    if (yukleniyor) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final ad = kullanici?['ad'] ?? '';
    final soyad = kullanici?['soyad'] ?? '';
    final email = kullanici?['email'] ?? '';
    final telefon = kullanici?['tel_no'] ?? '-';
    final kullaniciId = kullanici?['kullanici_id'] ?? '-';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565A9),
        centerTitle: true,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(cardColor),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 45,
                      backgroundColor: Color(0xFFE8EEF5),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFF0B4574),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$ad $soyad',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            'Email: $email',
                            style: TextStyle(fontSize: 16, color: textColor),
                          ),
                          Text(
                            'Kullanıcı ID: $kullaniciId',
                            style: TextStyle(fontSize: 16, color: textColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profil resmi değiştirme kısmı daha sonra bağlanacak'),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F0DF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, color: Color(0xFF0B4574)),
                        SizedBox(width: 8),
                        Text(
                          'Profil Resmini Düzenle',
                          style: TextStyle(fontSize: 17),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _sectionCard(
            cardColor: cardColor,
            title: 'Profil Bilgileri',
            textColor: textColor,
            children: [
              _infoRow(Icons.email, 'Email Adresi: $email', textColor),
              _infoRow(Icons.phone, 'Telefon Numarası: $telefon', textColor),
              _infoRow(Icons.key, 'Şifre Değiştir', textColor),
              _infoRow(Icons.badge, 'Kullanıcı ID: $kullaniciId', textColor),
            ],
          ),

          const SizedBox(height: 14),

          _sectionCard(
            cardColor: cardColor,
            title: 'Uygulama Ayarları',
            textColor: textColor,
            children: [
              _clickRow(
                icon: Icons.translate,
                text: 'Dil',
                value: 'Türkçe',
                textColor: textColor,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Şimdilik sadece Türkçe destekleniyor')),
                  );
                },
              ),
             
             
            ],
          ),

          const SizedBox(height: 14),

          _sectionCard(
            cardColor: cardColor,
            title: 'Hakkında',
            textColor: textColor,
            children: [
              _infoRow(Icons.menu_book, 'Kullanım Koşulları', textColor),
              _infoRow(Icons.shield, 'Gizlilik Politikası', textColor),
              _infoRow(Icons.star, 'Uygulamayı Puanla', textColor),
            ],
          ),

          const SizedBox(height: 14),

          _sectionCard(
            cardColor: cardColor,
            title: 'Güvenlik',
            textColor: textColor,
            children: [
              _clickRow(
                icon: Icons.history,
                text: 'Son Girişler',
                value: '',
                textColor: textColor,
                onTap: sonGirisleriGoster,
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: cikisYap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Çıkış Yap',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  Widget _sectionCard({
    required Color cardColor,
    required String title,
    required Color textColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0B4574)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 17, color: textColor),
            ),
          ),
          const Icon(Icons.edit, color: Color(0xFF0B4574), size: 20),
        ],
      ),
    );
  }

  Widget _clickRow({
    required IconData icon,
    required String text,
    required String value,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0B4574)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 17, color: textColor),
              ),
            ),
            if (value.isNotEmpty)
              Text(
                value,
                style: TextStyle(fontSize: 17, color: textColor),
              ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: textColor),
          ],
        ),
      ),
    );
  }
}
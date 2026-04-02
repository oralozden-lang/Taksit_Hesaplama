import 'package:flutter/material.dart';

void main() {
  runApp(const TaksitApp());
}

class TaksitApp extends StatelessWidget {
  const TaksitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taksit Hesaplama',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TaksitSayfasi(),
    );
  }
}

class AylikSatir {
  final int ay;
  final double baslangicBakiye;
  final double faizGetirisi;
  final double taksitOdemesi;
  final double kalanBakiye;

  AylikSatir({
    required this.ay,
    required this.baslangicBakiye,
    required this.faizGetirisi,
    required this.taksitOdemesi,
    required this.kalanBakiye,
  });
}

class TaksitSayfasi extends StatefulWidget {
  const TaksitSayfasi({super.key});

  @override
  State<TaksitSayfasi> createState() => _TaksitSayfasiState();
}

class _TaksitSayfasiState extends State<TaksitSayfasi> {
  final anaParaController = TextEditingController();
  final faizController = TextEditingController();
  final vadeFarkiController = TextEditingController();
  final taksitSayisiController = TextEditingController();
  final stopajController = TextEditingController();

  double? taksitTutari;
  double? toplamOdenecek;
  double? sonucFark;
  List<AylikSatir> taksitTablosu = [];

  void hesapla() {
    final anaPara = double.tryParse(
      anaParaController.text.replaceAll(',', '.'),
    );
    final yillikFaiz = double.tryParse(
      faizController.text.replaceAll(',', '.'),
    );
    final vadeFarki = double.tryParse(
      vadeFarkiController.text.replaceAll(',', '.'),
    );
    final taksitSayisi = int.tryParse(taksitSayisiController.text);

    if (anaPara == null ||
        yillikFaiz == null ||
        vadeFarki == null ||
        taksitSayisi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun!')),
      );
      return;
    }

    final stopaj =
        double.tryParse(stopajController.text.replaceAll(',', '.')) ?? 0;
    final brutGetiriOrani = (yillikFaiz / 100) / 365 * 30;
    final aylikFaizOrani = brutGetiriOrani * (1 - stopaj / 100);
    final toplam = anaPara + (anaPara * (vadeFarki / 100));
    final hesaplananTaksit = toplam / taksitSayisi;

    List<AylikSatir> tablo = [];
    double bakiye = anaPara;

    for (int ay = 1; ay <= taksitSayisi; ay++) {
      final faizGetirisi = bakiye * aylikFaizOrani;
      final kalanBakiye = bakiye + faizGetirisi - hesaplananTaksit;
      tablo.add(
        AylikSatir(
          ay: ay,
          baslangicBakiye: bakiye,
          faizGetirisi: faizGetirisi,
          taksitOdemesi: hesaplananTaksit,
          kalanBakiye: kalanBakiye,
        ),
      );
      bakiye = kalanBakiye;
    }

    setState(() {
      taksitTutari = hesaplananTaksit;
      toplamOdenecek = toplam;
      sonucFark = bakiye;
      taksitTablosu = tablo;
    });
  }

  String formatTutar(double tutar) {
    final prefix = tutar < 0 ? '-₺' : '₺';
    return '$prefix${tutar.abs().toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taksit Hesaplama'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Parametreler',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: anaParaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ana Para',
                        border: OutlineInputBorder(),
                        prefixText: '₺',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: faizController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Yıllık Faiz / Getiri Oranı',
                        border: OutlineInputBorder(),
                        suffixText: '%',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stopajController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stopaj Oranı (Opsiyonel)',
                        border: OutlineInputBorder(),
                        suffixText: '%',
                        hintText: 'Boş bırakılabilir',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: vadeFarkiController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Vade Farkı Oranı',
                        border: OutlineInputBorder(),
                        suffixText: '%',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: taksitSayisiController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Taksit Sayısı',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: hesapla,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'HESAPLA',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (taksitTutari != null) ...[
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Özet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Toplam Ödenecek Tutar'),
                          Text(
                            formatTutar(toplamOdenecek!),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Aylık Taksit Tutarı'),
                          Text(
                            formatTutar(taksitTutari!),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${taksitTablosu.length}. Ay Sonu Bakiye'),
                          Text(
                            formatTutar(sonucFark!),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: sonucFark! >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: sonucFark! >= 0
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          sonucFark! >= 0
                              ? '✅ Taksitli alım avantajlı! ${formatTutar(sonucFark!)} kârdasınız.'
                              : '❌ Taksitli alım dezavantajlı! ${formatTutar(sonucFark!.abs())} zarardasınız.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: sonucFark! >= 0
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aylık Taksit Tablosu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Table(
                        border: TableBorder.all(color: Colors.grey.shade300),
                        columnWidths: const {
                          0: FlexColumnWidth(1),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(2),
                          4: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                            ),
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(6),
                                child: Text(
                                  'Ay',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(6),
                                child: Text(
                                  'Bakiye',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(6),
                                child: Text(
                                  'Getiri',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(6),
                                child: Text(
                                  'Taksit',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(6),
                                child: Text(
                                  'Kalan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          ...taksitTablosu.map(
                            (satir) => TableRow(
                              decoration: BoxDecoration(
                                color: satir.ay.isOdd
                                    ? Colors.white
                                    : Colors.grey.shade50,
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    '${satir.ay}',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    formatTutar(satir.baslangicBakiye),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    formatTutar(satir.faizGetirisi),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    formatTutar(satir.taksitOdemesi),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    formatTutar(satir.kalanBakiye),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: satir.kalanBakiye >= 0
                                          ? Colors.black
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

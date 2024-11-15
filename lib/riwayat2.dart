import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HistoryCard extends StatefulWidget {
  @override
  _HistoryCardState createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  // Variabel untuk menyimpan data yang diambil
  String ketinggianAir = 'Loading...';
  String kadarNutrisi = 'Loading...';
  String lampu = 'Loading...';
  String intensitasCahaya = 'Loading...';
  String statusTanaman = 'Loading...';

  // Fungsi untuk mengambil data dari API
  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://172.16.104.132/api/getPlantStatus.php'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          setState(() {
            ketinggianAir = "${data['ketinggian_air']} ml";
            kadarNutrisi = data['kadar_nutrisi'];
            lampu = 'on/off'; // Ganti dengan logika status lampu jika ada
            intensitasCahaya = "${data['intensitas_cahaya']} cd";
            statusTanaman = data['status_tanaman'];
          });
        } else {
          setState(() {
            ketinggianAir = 'No data';
            kadarNutrisi = 'No data';
            intensitasCahaya = 'No data';
            statusTanaman = 'No data';
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      setState(() {
        ketinggianAir = 'Error';
        kadarNutrisi = 'Error';
        intensitasCahaya = 'Error';
        statusTanaman = 'Error';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fungsi untuk mendapatkan tanggal saat ini
  String _getCurrentDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('d/M/yyyy');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 20),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Riwayat hari ini', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_getCurrentDate(), style: TextStyle(fontSize: 16)), // Tanggal realtime
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: Image.asset(
            'assets/image/kangkung1.png',
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Ketinggian air', ketinggianAir),
              _buildInfoRow('Kadar Nutrisi', kadarNutrisi),
              _buildInfoRow('Lampu', lampu),
              _buildInfoRow('Intensitas cahaya', intensitasCahaya),
              _buildInfoRow('Status', statusTanaman),
            ],
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Tutup', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: TextStyle(fontSize: 14)),
          Text(value, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

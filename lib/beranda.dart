import 'package:flutter/material.dart';
import 'profil.dart'; // Ensure profil.dart exists
import 'package:intl/intl.dart'; // For date and time formatting
import 'dart:async'; // For Timer
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For HTTP requests

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(username: ''), // Uses HomeScreen as the main screen
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String username;
  HomeScreen({required this.username});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentTime = '';
  String _nutrisiStatus = '';
  String _intensitasCahaya = '';
  String _ketinggianAir = '';
  String _plantStatus = '';

  // Base URL for the API endpoint
  final String baseUrl = 'http://172.16.104.132/api/getPlantStatus.php';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _fetchStatusData();
    Timer.periodic(Duration(minutes: 1), (Timer t) => _updateTime());
    Timer.periodic(Duration(seconds: 10), (Timer t) => _fetchStatusData());
  }

  void _updateTime() {
    final now = DateTime.now();
    final formattedTime = DateFormat('EEEE, d MMMM yyyy, HH:mm').format(now);
    setState(() {
      _currentTime = formattedTime;
    });
  }

  Future<void> _fetchStatusData() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _plantStatus = data['status_tanaman'];
          _intensitasCahaya = '${data['intensitas_cahaya']} cd';
          _ketinggianAir = '${data['ketinggian_air']} ml';
          _nutrisiStatus = '${data['kadar_nutrisi']} %';
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  void _showProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(), // Ensure ProfileScreen is imported
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Beranda', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () => _showProfile(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Hai, ${widget.username}!\nSelamat Datang Di Aquagrow',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 26.0),
                        child: Image.asset(
                          'assets/image/logo2.png',
                          fit: BoxFit.cover,
                          height: 30,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error, color: Colors.red);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    _currentTime,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  _buildNotificationScrollView(),
                  SizedBox(height: 20),
                  _buildVideoContainer(),
                  SizedBox(height: 20),
                  Text(
                    'Kontrol Alat',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  _buildControlCards(),
                  SizedBox(height: 20),
                  Text(
                    'Pengukuran Sensor',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  _buildMeasurementCards(),
                  SizedBox(height: 20),
                  Text(
                    'Keadaan Tanaman',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildStatusCard('Status', _plantStatus),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationScrollView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildNotificationBox('Pesan Notifikasi 1', _ketinggianAir, _nutrisiStatus, _intensitasCahaya),
          SizedBox(width: 10),
          _buildNotificationBox('Pesan Notifikasi 2', _ketinggianAir, _nutrisiStatus, _intensitasCahaya),
        ],
      ),
    );
  }

  Widget _buildNotificationBox(String message, String ketinggianAir, String kadarNutrisi, String intensitasCahaya) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.green[800], borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 10),
          Text('Ketinggian Air: $ketinggianAir', style: TextStyle(color: Colors.white)),
          Text('Kadar Nutrisi: $kadarNutrisi', style: TextStyle(color: Colors.white)),
          Text('Intensitas Cahaya: $intensitasCahaya', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildVideoContainer() {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.green[200],
      child: Center(child: Text('Video', style: TextStyle(fontSize: 16))),
    );
  }

  Widget _buildControlCards() {
    return Column(
      children: [
        _buildCardWithIcon('Pompa Nutrisi', 'Aktif', Icons.local_drink, Colors.orange),
        _buildCardWithIcon('Pompa Air', 'Aktif', Icons.water, Colors.blue),
        _buildCardWithIcon('Lampu UV', 'Aktif', Icons.lightbulb, Colors.purple),
        _buildCardWithIcon('Kamera', 'Aktif', Icons.camera_alt, Colors.teal),
      ],
    );
  }

  Widget _buildMeasurementCards() {
    return Column(
      children: [
        _buildMeasurementCard('Intensitas Cahaya', _intensitasCahaya, Icons.wb_sunny, Colors.yellow),
        _buildMeasurementCard('Ketinggian Air', _ketinggianAir, Icons.water_drop, Colors.blue),
        _buildMeasurementCard('Kadar Nutrisi', _nutrisiStatus, Icons.eco, Colors.lightGreen),
      ],
    );
  }

  Widget _buildCardWithIcon(String title, String status, IconData icon, Color iconColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: iconColor),
                SizedBox(width: 10),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Text(status, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementCard(String title, String measurement, IconData icon, Color iconColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: iconColor),
                SizedBox(width: 10),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Text(measurement, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String status) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(status, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

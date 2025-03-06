import 'package:flutter/material.dart';
import '../models/security_guard.dart';
import 'register_user_screen.dart';
import 'register_equipment_screen.dart';
import 'qr_scanner_screen.dart';
import 'access_history_screen.dart';

class DashboardScreen extends StatelessWidget {
  final SecurityGuard securityGuard;
  const DashboardScreen({Key? key, required this.securityGuard}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Control de Equipos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardItem(
              context,
              'Registrar Aprendiz',
              Icons.person_add,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterUserScreen()),
              ),
            ),
            _buildDashboardItem(
              context,
              'Registrar Equipo',
              Icons.computer,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterEquipmentScreen()),
              ),
            ),
            _buildDashboardItem(
              context,
              'Control de Acceso',
              Icons.qr_code_scanner,
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRScannerScreen()),
              ),
            ),
            _buildDashboardItem(
              context,
              'Historial',
              Icons.history,
              Colors.purple,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccessHistoryScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
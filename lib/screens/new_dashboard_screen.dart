import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/security_guard.dart';
import '../models/access_log.dart';
import '../models/equipment.dart';
import '../models/user.dart';
import '../services/api_access_log_service.dart';
import '../services/api_equipment_service.dart';
import '../services/api_user_service.dart';
import 'register_user_screen.dart';
import 'register_equipment_screen.dart';
import 'qr_scanner_screen.dart';
import 'access_history_screen.dart';
import '../widgets/dashboard_charts.dart';

class NewDashboardScreen extends StatefulWidget {
  final SecurityGuard securityGuard;
  
  const NewDashboardScreen({Key? key, required this.securityGuard}) : super(key: key);

  @override
  _NewDashboardScreenState createState() => _NewDashboardScreenState();
}

class _NewDashboardScreenState extends State<NewDashboardScreen> {
  final ApiEquipmentService _equipmentService = ApiEquipmentService();
  final ApiAccessLogService _accessLogService = ApiAccessLogService();
  final ApiUserService _userService = ApiUserService();
  
  List<Equipment> _equipments = [];
  List<AccessLog> _recentLogs = [];
  List<User> _users = [];
  int _alertCount = 0;
  bool _isLoading = true;
  bool _isDarkMode = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load equipment data
      final equipments = await _equipmentService.getAllEquipment();
      
      // Load recent access logs
      final recentLogs = await _accessLogService.getAllAccessLogs();
      
      // Load users
      final users = await _userService.getAllUsers();
      
      // Calculate alerts (equipment without exit logs)
      int alertCount = 0;
      for (var equipment in equipments) {
        final logs = await _accessLogService.getAccessLogsByEquipment(equipment.id);
        if (logs.isNotEmpty && logs.last.accessType == 'entry') {
          alertCount++;
        }
      }
      
      setState(() {
        _equipments = equipments;
        _recentLogs = recentLogs;
        _users = users;
        _alertCount = alertCount;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset('lib/img/logo.png', height: 30),
              SizedBox(width: 10),
              Text('Control de Equipos'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // Show search dialog
                _showSearchDialog(context);
              },
            ),
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
            ),
          ],
        ),
        drawer: _buildDrawer(),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Panel Superior - Información resumida y estadísticas
                      _buildSummaryPanel(),
                      SizedBox(height: 24),
                      
                      // Panel Central - Accesos rápidos a funciones principales
                      _buildQuickAccessPanel(context),
                      SizedBox(height: 24),
                      
                      // Panel Inferior - Información detallada y registros recientes
                      _buildRecentAccessPanel(),
                    ],
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QRScannerScreen()),
            );
          },
          child: Icon(Icons.qr_code_scanner),
          tooltip: 'Escanear QR',
        ),
      ),
    );
  }
  
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Text(
                    widget.securityGuard.firstName[0] + widget.securityGuard.lastName[0],
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '${widget.securityGuard.firstName} ${widget.securityGuard.lastName}',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  'Guardia de Seguridad',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.person_add),
            title: Text('Registrar Aprendiz'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterUserScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.computer),
            title: Text('Registrar Equipo'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterEquipmentScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.qr_code_scanner),
            title: Text('Control de Acceso'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRScannerScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Historial'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccessHistoryScreen()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configuración'),
            onTap: () {
              // TODO: Implementar pantalla de configuración
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Cerrar Sesión'),
            onTap: () {
              // TODO: Implementar cierre de sesión
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Equipos',
                _equipments.length.toString(),
                Icons.computer,
                Colors.blue,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Accesos',
                _recentLogs.length.toString(),
                Icons.login,
                Colors.green,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Alertas',
                _alertCount.toString(),
                Icons.warning,
                Colors.orange,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        // Gráfico de barras para entradas/salidas por día
        DashboardCharts.buildWeeklyAccessChart(_recentLogs, context),
        SizedBox(height: 16),
        // Gráfico circular para distribución de equipos
        DashboardCharts.buildEquipmentDistributionChart(_equipments, context),
        SizedBox(height: 16),
        // Mapa de calor para horarios de actividad
        DashboardCharts.buildHeatmapChart(_recentLogs, context),
      ],
    );
  }
  
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickAccessPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accesos Rápidos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
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
      ],
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
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
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
                size: 32,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
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
  
  Widget _buildRecentAccessPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accesos Recientes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(16),
          child: _recentLogs.isEmpty
              ? Center(
                  child: Text(
                    'No hay registros recientes',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Column(
                  children: _recentLogs.map((log) => _buildAccessLogItem(log)).toList(),
                ),
        ),
      ],
    );
  }
  
  Widget _buildAccessLogItem(AccessLog log) {
    // Buscar información del usuario y equipo
    final user = _users.firstWhere(
      (u) => u.id == log.userId,
      orElse: () => User(
        id: 'unknown',
        cardId: 'unknown',
        firstName: 'Usuario',
        lastName: 'Desconocido',
        registrationDate: DateTime.now(),
      ),
    );
    
    final equipment = _equipments.firstWhere(
      (e) => e.id == log.equipmentId,
      orElse: () => Equipment(
        id: 'unknown',
        name: 'Equipo Desconocido',
        description: '',
        userId: '',
        peripherals: [],
        qrCode: '',
        assignmentDate: DateTime.now(),
      ),
    );
    
    final isEntry = log.accessType == 'entry';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isEntry ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEntry ? Icons.login : Icons.logout,
              color: Colors.white,
              size: 16,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  equipment.name,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isEntry ? 'Entrada' : 'Salida',
                style: TextStyle(
                  color: isEntry ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showSearchDialog(BuildContext context) {
    String searchQuery = '';
    String searchType = 'all'; // 'all', 'user', 'equipment'
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Búsqueda Avanzada'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, ID o equipo',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  searchQuery = value;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Text('Todos'),
                      selected: searchType == 'all',
                      onSelected: (selected) {
                        if (selected) {
                          searchType = 'all';
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: Text('Usuarios'),
                      selected: searchType == 'user',
                      onSelected: (selected) {
                        if (selected) {
                          searchType = 'user';
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: Text('Equipos'),
                      selected: searchType == 'equipment',
                      onSelected: (selected) {
                        if (selected) {
                          searchType = 'equipment';
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar lógica de búsqueda
              Navigator.pop(context);
            },
            child: Text('Buscar'),
          ),
        ],
      ),
    );
  }
}
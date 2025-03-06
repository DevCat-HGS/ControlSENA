import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/access_log.dart';
import '../models/equipment.dart';
import '../models/user.dart';

class AccessHistoryScreen extends StatefulWidget {
  @override
  _AccessHistoryScreenState createState() => _AccessHistoryScreenState();
}

class _AccessHistoryScreenState extends State<AccessHistoryScreen> {
  final _databaseService = DatabaseService();
  
  bool _isLoading = false;
  List<AccessLog> _accessLogs = [];
  Map<String, Equipment> _equipmentCache = {};
  Map<String, User> _userCache = {};
  
  DateTime _selectedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _databaseService.initialize();
    _loadAccessLogs();
  }
  
  Future<void> _loadAccessLogs() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Aquí deberías implementar un método en DatabaseService para obtener
      // los registros de acceso de una fecha específica
      final logs = await _databaseService.getAccessLogsByDate(_selectedDate);
      
      setState(() {
        _accessLogs = logs;
      });
      
      // Cargar información de equipos y usuarios para mostrar detalles
      for (final log in logs) {
        if (!_equipmentCache.containsKey(log.equipmentId)) {
          final equipment = await _databaseService.getEquipmentById(log.equipmentId);
          if (equipment != null) {
            _equipmentCache[log.equipmentId] = equipment;
          }
        }
        
        if (!_userCache.containsKey(log.userId)) {
          final user = await _databaseService.getUserById(log.userId);
          if (user != null) {
            _userCache[log.userId] = user;
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar historial: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAccessLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Accesos'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _accessLogs.isEmpty
              ? Center(
                  child: Text(
                    'No hay registros de acceso para la fecha seleccionada',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _accessLogs.length,
                  itemBuilder: (context, index) {
                    final log = _accessLogs[index];
                    final equipment = _equipmentCache[log.equipmentId];
                    final user = _userCache[log.userId];
                    
                    return Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: log.accessType == 'entry'
                              ? Colors.green
                              : Colors.red,
                          child: Icon(
                            log.accessType == 'entry'
                                ? Icons.login
                                : Icons.logout,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          user != null
                              ? '${user.firstName} ${user.lastName}'
                              : 'Usuario Desconocido',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              equipment != null
                                  ? 'Equipo: ${equipment.serialNumber}'
                                  : 'Equipo Desconocido',
                            ),
                            Text(
                              'Hora: ${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}',
                            ),
                          ],
                        ),
                        trailing: Text(
                          log.accessType == 'entry' ? 'Entrada' : 'Salida',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: log.accessType == 'entry'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/database_service.dart';
import '../models/equipment.dart';
import '../models/access_log.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final _databaseService = DatabaseService();
  final MobileScannerController _scannerController = MobileScannerController();
  
  bool _isLoading = false;
  Equipment? _scannedEquipment;
  String? _accessType;
  bool _isScanning = false;
  
  @override
  void initState() {
    super.initState();
    _databaseService.initialize();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _processBarcode(String? value) async {
    if (value == null) return;
    
    setState(() {
      _isLoading = true;
      _isScanning = false;
    });
    
    try {
      // Buscar el equipo por el código QR
      final equipment = await _databaseService.getEquipmentByQR(value);
      
      if (equipment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Equipo no encontrado')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Determinar si es entrada o salida
      final accessType = await _databaseService.determineAccessType(
        equipment.id,
        equipment.userId,
      );
      
      setState(() {
        _scannedEquipment = equipment;
        _accessType = accessType;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar el código QR: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registerAccess() async {
    if (_scannedEquipment == null || _accessType == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final accessLog = AccessLog(
        id: '', // MongoDB generará el ID
        equipmentId: _scannedEquipment!.id,
        userId: _scannedEquipment!.userId,
        timestamp: DateTime.now(),
        accessType: _accessType!,
      );
      
      await _databaseService.logAccess(accessLog);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _accessType == 'entry'
                ? 'Entrada registrada con éxito'
                : 'Salida registrada con éxito',
          ),
        ),
      );
      
      // Limpiar después de registrar
      setState(() {
        _scannedEquipment = null;
        _accessType = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar acceso: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Control de Acceso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escanear Código QR',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    if (!_isScanning)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => setState(() => _isScanning = true),
                          icon: Icon(Icons.qr_code_scanner),
                          label: Text('Escanear QR'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 300,
                              child: MobileScanner(
                                controller: _scannerController,
                                onDetect: (capture) {
                                  final List<Barcode> barcodes = capture.barcodes;
                                  if (barcodes.isNotEmpty) {
                                    _processBarcode(barcodes.first.rawValue);
                                  }
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () => setState(() => _isScanning = false),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            if (_scannedEquipment != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información del Equipo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text('Número de Serie: ${_scannedEquipment!.serialNumber}'),
                      SizedBox(height: 8),
                      Text('Fecha de Asignación: ${_scannedEquipment!.assignmentDate.toString().split('.')[0]}'),
                      SizedBox(height: 8),
                      Text(
                        'Tipo de Acceso: ${_accessType == 'entry' ? 'Entrada' : 'Salida'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _accessType == 'entry' ? Colors.green : Colors.red,
                        ),
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _registerAccess,
                          child: Text('Registrar ${_accessType == 'entry' ? 'Entrada' : 'Salida'}'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
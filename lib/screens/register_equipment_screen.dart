import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/qr_service.dart';
import '../models/equipment.dart';
import '../models/peripherals.dart';
import '../models/user.dart';
import '../widgets/qr_code_widget.dart';

class RegisterEquipmentScreen extends StatefulWidget {
  @override
  _RegisterEquipmentScreenState createState() => _RegisterEquipmentScreenState();
}

class _RegisterEquipmentScreenState extends State<RegisterEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _cardIdController = TextEditingController();
  User? _selectedUser;
  final _databaseService = DatabaseService();
  final _qrService = QRService();
  
  bool _isLoading = false;
  String? _generatedQR;
  
  // Lista de periféricos disponibles
  final List<String> _peripheralTypes = [
    'Mouse',
    'Teclado',
    'Base Refrigerante',
    'Cargador',
    'Almohadilla'
  ];
  
  // Mapa para almacenar los periféricos seleccionados y sus números de serie
  final Map<String, String?> _selectedPeripherals = {};

  @override
  void initState() {
    super.initState();
    _databaseService.initialize();
  }

  Future<void> _searchUser() async {
    if (_cardIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor ingrese un número de tarjeta')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = await _databaseService.getUserByCardId(_cardIdController.text);
      setState(() {
        _selectedUser = user;
        _isLoading = false;
      });
      
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario no encontrado. Regístrelo primero.')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar usuario: $e')),
      );
    }
  }

  void _togglePeripheral(String type, bool value) {
    setState(() {
      if (value) {
        _selectedPeripherals[type] = null; // Inicialmente sin número de serie
      } else {
        _selectedPeripherals.remove(type);
      }
    });
  }

  Future<void> _registerEquipment() async {
    if (_formKey.currentState!.validate() && _selectedUser != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Convertir el mapa de periféricos a una lista de objetos Peripheral
        final peripherals = _selectedPeripherals.entries.map((entry) {
          return Peripheral(
            type: entry.key,
            serialNumber: entry.value,
            isAssigned: true,
          );
        }).toList();
        
        // Generar código QR único para identificación interna
        final qrCode = _qrService.generateUniqueQRCode(
          _serialNumberController.text,
          _selectedUser!.id,
        );
        
        final equipment = Equipment(
          id: '', // MongoDB generará el ID
          name: _nameController.text,
          description: _descriptionController.text,
          userId: _selectedUser!.id,
          peripherals: peripherals,
          qrCode: qrCode,
          serialNumber: _serialNumberController.text,
          assignmentDate: DateTime.now(),
        );
        
        final equipmentId = await _databaseService.addEquipment(equipment);
        
        // Recuperar el equipo completo con su ID generado
        final savedEquipment = await _databaseService.getEquipmentById(equipmentId);
        
        if (savedEquipment != null) {
          // Generar QR completo con toda la información del usuario y equipo
          final completeQR = _qrService.generateCompleteQRCode(_selectedUser!, savedEquipment);
          
          setState(() {
            _generatedQR = completeQR;
          });
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Equipo registrado con éxito')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar equipo: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Equipo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sección para escanear tarjeta de usuario
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información del Aprendiz',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cardIdController,
                                decoration: InputDecoration(
                                  labelText: 'Número de Tarjeta',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingrese el número de tarjeta';
                                  }
                                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                    return 'Por favor ingrese solo números';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _searchUser,
                              child: Text('Buscar'),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        if (_selectedUser != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nombre: ${_selectedUser!.firstName} ${_selectedUser!.lastName}'),
                              Text('ID de Tarjeta: ${_selectedUser!.cardId}'),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Sección para información del equipo
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
                        Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Nombre del Equipo',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese el nombre del equipo';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Descripción',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese una descripción';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _serialNumberController,
                              decoration: InputDecoration(
                                labelText: 'Número de Serie (opcional)',
                                border: OutlineInputBorder(),
                              ),
                              // No validator required since it's optional
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Sección para periféricos
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Periféricos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        ..._peripheralTypes.map((type) {
                          final isSelected = _selectedPeripherals.containsKey(type);
                          return Column(
                            children: [
                              CheckboxListTile(
                                title: Text(type),
                                value: isSelected,
                                onChanged: (value) {
                                  _togglePeripheral(type, value ?? false);
                                },
                              ),
                              if (isSelected)
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Número de Serie (opcional)',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPeripherals[type] = value.isEmpty ? null : value;
                                      });
                                    },
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _registerEquipment,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Registrar Equipo'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Mostrar el código QR generado
                if (_generatedQR != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Código QR Generado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          QRCodeWidget(
                            data: _generatedQR!,
                            size: 250,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Aquí puedes implementar la funcionalidad para imprimir el QR
                            },
                            child: Text('Imprimir QR'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
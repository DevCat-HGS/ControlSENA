import 'package:flutter/material.dart';

class DebugUtils {
  // Niveles de log para diferentes tipos de mensajes
  static const int INFO = 0;
  static const int WARNING = 1;
  static const int ERROR = 2;
  
  // Controla si el debugging está activado
  static bool debuggingEnabled = true;
  
  // Log general con nivel
  static void log(String message, {int level = INFO}) {
    if (!debuggingEnabled) return;
    
    final prefix = level == INFO 
        ? 'INFO'
        : level == WARNING 
            ? 'WARNING'
            : 'ERROR';
    
    print('DEBUG [$prefix]: $message');
  }
  
  // Log específico para información
  static void info(String message) {
    log(message, level: INFO);
  }
  
  // Log específico para advertencias
  static void warning(String message) {
    log(message, level: WARNING);
  }
  
  // Log específico para errores
  static void error(String message, {StackTrace? stackTrace}) {
    log(message, level: ERROR);
    if (stackTrace != null) {
      print('DEBUG [STACK]: $stackTrace');
    }
  }
  
  // Muestra un diálogo de error detallado
  static void showErrorDialog(BuildContext context, String title, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Se produjo un error:'),
                SizedBox(height: 10),
                Text(errorMessage, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Por favor, verifique la conexión con el servidor y los datos ingresados.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
  // Registra un objeto como JSON para depuración
  static void logObject(String label, dynamic object) {
    if (!debuggingEnabled) return;
    
    try {
      if (object is Map) {
        print('DEBUG OBJECT [$label]: $object');
      } else {
        print('DEBUG OBJECT [$label]: $object');
      }
    } catch (e) {
      error('Error al registrar objeto $label: $e');
    }
  }
}
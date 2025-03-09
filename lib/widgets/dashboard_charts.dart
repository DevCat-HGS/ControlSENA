import 'package:flutter/material.dart';
import '../models/access_log.dart';
import '../models/equipment.dart';

class DashboardCharts {
  /// Crea un gráfico circular para mostrar la distribución de tipos de equipos
  static Widget buildEquipmentDistributionChart(List<Equipment> equipments, BuildContext context) {
    // Agrupar equipos por tipo o categoría
    Map<String, int> equipmentTypes = {};
    
    // En un caso real, los equipos tendrían un campo de tipo o categoría
    // Aquí simulamos algunos tipos basados en el nombre del equipo
    for (var equipment in equipments) {
      String type = 'Otros';
      if (equipment.name.toLowerCase().contains('laptop')) {
        type = 'Laptops';
      } else if (equipment.name.toLowerCase().contains('desktop')) {
        type = 'Desktops';
      } else if (equipment.name.toLowerCase().contains('tablet')) {
        type = 'Tablets';
      } else if (equipment.name.toLowerCase().contains('monitor')) {
        type = 'Monitores';
      }
      
      equipmentTypes[type] = (equipmentTypes[type] ?? 0) + 1;
    }
    
    // Colores para cada tipo de equipo
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución de Equipos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: equipments.isEmpty
                ? Center(child: Text('No hay datos disponibles'))
                : Row(
                    children: [
                      // Aquí iría el gráfico circular real
                      // Por ahora, mostramos una representación simple
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  colors: colors.take(equipmentTypes.length).toList(),
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).cardColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Leyenda del gráfico
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...equipmentTypes.entries.map((entry) {
                              final index = equipmentTypes.keys.toList().indexOf(entry.key);
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      color: colors[index % colors.length],
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${entry.key}: ${entry.value}',
                                        style: TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// Crea un gráfico de barras para mostrar entradas/salidas por día de la semana
  static Widget buildWeeklyAccessChart(List<AccessLog> logs, BuildContext context) {
    // Agrupar logs por día de la semana
    Map<int, Map<String, int>> accessByDay = {};
    
    // Inicializar el mapa para todos los días de la semana
    for (int i = 1; i <= 7; i++) {
      accessByDay[i] = {'entry': 0, 'exit': 0};
    }
    
    // Contar entradas y salidas por día
    for (var log in logs) {
      final day = log.timestamp.weekday;
      final type = log.accessType;
      accessByDay[day]![type] = (accessByDay[day]![type] ?? 0) + 1;
    }
    
    // Nombres de los días de la semana
    final weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accesos por Día',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: logs.isEmpty
                ? Center(child: Text('No hay datos disponibles'))
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Eje Y (valores)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('10', style: TextStyle(fontSize: 10)),
                          Text('5', style: TextStyle(fontSize: 10)),
                          Text('0', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                      SizedBox(width: 8),
                      // Gráfico de barras
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(7, (index) {
                            final day = index + 1;
                            final entries = accessByDay[day]!['entry'] ?? 0;
                            final exits = accessByDay[day]!['exit'] ?? 0;
                            
                            // Altura máxima para las barras
                            final maxHeight = 100.0;
                            // Factor de escala (asumiendo máximo 10 accesos)
                            final scale = maxHeight / 10;
                            
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Barra de entradas
                                Container(
                                  width: 10,
                                  height: entries * scale,
                                  color: Colors.green,
                                ),
                                // Barra de salidas
                                Container(
                                  width: 10,
                                  height: exits * scale,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 4),
                                // Etiqueta del día
                                Text(
                                  weekdays[index],
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
          ),
          // Leyenda
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(width: 10, height: 10, color: Colors.green),
                  SizedBox(width: 4),
                  Text('Entradas', style: TextStyle(fontSize: 10)),
                ],
              ),
              SizedBox(width: 16),
              Row(
                children: [
                  Container(width: 10, height: 10, color: Colors.red),
                  SizedBox(width: 4),
                  Text('Salidas', style: TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Crea un mapa de calor para mostrar horarios de mayor actividad
  static Widget buildHeatmapChart(List<AccessLog> logs, BuildContext context) {
    // Agrupar logs por hora del día
    Map<int, int> accessByHour = {};
    
    // Inicializar el mapa para todas las horas del día
    for (int i = 0; i < 24; i++) {
      accessByHour[i] = 0;
    }
    
    // Contar accesos por hora
    for (var log in logs) {
      final hour = log.timestamp.hour;
      accessByHour[hour] = (accessByHour[hour] ?? 0) + 1;
    }
    
    // Encontrar el valor máximo para normalizar
    final maxValue = accessByHour.values.reduce((a, b) => a > b ? a : b);
    
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Horarios de Actividad',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: logs.isEmpty
                ? Center(child: Text('No hay datos disponibles'))
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: 24,
                    itemBuilder: (context, index) {
                      final count = accessByHour[index] ?? 0;
                      // Normalizar el valor para obtener una intensidad de color
                      final intensity = maxValue > 0 ? count / maxValue : 0.0;
                      
                      return Tooltip(
                        message: '$index:00 - ${count} accesos',
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1 + intensity * 0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '$index',
                              style: TextStyle(
                                fontSize: 10,
                                color: intensity > 0.5 ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
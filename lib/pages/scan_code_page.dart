import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({super.key});

  @override
  State<ScanCodePage> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  final String _baseUrl = "https://qr-coadet-default-rtdb.firebaseio.com/.json";

  void _searchAndUpdateAttendance(String qrValue) async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> database = json.decode(response.body);
      String? studentName;
      String? course;
      String? year;
      String? studentKey;
      String? lastAttendance;

      // Buscando a través de la base de datos completa
      database.forEach((y, yearData) {
        yearData.forEach((c, courseData) {
          courseData.forEach((sKey, studentData) {
            if (sKey == qrValue) {
              studentName = studentData['nombreDelEstudiante'];
              lastAttendance = studentData['ultimaAsistencia'];
              course = c;
              year = y;
              studentKey = sKey;
            }
          });
        });
      });

      if (studentName != null) {
        _confirmUpdateDialog(studentName!, course!, year!, studentKey!,
            lastAttendance ?? "No registrada");
      } else {
        _showDialog("Estudiante no encontrado",
            "El código QR no corresponde a un estudiante registrado.");
      }
    } else {
      _showDialog(
          "Error de conexión", "No se pudo conectar con la base de datos.");
    }
  }

  void _confirmUpdateDialog(String studentName, String course, String year,
      String studentKey, String lastAttendance) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Estudiante encontrado"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nombre: $studentName"),
              Text("Curso: $course"),
              Text("Última Asistencia: $lastAttendance"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cierra el diálogo
                await _updateAttendance(year, course, studentKey);
              },
              child: const Text("Actualizar Asistencia"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAttendance(
      String year, String course, String studentKey) async {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    final updateUrl = Uri.parse(
        'https://qr-coadet-default-rtdb.firebaseio.com/$year/$course/$studentKey/ultimaAsistencia.json');
    final response =
        await http.put(updateUrl, body: json.encode(formattedDate));

    if (response.statusCode == 200) {
      _showDialog("Asistencia Actualizada",
          "La última asistencia se ha actualizado a: $formattedDate");
    } else {
      _showDialog(
          "Error al actualizar", "No se pudo actualizar la asistencia.");
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Código QR'),
      ),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          returnImage: false,
        ),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            _searchAndUpdateAttendance(barcodes.first.rawValue ?? "");
          }
        },
      ),
    );
  }
}

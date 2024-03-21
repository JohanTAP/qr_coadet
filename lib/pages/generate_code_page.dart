import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class GenerateCodePage extends StatefulWidget {
  const GenerateCodePage({super.key});

  @override
  State<GenerateCodePage> createState() => _GenerateCodePageState();
}

class _GenerateCodePageState extends State<GenerateCodePage> {
  String? qrData;

  // Esta función actualiza el estado para generar el código QR
  void _generateQR(String value) {
    setState(() {
      qrData = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar Código QR'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Ingrese su código',
                // El IconButton ahora llama a _generateQR
                suffixIcon: IconButton(
                  icon: const Icon(Icons.done),
                  onPressed: () {
                    if (qrData != null) _generateQR(qrData!);
                  },
                ),
              ),
              onSubmitted: (value) {
                _generateQR(
                    value); // Llama a _generateQR cuando se envía el formulario
              },
              onChanged: (value) {
                // Esto asegura que el valor actual se capture para usarlo con el IconButton
                qrData = value;
              },
            ),
            if (qrData != null &&
                qrData!.isNotEmpty) // Asegurarse de que qrData no esté vacío
              Card(
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Center(
                      child: PrettyQrView.data(data: qrData!),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

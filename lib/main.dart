import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Right Angle Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class LocalizedDecimalInput {
  static String? validateAndParseDecimal(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter value for $fieldName';
    }

    // Replace comma with dot for parsing
    String normalizedValue = value.replaceAll(',', '.');

    // Check if it's a valid number after normalization
    if (double.tryParse(normalizedValue) == null) {
      return 'Please enter a valid number';
    }

    if (double.parse(normalizedValue) <= 0) {
      return 'Value must be greater than 0';
    }

    return null;
  }

  static double parseDecimal(String value) {
    return double.parse(value.replaceAll(',', '.'));
  }
}

class LocalizedDecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Allow backspace and deletion
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Create a pattern that allows:
    // - Numbers
    // - Single dot or comma as decimal separator
    // - Only one decimal separator
    final RegExp regExp = RegExp(r'^[0-9]*[,.]?[0-9]*$');

    // If the new value doesn't match our pattern, return the old value
    if (!regExp.hasMatch(newValue.text)) {
      return oldValue;
    }

    // Count decimal separators
    int dots = newValue.text.split('.').length - 1;
    int commas = newValue.text.split(',').length - 1;

    // If there's more than one decimal separator, return the old value
    if (dots + commas > 1) {
      return oldValue;
    }

    return newValue;
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}


class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerA = TextEditingController();
  final TextEditingController _controllerB = TextEditingController();
  final TextEditingController _controllerC = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  double? result;
  String? angle;


  void _calculateX() {
    if (_formKey.currentState!.validate()) {
      double a = LocalizedDecimalInput.parseDecimal(_controllerA.text);
      double b = LocalizedDecimalInput.parseDecimal(_controllerB.text);
      double c = LocalizedDecimalInput.parseDecimal(_controllerC.text);

      final calculation = (pow(a, 2) + pow(b, 2) - pow(c, 2)) / (2 * a);
      String legend = "";

      if (calculation >= 0) {
        legend += "> 0, ";
        if ( calculation > 90 ) {
          legend += "dan > 90 (Tumpul)";
        } else {
          legend += "dan < 90 (Lancip)";
        }
      } else {
        legend += "< 0, dan < 90 (Lancip)";
      }

      setState(() {
        result = calculation;
        angle = legend;
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _clearAll() {
    setState(() {
      _controllerA.clear();
      _controllerB.clear();
      _controllerC.clear();
      result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Right Angle Calculator'),
        centerTitle: true,
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Input Values',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _controllerA,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [LocalizedDecimalFormatter()],
                          decoration: const InputDecoration(
                            labelText: 'Enter A',
                            border: OutlineInputBorder(),
                            hintText: '0.0',
                          ),
                          validator: (value) => LocalizedDecimalInput.validateAndParseDecimal(value, 'A'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _controllerB,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [LocalizedDecimalFormatter()],
                          decoration: const InputDecoration(
                            labelText: 'Enter B',
                            border: OutlineInputBorder(),
                            hintText: '0.0',
                          ),
                          validator: (value) => LocalizedDecimalInput.validateAndParseDecimal(value, 'B'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _controllerC,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [LocalizedDecimalFormatter()],
                          decoration: const InputDecoration(
                            labelText: 'Enter C',
                            border: OutlineInputBorder(),
                            hintText: '0.0',
                          ),
                          validator: (value) => LocalizedDecimalInput.validateAndParseDecimal(value, 'C'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _calculateX,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text(
                    'Hitung',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _clearAll,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.red, // Red color for clear button
                    foregroundColor: Colors.white, // White text
                  ),
                  child: const Text(
                    'Bersihkan',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 24),
                if (result != null) ...[
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Hasil',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'X = ${result!.toStringAsFixed(2)} ${angle}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
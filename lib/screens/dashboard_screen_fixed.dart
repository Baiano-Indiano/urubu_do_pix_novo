import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  final double saldo;
  final List<Map<String, dynamic>> historico;
  DashboardScreen({super.key, required this.saldo, List<Map<String, dynamic>>? historico})
    : historico = historico ?? [];

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ... (keep all existing state variables and methods)


  @override
  Widget build(BuildContext context) {
    // Calculate values used in the UI
    final totalEnviado = widget.historico.fold(0.0, (sum, item) => sum + (item['valor'] ?? 0.0));
    final qtdTransf = widget.historico.length;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Add your app bar actions here
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Resumo Financeiro', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Enviado:', style: TextStyle(fontSize: 16)),
                      Text('R\$ ${totalEnviado.toStringAsFixed(2)}', 
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('Total de Transferências: $qtdTransf', 
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Add more widgets here as needed
            ],
          ),
        ),
      ),
    );
  }

  // ... (keep all other methods)
}

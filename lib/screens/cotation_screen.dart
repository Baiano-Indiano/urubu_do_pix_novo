import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class CotationScreen extends StatefulWidget {
  const CotationScreen({super.key});

  @override
  State<CotationScreen> createState() => _CotationScreenState();
}

class _CotationScreenState extends State<CotationScreen> {
  double? _dollarRate;
  double? _euroRate;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCotacoes();
  }

  Future<void> _fetchCotacoes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final cotacoes = await ApiService().fetchCotacoes();
      if (mounted) {
        setState(() {
          _dollarRate = cotacoes['dolar'];
          _euroRate = cotacoes['euro'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red),
      );
      setState(() {
        _error = 'Erro ao buscar cotações';
        _isLoading = false;
      });
    }
  }

  final TextEditingController _realController = TextEditingController();

  @override
  void dispose() {
    _realController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var inputDecoration = const InputDecoration(
      border: OutlineInputBorder(),
      labelText: "Reais (R\$)",
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar cotações',
            onPressed: _fetchCotacoes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Conversor de Moedas',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('Dólar: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_dollarRate != null
                              ? 'R\$ ${_dollarRate!.toStringAsFixed(2)}'
                              : '--'),
                          const SizedBox(width: 24),
                          const Text('Euro: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_euroRate != null
                              ? 'R\$ ${_euroRate!.toStringAsFixed(2)}'
                              : '--'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _realController,
                        decoration: inputDecoration,
                        keyboardType: TextInputType.number,
                        inputFormatters: const [],
                        onChanged: (value) {
                          String digits =
                              value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (digits.isEmpty) {
                            _realController.text = '';
                            _realController.selection =
                                const TextSelection.collapsed(offset: 0);
                            setState(() {});
                            return;
                          }
                          double parsed = double.parse(digits) / 100;
                          String formatted = NumberFormat.currency(
                                  locale: 'pt_BR', symbol: 'R\$')
                              .format(parsed);
                          _realController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                                offset: formatted.length),
                          );
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Text('Dólar'),
                                    Text(_realController.text.isEmpty ||
                                            _dollarRate == null
                                        ? '0.00'
                                        : (() {
                                            try {
                                              String digits = _realController
                                                  .text
                                                  .replaceAll(
                                                      RegExp(r'[^0-9]'), '');
                                              if (digits.isEmpty) return '0.00';
                                              double real =
                                                  double.parse(digits) / 100;
                                              return (real / _dollarRate!)
                                                  .toStringAsFixed(2);
                                            } catch (_) {
                                              return '0.00';
                                            }
                                          })()),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Text('Euro'),
                                    Text(_realController.text.isEmpty ||
                                            _euroRate == null
                                        ? '0.00'
                                        : (() {
                                            try {
                                              String digits = _realController
                                                  .text
                                                  .replaceAll(
                                                      RegExp(r'[^0-9]'), '');
                                              if (digits.isEmpty) return '0.00';
                                              double real =
                                                  double.parse(digits) / 100;
                                              return (real / _euroRate!)
                                                  .toStringAsFixed(2);
                                            } catch (_) {
                                              return '0.00';
                                            }
                                          })()),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}

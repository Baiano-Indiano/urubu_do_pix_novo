import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'receipt_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Formatador de CPF
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    String formatted = '';
    for (int i = 0; i < digits.length && i < 11; i++) {
      if (i == 3 || i == 6) formatted += '.';
      if (i == 9) formatted += '-';
      formatted += digits[i];
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Formatador de Celular (BR)
class CelularInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    String formatted = '';
    for (int i = 0; i < digits.length && i < 11; i++) {
      if (i == 0) formatted += '(';
      if (i == 2) formatted += ') ';
      if (i == 7) formatted += '-';
      formatted += digits[i];
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _selectedPixType = 'cpf';
  String _selectedCurrency = 'real';
  double? _dollarRate;
  double? _euroRate;
  double _saldo = 0.0;
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  String? _errorMessage;
  Set<String> _favoritos = {};

  @override
  void initState() {
    super.initState();
    _fetchSaldoEHistorico();
    _fetchCotacoes();
    _loadFavoritos();
  }

  Future<void> _loadFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoritos = (prefs.getStringList('favoritos') ?? []).toSet();
    });
  }

  bool _camposValidos() {
    final destinatario = _recipientController.text.trim();
    String digits = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    double? valor = digits.isEmpty ? null : double.tryParse(digits)! / 100;
    if (_selectedPixType == 'cpf') {
      if (destinatario.isEmpty ||
          destinatario.length != 11 ||
          int.tryParse(destinatario) == null) {
        return false;
      }
    } else if (_selectedPixType == 'celular') {
      if (destinatario.isEmpty || destinatario.length < 10) return false;
    } else if (_selectedPixType == 'email') {
      if (destinatario.isEmpty || !destinatario.contains('@')) return false;
    } else {
      if (destinatario.isEmpty) return false;
    }
    if (valor == null || valor < 0.5) return false;
    return true;
  }

  Future<void> _fetchCotacoes() async {
    try {
      final cotacoes = await ApiService().fetchCotacoes();
      setState(() {
        _dollarRate = cotacoes['dolar'];
        _euroRate = cotacoes['euro'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _fetchSaldoEHistorico() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final api = ApiService();
      final saldo = await api.fetchSaldo();
      final historico = await api.fetchHistorico();
      if (mounted) {
        setState(() {
          _saldo = saldo;
          _history = historico;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao buscar saldo/histórico';
        _isLoading = false;
      });
    }
  }

  Future<void> _realizarTransferencia() async {
    final destinatario = _recipientController.text.trim();
    // Extrai valor formatado
    String digits = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    double? valor = digits.isEmpty ? null : double.parse(digits) / 100;
    double valorEmReais = 0.0;
    if (_selectedCurrency == 'real') {
      valorEmReais = valor ?? 0.0;
    } else if (_selectedCurrency == 'dolar') {
      if (_dollarRate == null) {
        setState(() {
          _errorMessage = 'Cotação do dólar não disponível.';
        });
        return;
      }
      valorEmReais = (valor ?? 0.0) * _dollarRate!;
    } else if (_selectedCurrency == 'euro') {
      if (_euroRate == null) {
        setState(() {
          _errorMessage = 'Cotação do euro não disponível.';
        });
        return;
      }
      valorEmReais = (valor ?? 0.0) * _euroRate!;
    }
    if (destinatario.isEmpty || valor == null) {
      setState(() {
        _errorMessage = 'Preencha destinatário e valor válido';
      });
      return;
    }
    if (valorEmReais < 0.5) {
      setState(() {
        _errorMessage = 'O valor mínimo para transferência é R\$ 0,50';
      });
      return;
    }
    if (valorEmReais > 50000) {
      setState(() {
        _errorMessage = 'O valor máximo para transferência é R\$ 50.000,00';
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final api = ApiService();
      await api.registrarTransferencia(
        destinatario,
        valorEmReais,
        moeda: _selectedCurrency == 'real'
            ? 'BRL'
            : _selectedCurrency == 'dolar'
                ? 'USD'
                : 'EUR',
        valorOriginal: valor,
      );
      await _fetchSaldoEHistorico();
      _recipientController.clear();
      _amountController.clear();
      setState(() {
        _errorMessage = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Transferência realizada com sucesso!'),
            backgroundColor: Colors.green));
      }
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ReceiptScreen(
              destinatario: destinatario,
              valorEmReais: valorEmReais,
              moeda: _selectedCurrency == 'real'
                  ? 'BRL'
                  : _selectedCurrency == 'dolar'
                      ? 'USD'
                      : 'EUR',
              valorOriginal: valor,
              data: DateTime.now().toString().substring(0, 16),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Erro ao transferir'), backgroundColor: Colors.red));
      }
      setState(() {
        _errorMessage = 'Erro ao transferir';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      if (args['destinatario'] != null) {
        _recipientController.text = args['destinatario'].toString();
      }
      if (args['valor'] != null) {
        _amountController.text = args['valor'].toString();
      }
    }
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transferência')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_favoritos.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Favoritos:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _favoritos.map((f) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ActionChip(
                              label: Text(f),
                              avatar: const Icon(Icons.star, color: Colors.orange),
                              onPressed: () {
                                setState(() {
                                  _recipientController.text = f;
                                });
                              },
                            ),
                          )).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text('Saldo: R\$ ${_saldo.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 24),
                    // Seletor de tipo de chave Pix
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedPixType,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de chave Pix',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'cpf', child: Text('CPF')),
                              DropdownMenuItem(
                                  value: 'celular', child: Text('Celular')),
                              DropdownMenuItem(
                                  value: 'email', child: Text('E-mail')),
                              DropdownMenuItem(
                                  value: 'aleatoria',
                                  child: Text('Chave Aleatória')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedPixType = value!;
                                _recipientController.clear();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _recipientController,
                      decoration: InputDecoration(
                        labelText: _selectedPixType == 'cpf'
                            ? 'CPF'
                            : _selectedPixType == 'celular'
                                ? 'Celular'
                                : _selectedPixType == 'email'
                                    ? 'E-mail'
                                    : 'Chave Aleatória',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: _selectedPixType == 'celular'
                          ? TextInputType.phone
                          : _selectedPixType == 'email'
                              ? TextInputType.emailAddress
                              : TextInputType.text,
                      inputFormatters: _selectedPixType == 'cpf'
                          ? [CpfInputFormatter()]
                          : _selectedPixType == 'celular'
                              ? [CelularInputFormatter()]
                              : [],
                    ),
                    const SizedBox(height: 16),
                    // Seletor de moeda
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCurrency,
                            decoration: const InputDecoration(
                              labelText: 'Moeda',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'real', child: Text('Real (BRL)')),
                              DropdownMenuItem(
                                  value: 'dolar', child: Text('Dólar (USD)')),
                              DropdownMenuItem(
                                  value: 'euro', child: Text('Euro (EUR)')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCurrency = value!;
                                _amountController.clear();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: _selectedCurrency == 'real'
                            ? 'Valor em Real'
                            : _selectedCurrency == 'dolar'
                                ? 'Valor em Dólar'
                                : 'Valor em Euro',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (digits.isEmpty) {
                          _amountController.text = '';
                          _amountController.selection =
                              const TextSelection.collapsed(offset: 0);
                          setState(() {});
                          return;
                        }
                        double parsed = double.parse(digits) / 100;
                        if (_selectedCurrency == 'real' && parsed > 50000) {
                          parsed = 50000;
                        } else if (_selectedCurrency == 'dolar' &&
                            parsed > 10000) {
                          parsed = 10000; // Aproximadamente 50 mil reais
                        } else if (_selectedCurrency == 'euro' &&
                            parsed > 9000) {
                          parsed = 9000; // Aproximadamente 50 mil reais
                        }
                        String symbol = _selectedCurrency == 'real'
                            ? 'R\$'
                            : _selectedCurrency == 'dolar'
                                ? 'US\$'
                                : '€';
                        String formatted = NumberFormat.currency(
                                locale: 'pt_BR', symbol: symbol)
                            .format(parsed);
                        _amountController.value = TextEditingValue(
                          text: formatted,
                          selection:
                              TextSelection.collapsed(offset: formatted.length),
                        );
                        setState(() {});
                      },
                    ),
                    if (_selectedCurrency != 'real' &&
                        _amountController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Builder(
                          builder: (_) {
                            String digits = _amountController.text
                                .replaceAll(RegExp(r'[^0-9]'), '');
                            if (digits.isEmpty) return const SizedBox();
                            double valor = double.parse(digits) / 100;
                            double? cotacao = _selectedCurrency == 'dolar'
                                ? _dollarRate
                                : _euroRate;
                            if (cotacao == null) return const SizedBox();
                            double emReais = valor * cotacao;
                            if (emReais > 50000) emReais = 50000;
                            return Text(
                                'Valor em reais: R\$ ${emReais.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold));
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (_errorMessage != null) ...[
                      Text(_errorMessage!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                    ],
                    ElevatedButton(
                      onPressed: _isLoading || !_camposValidos()
                          ? null
                          : _realizarTransferencia,
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Transferir'),
                    ),
                    const SizedBox(height: 30),
                    const Text('Histórico de Transferências',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final item = _history[index];
                          return ListTile(
                            leading: const Icon(Icons.swap_horiz),
                            title: Text('Para: ${item['destinatario']}'),
                            subtitle: Text(
                                'Valor: R\$ ${item['valor'].toStringAsFixed(2)}'),
                            trailing: Text(item['data']),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

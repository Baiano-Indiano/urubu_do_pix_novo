import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:share_plus/share_plus.dart';
import 'package:urubu_pix/utils/csv_utils.dart';
import 'package:urubu_pix/utils/pdf_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  final double saldo;
  final List<Map<String, dynamic>> historico;
  DashboardScreen({super.key, required this.saldo, List<Map<String, dynamic>>? historico})
    : historico = historico ?? [];

  

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Controle de paginação
  final int _itensPorPagina = 10;
  int _itensExibidos = 0;
  bool _carregandoMais = false;
  final ScrollController _scrollController = ScrollController();
  
  // Filtros
  String _filtroDestinatario = '';
  String _filtroTipo = 'Todos';
  DateTime? _filtroDataInicio;
  DateTime? _filtroDataFim;
  double? _filtroValorMin;
  double? _filtroValorMax;
  String? _erroFiltroData;
  
  // Controladores
  final TextEditingController _dataInicioController = TextEditingController();
  final TextEditingController _dataFimController = TextEditingController();
  final TextEditingController _valorMinController = TextEditingController();
  final TextEditingController _valorMaxController = TextEditingController();
  
  // Gráficos
  String _tipoGrafico = 'Barra';
  final List<String> _tiposGraficos = ['Barra', 'Linha', 'Pizza'];
  
  // Personalização
  bool _mostrarSaldo = true;
  bool _mostrarTransferencias = true;
  final Map<String, bool> _graficosVisiveis = {
    'Barra': true,
    'Linha': true,
    'Pizza': true,
  };

  // --- Removidas todas as duplicatas abaixo deste ponto ---

  void _validarFiltroData() {
    if (_filtroDataInicio != null && _filtroDataFim != null) {
      if (_filtroDataInicio!.isAfter(_filtroDataFim!)) {
        setState(() {
          _erroFiltroData = 'A data inicial não pode ser maior que a data final.';
        });
      } else {
        setState(() {
          _erroFiltroData = null;
        });
      }
    } else {
      setState(() {
        _erroFiltroData = null;
      });
    }
  }

  void _limparFiltros() {
    setState(() {
      _filtroDestinatario = '';
      _filtroTipo = 'Todos';
      _filtroDataInicio = null;
      _filtroDataFim = null;
      _filtroValorMin = null;
      _filtroValorMax = null;
      _dataInicioController.clear();
      _dataFimController.clear();
      _valorMinController.clear();
      _valorMaxController.clear();
      _erroFiltroData = null;
    });
  }



  @override
  void initState() {
    super.initState();
    _carregarPreferenciasPersonalizacao();
    // Inicialização do plugin de notificações antes do uso
    _initializeNotifications().then((_) => checarSaldoENotificar());
    _scrollController.addListener(_onScroll);
  }

  // Inicializa o plugin de notificações
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);
    await notificationsPlugin.initialize(initSettings);
  }

  // Torne o plugin de notificações público para evitar warning de underline
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Método de checagem de saldo e notificação
  Future<void> checarSaldoENotificar() async {
    if (widget.saldo < 100) {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'saldo_baixo',
        'Saldo Baixo',
        channelDescription: 'Notificações de saldo baixo',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);
      await notificationsPlugin.show(
        0,
        'Atenção: Saldo Baixo',
        'Seu saldo está abaixo de R\$ 100,00. Considere realizar um depósito.',
        notificationDetails,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _dataInicioController.dispose();
    _dataFimController.dispose();
    _valorMinController.dispose();
    _valorMaxController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _carregarMaisItens();
    }
  }

  Future<void> _carregarMaisItens() async {
    if (_carregandoMais) return;
    
    setState(() {
      _carregandoMais = true;
    });
    
    // Simula um atraso de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _itensExibidos = (_itensExibidos + _itensPorPagina).clamp(0, _historicoFiltrado.length);
      _carregandoMais = false;
    });
  }

  List<Map<String, dynamic>> get _historicoFiltrado {
    return widget.historico.where((item) {
      // Filtro por destinatário
      if (_filtroDestinatario.isNotEmpty && 
          !(item['destinatario']?.toString() ?? '').toLowerCase().contains(_filtroDestinatario.toLowerCase())) {
        return false;
      }
      // Filtro por tipo
      if (_filtroTipo != 'Todos' && item['tipo'] != _filtroTipo) {
        return false;
      }
      // Filtro por data
      final data = item['data'] is DateTime ? item['data'] as DateTime : null;
      if (data != null) {
        if (_filtroDataInicio != null && data.isBefore(_filtroDataInicio!)) {
          return false;
        }
        if (_filtroDataFim != null && data.isAfter(_filtroDataFim!)) {
          return false;
        }
      }
      // Filtro por valor
      final valor = (item['valor'] as num?)?.toDouble();
      if (valor != null) {
        if (_filtroValorMin != null && valor < _filtroValorMin!) {
          return false;
        }
        if (_filtroValorMax != null && valor > _filtroValorMax!) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  String _formatarData(DateTime data) {
    return DateFormat('dd/MM/yyyy').format(data);
  }

  Future<void> _carregarPreferenciasPersonalizacao() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _mostrarSaldo = prefs.getBool('mostrarSaldo') ?? true;
      _mostrarTransferencias = prefs.getBool('mostrarTransferencias') ?? true;
      for (final tipo in _tiposGraficos) {
        _graficosVisiveis[tipo] = prefs.getBool('grafico_$tipo') ?? true;
      }
    });
  }

  Future<void> _salvarPreferenciasPersonalizacao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mostrarSaldo', _mostrarSaldo);
    await prefs.setBool('mostrarTransferencias', _mostrarTransferencias);
    for (final tipo in _tiposGraficos) {
      await prefs.setBool('grafico_$tipo', _graficosVisiveis[tipo]!);
    }
  }

  Widget _buildPersonalizacaoModal() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Personalizar Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Mostrar saldo'),
                value: _mostrarSaldo,
                onChanged: (v) {
                  setModalState(() => _mostrarSaldo = v);
                },
              ),
              SwitchListTile(
                title: const Text('Mostrar lista de transferências'),
                value: _mostrarTransferencias,
                onChanged: (v) {
                  setModalState(() => _mostrarTransferencias = v);
                },
              ),
              const Divider(),
              const Text('Gráficos visíveis:'),
              ..._tiposGraficos.map((tipo) => CheckboxListTile(
                    title: Text(tipo),
                    value: _graficosVisiveis[tipo],
                    onChanged: (v) {
                      setModalState(() => _graficosVisiveis[tipo] = v ?? true);
                    },
                  )),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    child: const Text('Salvar'),
                    onPressed: () async {
                      await _salvarPreferenciasPersonalizacao();
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalEnviado =
        widget.historico.fold(0.0, (sum, item) => sum + (item['valor'] ?? 0.0));
    int qtdTransf = widget.historico.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Personalizar Dashboard',
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => _buildPersonalizacaoModal(),
              );
              setState(() {}); // Atualiza após fechar modal
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.blue),
            tooltip: 'Exportar CSV',
            onPressed: () async {
              final csv = CsvUtils.toCsv(_historicoFiltrado);
              await SharePlus.instance.share(ShareParams(
                  text: csv, subject: 'Exportação CSV - Urubu Pix'));
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
            tooltip: 'Exportar PDF',
            onPressed: () async {
              final pdfBytes = await PdfUtils.toPdf(_historicoFiltrado);
              final tempDir = await getTemporaryDirectory();
              final file = await File('${tempDir.path}/widget.historico_urubupix.pdf').writeAsBytes(pdfBytes);
              await SharePlus.instance.share(ShareParams(
                files: [XFile(file.path)],
                subject: 'Exportação PDF - Urubu Pix',
              ));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saldo atual:', style: TextStyle(fontSize: 16)),
              Text(
                  NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                      .format(widget.saldo),
                  style:
                      const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const Text('Total transferido:', style: TextStyle(fontSize: 16)),
              Text(
                  NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                      .format(totalEnviado),
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 24),
              const Text('Quantidade de transferências:',
                  style: TextStyle(fontSize: 16)),
              Text(qtdTransf.toString(), style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Resumo financeiro:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: _tipoGrafico,
                    items: _tiposGraficos.map((tipo) => DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _tipoGrafico = val);
                    },
                  ),
                ],
              ),
              // Gráficos customizáveis
              if (_graficosVisiveis[_tipoGrafico] ?? true)
                SizedBox(
                  height: 200,
                  child: _buildGrafico(),
                ),
              const SizedBox(height: 32),
              if (_mostrarTransferencias) ...[
                const Text('Últimas transferências:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 220,
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Buscar destinatário',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _filtroDestinatario = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 130,
                        child: DropdownButton<String>(
                          value: _filtroTipo,
                          hint: const Text('Tipo'),
                          items: ['Todos', 'Enviado', 'Recebido'].map((tipo) => DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo),
                          )).toList(),
                          onChanged: (tipo) {
                            setState(() {
                              _filtroTipo = tipo ?? 'Todos';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 130,
                        child: TextField(
                          controller: _dataInicioController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Data início',
                            prefixIcon: Icon(Icons.date_range),
                          ),
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _filtroDataInicio = picked;
                                _dataInicioController.text = _formatarData(picked);
                                _validarFiltroData();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 130,
                        child: TextField(
                          controller: _dataFimController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Data fim',
                            prefixIcon: Icon(Icons.date_range),
                          ),
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _filtroDataFim = picked;
                                _dataFimController.text = _formatarData(picked);
                                _validarFiltroData();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _valorMinController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Valor mínimo',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _filtroValorMin = double.tryParse(value);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _valorMaxController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Valor máximo',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _filtroValorMax = double.tryParse(value);
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Limpar filtros',
                        onPressed: _limparFiltros,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_erroFiltroData != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(_erroFiltroData!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _itensExibidos < _historicoFiltrado.length
                        ? _itensExibidos + 1
                        : _historicoFiltrado.length,
                    itemBuilder: (context, index) {
                      if (index < _itensExibidos && index < _historicoFiltrado.length) {
                        final item = _historicoFiltrado[index];
                        final destinatario = item['destinatario']?.toString() ?? 'Desconhecido';
                        final valor = (item['valor'] as num?)?.toDouble() ?? 0.0;
                        final data = item['data'] is DateTime ? item['data'] as DateTime : DateTime.now();

                        return ListTile(
                          leading: const Icon(Icons.swap_horiz),
                          title: Text('Para: $destinatario'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Valor: R\$ ${valor.toStringAsFixed(2)}'),
                              Text('Data: ${_formatarData(data)}'),
                            ],
                          ),
                        );
                      } else if (_carregandoMais) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: Text('Não há mais itens para carregar')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ]),
          ),
    )
    );
            
          
        
      
    
  }

  List<double> get valoresPorMes {
    final now = DateTime.now();
    List<double> valores = List.filled(6, 0);
    for (var item in widget.historico) {
      DateTime? data;
      if (item['data'] is DateTime) {
        data = item['data'] as DateTime;
      } else if (item['data'] is String) {
        data = DateTime.tryParse(item['data']);
      }
      if (data == null) continue;
      double valor = (item['valor'] as num?)?.toDouble() ?? 0.0;
      int diff = (now.year - data.year) * 12 + (now.month - data.month);
      if (diff >= 0 && diff < 6) {
        valores[5 - diff] += valor;
      }
    }
    return valores;
  }


  Widget _buildGrafico() {
    switch (_tipoGrafico) {
      case 'Barra':
        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (valoresPorMes.isNotEmpty ? valoresPorMes.reduce((a, b) => a > b ? a : b) : 0) + 20,
            barGroups: List.generate(valoresPorMes.length, (i) {
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: valoresPorMes[i],
                    color: Colors.blue[600],
                    width: 24,
                    borderRadius: BorderRadius.circular(4),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: (valoresPorMes.isNotEmpty ? valoresPorMes.reduce((a, b) => a > b ? a : b) : 0) + 20,
                      color: Colors.blue[100]!.withAlpha(128),
                    ),
                  )
                ],
                showingTooltipIndicators: const [0],
              );
            }),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    final mes = DateTime.now().subtract(Duration(days: (5-value.toInt())*30));
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('${mes.month}/${mes.year%100}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              verticalInterval: 1,
              horizontalInterval: 20,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withAlpha(216),
                strokeWidth: 1,
              ),
            ),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.white,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    'R\$ ${rod.toY.toStringAsFixed(2)}',
                    const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
          ),
        );
      case 'Linha':
        return LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(valoresPorMes.length, (i) =>
                    FlSpot(i.toDouble(), valoresPorMes[i])),
                isCurved: true,
                color: Colors.green[700],
                barWidth: 4,
                belowBarData: BarAreaData(show: true, color: Colors.green[200]!.withAlpha(102)),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 5,
                    color: Colors.white,
                    strokeWidth: 3,
                    strokeColor: Colors.green[700]!,
                  ),
                ),
                showingIndicators: List.generate(valoresPorMes.length, (i) => i),
              ),
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    final mes = DateTime.now().subtract(Duration(days: (5-value.toInt())*30));
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('${mes.month}/${mes.year%100}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toInt().toString(), style: const TextStyle(fontSize: 12));
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                left: BorderSide(color: Colors.grey, width: 1),
                bottom: BorderSide(color: Colors.grey, width: 1),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              verticalInterval: 1,
              horizontalInterval: 20,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withAlpha(216),
                strokeWidth: 1,
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.grey.withAlpha(216),
                strokeWidth: 1,
              ),
            ),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: Colors.white,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      'R\$ ${spot.y.toStringAsFixed(2)}',
                      const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        );
      case 'Pizza':
        return PieChart(
          PieChartData(
            sections: List.generate(valoresPorMes.length, (i) {
              final double fontSize = 18;
              final double radius = 50;
              return PieChartSectionData(
                color: Colors.primaries[i % Colors.primaries.length].withAlpha(216),
                value: valoresPorMes[i],
                title: valoresPorMes[i] > 0 ? 'R\$ ${valoresPorMes[i].toStringAsFixed(2)}' : '',
                radius: radius,
                titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.black87),
                titlePositionPercentageOffset: 0.55,
                borderSide: BorderSide(color: Colors.white, width: 2),
              );
            }),
            sectionsSpace: 4,
            centerSpaceRadius: 36,
            borderData: FlBorderData(show: false),
          ),
        );
      default:
        return PieChart(
          PieChartData(
            sections: List.generate(valoresPorMes.length, (i) {
              final double fontSize = 18;
              final double radius = 50;
              return PieChartSectionData(
                color: Colors.primaries[i % Colors.primaries.length].withAlpha((0.85 * 255).toInt()),
                value: valoresPorMes[i],
                title: valoresPorMes[i] > 0 ? 'R\$ ${valoresPorMes[i].toStringAsFixed(2)}' : '',
                radius: radius,
                titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.black87),
                titlePositionPercentageOffset: 0.55,
                borderSide: BorderSide(color: Colors.white, width: 2),
              );
            }),
            sectionsSpace: 4,
            centerSpaceRadius: 36,
            borderData: FlBorderData(show: false),
          ),
        );
    }
  }

}
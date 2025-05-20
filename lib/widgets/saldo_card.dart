import 'package:flutter/material.dart';

/// Widget que exibe o saldo do usuário com opção de mostrar/ocultar
class SaldoCard extends StatelessWidget {
  final double saldo;
  final bool visivel;
  final bool isLoading;
  final String? error;
  final VoidCallback onToggleVisibilidade;

  const SaldoCard({
    super.key,
    required this.saldo,
    required this.visivel,
    required this.isLoading,
    this.error,
    required this.onToggleVisibilidade,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white10
            : Theme.of(context).primaryColor.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 32,
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Text(
        error!,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: visivel
              ? Text(
                  'R\$ ${saldo.toStringAsFixed(2)}',
                  key: const ValueKey('saldoVisivel'),
                  style: _buildTextStyle(context),
                )
              : Text(
                  '••••••',
                  key: const ValueKey('saldoOculto'),
                  style: _buildTextStyle(context),
                ),
        ),
        IconButton(
          icon: Icon(visivel ? Icons.visibility : Icons.visibility_off),
          tooltip: visivel ? 'Ocultar saldo' : 'Mostrar saldo',
          onPressed: onToggleVisibilidade,
        ),
      ],
    );
  }

  TextStyle _buildTextStyle(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 36,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black87,
    );
  }
}

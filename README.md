# 🏦 Urubu PIX - Banco Digital

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Test Status](https://img.shields.io/badge/tests-passing-brightgreen?style=for-the-badge)](https://github.com/seu-usuario/urubu_pix/actions)

Um aplicativo de banco digital moderno desenvolvido em Flutter, oferecendo uma solução completa para gerenciamento financeiro pessoal, com foco em transferências via PIX, histórico de transações e visualização de saldo em tempo real.

## ✨ Funcionalidades Principais

- 💰 **Gerenciamento de Conta**
  - Visualização de saldo em tempo real
  - Extrato detalhado de transações
  - Perfil do usuário personalizável

- 🔄 **Operações Financeiras**
  - Transferências PIX (CPF, Chave Aleatória, Email, Telefone)
  - Histórico de transações com filtros
  - Comprovantes de transferência

- 📊 **Dashboard Intuitivo**
  - Gráficos de movimentação financeira
  - Visão geral das despesas e receitas
  - Categorização de transações

- 🔒 **Segurança**
  - Autenticação segura
  - Biometria e reconhecimento facial
  - Confirmação em duas etapas

- 🌐 **Acessibilidade**
  - Suporte a temas claro/escuro
  - Interface responsiva para diferentes tamanhos de tela
  - Suporte a múltiplos idiomas

## 🚀 Começando

### Pré-requisitos

- Flutter SDK (versão 3.0.0 ou superior)
- Dart SDK (versão 3.0.0 ou superior)
- Android Studio / Xcode (para desenvolvimento móvel)
- VS Code ou Android Studio (recomendado para desenvolvimento)

### Instalação

1. **Clone o repositório**
   ```bash
   git clone https://github.com/seu-usuario/urubu_pix.git
   cd urubu_pix
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Execute o aplicativo**
   ```bash
   flutter run
   ```

## 🏗️ Estrutura do Projeto

```
lib/
├── main.dart               # Ponto de entrada do aplicativo
├── l10n/                   # Arquivos de internacionalização
│   └── intl_*.arb         # Arquivos de tradução
├── screens/                # Telas do aplicativo
│   ├── auth/               # Fluxo de autenticação
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/               # Tela inicial
│   │   └── home_screen.dart
│   ├── dashboard/          # Dashboard financeiro
│   │   └── dashboard_screen.dart
│   ├── transfers/          # Fluxo de transferências
│   │   ├── transfer_screen.dart
│   │   └── transfer_detail_screen.dart
│   ├── history/            # Histórico de transações
│   │   └── history_screen.dart
│   └── profile/            # Perfil do usuário
│       └── profile_screen.dart
├── widgets/                # Componentes reutilizáveis
│   ├── common/             # Componentes gerais
│   │   ├── buttons/
│   │   ├── dialogs/
│   │   └── loaders/
│   ├── saldo_card.dart     # Card de saldo
│   └── transaction_list.dart # Lista de transações
├── services/               # Camada de serviços
│   ├── api_service.dart    # Comunicação com a API
│   └── auth_service.dart   # Gerenciamento de autenticação
└── utils/                  # Utilitários
    ├── constants.dart      # Constantes do aplicativo
    ├── formatters.dart     # Formatadores de dados
    └── validators.dart     # Validações de formulário
```

## 🧪 Testes

O projeto inclui testes unitários e de widget para garantir a qualidade do código:

```bash
# Executar todos os testes
flutter test

# Executar testes específicos
flutter test test/screens/home_screen_test.dart
```

## 📦 Dependências Principais

| Pacote | Versão | Descrição |
|--------|--------|------------|
| `provider` | ^6.0.5 | Gerenciamento de estado |
| `http` | ^1.4.0 | Requisições HTTP |
| `shared_preferences` | ^2.2.0 | Armazenamento local |
| `intl` | ^0.19.0 | Internacionalização |
| `fl_chart` | ^0.66.0 | Gráficos |
| `mockito` | ^5.4.4 | Mocks para testes |
| `supabase_flutter` | ^2.9.0 | Backend como Serviço |
| `image_picker` | ^1.0.4 | Seleção de imagens |
| `url_launcher` | ^6.1.14 | Abertura de URLs |
| `google_fonts` | ^6.1.0 | Fontes personalizadas |
| `pdf` | ^3.10.8 | Geração de PDF |
| `flutter_local_notifications` | ^16.3.2 | Notificações locais |

## 🤝 Contribuição

1. Faça um Fork do projeto
2. Crie uma Branch para sua Feature (`git checkout -b feature/AmazingFeature`)
3. Adicione suas mudanças (`git add .`)
4. Comite suas mudanças (`git commit -m 'Add some AmazingFeature'`)
5. Faça o Push da Branch (`git push origin feature/AmazingFeature`)
6. Abra um Pull Request

## 📄 Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## ✉️ Contato

Seu Nome - [@seu_twitter](https://twitter.com/seu_twitter) - email@exemplo.com

Link do Projeto: [https://github.com/seu-usuario/urubu_pix](https://github.com/seu-usuario/urubu_pix)

## 📝 Notas de Atualização

### 1.1.0 (2025-05-20)
- Adicionado suporte a notificações locais
- Melhorias na interface do usuário
- Otimização de desempenho
- Correções de bugs menores

### 1.0.0 (2025-04-15)
- Versão inicial do aplicativo
- Funcionalidades básicas de transferência PIX
- Dashboard com histórico de transações
- Autenticação de usuários
- Perfil do usuário
- Geração de comprovantes em PDF

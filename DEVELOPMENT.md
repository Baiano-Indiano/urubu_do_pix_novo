# Guia do Desenvolvedor - Urubu PIX

Este documento fornece informações técnicas detalhadas para desenvolvedores que desejam contribuir com o projeto Urubu PIX.

## 🏗️ Arquitetura

O Urubu PIX segue uma arquitetura em camadas com separação clara de responsabilidades:

1. **Camada de Apresentação (UI)**
   - Widgets e controladores de interface
   - Componentes reutilizáveis
   - Gerenciamento de estado com Provider

2. **Camada de Domínio**
   - Regras de negócio
   - Casos de uso
   - Modelos de domínio

3. **Camada de Dados**
   - Repositórios
   - Fontes de dados (API local/remota)
   - Mapeamento de dados

4. **Camada de Infraestrutura**
   - Serviços de rede (API)
   - Armazenamento local
   - Autenticação

## 🔄 Padrões de Projeto

- **Repository Pattern**: Para abstração do acesso a dados
- **Provider Pattern**: Para gerenciamento de estado
- **Service Locator**: Para injeção de dependências
- **Factory Pattern**: Para criação de objetos complexos

## 🧩 Estrutura de Pastas

```
lib/
├── main.dart               # Ponto de entrada
├── l10n/                    # Internacionalização
├── screens/                 # Telas do aplicativo
│   ├── auth/               # Autenticação
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── dashboard/          # Dashboard financeiro
│   │   └── dashboard_screen.dart
│   ├── transfers/          # Transferências
│   │   ├── transfer_screen.dart
│   │   └── transfer_detail_screen.dart
│   ├── history/            # Histórico
│   │   └── history_screen.dart
│   └── profile/            # Perfil
│       └── profile_screen.dart
├── widgets/                # Componentes UI reutilizáveis
│   ├── common/             # Componentes gerais
│   │   ├── buttons/
│   │   ├── dialogs/
│   │   └── loaders/
│   ├── saldo_card.dart     # Card de saldo
│   └── transaction_list.dart # Lista de transações
├── services/               # Serviços de negócios
│   ├── api_service.dart    # Comunicação com API
│   └── auth_service.dart   # Autenticação
└── utils/                  # Utilitários
    ├── constants.dart      # Constantes
    ├── formatters.dart     # Formatadores
    └── validators.dart     # Validações

test/                      # Testes automatizados
├── mocks/                 # Mocks para testes
├── screens/               # Testes de tela
└── widgets/               # Testes de widgets
```

## 🛠️ Configuração do Ambiente

1. **Configuração do Ambiente Flutter**
   ```bash
   flutter doctor
   flutter pub get
   ```

2. **Variáveis de Ambiente**
   Crie um arquivo `.env` na raiz do projeto:
   ```
   # Configurações da API
   API_BASE_URL=your_api_url_here
   
   # Chaves de API
   GOOGLE_MAPS_API_KEY=your_google_maps_key
   ```

3. **Geração de Código**
   Execute o build_runner para gerar códigos:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## 🧪 Testes

### Estratégia de Testes

1. **Testes Unitários**
   - Testam unidades individuais de código
   - Rápidos e isolados
   ```bash
   flutter test test/unit/
   ```

2. **Testes de Widget**
   - Testam a interface do usuário
   - Verificam a renderização e interações
   ```bash
   flutter test test/widgets/
   ```

3. **Testes de Integração**
   - Testam fluxos completos
   - Verificam a integração entre componentes
   ```bash
   flutter test integration_test/
   ```

### Boas Práticas

- Mantenha os testes independentes
- Use mocks para dependências externas
- Siga o padrão AAA (Arrange-Act-Assert)
- Nomeie os testes de forma descritiva
- Mantenha a cobertura de testes acima de 80%

### Geração de Cobertura

```bash
flutter test --coverage
# Gera relatório em HTML
genhtml coverage/lcov.info -o coverage/html
```

## 🔄 Padrões de Código

1. **Nomenclatura**
   - Classes: `PascalCase`
   - Variáveis e funções: `camelCase`
   - Constantes: `UPPER_CASE`

2. **Documentação**
   - Documente todas as classes públicas
   - Use DartDoc para documentação de API
   - Mantenha comentários explicativos para lógicas complexas

3. **Estilo**
   - Siga as diretrizes oficiais do Flutter
   - Use `dart format` para formatação consistente

## 🔒 Segurança

### Armazenamento Seguro
- Use `flutter_secure_storage` para dados sensíveis
- Nunca armazene tokens ou senhas em texto puro
- Utilize o Keychain (iOS) e o Keystore (Android) para armazenamento seguro

### Validação de Dados
- Valide todas as entradas do usuário no cliente e no servidor
- Use expressões regulares para validação de formatos
- Implemente sanitização de dados para prevenir injeção

### Comunicação
- Utilize HTTPS para todas as requisições de rede
- Implemente SSL Pinning
- Valide certificados SSL
- Use tokens de acesso com tempo de vida limitado

### Autenticação
- Implemente autenticação de dois fatores
- Use refresh tokens
- Implemente bloqueio após várias tentativas falhas
- Registre atividades suspeitas

### Privacidade
- Minimize a coleta de dados
- Obtenha consentimento explícito do usuário
- Cumpra a LGPD/GDPR

## 📦 Gerenciamento de Dependências

1. **Atualização de Pacotes**
   ```bash
   flutter pub outdated
   flutter pub upgrade --major-versions
   ```

2. **Verificação de Vulnerabilidades**
   ```bash
   flutter pub upgrade --dry-run
   ```

## 🚀 Implantação

### Pré-requisitos
- Certifique-se de que todos os testes estão passando
- Atualize o número da versão no `pubspec.yaml`
- Atualize o CHANGELOG.md

### Android
1. Gere a chave de assinatura (se ainda não tiver)
2. Configure o `key.properties`
3. Gere o bundle de release:
   ```bash
   flutter build appbundle --release
   ```
4. Envie para a Google Play Console

### iOS
1. Atualize o número da versão no `Info.plist`
2. Gere o arquivo IPA:
   ```bash
   flutter build ipa --export-options-plist=ios/exportOptions.plist
   ```
3. Envie para o App Store Connect

### Atualizações
- Mantenha as dependências atualizadas
- Documente as mudanças significativas
- Comunique as atualizações aos usuários

## 🐛 Depuração

1. **Logs**
   ```dart
   import 'dart:developer' as developer;
   
   void someMethod() {
     developer.log('Debug log', name: 'my.app.category');
   }
   ```

2. **Observação de Mudanças**
   ```bash
   flutter pub run build_runner watch --delete-conflicting-outputs
   ```

## 🤝 Contribuição

1. Siga o [Código de Conduta](CODE_OF_CONDUCT.md)
2. Crie uma branch descritiva para suas alterações
3. Escreva testes para novas funcionalidades
4. Atualize a documentação conforme necessário
5. Envie um Pull Request com uma descrição clara

## 📝 Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

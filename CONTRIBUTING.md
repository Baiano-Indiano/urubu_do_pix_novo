# Guia de Contribuição

Obrigado por considerar contribuir para o Urubu PIX! Estamos felizes em tê-lo a bordo. Por favor, reserve um tempo para revisar este documento para que o processo de contribuição seja fácil e eficaz para todos os envolvidos.

## 📋 Antes de começar

Antes de começar a contribuir, por favor:

1. Leia nosso [Código de Conduta](CODE_OF_CONDUCT.md)
2. Verifique se não há uma [issue](https://github.com/seu-usuario/urubu_pix/issues) existente para o que você pretende trabalhar
3. Se você está começando, procure por issues com a tag `good first issue`

## 🛠 Configuração do Ambiente

1. **Faça um fork** do repositório
2. **Clone** o repositório para sua máquina local:
   ```bash
   git clone https://github.com/seu-usuario/urubu_pix.git
   cd urubu_pix
   ```
3. **Instale as dependências**:
   ```bash
   flutter pub get
   ```
4. **Execute o aplicativo** para garantir que tudo está funcionando:
   ```bash
   flutter run
   ```

## 🔄 Fluxo de Trabalho

1. **Crie uma branch** para sua feature ou correção:
   ```bash
   git checkout -b feature/nome-da-sua-feature
   # ou
   git checkout -b fix/nome-da-correcao
   ```

2. **Faça suas alterações** seguindo as diretrizes de estilo e testes

3. **Execute os testes** para garantir que nada quebre:
   ```bash
   flutter test
   ```

4. **Faça o commit** das suas alterações:
   ```bash
   git add .
   git commit -m "tipo(escopo): mensagem descritiva"
   ```
   
   Exemplos de mensagens de commit:
   - `feat(home): adiciona botão de atualizar saldo`
   - `fix(auth): corrige validação de senha`
   - `docs: atualiza documentação do README`

5. **Envie as alterações** para o seu fork:
   ```bash
   git push origin nome-da-sua-branch
   ```

6. **Abra um Pull Request** para o branch `main` do repositório original

## 📝 Convenções de Código

### Nomenclatura
- Use nomes descritivos para variáveis, funções e classes
- Siga as convenções de nomenclatura do Dart:
  - Classes: `PascalCase`
  - Variáveis e funções: `camelCase`
  - Constantes: `UPPER_CASE`

### Formatação
- Use `dart format` para manter a formatação consistente
- Linhas não devem ultrapassar 80 caracteres
- Use ponto e vírgula no final das declarações

### Documentação
- Documente todas as classes e métodos públicos
- Use DartDoc para documentação de API
- Mantenha os comentários atualizados com o código

## 🧪 Testes

### Escrevendo Testes
- Escreva testes para novas funcionalidades
- Mantenha a cobertura de testes acima de 80%
- Use mocks para dependências externas

### Executando Testes
```bash
# Todos os testes
flutter test

# Testes específicos
flutter test test/unit/auth_service_test.dart

# Com cobertura
flutter test --coverage
```

## 📦 Gerenciamento de Dependências
- Atualize as dependências regularmente
- Use versões específicas no `pubspec.yaml`
- Documente alterações significativas nas dependências

## 🚀 Implantação

### Android
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ipa --export-options-plist=ios/exportOptions.plist
```

## 📄 Licença

Ao contribuir, você concorda que suas contribuições serão licenciadas sob a [Licença MIT](LICENSE).

## 🙋 Dúvidas?

Se você tiver dúvidas ou precisar de ajuda, abra uma issue no repositório ou entre em contato com a equipe de manutenção.

Obrigado por contribuir para o Urubu PIX! 🎉

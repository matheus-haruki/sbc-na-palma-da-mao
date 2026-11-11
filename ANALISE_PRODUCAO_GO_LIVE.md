# Relatório Técnico: Diagnóstico e Plano de Ação para Produção (Go-Live)
### Aplicativo: SBC na Palma da Mão (Prefeitura de São Bernardo do Campo)
**Data da Análise:** 11 de Novembro de 2026  
**Tecnologia:** Flutter 3 (Dart 3), Modular 6, BLoC / Cubit  
**Plataformas Alvo:** Android (Google Play Store) e iOS (Apple App Store)

---

## 1. Sumário Executivo

Esta auditoria técnica avaliou a prontidão do aplicativo **SBC na Palma da Mão** para publicação e operação em ambiente de produção. Foram analisados aspectos de **segurança da informação, conformidade com políticas das lojas (Apple & Google), resiliência de rede, observabilidade, configurações nativas de build e experiência do usuário (UX)**.

O aplicativo possui uma arquitetura bem delineada utilizando BLoC/Cubit e Modular, e seus fluxos principais (IPTU, Débitos de Trânsito, Zeladoria Urbana) estão funcionais. No entanto, foram identificados **bloqueadores críticos (P0)** que impediriam a aprovação nas lojas ou colocariam em risco a integridade dos dados dos munícipes em produção se não forem tratados previamente.

---

## 2. Bloqueadores Críticos de Segurança e Conformidade (P0)

> [!CAUTION]
> Itens nesta seção representam riscos diretos de rejeição automática nas lojas (Google Play e App Store) e vulnerabilidades de segurança da informação (LGPD).

### 2.1. Desativação de Verificação SSL (`badCertificateCallback = true`)
* **Arquivos Afetados:**
  * `lib/modules/zeladoria/zeladoria_module.dart` (linhas 20-27)
  * `lib/modules/iptu/iptu_module.dart` (linhas 17-24)
  * `lib/modules/debitos_transito/transito_module.dart` (linhas 17-24)
  * `lib/modules/home/home_module.dart` (linhas 21-28)
* **Diagnóstico:** Em quatro módulos do app, o adaptador HTTP do Dio foi configurado para aceitar qualquer certificado:
  ```dart
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    },
  );
  ```
* **Impacto:** Permite ataques de *Man-In-The-Middle* (MITM), onde um intermediário na mesma rede pode interceptar dados sensíveis de munícipes (CPF, celular, endereço, fotos). Além disso, os scanners de segurança automatizados da Apple e da Google sinalizam e rejeitam binários com essa brecha aberta.
* **Ação Corretiva:** Em produção, os servidores municipais possuem certificados SSL válidos (emitidos por Autoridades Certificadoras reconhecidas). Essa sobrescrita deve ser **completamente removida** no código de produção ou condicionada estritamente a `if (kDebugMode)`.

---

### 2.2. Tráfego Cleartext (HTTP Inseguro) Habilitado no Android
* **Arquivo Afetado:** `android/app/src/main/AndroidManifest.xml` (linha 11)
  ```xml
  android:usesCleartextTraffic="true"
  ```
* **Diagnóstico:** Permite conexões HTTP sem criptografia em todo o aplicativo Android.
* **Impacto:** O Google Play Console emite avisos no *Pre-launch Report* e pode barrar atualizações que trafeguem dados pessoais por conexões não seguras.
* **Ação Corretiva:** Alterar para `android:usesCleartextTraffic="false"` e garantir que todos os endpoints de produção utilizem estritamente `https://`.

---

### 2.3. Endpoints de Homologação, Intranet e Túnel Pessoal (Ngrok) Hardcoded
* **Arquivos Afetados:**
  1. `lib/modules/chat/data/repositories/chat_repository.dart` (linhas 12-13):
     ```dart
     final String _baseUrl = 'https://armband-appraiser-uneasy.ngrok-free.dev';
     final String _wsUrl = 'wss://armband-appraiser-uneasy.ngrok-free.dev/ws-atendimento/websocket';
     ```
     *URL temporária de túnel pessoal (Ngrok). O módulo de chat quebrará no momento em que o túnel for encerrado.*
  2. `lib/modules/debitos_transito/repositories/transito_repository.dart` (linhas 13-17):
     ```dart
     static const bool useHomolog = true;
     static const String _hmgBaseUrl = 'http://dti-pwebhmg-02:8080/consulta-de-debitos';
     ```
     *Booleano manual e URL apontando para uma máquina de intranet interna (`dti-pwebhmg-02`), inacessível fora da rede da Prefeitura.*
  3. `lib/modules/zeladoria/repositories/zeladoria_repository.dart` (linha 18) e `endereco_repository.dart` (linha 10):
     ```dart
     static const String baseUrl = 'https://appsbc-api-hmg.saobernardo.sp.gov.br/v1';
     ```
     *Endpoint fixo no servidor de homologação (`hmg`).*
* **Ação Corretiva:** Implementar gerenciamento centralizado de ambientes via **Flavors** ou variáveis de build `--dart-define` / pacote `envied`, garantindo que compilações de Release apontem automaticamente para as URLs oficiais de produção:
  * Exemplo: `https://appsbc-api.saobernardo.sp.gov.br/v1`
  * Exemplo: `https://consultadebitos.saobernardo.sp.gov.br/consulta-de-debitos`

---

### 2.4. Identificador de Pacote Genérico (`com.example`)
* **Arquivo Afetado:** `android/app/build.gradle.kts` (linhas 8 e 19)
  ```kotlin
  namespace = "com.example.palma_da_mao"
  applicationId = "com.example.palma_da_mao"
  ```
* **Diagnóstico:** O Google Play Console **rejeita sumariamente** o upload de pacotes contendo o prefixo `com.example`.
* **Ação Corretiva:** Alterar o `applicationId` e o `namespace` para o domínio oficial da entidade municipal, por exemplo: `br.gov.sp.saobernardo.palmadamao` ou `br.gov.sp.saobernardo.app`.

---

### 2.5. Política de Aplicativos Governamentais nas Lojas
* **Google Play Policy (Government Apps):**
  * Aplicativos que prestam serviços públicos municipais não podem ser publicados em contas pessoais sem autorização formal.
  * O app deve ser publicado na conta de desenvolvedor corporativa oficial da Prefeitura de São Bernardo do Campo (validada com número D-U-N-S governamental) **ou** deve ser submetido previamente o formulário de autorização governamental no Google Play Console (*Play Console Help > Government Apps verification*).
* **Apple App Store (Guideline 5.2.5 - Intellectual Property):**
  * A Apple exige que aplicativos municipais sejam distribuídos sob a conta *Apple Developer Organization* oficial da Prefeitura.

---

## 3. Configurações Nativas de Build & Assinatura (P0 / P1)

### 3.1. Assinatura de Release do Android com Chaves de Debug
* **Arquivo Afetado:** `android/app/build.gradle.kts` (linhas 29-34)
  ```kotlin
  buildTypes {
      release {
          signingConfig = signingConfigs.getByName("debug")
      }
  }
  ```
* **Diagnóstico:** O build de release está configurado para ser assinado com a chave padrão de debug (`debug.keystore`).
* **Ação Corretiva:**
  1. Gerar a Keystore de produção oficial (`upload-keystore.jks`).
  2. Criar o arquivo `android/key.properties` (já adicionado ao `.gitignore`):
     ```properties
     storePassword=SENHA_DA_KEYSTORE
     keyPassword=SENHA_DA_CHAVE
     keyAlias=upload
     storeFile=upload-keystore.jks
     ```
  3. Atualizar o `build.gradle.kts` para ler `key.properties` e vincular ao `signingConfigs.create("release")`.

---

### 3.2. Permissões Depreciadas no Android
* **Arquivo Afetado:** `android/app/src/main/AndroidManifest.xml` (linhas 6-7)
  ```xml
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
  ```
* **Diagnóstico:** A partir do Android 13 (API 33), essas permissões amplas de leitura/escrita foram descontinuadas. O plugin `image_picker` moderno já utiliza o seletor nativo do sistema operacional (*Photo Picker*) sem necessitar de permissões de armazenamento de arquivos.
* **Ação Corretiva:** Remover `WRITE_EXTERNAL_STORAGE` e `READ_EXTERNAL_STORAGE` do manifesto para evitar questionários de auditoria no Google Play Console.

---

### 3.3. Textos Justificativos de Permissões no iOS (`Info.plist`)
* **Arquivo Afetado:** `ios/Runner/Info.plist` (linhas 34-39)
* **Textos Atuais:**
  * `NSCameraUsageDescription`: *"Precisamos da câmera para registrar as fotos da zeladoria."*
  * `NSLocationWhenInUseUsageDescription`: *"Precisamos da sua localização para registrar onde o problema de zeladoria está ocorrendo."*
  * `NSPhotoLibraryUsageDescription`: *"Precisamos de acesso à galeria para anexar fotos da zeladoria."*
* **Impacto:** A equipe de revisão da Apple (Guideline 5.1.1) frequentemente rejeita descrições genéricas ou que mencionem apenas um módulo específico, orientando que o texto descreva o valor prático geral para o munícipe.
* **Textos Recomendados:**
  * `NSCameraUsageDescription`: *"O aplicativo utiliza a câmera para que você possa fotografar e anexar evidências visuais às solicitações de serviços municipais."*
  * `NSPhotoLibraryUsageDescription`: *"O aplicativo necessita de acesso à galeria para que você escolha fotos e comprovantes para anexar às suas solicitações."*
  * `NSLocationWhenInUseUsageDescription`: *"Sua localização é utilizada exclusivamente para preencher e indicar com precisão o local da ocorrência do serviço municipal."*

---

### 3.4. Unificação dos Nomes do Aplicativo
* **AndroidManifest.xml:** `android:label="SBC + i"`
* **Info.plist:** `CFBundleDisplayName = "SBC + i"`
* **AppWidget:** `title: 'SBC na Palma da Mão'`
* **Ação Corretiva:** Alinhar o nome comercial oficial que deve constar no launcher dos smartphones e na barra de títulos da aplicação.

---

## 4. Resiliência de Rede & Robustez da Aplicação (P1)

### 4.1. Ausência de Timeouts em Requisições HTTP (Dio)
* **Diagnóstico:** As instâncias de `Dio` em `ZeladoriaModule`, `IptuModule` e `TransitoModule` utilizam a configuração padrão de timeout do Dio (`Duration.zero` = infinito).
* **Impacto:** Em redes 3G/4G com oscilação de sinal ou em caso de lentidão temporária no backend, a interface do munícipe permanece em estado de carregamento eterno sem exibir mensagens de erro ou opção de tentar novamente.
* **Ação Corretiva:** Definir timeouts explícitos na inicialização do Dio:
  ```dart
  BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 25),
    sendTimeout: const Duration(seconds: 30),
  )
  ```

---

### 4.2. Eliminação de Logs `print()` em Produção
* **Arquivos Afetados:**
  * `lib/modules/iptu/presentational/controllers/iptu_cubit.dart` (linhas 21-22)
  * `lib/modules/debitos_transito/presentational/controllers/transito_cubit.dart` (linhas 21-22)
* **Diagnóstico:** Mensagens de erro e stacktraces são emitidos com `print()` puro.
* **Impacto:** Informações técnicas e eventuais dados pessoais (como CPFs) são gravados diretamente no `logcat` (Android) e `sysdiagnose` (iOS), acessíveis por ferramentas externas conectadas ao aparelho.
* **Ação Corretiva:** Substituir por `debugPrint()` condicionado a `kDebugMode` ou usar um logger estruturado que seja silenciado nas builds de produção.

---

## 5. Observabilidade, Crash Reporting & Monitoramento (P1)

### 5.1. Falta de SDK de Crash Reporting
* **Diagnóstico:** O projeto não possui integração com **Firebase Crashlytics** nem **Sentry**.
* **Impacto:** Se um munícipe enfrentar um crash inesperado em seu dispositivo (ex: erro de layout, parsing de JSON ou exceção de ponteiro nulo), a equipe técnica não terá conhecimento da falha e nem o stacktrace correspondente.
* **Ação Corretiva:** Integrar `firebase_crashlytics` ou `sentry_flutter` capturando erros assíncronos e de renderização no `main.dart`:
  ```dart
  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  ```

---

## 6. Experiência do Usuário (UX), Acessibilidade & Internacionalização (P1 / P2)

### 6.1. Suporte Nativo a Português (`flutter_localizations`)
* **Arquivo Afetado:** `lib/app_widget.dart`
* **Diagnóstico:** O pacote `flutter_localizations` não está instalado no `pubspec.yaml`, e o `AppWidget` não declara `localizationsDelegates`.
* **Impacto:** Menus contextuais nativos (como a barra de seleção de texto *Copy, Paste, Select All*), calendários e mensagens de acessibilidade dos leitores de tela padrão (TalkBack/VoiceOver) permanecem em **inglês**.
* **Ação Corretiva:**
  1. Adicionar `flutter_localizations` no `pubspec.yaml`.
  2. Configurar o `AppWidget`:
     ```dart
     supportedLocales: const [Locale('pt', 'BR')],
     localizationsDelegates: const [
       GlobalMaterialLocalizations.delegate,
       GlobalWidgetsLocalizations.delegate,
       GlobalCupertinoLocalizations.delegate,
     ],
     ```

---

### 6.2. Tratamento de Modo Escuro (Dark Mode)
* **Diagnóstico:** O app foi construído com esquema de cores claras, porém o `AppWidget` não fixa `themeMode: ThemeMode.light`.
* **Impacto:** Em smartphones com modo escuro ativado pelo sistema, diálogos nativos ou seletores de texto podem inverter certas cores, gerando conflitos visuais (ex: texto claro em fundo claro).
* **Ação Corretiva:** Fixar `themeMode: ThemeMode.light` enquanto um tema escuro completo não for desenvolvido.

---

### 6.3. Limpeza de Arquivos de Rascunho / Teste
* **Arquivo Afetado:** `lib/modules/home/presentational/ui/pages/teste.html` (26 KB)
* **Diagnóstico:** Arquivo HTML bruto sem uso no código-fonte em produção.
* **Ação Corretiva:** Excluir o arquivo para evitar peso desnecessário no bundle da aplicação.

---

## 7. Otimizações de Build de Produção (P2)

### 7.1. Ofuscação de Código e Minificação R8
* Para proteger a propriedade intelectual e as regras de negócio municipais contra engenharia reversa via descompilação de APKs:
  ```bash
  # Android (App Bundle)
  flutter build appbundle --release --obfuscate --split-debug-info=./build/symbols

  # iOS (IPA)
  flutter build ipa --release --obfuscate --split-debug-info=./build/symbols
  ```
* Habilitar o R8 no `android/app/build.gradle.kts`:
  ```kotlin
  buildTypes {
      release {
          isMinifyEnabled = true
          isShrinkResources = true
          proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
      }
  }
  ```

---

## 8. Matriz de Priorização (Checklist para Go-Live)

| Nível | Item | Ação | Status Atual |
| :--- | :--- | :--- | :--- |
| **P0** | **Certificados SSL** | Remover `badCertificateCallback = true` em todos os módulos | Pendente |
| **P0** | **Application ID** | Mudar de `com.example` para domínio oficial institucional | Pendente |
| **P0** | **Chave de Release** | Configurar Keystore de produção no Android (`key.properties`) | Pendente |
| **P0** | **Cleartext Traffic** | Definir `usesCleartextTraffic="false"` no AndroidManifest | Pendente |
| **P0** | **URLs de Produção** | Substituir `ngrok`, URLs `hmg` e VPN interna por URLs oficiais | Pendente |
| **P0** | **Contas das Lojas** | Verificar autorização de app governamental (Google Play & Apple) | Ação de Gestão |
| **P1** | **Timeouts HTTP** | Configurar 15s de conexão e 25s de leitura no Dio | Pendente |
| **P1** | **Crash Reporting** | Integrar Firebase Crashlytics ou Sentry no `main.dart` | Pendente |
| **P1** | **Localização pt-BR** | Adicionar `flutter_localizations` para menus e acessibilidade | Pendente |
| **P1** | **Info.plist (iOS)** | Aprimorar justificativas de Câmera, Galeria e Localização | Pendente |
| **P1** | **Logs em Release** | Remover `print()` de stacktraces em controllers | Pendente |
| **P2** | **Dark Mode Lock** | Forçar `themeMode: ThemeMode.light` no `AppWidget` | Pendente |
| **P2** | **Limpeza** | Deletar arquivo `teste.html` | Pendente |
| **P2** | **Ofuscação** | Ativar flags `--obfuscate` e R8 no pipeline de build | Pendente |

---
*Relatório gerado pela ferramenta de análise de código Antigravity.*

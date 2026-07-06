# palma_da_mao

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Serviços oferecidos pelo app:

- A voz da gente
- Guia de Serviços (Remover)
- Notícias do Munícipio (https://www.saobernardo.sp.gov.br/noticias-do-municipio)
- Guia Cultural (Alterar navegação)
- IPTU: 
    - Segunda Via IPTU
    - Tire suas Dúvidas sobre IPTU (Desenvolver nova tela)
    - Desconto do IPTU para Aposentados (Desenvolver nova tela)
- Saúde (serviço indisponível no app)
- Tributos
    - Consultar Débitos
    - 2ª Via de Carnê do ISS de Construção Civil
    - 2ª Via de Parcelamento
    - Alteração de Vencimento de IPTU
    - Alteração Cadastral de IPTU
- Ocorrências com Animais (Desenvolver nova tela)
- Vizinhos da Fauna
- Consulta Prévia de Zoneamento
- Noite Tranquila
- Parcelamento Câmara de Conciliação
- Parcelamento Normal
- Programa Tudo em Dia
- Biblioteca Pública
- Perguntas sobre Corona Vírus (REMOVER)
- Adote um Amigo
    - Instruções para adoção
    - Adote
- Denúncia COVID (REMOVER)
- IPTU Premiado
    - Pesquisa de cupons participantes
    - Cupons ganhadores
- Nota de Prêmios
    - Instruções
    - Pesquisa de cupons participantes
    - Cupons ganhadores
- Meus Dados Municipais (https://agendaeletronica.saobernardo.sp.gov.br/agenda_municipe/administracao/pagina-dados-incompletos)


---


# Documentação Técnica: MVP - Módulo de Serviços e Home

Este documento consolida as decisões arquiteturais, padrões de projeto e implementações técnicas adotadas durante o desenvolvimento do MVP (Minimum Viable Product). O foco desta fase foi estruturar a camada de apresentação e navegação para exibição de conteúdo rico, garantindo alta performance, extensibilidade e estrita adesão ao Material Design.

---

## 1. Arquitetura e Separação de Responsabilidades

Para evitar o acúmulo de regras e dados estáticos na camada de UI (Views), implementamos uma separação rigorosa de diretórios e responsabilidades dentro do módulo de serviços:

* **`models/`**: Contém as abstrações e classes tipadas que definem os contratos de dados (ex: `FaqItem`, `NoticiaItem`).
* **`mocks/`**: Isola todos os dados estáticos temporários (*hardcoded*). Essa decisão garante que as Views permaneçam "burras" e focadas apenas na renderização. A transição para consumo de API externa exigirá apenas a substituição do Mock por chamadas HTTP via um gerenciador de estado (Cubit/Bloc), sem necessidade de reescrever as telas.
* **`presentational/ui/pages/`**: Estruturada em subdomínios (ex: `/iptu/`, `/animais/`) para evitar superlotação do diretório raiz de páginas.

---

## 2. Padrões de Projeto e Modelagem de Dados

### 2.1. Motor de Renderização Baseado em Blocos (Content Blocks)
Foi identificada a necessidade de renderizar respostas complexas que intercalam textos e imagens. A abordagem inicial com `Map<String, String>` foi rejeitada por falta de *Type Safety* e rigidez.

**Solução Aplicada:**
Implementação do padrão de Blocos de Conteúdo usando polimorfismo no modelo `FaqModel`:
* Criação da classe base abstrata `FaqContent`.
* Extensão para blocos específicos: `FaqText` e `FaqImage`.
* O motor de renderização da UI (`SliverList`) itera sobre uma `List<FaqContent>`, verificando o tipo do bloco em tempo de execução (`if (bloco is FaqText)`) e desenhando o widget apropriado.

> **Motivo:** Extensibilidade. Se no futuro houver necessidade de renderizar vídeos, tabelas ou mapas, basta criar um novo modelo (ex: `FaqVideo extends FaqContent`) e adicionar uma condicional no construtor da View, sem quebrar o código existente.

---

## 3. Decisões de UI/UX e Performance

### 3.1. Rejeição do "Accordion Hell" (ExpansionTile)
Nas listagens extensas, como `IptuDuvidasPage` e `OcorrenciasAnimaisPage`, o uso de dropdowns inline (`ExpansionTile`) foi rejeitado. Expandir múltiplos itens com textos longos quebraria o contexto espacial do usuário e prejudicaria o scroll.

* **Solução:** Adoção do padrão de *Master-Detail* emulando um modal. A lista atua apenas como índice, e a leitura do conteúdo ocorre em um `DraggableScrollableSheet` (BottomSheet). Isso preserva o contexto da lista em background e foca a atenção do usuário no conteúdo ativo.

### 3.2. Acessibilidade em Documentos Visuais
Imagens em aplicativos governamentais ou de serviços frequentemente contêm textos miúdos (ex: exemplos de carnês de IPTU).

* **Implementação:** Envelopamento do widget `Image` em um `InteractiveViewer`.
* **Motivo:** Permite o gesto nativo de *pinch-to-zoom* (pinça) e *pan* (arrasto), garantindo acessibilidade sem a necessidade de pacotes externos.

### 3.3. Uso de Slivers para Interfaces Compostas
A tela `OcorrenciasAnimaisPage` exigia um texto introdutório, uma lista de itens iteráveis e um rodapé com links.

* **Implementação:** Utilização exclusiva de `CustomScrollView` com `SliverToBoxAdapter` e `SliverList`.
* **Motivo:** Performance. Os Slivers garantem que apenas os itens visíveis na tela sejam renderizados e mantêm todos os componentes (cabeçalho, lista, rodapé) em um único eixo de rolagem fluido a 60FPS.

### 3.4. Controle de Feedback Visual (Ripple Effect e Camadas de Pintura)
Durante a implementação de `Container` com fundo branco e bordas arredondadas sobre itens interativos (`ListTile`, `InkWell`), o linter reportou que os *ink splashes* estariam invisíveis.

* **Causa:** O Material Design renderiza a animação de clique no widget `Material` ancestral mais próximo. O fundo sólido do `Container` encobria essa animação.
* **Solução Inicial:** Injeção de um `Material(color: Colors.transparent)` sobre o `ListTile` para criar uma tela de pintura dedicada.
* **Ajuste Final:** Por decisão de design, o feedback visual nativo foi desativado explicitamente configurando `splashColor` e `highlightColor` como `Colors.transparent` nas áreas interativas, preservando estritamente as propriedades do Design System customizado.

### 3.5. Compartimentação de Informação Densa (Tabs)
A página `AdocaoGrandePortePage` exigia a exibição de extensas exigências documentais e legislativas para diferentes espécies.

* **Implementação:** Uso de `DefaultTabController` gerenciando abas nativas para separar o escopo visual entre "Bovinos" e "Equinos".
* **Motivo:** Redução de fadiga visual (*Cognitive Load*). O usuário não precisa realizar um scroll infinito passando por informações irrelevantes para o seu caso de uso.

---

## 4. Roteamento (Flutter Modular)

Durante a navegação entre a tela de instruções e a tela de grande porte, ocorreu a exceção `RouteNotFoundException` devido ao uso de caminhos relativos em sub-rotas ambíguas.

**Solução Adotada:**
Padronização de navegação absoluta para telas de primeiro nível e subnível dentro do mesmo módulo.

* **Registro:** 
```dart
  r.child('/grande-porte', child: (context) => const AdocaoGrandePortePage());
  ```
* **Invocação:** 
```dart
  Modular.to.pushNamed('/main/servicos/grande-porte');
  ```
> **Motivo:** Roteamento absoluto blinda a aplicação contra falhas de contexto. Se uma tela for acessada via *deeplink* ou de diferentes pontos da pilha de navegação, o Modular sempre conseguirá resolver a rota a partir da raiz.

---

## 5. Delegação de Eventos (Padrão Command Simplificado)

No componente `NoticiasCarousel`, havia o requisito de que diferentes slides navegassem para contextos completamente distintos (rotas nativas com argumentos, rotas web, telas estáticas).

**Solução Adotada:**
Inversão de dependência na ação de clique. O `PageView` deixou de ter lógica condicional (`if index == 0 navigate...`). A propriedade `onTap` foi adicionada ao modelo `NoticiaItem`.

> **Motivo (KISS & SRP):** A View que renderiza o carrossel agora é agnóstica em relação ao destino final da ação. A responsabilidade de definir o comportamento de clique foi transferida para quem instancia a lista de dados. Isso torna o `NoticiasCarousel` altamente coeso e totalmente reutilizável em outras partes do aplicativo.
# Firy Streak 🔥 - Um App Gamificado de Hábitos Profissional em Flutter

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=for-the-badge&logo=flutter)
![Riverpod](https://img.shields.io/badge/State%20Management-Riverpod-blueviolet?style=for-the-badge)
![Firebase](https://img.shields.io/badge/Firebase-SDK-orange?style=for-the-badge&logo=firebase)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-enabled-blue?logo=githubactions)
![Figma](https://img.shields.io/badge/Figma-Design%20%26%20Prototyping-%23F24E1E?style=for-the-badge&logo=figma)
[![Live Demo](https://img.shields.io/badge/Live%20Demo-Visitar-brightgreen?style=for-the-badge&logo=firebase)](https://firy-streak.web.app/)

<p align="center">
  <img src="https://github.com/user-attachments/assets/4e539bb0-7af8-47c1-ae2f-042108849221" alt="Descrição do GIF" />
</p>


**Firy Streak** é mais do que um simples app de hábitos; é um projeto de portfólio onde demonstro minhas habilidades em criar aplicativos Flutter robustos, escaláveis e testáveis. Nele, o usuário cuida de um pet virtual, o **Firy**, alimentando-o diariamente ao cumprir um hábito. O objetivo é manter a sequência (streak) e ver o pet evoluir.

Desde a concepção, meu foco foi construir uma base sólida, aplicando princípios de **Arquitetura Limpa**, gerenciamento de estado reativo com **Riverpod** e automação com **GitHub Actions**.

## 🌟 Destaques Técnicos (O que eu quero demonstrar com este projeto)

Como este é um projeto de portfólio, minhas escolhas técnicas foram intencionais para simular um ambiente de desenvolvimento profissional.

*   **🎨 Design e Prototipação com Figma:** Meu envolvimento no projeto foi além do código. Antes de escrever a primeira linha de Flutter, estruturei o fluxo do usuário e prototipei as telas no Figma. Mais importante, **eu criei pessoalmente todos os assets vetoriais (SVGs) do pet Firy**, desde o ovo até seus estágios de evolução e estados de humor. Essa abordagem garante uma identidade visual única e demonstra minha capacidade de navegar entre o design de UI/UX e a implementação técnica para entregar um produto final polido.
*   **🚀 Arquitetura Limpa (Feature-First):** Abandonei uma estrutura simples e organizei o projeto em `features` (`auth`, `pet_management`, `quotes`) e `core` (elementos compartilhados como tema, auth_gate). Cada feature é um módulo com suas próprias camadas (`application`, `data`, `domain`, `presentation`), garantindo baixo acoplamento e alta escalabilidade.
*   **💧 Gerenciamento de Estado com Riverpod:** Migrei do `Provider` tradicional para o **Riverpod**. Isso me permitiu um controle mais granular e testável do estado. Utilizei diferentes tipos de providers (`Provider`, `StateProvider`, `StreamProvider`, `FutureProvider`) para lidar com injeção de dependência, estado da UI, streams em tempo real do Firestore e chamadas de API assíncronas de forma eficiente e declarativa.
*   **🤖 CI/CD com GitHub Actions:** Implementei um workflow completo de Integração e Deploy Contínuo. A cada `push` na branch `main`:
    1.  Os testes unitários são executados automaticamente para garantir a integridade da lógica de negócios.
    2.  Se os testes passarem, o app web é buildado em modo `release`.
    3.  A nova versão é enviada automaticamente para o **Firebase Hosting**.
*   **🧪 Testabilidade da Lógica de Negócios:** A lógica mais crítica do app – o estado do pet baseado na passagem do tempo – é 100% testável. Utilizei injeção de dependência para injetar um `Clock` "fake" nos testes, permitindo simular a passagem de horas e dias em milissegundos. Usei também `fake_cloud_firestore` e `firebase_auth_mocks` para testar as interações com o Firebase de forma rápida e isolada.
*   **💻 Experiência Web Aprimorada:** Para a versão web, criei um `MobileFrameWrapper`, um widget que envolve o aplicativo em uma moldura de celular em telas maiores. É um detalhe que demonstra meu cuidado com a apresentação e a experiência do usuário em diferentes plataformas.
*   **☁️ Integração com API Externa:** Adicionei uma feature (`quotes`) que consome uma API REST para buscar frases motivacionais, exibidas quando o usuário alimenta o Firy. Isso demonstra minha capacidade de lidar com requisições HTTP e gerenciar o estado assíncrono resultante com `FutureProvider`.

## ✨ Funcionalidades

*   ✅ **Autenticação Segura:** Cadastro e Login com Email/Senha usando Firebase Authentication.
*   🐣 **Onboarding de Usuário:** Uma introdução visualmente agradável para novos usuários, cujo estado (visto/não visto) é persistido localmente com `shared_preferences`.
*   🔥 **Gamificação de Hábitos:** O usuário escolhe um hábito e alimenta o Firy para manter sua sequência de dias.
*   🥚 **Evolução do Pet:** O Firy não apenas fica feliz ou triste. Ele **evolui** através de diferentes estágios (`Bebê` -> `Criança` -> `Adolescente` -> `Adulto`) conforme a streak do usuário aumenta.
*   💬 **Interação Dinâmica:** O Firy se comunica através de balões de fala. Quando está com fome, ele pede comida. Quando é alimentado, ele exibe uma frase motivacional obtida de uma API externa.
*   ☁️ **Persistência em Nuvem:** Todos os dados do usuário, do pet e do hábito são salvos em tempo real no Cloud Firestore.
*   💻 **Suporte Multiplataforma:** Código-fonte único que roda em Android, iOS e Web (com deploy automatizado).

## 🎨 O Ciclo de Vida do Firy

O estado do Firy é determinado por duas variáveis principais: a **passagem do tempo** e o **tamanho da streak**.

1.  **Ovo 🐣 (`streak = 0`)**: Todo novo pet começa como um ovo. Ao ser "chocado" (alimentado pela primeira vez), ele nasce.
2.  **Bebê 👶 (`streak: 1-9`)**: O primeiro estágio. Precisa ser alimentado a cada 24h.
3.  **Criança 🧒 (`streak: 10-29`)**: O pet evolui!
4.  **Adolescente 🧑 (`streak: 30-59`)**: Mais uma evolução, recompensando a consistência.
5.  **Adulto 🧔 (`streak: 60+`)**: O estágio final da evolução do Firy.

O status diário é simples:
`[ALIMENTADO 😊]` --- *passam 24h* ---> `[FAMINTO 😥]` --- *passam mais 24h* ---> `[MORTO 💀]`

Quando o pet morre, a streak é zerada e o usuário pode revivê-lo para começar um novo ciclo.

## 💡 Da Ideia ao Pixel: O Processo de Design no Figma

Para garantir uma experiência de usuário coesa e um desenvolvimento ágil, não pulei direto para o código. Todo o projeto foi meticulosamente planejado, prototipado e desenhado no Figma antes da implementação. Isso me permitiu validar fluxos, testar layouts e criar uma base visual sólida.

Meu processo no Figma incluiu:

*   **Prototipação da UI/UX:** Definição das telas, navegação e da jornada completa do usuário, desde o onboarding até a interação diária com o pet.
*   **Criação de um Mini Design System:** Desenvolvi componentes reutilizáveis (botões, cards, inputs) para garantir consistência visual e acelerar o desenvolvimento no Flutter.
*   **Design de Assets Personalizados:** Todos os sprites do Firy e outros elementos visuais foram criados como vetores (SVG) diretamente no Figma, garantindo que fossem leves e escaláveis para qualquer tamanho de tela.

Essa base sólida no Figma foi fundamental para construir uma interface bonita e funcional de forma eficiente.

![image](https://github.com/user-attachments/assets/d522c177-cb95-4695-8e16-9f18c3bcdf54)
![image](https://github.com/user-attachments/assets/3617e82a-efde-4053-a5aa-c9c4a17bd022)

## ⚙️ O Ecossistema do Projeto: A API de Quotes

Para levar a interatividade a outro nível e garantir frases temáticas e divertidas (cheias de trocadilhos como "Jack Chamas" e "Fogarlett Johansson"), eu desenvolvi uma API dedicada para o projeto.

Trata-se de uma API REST simples, construída com **Node.js e Express**, que lê um arquivo JSON e serve uma frase aleatória a cada requisição do aplicativo Flutter. Para garantir alta disponibilidade e um deploy facilitado, a API está hospedada na **Vercel**.

Isso demonstra a criação de um ecossistema completo, onde o front-end (Flutter) consome um serviço de back-end (Node.js) que eu mesmo criei e implantei.

> **Você pode conferir o código-fonte da API em seu próprio repositório:**
> ### ➡️ [lucaseneiva/firy-streak-api](https://github.com/lucaseneiva/firy-streak-api)

## 🛠️ Tecnologias e Arquitetura

### Tecnologias Principais

*   **[Figma](https://www.figma.com/)**: Para o design da UI/UX, prototipação e criação dos assets visuais do projeto.
*   **[Flutter](https://flutter.dev/) & [Dart](https://dart.dev/)**: Para a UI e a lógica do aplicativo.
*   **[Riverpod](https://riverpod.dev/)**: Para gerenciamento de estado reativo e injeção de dependência.
*   **[Firebase](https://firebase.google.com/)**:
    *   **Authentication**: Gerenciamento de usuários.
    *   **Cloud Firestore**: Banco de dados NoSQL para dados em tempo real.
    *   **Hosting**: Para o deploy da versão web.
*   **[Vercel](https://vercel.com/)**: Plataforma de deploy para a API serverless.
*   **[GitHub Actions](https://github.com/features/actions)**: Para automação de testes e deploy (CI/CD).
*   **[http](https://pub.dev/packages/http)**: Para consumir a API de frases motivacionais.
*   **[flutter_svg](https://pub.dev/packages/flutter_svg)**: Para renderizar as imagens vetoriais do pet.
*   **[google_fonts](https://pub.dev/packages/google_fonts)**: Para uma tipografia elegante.

### Estrutura do Projeto

Adotei uma arquitetura limpa e escalável, separando as responsabilidades de forma clara.

```
lib/
├── core/                   # Módulos compartilhados por todo o app
│   ├── auth/
│   │   └── auth_gate.dart  # "Portão" que gerencia o estado de auth do usuário
│   ├── theme/              # Tema global do app (cores, fontes, etc.)
│   └── utils/              # Utilitários, como o MobileFrameWrapper
│
├── features/               # Cada funcionalidade principal do app é um módulo
│   ├── auth/               # Feature de Autenticação (Login, Cadastro)
│   │   ├── application/    # Lógica de estado (Providers do Riverpod)
│   │   └── presentation/   # Widgets e Telas (UI)
│   │
│   ├── pet_management/     # Feature principal (cuidar do pet)
│   │   ├── application/    # Providers do pet
│   │   ├── data/           # Lógica de dados (PetService)
│   │   ├── domain/         # Modelos e Enums (PetState)
│   │   └── presentation/   # Telas (Home, Onboarding) e Widgets
│   │
│   └── quotes/             # Feature de frases motivacionais
│       ├── application/    # Provider da quote
│       └── data/           # Serviço que consome a API
│
└── main.dart               # Ponto de entrada, inicializa o Firebase e o ProviderScope
```

## 🚀 Como Começar

Siga os passos abaixo para configurar e executar o projeto localmente.

### Pré-requisitos

*   **Flutter SDK**: Versão 3.x ou superior.
*   **Conta no Firebase**: [Crie uma gratuitamente](https://firebase.google.com/).

### Configuração do Firebase

1.  **Crie um Projeto no Firebase** e ative os serviços de **Authentication (Email/Senha)** e **Firestore Database**.
2.  **Configure a FlutterFire CLI** seguindo o [guia oficial](https://firebase.flutter.dev/docs/cli).
3.  **Conecte o App ao Firebase** executando na raiz do projeto:
    ```bash
    flutterfire configure
    ```
    Isso irá gerar o arquivo `lib/firebase_options.dart` com as credenciais do seu projeto.

### Instalação

1.  **Clone o Repositório:**
    ```bash
    git clone https://github.com/lucaseneiva/firy-streak-app.git
    cd firy-streak-app
    ```

2.  **Instale as Dependências:**
    ```bash
    flutter pub get
    ```

## ▶️ Executando o Aplicativo

Com o ambiente configurado, execute o seguinte comando:

```bash
flutter run
```

## 🧪 Executando os Testes

Para garantir a qualidade da lógica de negócios, execute os testes unitários. Além de poder rodar localmente, esses testes são executados automaticamente a cada `push` para a branch `main` através do nosso workflow de CI/CD no GitHub Actions.

```bash
flutter test
```

## ✒️ Autor

-   **Lucas E. Eneiva** - [GitHub](https://github.com/lucaseneiva)

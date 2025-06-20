
---

# Firy Streak 🔥

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=for-the-badge&logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-SDK-orange?style=for-the-badge&logo=firebase)
![Tests](https://img.shields.io/badge/Tests-Passing-brightgreen?style=for-the-badge&logo=jest)
![License](https://img.shields.io/badge/License-MIT-purple?style=for-the-badge)

![image](https://github.com/user-attachments/assets/5dc47d5f-0af1-4400-a9d2-ce5c56222096)

**Firy Streak** é um aplicativo multiplataforma (Android, iOS, Web, Desktop) desenvolvido em Flutter que gamifica a criação de hábitos. Cuide do seu pet virtual, o **Firy**, alimentando-o diariamente para manter sua sequência (streak) e vê-lo evoluir!

O projeto foi construído com foco em uma arquitetura limpa, separação de responsabilidades e alta testabilidade, especialmente para a lógica de negócios que depende do tempo.

---

## 📋 Sumário

- [✨ Funcionalidades](#-funcionalidades)
- [🎨 Visual](#-visual)
- [🛠️ Tecnologias e Arquitetura](#️-tecnologias-e-arquitetura)
- [🚀 Como Começar](#-como-começar)
  - [Pré-requisitos](#pré-requisitos)
  - [Configuração do Firebase](#configuração-do-firebase)
  - [Instalação](#instalação)
- [▶️ Executando o Aplicativo](#️-executando-o-aplicativo)
- [🧪 Executando os Testes](#-executando-os-testes)
- [📁 Estrutura do Projeto](#-estrutura-do-projeto)
- [✒️ Autor](#️-autor)

---

## ✨ Funcionalidades

- ✅ **Autenticação de Usuários:** Cadastro e Login seguros com Email/Senha usando Firebase Authentication.
- 🔥 **Gamificação de Hábitos:** Mantenha uma sequência de "dias de fogo" (streak) alimentando seu pet.
- 🥚 **Pet Virtual Interativo:** O estado do Firy (Ovo, Alimentado, Faminto, Morto) muda com base nas suas ações e no tempo.
- ☁️ **Persistência de Dados em Nuvem:** Todos os dados do usuário e do pet são salvos em tempo real no Cloud Firestore.
- 🎯 **Arquitetura Limpa e Testável:** Separação clara entre UI, lógica de negócios e serviços de dados.
- 💻 **Suporte Multi-plataforma:** Código-fonte único que roda em Android, iOS, Web e Desktop.

## 🎨 Visual

O ciclo de vida do seu Firy é simples e recompensador:

```
[OVO 🐣] ---Alimentar--> [ALIMENTADO 😊] ---+1 dia sem alimentar--> [FAMINTO 😥] ---+1 dia sem alimentar--> [MORTO 💀]
```

| Estado | Imagem (SVG) | Descrição |
| :--- | :---: | :--- |
| **OVO** | `egg.svg` | Um novo pet esperando para ser cuidado! |
| **ALIMENTADO** | `fed.svg` | Pet feliz e streak aumentada! |
| **FAMINTO** | `not_fed.svg` | O pet precisa de atenção! Sua streak está em risco. |
| **MORTO** | `dead.svg` | A streak foi perdida. Reviva o pet para começar de novo. |

## 🛠️ Tecnologias e Arquitetura

Este projeto utiliza tecnologias de ponta para garantir uma experiência de desenvolvimento e de usuário robusta.

### Tecnologias Principais

- **[Flutter](https://flutter.dev/) & [Dart](https://dart.dev/)**: Para a construção da UI e da lógica do aplicativo.
- **[Firebase](https://firebase.google.com/)**:
  - **Authentication**: Gerenciamento de usuários.
  - **Cloud Firestore**: Banco de dados NoSQL para armazenar os dados do usuário e do pet.
- **[flutter_svg](https://pub.dev/packages/flutter_svg)**: Para renderizar as imagens vetoriais do pet.
- **[Provider / StreamBuilder](https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html)**: Para gerenciamento de estado reativo, ouvindo as mudanças do Firebase em tempo real.

### Arquitetura e Padrões de Projeto

- **Separação de Responsabilidades**:
  - **UI (`/lib/*_screen.dart`)**: Camada de apresentação, responsável por exibir os dados e capturar as interações do usuário.
  - **Serviço (`/lib/pet_service.dart`)**: Camada de lógica de negócios. Centraliza todas as regras de como o pet se comporta, como o tempo afeta seu estado e as interações com o banco de dados.
  - **Controle de Autenticação (`/lib/auth_gate.dart`)**: Um widget "portão" que gerencia o estado de autenticação do usuário e decide qual tela exibir (Login ou Home).

- **Injeção de Dependência para Testabilidade**:
  - O `PetService` recebe suas dependências (Firestore, Auth e `Clock`) via construtor.
  - O uso do pacote **[clock](https://pub.dev/packages/clock)** permite simular a passagem do tempo nos testes, garantindo que a lógica de "fome" e "morte" do pet funcione como esperado sem a necessidade de esperar horas ou dias reais. Isso é um pilar da alta qualidade e profissionalismo do código.

- **Testes Unitários Abrangentes**:
  - A lógica crítica em `pet_service.dart` é coberta por testes unitários.
  - Utilizamos **`fake_cloud_firestore`** e **`firebase_auth_mocks`** para simular o backend do Firebase, permitindo testes rápidos e independentes da rede.
  - **`fake_async`** é usado em conjunto com `clock` para controlar o fluxo do tempo nos testes.

## 🚀 Como Começar

Siga os passos abaixo para configurar e executar o projeto localmente.

### Pré-requisitos

- **Flutter SDK**: Versão 3.x ou superior. [Guia de instalação](https://docs.flutter.dev/get-started/install).
- **Editor de Código**: VS Code ou Android Studio (com os plugins do Flutter/Dart).
- **Conta no Firebase**: [Crie uma gratuitamente](https://firebase.google.com/).

### Configuração do Firebase

1.  **Crie um Projeto no Firebase:** Acesse o [console do Firebase](https://console.firebase.google.com/) e crie um novo projeto.

2.  **Ative os Serviços:**
    - No menu "Build", vá para **Authentication**, clique em "Começar" e ative o provedor **"E-mail/senha"**.
    - No menu "Build", vá para **Firestore Database**, clique em "Criar banco de dados" e inicie no **modo de produção** (production mode).

3.  **Configure o FlutterFire CLI:**
    - Se ainda não tiver, instale a CLI do Firebase: `npm install -g firebase-tools`.
    - Faça login: `firebase login`.
    - Instale a CLI do FlutterFire: `dart pub global activate flutterfire_cli`.

4.  **Conecte o App ao Firebase:**
    - Na raiz do projeto, execute o comando:
      ```bash
      flutterfire configure
      ```
    - Siga as instruções, selecionando o projeto Firebase que você criou. Este comando irá gerar/atualizar automaticamente o arquivo `lib/firebase_options.dart` com as credenciais do seu projeto.

### Instalação

1.  **Clone o Repositório:**
    ```bash
    git clone https://github.com/lucaseneiva/firy_streak.git
    cd lucaseneiva-firy_streak
    ```

2.  **Instale as Dependências:**
    ```bash
    flutter pub get
    ```

## ▶️ Executando o Aplicativo

Com o ambiente configurado, execute o seguinte comando para iniciar o aplicativo em um emulador, simulador ou dispositivo conectado:

```bash
flutter run
```

## 🧪 Executando os Testes

Para garantir a qualidade e a integridade da lógica de negócios, execute os testes unitários:

```bash
flutter test
```

Você verá os testes em `test/pet_service_test.dart` serem executados, validando a lógica de tempo e as interações com o Firebase mockado.

## 📁 Estrutura do Projeto

A lógica principal do aplicativo está concentrada no diretório `lib/`:

```
lib/
├── auth_gate.dart          # Decide entre a tela de Login e a Home com base no estado de auth.
├── home_screen.dart        # Tela principal para usuários logados, exibe o pet.
├── login_screen.dart       # Tela de login.
├── main.dart               # Ponto de entrada do aplicativo, inicializa o Firebase.
├── pet_service.dart        # Coração da lógica de negócios do pet (estado, alimentação, etc.).
└── register_screen.dart    # Tela de cadastro de novos usuários.
```

## ✒️ Autor

- **Lucas E. Eneiva** - [GitHub](https://github.com/lucaseneiva)

# Thermo Wear
ThermoWear é um aplicativo desenvolvido em Flutter para Wear OS (Android) que demonstra o uso criativo de sensores de hardware em dispositivos vestíveis. O projeto apresenta um widget interativo que responde a movimentos físicos do usuário para exibir dados ambientais.

![Demonstração APP Thermo Wear](https://github.com/PedroCoelhoIF/Thermo_Wear/blob/main/assets/demo/demo-app-thermo-wear.gif?raw=true)

## Funcionalidades:
  - Navegação atráves da inclinação do dispositivo: Utiliza o acelerômetro para detectar quando o usuário inclina o smartwatch em direção ao rosto, trocando automaticamente da tela de boas-vindas para a leitura de dados.
  - Monitoramento Ambiental: Acessa o sensor nativo de hardware do smartwatch para captar e exibir a temperatura ambiente em tempo real.
  - Interface Adaptativa: Layout otimizado para telas redondas de smartwatches.
  - O aplicativo possui dois estados principais gerenciados pelo widget ThermoWearWidget:
      1. Estado de Repouso: Exibe uma mensagem convidando o usuário a interagir.
      2. Estado Ativo (Inclinado): Ao detectar que o relógio está na posição de leitura (eixo Z alinhado com a gravidade), o app exibe a temperatura atual. Ao abaixar o braço, ele retorna ao estado inicial.

## Tecnologias Utilizadas:
  - Flutter - Framework de UI.
  - sensors_plus - Para acesso ao acelerômetro (detecção de inclinação).
  - MethodChannel - Para comunicação nativa com o sensor de temperatura do Android.

## 👥 Equipe:
  - Pedro
  - [Marcos] (https://github.com/dipardi) - Testes unitários para garantir o funcionamento do app.

## 🛠️ Como Executar o Projeto:
Para baixar e executar este projeto localmente, siga os passos abaixo.
  1. Clone o repositório ou baixe.
  2. Instale as dependências (flutter pub get)
  3. Escolha o emulador, rode o arquivo main.dart presente na pasta example.

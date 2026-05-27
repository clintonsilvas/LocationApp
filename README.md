# 📦 LocationApp - Sistema de Entregas com Geolocalização

Aplicativo Flutter para gerenciamento de entregas com **SQLite local**, **geolocalização em tempo real** e visualização no mapa.

---

## 🚀 Funcionalidades

- 📋 Cadastro de entregas
- ✏️ Edição de entregas
- 🗑️ Exclusão de entregas
- 📍 Captura automática da localização atual
- 🗺️ Exibição da posição no mapa (OpenStreetMap)
- 🔄 Atualização em tempo real da lista
- 🗄️ Banco de dados local (SQLite)
- 📊 Status da entrega (Enum)

---

## 🧱 Tecnologias utilizadas

- Flutter
- Dart
- SQLite (sqflite)
- Geolocator
- Flutter Map (OpenStreetMap)
- GoRouter
- UUID

---

## 📱 Status da entrega

- 🟠 Pendente
- 🔵 Saiu para entrega
- 🟣 Em transporte
- 🟢 Entregue

---

## 🗺️ Geolocalização

O app utiliza o pacote **Geolocator** para capturar automaticamente:

- Latitude
- Longitude

Esses dados são exibidos no mapa usando **Flutter Map**.

---

## 🗃️ Estrutura do projeto

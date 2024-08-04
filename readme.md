# Simulador de Empréstimo

Este é um aplicativo Flutter para simulações de empréstimos.

## Requisitos

- Flutter
- Dart
- [Composer](https://getcomposer.org/) (para o backend Laravel)
- PHP 7.4 (ou versão compatível com o backend Laravel)

## Configuração do Projeto

### Frontend (Flutter)
      
 **Instale as Dependências**

No diretório do projeto, instale as dependências necessárias:

```bash
flutter pub get
```

Conecte um dispositivo ou inicie um emulador e execute o aplicativo:

```bash
flutter run
```

### Backend (Laravel)

Certifique-se de ter o PHP e o Composer instalados. Instale as dependências da API:

```bash
composer install
```


Crie um arquivo .env a partir do .env.example e configure as variáveis de ambiente conforme necessário.
1. **Inicie o Servidor**

Inicie o servidor local para a API:

```bash
php artisan serve
```
O servidor estará disponível em http://127.0.0.1:8000 por padrão.

   

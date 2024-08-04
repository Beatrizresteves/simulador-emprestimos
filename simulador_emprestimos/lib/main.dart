import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(SimuladorEmprestimosApp());
}

class SimuladorEmprestimosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulador de Empréstimos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SimuladorEmprestimosPage(),
    );
  }
}

class SimuladorEmprestimosPage extends StatefulWidget {
  @override
  _SimuladorEmprestimosPageState createState() => _SimuladorEmprestimosPageState();
}

class _SimuladorEmprestimosPageState extends State<SimuladorEmprestimosPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _valorController = TextEditingController();
  List<String> _instituicoes = [];
  List<String> _convenios = [];
  List<String> _selectedInstituicoes = [];
  List<String> _selectedConvenios = [];
  int _selectedParcela = 36;
  String? _resultadoSimulacao;

  @override
  void initState() {
    super.initState();
    _fetchInstituicoes();
    _fetchConvenios();
  }

  Future<void> _fetchInstituicoes() async {
    // Chamar o endpoint da API para obter as instituições
    // Por exemplo, http.get('HOST/api/instituicao')
    // E atualizar o estado com os dados recebidos
    setState(() {
      _instituicoes = ['Instituição 1', 'Instituição 2']; // Exemplo
    });
  }

  Future<void> _fetchConvenios() async {
    // Chamar o endpoint da API para obter os convênios
    // Por exemplo, http.get('HOST/api/convenio')
    // E atualizar o estado com os dados recebidos
    setState(() {
      _convenios = ['Convênio 1', 'Convênio 2']; // Exemplo
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Remove R$ e converte para double
        final valorString = _valorController.text.replaceAll(r'R$', '').replaceAll('.', '').replaceAll(',', '.');
        final valorEmprestimo = double.parse(valorString);
        final instituicoes = _selectedInstituicoes;
        final convenios = _selectedConvenios;
        final parcela = _selectedParcela;

        // Enviar os dados para a API na rota /api/simular
        final response = await http.post(
          Uri.parse('http://localhost:8000/api/simular'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'valorEmprestimo': valorEmprestimo,
            'instituicoes': instituicoes,
            'convenios': convenios,
            'parcelas': parcela,
          }),
        );

        if (response.statusCode == 200) {
          // Processar a resposta da API
          final responseData = json.decode(response.body);
          setState(() {
            _resultadoSimulacao = responseData['resultado']; // Ajuste conforme o formato da resposta da sua API
          });
        } else {
          // Tratar erros na resposta da API
          setState(() {
            _resultadoSimulacao = 'Erro na simulação. Tente novamente.';
          });
        }
      } catch (e) {
        print('Erro ao converter o valor: $e');
        setState(() {
          _resultadoSimulacao = 'Erro ao converter o valor. Verifique o formato.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simulador de Empréstimos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _valorController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyTextInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Valor do Empréstimo',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(labelText: 'Instituições'),
                items: _instituicoes.map((instituicao) {
                  return DropdownMenuItem<String>(
                    value: instituicao,
                    child: Text(instituicao),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null && !_selectedInstituicoes.contains(value)) {
                    setState(() {
                      _selectedInstituicoes.add(value);
                    });
                  }
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(labelText: 'Convênios'),
                items: _convenios.map((convenio) {
                  return DropdownMenuItem<String>(
                    value: convenio,
                    child: Text(convenio),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null && !_selectedConvenios.contains(value)) {
                    setState(() {
                      _selectedConvenios.add(value);
                    });
                  }
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Parcelas'),
                value: _selectedParcela,
                items: [36, 48, 60, 72, 84].map((parcela) {
                  return DropdownMenuItem<int>(
                    value: parcela,
                    child: Text('$parcela parcelas'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedParcela = value;
                    });
                  }
                },
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Simular'),
              ),
              if (_resultadoSimulacao != null) ...[
                SizedBox(height: 32.0),
                Text(
                  'Resultado da Simulação:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                Text(
                  _resultadoSimulacao!,
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CurrencyTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String text = newValue.text;
    text = text.replaceAll('.', '');
    text = text.replaceAll(',', '.');
    if (text.isNotEmpty) {
      final doubleValue = double.tryParse(text) ?? 0;
      final formatter = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2);
      final newText = formatter.format(doubleValue);
      return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
    return newValue;
  }
}

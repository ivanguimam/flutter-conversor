import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController realController = TextEditingController();
  final TextEditingController dolarController = TextEditingController();
  final TextEditingController euroController = TextEditingController();

  late double dollar;
  late double euro;

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void realChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(text);

    dolarController.text = (real / dollar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void dolarChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double dollar = double.parse(text);

    realController.text = (dollar * this.dollar).toStringAsFixed(2);
    euroController.text = (dollar * this.dollar / euro).toStringAsFixed(2);
  }

  void euroChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double euro = double.parse(text);

    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dollar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.amber,
          centerTitle: true,
          title: Text('\$ Conversor \$')),
      backgroundColor: Colors.black,
      body: FutureBuilder<Map>(
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  "Carregando Dados...",
                  style: TextStyle(
                    color: Colors.amber,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Erro ao carregar os dados :(",
                    style: TextStyle(
                      color: Colors.amber,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              dollar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
              euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];

              return SingleChildScrollView(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.monetization_on, size: 150, color: Colors.amber),
                    buildTextField("Real", "R\$", realController, realChanged),
                    const Divider(),
                    buildTextField(
                        "Dólar", "US\$", dolarController, dolarChanged),
                    const Divider(),
                    buildTextField("Euro", "€", euroController, euroChanged),
                  ],
                ),
              );
          }
        },
        future: getData(),
      ),
    );
  }
}

const url = "https://api.hgbrasil.com/finance?format=json&key=05932543";

Future<Map> getData() async {
  Uri uri = Uri.parse(url);
  http.Response response = await http.get(uri);

  return json.decode(response.body);
}

TextField buildTextField(String label, String prefix,
    TextEditingController controller, Function(String text) onChanged) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      border: OutlineInputBorder(),
      labelStyle: TextStyle(color: Colors.amber),
      labelText: label,
      prefixText: prefix,
    ),
    keyboardType: TextInputType.number,
    onChanged: onChanged,
    style: TextStyle(color: Colors.amber, fontSize: 25),
  );
}

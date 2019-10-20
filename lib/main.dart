import "package:flutter/material.dart";

import "package:http/http.dart" as http;
import "dart:async";
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance";

void main() async {
  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
          inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white))))));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar = 0.0;
  double euro = 0.0;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanged(String text){
    double real = double.parse(realController.text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text){
    double dolar = double.parse(dolarController.text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text){
    double euro = double.parse(euroController.text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text("Conversor de moedas"),
            centerTitle: true,
            backgroundColor: Colors.amber),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: Text("Carregando dados...",
                          style:
                              TextStyle(color: Colors.amber, fontSize: 25.0)));
                default:
                  if (snapshot.hasError) {
                    return Center(
                        child: Text("Erro ao carregar dados",
                            style: TextStyle(
                                color: Colors.amber, fontSize: 25.0)));
                  } else {
                    dolar =
                        snapshot.data["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                    return SingleChildScrollView(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Icon(Icons.monetization_on,
                                size: 150.0, color: Colors.amber),
                            buildTextField("Reais", "R\$", realController, _realChanged),
                            Divider(),
                            buildTextField("Dolares", "US\$", dolarController, _dolarChanged),
                            Divider(),
                            buildTextField("Euros", "E", euroController, _euroChanged)
                          ],
                        ));
                  }
              }
            }));
  }
}

Widget buildTextField(String label, String prefix, TextEditingController c, Function f) {
  return TextFormField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: "$prefix"),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<User> fetchUser() async {
  final response = await http.get(Uri.parse('http://192.168.1.48:8080/api/users/5'));

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}'); // Imprime el cuerpo de la respuesta

  if (response.statusCode == 200) {
    try {
      // Parsear el JSON a un mapa de datos y crear el usuario
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      print('Error parsing JSON: $e'); // Imprimir si hay un error en la conversión
      throw const FormatException('Failed to parse User');
    }
  } else {
    throw Exception('Failed to load User');
  }
}

void testConnection() async {
  try {
    final response = await http.get(Uri.parse('http://192.168.1.48:8080'));
    print('Test Connection - Response status: ${response.statusCode}');
    print('Test Connection - Response body: ${response.body}');
  } catch (e) {
    print('Error in testConnection: $e');
  }
}

class User {
  final int id;
  final String email;
  final String username;
  final String nameUser;
  final String lastName;
  final String password;

  const User({
    required this.username,
    required this.id,
    required this.nameUser,
    required this.email,
    required this.lastName,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('Parsing user JSON: $json'); // Imprime el JSON antes de procesarlo

    if (json.containsKey('id') &&
        json.containsKey('email') &&
        json.containsKey('username') &&
        json.containsKey('nameUser') &&
        json.containsKey('lastName') &&
        json.containsKey('password')) {
      return User(
        id: json['id'],
        email: json['email'],
        username: json['username'],
        nameUser: json['nameUser'],
        lastName: json['lastName'],
        password: json['password'],
      );
    } else {
      throw const FormatException('Failed to load User.');
    }
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<User> futureUser;

  @override
  void initState() {
    super.initState();
    futureUser = fetchUser();
    testConnection(); // Llama a la función de prueba de conexión aquí
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<User>(
            future: futureUser,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print('User data loaded: ${snapshot.data}'); // Imprimir datos cargados
                return Text(snapshot.data!.nameUser);
              } else if (snapshot.hasError) {
                print('Error in FutureBuilder: ${snapshot.error}'); // Imprimir error en FutureBuilder
                return Text('${snapshot.error}');
              }

              // Muestra un indicador de carga por defecto
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:listacontatosdesafio/lista_contatos_page.dart';
import 'package:listacontatosdesafio/temp_camera_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ListaContatosPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink,)
    );
  }
}
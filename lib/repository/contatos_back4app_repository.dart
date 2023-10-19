import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:listacontatosdesafio/models/contatos_back4app_model.dart';

class ContatosBack4AppRepository {

  final _dio = Dio();

  ContatosBack4AppRepository() {
    _dio.options.headers["X-Parse-Application-Id"] = dotenv.get("BACK4APPPARSEID");
    _dio.options.headers["X-Parse-REST-API-Key"] = dotenv.get("BACK4APPRESTAPI");
    _dio.options.headers["Content-Type"] = "application/json";
    _dio.options.baseUrl = dotenv.get("BACK4APPURL");
  }

  Future<ContatosBack4AppModel> obterContatos() async {
    var url = "/Contato";
    var result = await _dio.get(url);
    return ContatosBack4AppModel.fromJson(result.data);
  }

  Future<void> criar(Contato contato) async {
    await _dio.post("/Contato", data: contato.toJsonCreateEndPoint());
  }

    Future<void> atualizar(String objectId, Contato contato) async {
    await _dio.put("/Contato/$objectId", data: contato.toJsonCreateEndPoint());
  }

    Future<void> remover(String objectId) async {
    await _dio.delete("/Contato/$objectId");
  }

}
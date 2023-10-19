class ContatosBack4AppModel {
  List<Contato> contatos = [];

  ContatosBack4AppModel(this.contatos);

  ContatosBack4AppModel.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      contatos = <Contato>[];
      json['results'].forEach((v) {
        contatos.add(Contato.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['results'] = contatos.map((v) => v.toJsonEndPoint()).toList();
      return data;
  }
}

class Contato {
  String objectId = "";
  String nome = "";
  String telefone = "";
  String descricao = "";
  String createdAt = "";
  String updatedAt = "";
  String imagem = "";

  Contato(
      this.objectId,
      this.nome,
      this.telefone,
      this.descricao,
      this.createdAt,
      this.updatedAt,
      this.imagem);

   Contato.criar(
      this.nome,
      this.telefone,
      this.descricao,
      this.imagem);   

  Contato.fromJson(Map<String, dynamic> json) {
    objectId = json['objectId'];
    nome = json['nome'];
    telefone = json['telefone'];
    descricao = json['descricao'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    imagem = json['imagem'];
  }

  Map<String, dynamic> toJsonEndPoint() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['objectId'] = objectId;
    data['nome'] = nome;
    data['telefone'] = telefone;
    data['descricao'] = descricao;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['imagem'] = imagem;
    return data;
  }

    Map<String, dynamic> toJsonCreateEndPoint() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nome'] = nome;
    data['telefone'] = telefone;
    data['descricao'] = descricao;
    data['imagem'] = imagem;
    return data;
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listacontatosdesafio/models/contatos_back4app_model.dart';
import 'package:listacontatosdesafio/repository/contatos_back4app_repository.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart';
import 'package:image_cropper/image_cropper.dart';

class ListaContatosPage extends StatefulWidget {
  const ListaContatosPage({super.key});

  @override
  State<ListaContatosPage> createState() => _ListaContatosPageState();
}

class _ListaContatosPageState extends State<ListaContatosPage> {

//Começo variaveis globais
  TextEditingController nomeController = TextEditingController();
  TextEditingController telefoneController = TextEditingController();
  TextEditingController descricaoController = TextEditingController();
  

  var contatoRepository = ContatosBack4AppRepository();
  var contatoModel = ContatosBack4AppModel([]);

  var nome = "";
  var telefone = "";
  var descricao = "";
  var imagem = "assets/DefaultImage.png";
  bool nomeVisibility = false;
  bool telefoneVisibility = false;
  bool descricaoVisibility = false;

  XFile? photo;

//Função de crop
 cropImage(XFile imageFile) async {

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.pink,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      await GallerySaver.saveImage(croppedFile.path);
      photo = XFile(croppedFile.path);
      imagem = photo!.path;
      setState(() {
        
      });
    }

    
  }

//Procedimentos de inicialização
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    carregarDados();
  }

  carregarDados() async {
    contatoModel = await contatoRepository.obterContatos();
    setState(() {
      
    });
  }

//Começo código da pagina
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          nomeController.text = "";
          telefoneController.text = "";
          descricaoController.text = "";
          //Cria "tela" para preencher informações e salvar um novo contato
        showDialog(context: context, builder: (BuildContext bc) {
          return StatefulBuilder(builder: ((context, setState) {
          return Dialog(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                width: 300,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const Text("Preencha os campos para criar um novo contato"),
                SizedBox(height: 20),

                //Botão para trocar a imagem
                Center(child: FloatingActionButton(child: (photo == null ? (Image(image: AssetImage('assets/DefaultImage.png'))) : Image.file(File(photo!.path))), onPressed:() async {
                  showModalBottomSheet(context: context, builder: (bc) {
                    return Wrap(children: [
                      ListTile(
                        leading: Icon(Icons.camera),
                        title: Text("Camera"),
                        onTap: () async {
                          final ImagePicker _picker = ImagePicker();
                          photo = await _picker.pickImage(source: ImageSource.camera);
                          if (photo != null) {
                            String path = (await path_provider.getApplicationDocumentsDirectory()).path;
                            String name = basename(photo!.path);
                            await photo!.saveTo("$path/$name");
                            
                            await GallerySaver.saveImage(photo!.path);
                            Navigator.pop(context);
                            // imagem = photo!.path;

                            cropImage(photo!);
                            
                            setState(() {});
                          }
                        } ),
                        ListTile(
                          leading: Icon(Icons.browse_gallery),
                          title: Text("Gallery"),
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            photo = await picker.pickImage(source: ImageSource.gallery);
                            Navigator.pop(context);
                            // imagem = photo!.path;
                            cropImage(photo!);
                            
                            setState(() {});
                          },
                          
                        )
                        
                    ],);         
                  });setState(() {});
                  
                },  
                
                ) ) , 
                
                
                
                const SizedBox(height: 20,),

                

                //Começo textfields
                const Text("Nome:"), 
                TextField(controller: nomeController,
                onChanged: (String value) {
                  nome = value;
                  setState(() {});
                }
                ),
                const SizedBox(height: 20,),
                const Text("Telefone:"),
                TextField(controller: telefoneController,
                keyboardType: TextInputType.number, 
                 onChanged: (String value) {
                  telefone = value;
                }),
                const SizedBox(height: 20,),
                const Text("Descricao:"),
                TextField(controller: descricaoController,
                 onChanged: (String value) {
                  descricao = value;
                }),
                const SizedBox(height: 50,),


                //Começo do botão salvar
                Center(child: TextButton(onPressed: () async {
                  await contatoRepository.criar(Contato.criar(nome, telefone, descricao, imagem));
                  setState(() {
                    carregarDados();
                  });
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }, child: const Text("Salvar")))  
              ],),
              ),
            )
          );}));
        });
},),


      appBar: AppBar(
        title: const Text("Lista de contatos"),),
        body:  Column(children: [
          Expanded(child: ListView.builder(
            itemCount: contatoModel.contatos.length,
            itemBuilder: (BuildContext bc, int index) {
              var contato = contatoModel.contatos[index];

              return Card(
                child: Dismissible(
                  key: Key(contato.objectId),
                  onDismissed: (dismissDirection) async {
                    await contatoRepository.remover(contato.objectId);
                    carregarDados();
                  },
                  child: InkWell(
                    child: ListTile(
                      title: Text(contato.nome),
                      leading: (contato.imagem == null ? (Image(image: AssetImage('assets/DefaultImage.png'))) : Image.file(File(contato.imagem))),
                      trailing: Text(contato.telefone),
                    ),
                    onTap: () {
                      nomeController.text = contato.nome;
                      telefoneController.text = contato.telefone;
                      descricaoController.text = contato.descricao;
                              showDialog(context: context, barrierDismissible: false,builder: (BuildContext bc,) {
                                  
          return StatefulBuilder(builder: (context, setState) {
            imagem = contato.imagem;
            return  Dialog(
              child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                width: 300,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Center(child: Text("Informações sobre ${contato.nome}:")),
                SizedBox(height: 20),
                //Botão para trocar a imagem
                Center(child: FloatingActionButton(child: (contato.imagem == null ? (Image(image: AssetImage('assets/DefaultImage.png'))) : Image.file(File(contato.imagem))), onPressed:() async {
                  showModalBottomSheet(context: context, builder: (bc) {
                    return Wrap(children: [
                      ListTile(
                        leading: Icon(Icons.camera),
                        title: Text("Camera"),
                        onTap: () async {
                          final ImagePicker _picker = ImagePicker();
                          photo = await _picker.pickImage(source: ImageSource.camera);
                          if (photo != null) {
                            String path = (await path_provider.getApplicationDocumentsDirectory()).path;
                            String name = basename(photo!.path);
                            await photo!.saveTo("$path/$name");
                            
                            await GallerySaver.saveImage(photo!.path);
                            Navigator.pop(context);
                            // imagem = photo!.path;

                            cropImage(photo!);
                            
                            setState(() {});
                          }
                        } ),
                        ListTile(
                          leading: Icon(Icons.browse_gallery),
                          title: Text("Gallery"),
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            photo = await picker.pickImage(source: ImageSource.gallery);
                            Navigator.pop(context);
                            // imagem = photo!.path;
                            cropImage(photo!);
                            
                            setState(() {});
                          },
                          
                        )
                        
                    ],);         
                  });setState(() {});
                  
                },  
                
                )),
                const SizedBox(height: 20,),
    
                //Começo textfields
                Row(
                  children: [
                    Text("Nome: ${contato.nome}"),
                    InkWell(
                      child: Icon(Icons.edit, size: 15,),
                      onTap: () {
                        setState(() {
                          nomeVisibility = !nomeVisibility;
                          //nomeController.text = contato.nome;
                        });
                      },),
                  ],
                ),
                Visibility(
                  visible: nomeVisibility,
                  child: TextField(controller: nomeController,
                  onChanged: (String value) {
                    setState(() {
                      nome = value;
                    });
                    
                  }
                  ),
                ),
                const SizedBox(height: 20,),

                Row(
                  children: [
                    Text("Telefone: ${contato.telefone}"),
                    InkWell(
                      child: Icon(Icons.edit, size: 15,),
                      onTap: () {
                        setState(() {
                          telefoneVisibility = !telefoneVisibility;
                          //telefoneController.text = contato.telefone;
                        });
                      },),
                  ],
                ),
                Visibility(
                  visible: telefoneVisibility,
                  child: TextField(controller: telefoneController,
                  keyboardType: TextInputType.number,  
                   onChanged: (String value) {
                   setState(() {
                      telefone = value;
                    });
                  }),
                ),
                const SizedBox(height: 20,),

                Row(
                  children: [
                    Text("Descricao:"),
                    InkWell(
                      child: Icon(Icons.edit, size: 15,),
                      onTap: () {
                        setState(() {
                          descricaoVisibility = !descricaoVisibility;
                          //descricaoController.text = contato.descricao;
                        });
                      },),
                  ],
                ),
                Text(contato.descricao),
                Visibility(
                  visible: descricaoVisibility,
                  child: TextField(controller: descricaoController,
                   onChanged: (String value) {
                     setState(() {
                      descricao = value;
                    });
                  }),
                ),
                const SizedBox(height: 50,),


                //Começo do botão salvar
                TextButton(onPressed: () async {     
                  nome = nomeController.text;
                  telefone = telefoneController.text;
                  descricao = descricaoController.text;
    
                  await contatoRepository.atualizar(contato.objectId, Contato.criar(nome, telefone, descricao, imagem));
                  // ignore: use_build_context_synchronousl
                  Navigator.pop(context);
                  nomeVisibility = false;
                  telefoneVisibility = false;
                  descricaoVisibility = false;
                  setState(() {
                    carregarDados();
                  });
                }, child: const Text("Salvar")), 
                //Começo botão cancelar
                TextButton(onPressed: () {
                  Navigator.pop(context);
                  nomeVisibility = false;
                  telefoneVisibility = false;
                  descricaoVisibility = false;
                  nomeController.text = contato.nome;
                  telefoneController.text = contato.telefone;
                  descricaoController.text = contato.descricao;
                  nome = nomeController.text;
                  telefone = telefoneController.text;
                  descricao = descricaoController.text;
                  setState(() {
                    carregarDados();
                  });
                }, child: const Text("Cancelar")) 
              ],),
              ),
            )
          );
          
          } );
         
        });
                    },
                  ),
                  ),
              );
              
              
            }))
        ],),
        ));
  }
}
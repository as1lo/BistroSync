import 'dart:convert';
import 'dart:io';
import 'package:bistro/classes/user.dart';
import 'package:bistro/screens/widgets/cores.dart';
import 'package:bistro/screens/widgets/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Config extends StatefulWidget {
  final BistroUser bistroUser; // Objeto da classe BistroUser

  Config({super.key, required this.bistroUser});

  @override
  _ConfigState createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final List<Map<String, dynamic>> _options = [];
  final _optionNameController = TextEditingController();
  String? _selectedIconName;

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? base64Image;
  Color? _primaryColor;
  Color? _tertiaryColor;

  @override
  void initState() {
    super.initState();
    _fetchInitialValues();
  }

  Future<void> _fetchInitialValues() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.bistroUser.id)
          .get();

      if (snapshot.exists) {
        setState(() {
          _nameController.text = snapshot['name'] ?? '';
          _primaryColor = _hexToColor(snapshot['primaryColor'] ?? '#FFFFFF');
          _tertiaryColor = _hexToColor(snapshot['tertiaryColor'] ?? '#FFFFFF');
          base64Image = snapshot['image_base64'];
          _senhaController.text = snapshot.data()!.containsKey('senhaWiFi')
              ? snapshot['senhaWiFi'] ?? ''
              : '';
          if (snapshot.exists && snapshot.data()!.containsKey('options')) {
            setState(() {
              _options
                  .addAll(List<Map<String, dynamic>>.from(snapshot['options']));
            });
          }
        });
      }
    } catch (e) {
      print("Erro ao buscar valores iniciais: $e");
    }
  }

  Future<void> _addOrUpdateOption({int? index}) async {
    final optionName = _optionNameController.text.trim();
    if (optionName.isEmpty || _selectedIconName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o nome e selecione um ícone.')),
      );
      return;
    }

    setState(() {
      if (index != null) {
        // Atualiza uma opção existente
        _options[index] = {
          'name': optionName,
          'icon': _selectedIconName!,
        };
      } else {
        // Adiciona uma nova opção
        _options.add({
          'name': optionName,
          'icon': _selectedIconName!,
        });
      }
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.bistroUser.id)
          .update({'options': _options});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opção salva com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar a opção: $e')),
      );
    }

    _optionNameController.clear();
    _selectedIconName = null;
    Navigator.of(context).pop();
  }

  void _showOptionDialog({Map<String, dynamic>? option, int? index}) {
    if (option != null) {
      _optionNameController.text = option['name'];
      _selectedIconName = option['icon'];
    } else {
      _optionNameController.clear();
      _selectedIconName = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index != null ? 'Editar Opção' : 'Adicionar Opção'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _optionNameController,
                decoration: InputDecoration(labelText: 'Nome da Opção'),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedIconName,
                decoration: InputDecoration(labelText: 'Ícone'),
                items: iconMapping.keys.map((iconName) {
                  return DropdownMenuItem(
                    value: iconName,
                    child: Row(
                      children: [
                        FaIcon(iconMapping[iconName]),
                        SizedBox(width: 10),
                        Text(iconName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedIconName = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => _addOrUpdateOption(index: index),
              child: Text(index != null ? 'Salvar' : 'Adicionar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteOption(int index) async {
    setState(() {
      _options.removeAt(index);
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.bistroUser.id)
          .update({'options': _options});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opção removida com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover a opção: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();

      setState(() {
        _imageFile = File(pickedFile.path);
        base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _updateSettings() async {
    if (_formKey.currentState!.validate() && base64Image != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.bistroUser.id)
            .update({
          'name': _nameController.text.trim(),
          'primaryColor': _colorToHex(_primaryColor ?? corPadrao()),
          'tertiaryColor': _colorToHex(_tertiaryColor ?? corPadrao()),
          'senhaWiFi': _senhaController.text.trim(),
          'image_base64': base64Image,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configurações salvas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar configurações: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  Future<void> _pickColor(String colorType) async {
    final pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) {
        Color tempColor = colorType == 'primary'
            ? (_primaryColor ?? Colors.white)
            : (_tertiaryColor ?? Colors.white);
        return AlertDialog(
          title: Text('Selecione uma cor'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: tempColor,
              onColorChanged: (color) {
                tempColor = color;
              },
              availableColors: allColors,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, tempColor);
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (pickedColor != null) {
      setState(() {
        if (colorType == 'primary') {
          _primaryColor = pickedColor;
        } else if (colorType == 'tertiary') {
          _tertiaryColor = pickedColor;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text('Configurações', style: TextStyle(color: Colors.white)),
          backgroundColor: _primaryColor ?? Colors.blue,
        ),
        body: Container(
            height: size.height,
            width: size.width,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome do restaurante
                      TextFormField(
                        controller: _nameController,
                        decoration:
                            InputDecoration(labelText: 'Nome do Restaurante'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, digite o nome do restaurante';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // senha
                      TextFormField(
                        controller: _senhaController,
                        decoration:
                            InputDecoration(labelText: 'Senha do Wi-Fi'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, digite a senha do Wi-FI';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),
                      // Seletor de cor primária
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Cor Primária:'),
                          ElevatedButton(
                            onPressed: () => _pickColor('primary'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor ?? Colors.white,
                              shape: CircleBorder(),
                              minimumSize: Size(40, 40),
                            ),
                            child: Container(),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Seletor de cor terciária
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Cor Secundária:'),
                          ElevatedButton(
                            onPressed: () => _pickColor('tertiary'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _tertiaryColor ?? Colors.white,
                              shape: CircleBorder(),
                              minimumSize: Size(40, 40),
                            ),
                            child: Container(),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      Text(
                        'Opções',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                          itemCount: _options.length,
                          itemBuilder: (context, index) {
                            final option = _options[index];
                            return ListTile(
                              leading: FaIcon(
                                  iconMapping[option['icon']] ?? FontAwesomeIcons.question),
                              title: Text(option['name']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showOptionDialog(
                                      option: option,
                                      index: index,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteOption(index),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      
                      SizedBox(height: 20),

                      // Botão para adicionar opção
                      ElevatedButton(
                        onPressed: () => _showOptionDialog(),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Colors.green,
                        ),
                        child: Text('Adicionar Nova Opção'),
                      ),

                      // Botão para selecionar imagem
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: _imageFile != null
                              ? Image.memory(
                                  base64Decode(base64Image!),
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Text(
                                    'Selecione a logo do restaurante',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Botão para salvar configurações
                      ElevatedButton(
                        onPressed: _updateSettings,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Colors.green,
                        ),
                        child: Text('Salvar Configurações'),
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }
}

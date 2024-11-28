import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class RegistraFiliado extends StatefulWidget {
  final String? filiadoId;
  final String? email;

  RegistraFiliado({Key? key, this.filiadoId, this.email}) : super(key: key);

  @override
  _RegistraFiliadoState createState() => _RegistraFiliadoState();
}

class _RegistraFiliadoState extends State<RegistraFiliado> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _wppController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.filiadoId != null) {
      _loadCliente();
    }
  }

  void _loadCliente() async {
    setState(() {
      _isLoading = true;
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
    .collection('filiados')
    .where('email_user', isEqualTo: widget.email)
    .get();

    // Verificar se há documentos retornados pela consulta
    if (querySnapshot.docs.isNotEmpty) {
      // Percorre todos os documentos retornados pela consulta
      for (var doc in querySnapshot.docs) {
        if (doc.id == widget.filiadoId) {
          var filiado = doc.data() as Map<String, dynamic>;

          _nameController.text = filiado['name'];
          _emailController.text = filiado['email'].toString();
          _wppController.text = filiado['whatsapp'].toString();

          break;
        }
      }
    } else {
      // Tratar o caso onde nenhum documento foi encontrado
      print('Nenhum produto encontrado para este usuário.');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _registerOrEditCliente() async {
    if (_formKey.currentState!.validate()) {
      if (widget.filiadoId == null) {
        // Registrar cliente
        await FirebaseFirestore.instance.collection('filiados').add({
          'name': _nameController.text,
          'email': _emailController.text,
          'whatsapp': _wppController.text,
          'email_user': widget.email
        });
      } else {
        // Atualizar cliente
        await FirebaseFirestore.instance
            .collection('filiados')
            .doc(widget.filiadoId)
            .update({
          'name': _nameController.text,
          'email': _emailController.text,
          'whatsapp': _wppController.text,
          'email_user': widget.email
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Filiado ${widget.filiadoId == null ? 'registrado' : 'atualizado'} com sucesso!'),
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
         title: Text(
              widget.filiadoId == null
                  ? 'Cadastrar Filiados'
                  : 'Editar Filiados',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 38,
              )),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(89, 19, 165, 1.0),
       
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 200, vertical: 100),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 0),
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Form(
                              key: _formKey,
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 35),
                                    TextFormField(
                                      style:
                                          const TextStyle(color: Colors.black87,
                                  fontWeight: FontWeight.bold),
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Nome do Filiado',
                                        labelStyle:
                                            TextStyle(color: Colors.black54,
                                  fontWeight: FontWeight.bold),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor, digite o nome do Filiado!';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    TextFormField(
                                      style:
                                          const TextStyle(color: Colors.black87,
                                  fontWeight: FontWeight.bold),
                                      controller: _emailController,
                                      decoration: const InputDecoration(
                                        labelText: 'Email',
                                        labelStyle:
                                            TextStyle(color: Colors.black54,
                                  fontWeight: FontWeight.bold),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor, digite o Email!';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    TextFormField(
                                      style:
                                          const TextStyle(color: Colors.black87,
                                  fontWeight: FontWeight.bold),
                                      controller: _wppController,
                                      decoration: const InputDecoration(
                                        labelText: 'Número do WhatsApp',
                                        labelStyle:
                                            TextStyle(color: Colors.black54,
                                  fontWeight: FontWeight.bold),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor, digite o número do WhatsApp!';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: _registerOrEditCliente,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color.fromRGBO(89, 19, 165, 1.0),
                                        minimumSize: const Size(2000, 42),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      child: Text(
                                        widget.filiadoId == null
                                            ? 'Registrar Filiado'
                                            : 'Editar Filiado',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

import 'package:bistro/screens/widgets/cores.dart';
import 'package:bistro/screens/widgets/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/inicial/telaLogin.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String _nome = '';
  String _email = '';
  String _whatsapp = '';
  String _password = '';
  String _confirmPassword = '';
  String erro = '';
  bool _isLoading = false;

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_password == _confirmPassword) {
          UserCredential userCredential =
              await _auth.createUserWithEmailAndPassword(
            email: _email,
            password: _password,
          );

          String uid = userCredential.user!.uid;

          await _firestore.collection('users').doc(uid).set({
            'name': _nome,
            'email': _email,
            'whatsapp': _whatsapp,
            'tipo_user': 'filiado'
          });

          final snackBar = SnackBar(
            content: Text('Cadastro concluído: ${userCredential.user!.email}'),
            duration: Duration(seconds: 5), // Duração da SnackBar
          );
          Navigator.pop(context);
          // Exibe a SnackBar
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          final snackBar = const SnackBar(
            content: Text('As senhas não correspondem'),
            duration: Duration(seconds: 5), // Duração da SnackBar
          );
          // Exibe a SnackBar
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } catch (e) {
        if (e is FirebaseAuthException) {
          if (e.code == 'email-already-in-use') {
            erro = 'Email já cadastrado';
          } else if (e.code == 'weak-password') {
            erro = 'Digite uma senha com mais de 6 digitos';
          } else if (e.code == 'invalid-email') {
            erro = 'Email inválido';
          } else {
            erro = 'Erro ao cadastrar';
          }
        }
        final snackBar = SnackBar(
          content: Text(erro),
          duration: Duration(seconds: 5), // Duração da SnackBar
        );
        // Exibe a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _mobile(size) {
    return Column(
      children: [
        SizedBox(
          height: size.height * 0.35,
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.01),
            child: Center(
              child: Text(
                'Preencha seus dados!',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.07,
                    color: Colors.white),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1, // espalhamento
                      blurRadius: 5, // desfoque
                      offset: Offset(0, 0) // posição x,y
                      )
                ]),
            child: Padding(
                padding: EdgeInsets.only(
                    top: size.width * 0.01,
                    bottom: size.width * 0.01,
                    right: size.width * 0.09,
                    left: size.width * 0.09),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: size.height * 0.02),
                        SizedBox(height: size.height * 0.02),
                        TextFormField(
                          decoration: inputDec('Nome Completo'),
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira seu nome';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _nome = value;
                          },
                        ),
                        SizedBox(height: size.height * 0.01),
                        TextFormField(
                          decoration: inputDec('Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira um e-mail';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _email = value;
                          },
                        ),
                        SizedBox(height: size.height * 0.01),
                        TextFormField(
                          decoration: inputDec('Whatsapp'),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira um número de WhatsApp';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _whatsapp = value;
                          },
                        ),
                        SizedBox(height: size.height * 0.01),
                        TextFormField(
                          decoration: inputDec('Senha'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira uma senha';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _password = value;
                          },
                        ),
                        SizedBox(height: size.height * 0.01),
                        TextFormField(
                          decoration: inputDec('Confirmar Senha'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, confirme a senha';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _confirmPassword = value;
                          },
                        ),
                        SizedBox(height: size.height * 0.02),
                        SizedBox(height: size.height * 0.02),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: gradientBtn(),
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  onPressed: _signup,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      fixedSize: Size(
                                          size.width * 0.8, size.height * 0.01),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5))),
                                  child: Text('Cadastrar',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: size.height * 0.022,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                            );
                          },
                          child: const Text(
                            'Já possui uma conta? Realize o login!',
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ),
      ],
    );
  }

  Widget _web(Size size) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(size.height * 0.04),
                  topLeft: Radius.circular(size.height * 0.04)),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                  top: size.width * 0.01,
                  bottom: size.width * 0.01,
                  right: size.width * 0.04,
                  left: size.width * 0.04),
              child: Form(
                  key: _formKey,
                  child: Column(children: [
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Text(
                      'Cadastro',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: size.width * 0.03),
                    ),
                    SizedBox(
                      height: size.height * 0.45,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: size.height * 0.02,
                            ),

                            //nome
                            SizedBox(
                              width: size.width * 0.2,
                              child: loginTextFormField(
                                  null, 'Nome Completo', TextInputType.name,
                                  (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira seu nome';
                                }
                                return null;
                              }, (value) {
                                _nome = value;
                              }),
                            ),
                            SizedBox(
                              height: size.height * 0.007,
                            ),
                            //email
                            SizedBox(
                              width: size.width * 0.2,
                              child: loginTextFormField(
                                  null, 'Email', TextInputType.name, (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira seu email';
                                }
                                return null;
                              }, (value) {
                                _email = value;
                              }),
                            ),
                            SizedBox(
                              height: size.height * 0.007,
                            ),
                            //whatsapp
                            SizedBox(
                              width: size.width * 0.2,
                              child: loginTextFormField(
                                  null, 'WhatsApp', TextInputType.name,
                                  (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira seu WhatsApp';
                                }
                                return null;
                              }, (value) {
                                _whatsapp = value;
                              }),
                            ),
                            SizedBox(
                              height: size.height * 0.007,
                            ),
                            //senha
                            SizedBox(
                              width: size.width * 0.2,
                              child: loginTextFormField(
                                  null, 'Senha', TextInputType.name, (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira uma senha';
                                }
                                return null;
                              }, (value) {
                                _password = value;
                              }),
                            ),
                            SizedBox(
                              height: size.height * 0.007,
                            ),
                            //confirmar senha
                            SizedBox(
                              width: size.width * 0.2,
                              child: loginTextFormField(
                                  null, 'Confirmar senha', TextInputType.name,
                                  (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira uma senha';
                                }
                                return null;
                              }, (value) {
                                _confirmPassword = value;
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                            color: corPadrao(),
                          ))
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientBtn(),
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ElevatedButton(
                              onPressed: _signup,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  fixedSize: Size(
                                      size.width * 0.2, size.height * 0.01),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5))),
                              child: Text('Confirmar',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: size.height * 0.022,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                      child: Text('Já possui uma conta? Realize o login!',
                          style: TextStyle(fontSize: size.height * 0.022)),
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    )
                  ])),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.01),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bem-Vindo!',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: size.width * 0.035,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: size.width <= 720
          ? Container(
              decoration: BoxDecoration(
                  color: corPadrao(),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1, // espalhamento
                        blurRadius: 5, // desfoque
                        offset: Offset(0, 0) // posição x,y
                        )
                  ]),
              child: _mobile(size),
            )
          : Center(
              child: Container(
                  height: size.height * 0.8,
                  margin: EdgeInsets.symmetric(
                      horizontal: size.width * 0.15,
                      vertical: size.height * 0.12),
                  //padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: corPadrao(),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1, // espalhamento
                            blurRadius: 5, // desfoque
                            offset: Offset(0, 0) // posição x,y
                            )
                      ]),
                  child: _web(size)),
            ),
    );
  }
}

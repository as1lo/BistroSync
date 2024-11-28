import 'dart:convert'; // For base64 decoding

import 'package:bistro/classes/user.dart';
import 'package:bistro/screens/inicial/telaLogin.dart';
import 'package:bistro/screens/mesa/opcaoMenu.dart';
import 'package:bistro/screens/widgets/cores.dart';
import 'package:bistro/screens/widgets/icons.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Mesa extends StatefulWidget {
  final BistroUser user;

  Mesa({required this.user});
  @override
  _MesaState createState() => _MesaState();
}

class _MesaState extends State<Mesa> {
  List<String> _carouselImages = []; // To store images from the database

  @override
  void initState() {
    super.initState();
    _fetchCarouselImages();
    print(widget.user.primaryColor);
  }

  Future<void> _fetchCarouselImages() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('carousel_images').get();
    setState(() {
      _carouselImages = snapshot.docs
          .map((doc) =>
              doc['image'] as String) // Assuming base64 is stored in 'image'
          .toList();
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Widget _buildCarousel() {
    if (_carouselImages.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 250.0,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: _carouselImages.map((base64Image) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.memory(
            base64Decode(base64Image),
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMenuList() {
    try {
      print('MENU LIST: ${widget.user.menuOptions}');

      if (widget.user.menuOptions == null || widget.user.menuOptions!.isEmpty) {
        return Center(
          child: Text(
            'Nenhuma opção disponível.',
          ),
        );
      }
      print('chegou lisview');
      print(widget.user.secondaryColor);
      return ListView.builder(
        shrinkWrap: true,
        itemCount: widget.user.menuOptions?.length,
        itemBuilder: (context, index) {
          final option = widget.user.menuOptions?[index];
          print(option?['categories']);

          return ListTile(
            leading: FaIcon(
              iconMapping[option!['icon']] ?? FontAwesomeIcons.question,
              color: hexToColor(widget.user.secondaryColor!),
            ),
            title: Text(
              option['name'] ?? 'Nenhuma opção disponível.',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Opcao(
                    user: widget.user,
                    categories: option['categories'] ?? [],
                  ),
                ),
              );
              print(
                  'Tapped on ${option['name'] ?? 'Nenhuma opção disponível.'}');
            },
          );
        },
      );
    } catch (e) {
      print(e);
      return Center(
        child: Text(
          'Nenhuma opção disponível.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            alignment: Alignment.center,
            width: size.width * 0.35,
            color: hexToColor(widget.user.primaryColor!),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        padding: EdgeInsets.all(size.width * 0.004),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius:
                              BorderRadius.circular(size.width * 0.01),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.table_bar, color: Colors.white),
                            SizedBox(width: size.width * 0.001),
                            Text(
                              'Mesa ${widget.user.num}',
                              style: TextStyle(
                                fontSize: size.width * 0.01,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      )
                    ]),
                    SizedBox(height: size.width * 0.01),
                    Image.memory(
                      base64Decode(widget.user.logobase64!),
                      fit: BoxFit.cover,
                      width: size.width * 0.25,
                    ),
                  ],
                ),

                //menu
                Container(
                  height: size.height * 0.4,
                  width: size.width * 0.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(size.width * 0.01),
                    //border: Border.all(color: Colors.white, width: 2),
                    color: Colors.white,
                  ),
                  child: _buildMenuList(),
                ),

                //footer
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Senha do Wi-Fi: ${widget.user.senhaWifi ?? 'Nenhuma senha disponível.'}',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      _buildCarousel(),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.shopping_cart,
                                  color: Colors.white),
                              onPressed: () {
                                // Open shopping cart logic
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.person, color: Colors.white),
                              onPressed: _logout,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

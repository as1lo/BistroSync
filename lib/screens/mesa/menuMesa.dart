import 'dart:convert'; // For base64 decoding

import 'package:bistro/classes/carrinho.dart';
import 'package:bistro/classes/user.dart';
import 'package:bistro/screens/inicial/telaLogin.dart';
import 'package:bistro/screens/mesa/meusPedidos.dart';
import 'package:bistro/screens/mesa/opcaoMenu.dart';
import 'package:bistro/screens/widgets/cores.dart';
import 'package:bistro/screens/widgets/icons.dart';
import 'package:bistro/screens/widgets/modalUsuario.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class Mesa extends StatefulWidget {
  BistroUser user;

  Mesa({required this.user});
  @override
  _MesaState createState() => _MesaState();
}

class _MesaState extends State<Mesa> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> _carouselImages = []; 
  final List<String> _carouselImagesTeste = [
    'https://scontent.frec43-1.fna.fbcdn.net/v/t39.30808-6/432393653_806032461551873_526858145156739060_n.jpg?stp=dst-jpg_p526x296_tt6&_nc_cat=100&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeGBLKLdgiLW8-fybSk1ljaoEEZXciJ2pt8QRldyInam38vegVWVxtgsvv--TktjNi1btu4EE5LHC88_kRAqLA48&_nc_ohc=NirTCQfhgHIQ7kNvgHJmCzN&_nc_zt=23&_nc_ht=scontent.frec43-1.fna&_nc_gid=Aw0ggqjjuRCqctqRJa9m-YV&oh=00_AYCANNn_3TmEesCmH8ewwKdTlIjhoh0S14OprtZpAwHjkg&oe=675613AB',
    'https://scontent.frec43-1.fna.fbcdn.net/v/t1.6435-9/193488813_3076156052612305_8703376804271831075_n.jpg?stp=dst-jpg_s600x600&_nc_cat=102&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeHVjHO_ocW4vmplyPX5LI9qgBqfjSu6xZmAGp-NK7rFmWaGvAyU4sNse_ZOp5SNzDcDSk0p3Ad01wvENKQKcaUk&_nc_ohc=YSWnRY3mTYQQ7kNvgGgDv_h&_nc_zt=23&_nc_ht=scontent.frec43-1.fna&_nc_gid=AJaXIWy58TUGNyaZJ2rMAsq&oh=00_AYB2LCfY91PaYyDmaOInZLtUKEbv_FJ3VRyzko23cT0Kqg&oe=6777ACBA',
    'https://scontent.frec43-1.fna.fbcdn.net/v/t39.30808-6/424785781_857634279706455_2193312101132460340_n.jpg?stp=dst-jpg_s600x600_tt6&_nc_cat=111&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeGIN7o-iVUK-lfYy4t5gHeVQ1BocjNX9a9DUGhyM1f1r0UvMCvjQPMhd1-q-dIYtijE4nMCd0UpfaauOeaNTarF&_nc_ohc=ThnctjC2VnIQ7kNvgEd1x_U&_nc_zt=23&_nc_ht=scontent.frec43-1.fna&_nc_gid=ADt5XMDn654AS1XGrITgw1E&oh=00_AYCr9wfvze5zYQH9XyZf3iflLug1ZDR4bCF2waAJ5VMXuw&oe=67561503',
    'https://scontent.frec43-1.fna.fbcdn.net/v/t39.30808-6/424737518_857634353039781_7137365586110246280_n.jpg?stp=dst-jpg_s600x600&_nc_cat=109&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeEIIpwTHimVzZa_4TpbRzFYLnlhl7pjUEAueWGXumNQQGXTLj_prlR5tPencoJnbQGgUs7tuF6BswHsVFqX5lEW&_nc_ohc=tWCHzyG0kDYQ7kNvgHEn5U_&_nc_zt=23&_nc_ht=scontent.frec43-1.fna&_nc_gid=ADt5XMDn654AS1XGrITgw1E&oh=00_AYAUY-Ef-oLK6VgRYSXvhpU-Z-UpKu80nGYsO2IO19Tcfw&oe=67561D45'
  ];

  @override
  void initState() {
    super.initState();
    _fetchCarouselImages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.user.idSessao == '' || widget.user.nomeSessao == '') {
        exibirModalUsuario(context, (codigoSessao, nome) {
          widget.user.idSessao = codigoSessao;
          widget.user.nomeSessao = nome;

          print('Código de sessão gerado: $codigoSessao');
          print('Nome do usuário: $nome');
        });
      }
    });
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

  Widget _buildCarousel(Size size) {
    if (_carouselImagesTeste.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    /*
    
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
    );*/

    return Center(
      child: CarouselSlider(
        options: CarouselOptions(
          height: size.height * 0.9,
          viewportFraction: 0.9,
          autoPlay: true,
          enlargeCenterPage: true,
        ),
        items: _carouselImagesTeste.map((base64Image) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              base64Image,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          );
        }).toList(),
      ),
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
    final carrinhoProvider = Provider.of<CarrinhoProvider>(context);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
        child: CarrinhoModal(
          carrinhoProvider: carrinhoProvider,
          bistroUser: widget.user,
          masterId: widget.user.idMaster!,
        ),
      ),
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
                      _buildCarousel(size),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                                icon: FaIcon(
                                  FontAwesomeIcons.bellConcierge,
                                  color: Colors.black,
                                ),
                                onPressed: () =>
                                    _scaffoldKey.currentState?.openEndDrawer(),
                                label: const Text(
                                  'Chamar Garçom',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                )),
                            SizedBox(
                              width: size.width * 0.01,
                            ),
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    hexToColor(widget.user.primaryColor!),
                              ),
                              icon: Icon(
                                Icons.shopping_cart_rounded,
                                color: hexToColor(widget.user.secondaryColor!),
                              ),
                              onPressed: () =>
                                  _scaffoldKey.currentState?.openEndDrawer(),
                            ),
                            SizedBox(
                              width: size.width * 0.01,
                            ),
                            IconButton(
                              icon: Icon(Icons.person, color: Colors.white),
                              onPressed: _logout,
                            ),
                            IconButton(
                              icon: Icon(Icons.menu, color: Colors.white),
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MeusPedidos(
                                            user: widget.user,
                                          ))),
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

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

IconData getIconFromCode(int codePoint) {
  return IconData(
    codePoint,
    fontFamily: 'MaterialIcons', 
  );
}


  Map<String, IconData> iconMapping = {
    'person': FontAwesomeIcons.person,
    'settings': FontAwesomeIcons.gear,
    'favorite': FontAwesomeIcons.heart,
    'star': FontAwesomeIcons.star,
    'beer': FontAwesomeIcons.beerMugEmpty,
    'wine': FontAwesomeIcons.wineBottle,
    'cocktail': FontAwesomeIcons.martiniGlassCitrus,
    'mug': FontAwesomeIcons.mugHot,
    'burger': FontAwesomeIcons.burger,
    'fish': FontAwesomeIcons.fish,
    'shrimp': FontAwesomeIcons.shrimp,
    'pizza': FontAwesomeIcons.pizzaSlice,
    'ice-cream': FontAwesomeIcons.iceCream,
    'cheese': FontAwesomeIcons.cheese,
    'bowl': FontAwesomeIcons.bowlFood,
    'hotdog': FontAwesomeIcons.hotdog,
    'list': FontAwesomeIcons.list,
  };

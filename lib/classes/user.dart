class BistroUser {
  final String id;
  final String email;
  final String tipoUser;
  final String name;
  final String telefone;
  final String? emailMaster;
  final int? num;
  final String? logobase64;
  final String? senhaWifi;
  final String? primaryColor;
  final String? secondaryColor;
  final String? idMaster;
  String? nomeSessao = '';
  String? idSessao = '';
  final List<Map<String, dynamic>>? menuOptions;

  BistroUser(
      {this.num,
      this.emailMaster,
      this.idMaster,
      this.logobase64,
      this.primaryColor,
      this.secondaryColor,
      this.senhaWifi,
      this.menuOptions,
      this.idSessao,
      this.nomeSessao,
      required this.email,
      required this.id,
      required this.tipoUser,
      required this.name,
      required this.telefone});
}

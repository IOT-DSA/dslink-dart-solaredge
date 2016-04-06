class Equipment {
  static const String _name = 'name';
  static const String _manufacturer = 'manufacturer';
  static const String _model = 'model';
  static const String _serial = 'serialNumber';
  String name;
  String manufacturer;
  String model;
  String serial;

  Equipment.fromJson(Map<String, String> map) {
    name = map[_name];
    manufacturer = map[_manufacturer];
    model = map[_model];
    serial = map[_serial];
  }
}
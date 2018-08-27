class Telemetry {
  static const List<String> batteryStates = const <String>['Invalid', 'Standby',
      'Thermal Management', 'Enabled', 'Fault'];
  String date;
  String state;
  num power;
  num lifetimeCharge;

  Telemetry.fromJson(Map map) {
    date = map['timeStamp'];
    power = map['power'];
    state = batteryStates[map['batteryState']];
    lifetimeCharge = map['lifeTimeEnergyCharged'];
  }
}

class Battery {
  String serial;
  num nameplate;
  List<Telemetry> telemetries;
  Battery.fromJson(Map map) {
    nameplate = map['nameplate'];
    serial = map['serialNumber'];
    telemetries = new List<Telemetry>();
    for (var mp in map['telemetries']) {
      if (mp == null || (mp as Map).isEmpty) continue;
      telemetries.add(new Telemetry.fromJson(mp));
    }
  }
}

class Equipment {
  String name;
  String manufacturer;
  String model;
  String serial;

  Equipment.fromJson(Map<String, String> map) {
    name = map['name'];
    manufacturer = map['manufacturer'];
    model = map['model'];
    serial = map['serialNumber'];
  }
}

class InverterData {
  String dateStr;
  DateTime date;
  num totalPower;
  num totalEnergy;
  num dcVoltage;
  num groundResistance;
  num powerLimit;
  num temperature;
  num vL1to2;
  num vL2to3;
  num vL3to1;
  String mode;
  List<PhaseData> phases;
  InverterData.fromJson(Map map) {
    dateStr = map['date'];
    date = DateTime.parse(dateStr);
    totalPower = map['totalActivePower'];
    totalEnergy = map['totalEnergy'];
    dcVoltage = map['dcVoltage'];
    groundResistance = map['groundFaultResistance'];
    powerLimit = map['powerLimit'];
    temperature = map['temperature'];
    mode = map['inverterMode'];
    vL1to2 = map['vL1To2'];
    vL2to3 = map['vL2To3'];
    vL3to1 = map['vL3To1'];

    var pd = map.keys.where((key) { return map[key] is Map; });
    if (pd.isNotEmpty) {
      phases = new List<PhaseData>();
      pd.forEach((key) {
        phases.add(new PhaseData.fromJson(key, map[key]));
      });
    }
  }
}

class PhaseData {
  String name;
  num acCurrent;
  num acVoltage;
  num acFrequency;
  num qRef;
  num cosPhi;
  num apparentPower;
  num activePower;
  num reactivePower;
  PhaseData.fromJson(this.name, Map map) {
    acCurrent = map['acCurrent'];
    acVoltage = map['acVoltage'];
    acFrequency = map['acFrequency'];
    qRef = map['qRef'];
    cosPhi = map['cosPhi'];
    apparentPower = map['apparentPower'];
    activePower = map['activePower'];
    reactivePower = map['reactivePower'];
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'acCurrent': acCurrent,
    'acVoltage': acVoltage,
    'acFrequency': acFrequency,
    'qRef': qRef,
    'cosPhi': cosPhi,
    'apparentPower': apparentPower,
    'activePower': activePower,
    'reactivePower': reactivePower
  };
}
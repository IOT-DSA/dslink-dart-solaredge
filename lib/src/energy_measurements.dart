class EnergyMeasurements {
  String timeUnit;
  List<TimeMeasurement> measurements;

  EnergyMeasurements.fromJson(Map map) {
    timeUnit = map['timeUnit'];
    var unit = map['unit'];

    var measList = map['values'] as List;
    measurements = new List<TimeMeasurement>.generate(measList.length,
        (int i) => new TimeMeasurement.fromJson(measList[i], unit));
  }
}

class TimeMeasurement extends EnergyMeasurement {
  String date;
  TimeMeasurement.fromJson(Map map, String energyUnit) :
        super(map['value'], energyUnit) {
    date = map['date'];
  }
}

class EnergyMeasurement {
  num value;
  String energyUnit;

  EnergyMeasurement(this.value, this.energyUnit);
  EnergyMeasurement.fromJson(Map map) {
    value = map['energy'];
    energyUnit = map['unit'];
  }
}
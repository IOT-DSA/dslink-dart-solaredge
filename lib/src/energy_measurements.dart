class EnergyMeasurements {
  String timeUnit;
  List<Measurement> measurements;

  EnergyMeasurements.fromJson(Map map) {
    timeUnit = map['timeUnit'];
    var unit = map['unit'];

    var measList = map['values'] as List;
    measurements = new List<Measurement>.generate(measList.length,
        (int i) => new Measurement.fromJson(measList[i], unit));
  }
}

class Measurement {
  String date;
  num value;
  String energyUnit;
  Measurement.fromJson(Map map, this.energyUnit) {
    date = map['date'];
    value = map['value'];
  }
}
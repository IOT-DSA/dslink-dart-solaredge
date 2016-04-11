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

class EnergyMeasurement {
  num value;
  String energyUnit;

  EnergyMeasurement(this.value, this.energyUnit);
  EnergyMeasurement.fromJson(Map map) {
    value = map['energy'];
    energyUnit = map['unit'];
  }
}

class TimeMeasurement extends EnergyMeasurement {
  String date;

  TimeMeasurement(this.date, num value, String unit) : super(value, unit);
  TimeMeasurement.fromJson(Map map, String energyUnit) :
        super(map['value'], energyUnit) {
    date = map['date'];
  }
}

class DetailedEnergy {
  String date;
  Map<String, EnergyMeasurement> measurements;

  DetailedEnergy(this.date) {
    measurements = new Map<String, EnergyMeasurement>();
  }

  void addMeasurement(String type, num value, String unit) {
    measurements[type] = new EnergyMeasurement(value, unit);
  }
}

class DetailedMeasurements {
  List<DetailedEnergy> measurements;

  DetailedMeasurements.fromJson(Map map) {
    measurements = new List<DetailedEnergy>();
    var unit = map['unit'];

    for(Map typeData in map['meters']) {
      var type = typeData['type'];
      for (var dateVal in typeData['values']) {
        var de = measurements.firstWhere((el) => el.date == dateVal['date'],
            orElse: () {
              var ret = new DetailedEnergy(dateVal['date']);
              measurements.add(ret);
              return ret;
        });
        de.addMeasurement(type, dateVal['value'], unit);
      }
    }

    measurements.sort((a, b) => a.date.compareTo(b.date));
  }
}

class FlowItem extends EnergyMeasurement {
  String status;

  FlowItem(this.status, num value, String unit) : super(value, unit);
}

class FlowStorage {
  String energyUnit;
  String status;
  num power;
  num chargeLevel;
  bool critical;

  FlowStorage.fromJson(Map map, this.energyUnit) {
    status = map['status'];
    power = map['currentPower'];
    chargeLevel = map['chargeLevel'];
    critical = map['critical'];
  }
}

class PowerFlow {
  String to;
  String from;
  FlowItem grid;
  FlowItem load;
  FlowItem pv;
  FlowStorage storage;

  PowerFlow.fromJson(Map map) {
    var unit = map['unit'];
    var tmp = map['connections'];
    if (tmp != null) {
      to = tmp['to'];
      from = tmp['from'];
    }
    tmp = map['GRID'];
    if (tmp != null) {
      grid = new FlowItem(tmp['status'], tmp['currentPower'], unit);
    }
    tmp = map['LOAD'];
    if (tmp != null) {
      load = new FlowItem(tmp['status'], tmp['currentPower'], unit);
    }
    tmp = map['PV'];
    if (tmp != null) {
      pv = new FlowItem(tmp['status'], tmp['currentPower'], unit);
    }
    tmp = map['STORAGE'];
    if (tmp != null) {
      storage = new FlowStorage.fromJson(tmp, unit);
    }
  }
}
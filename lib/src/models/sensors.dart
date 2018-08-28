class Sensor {
  String name;
  String measurement;
  String type;

  Sensor(this.name, this.measurement, this.type);

  Sensor.fromJson(Map map) {
    name = map['name'];
    measurement = map['measurement'];
    type = map['type'];
  }
}

class SensorConnections {
  String conenctedTo;
  List<Sensor> sensors;

  SensorConnections.fromJson(Map map) {
    conenctedTo = map['connectedTo'];
    sensors = new List<Sensor>();
    if (map['sensors'] != null) {
      for (var sens in map['sensors']) {
        sensors.add(new Sensor.fromJson(sens));
      }
    }
  }
}

class SensorData {
  String connectedTo;
  String date;
  Map measurements;

  SensorData.fromJson(this.connectedTo, Map map) {
    date = map['date'];
    measurements = map..remove('date');
  }
}
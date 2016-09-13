import 'dart:async';

import 'package:dslink/nodes.dart';

import 'se_base.dart';
import '../src/client.dart';
import '../models.dart';

//* @Node SensorNode
//* @Is sensorNode
//* @Parent gateway
//*
//* Collection of data for Sensors located at the site.
//*
//* Sensor's are connected to gateways which only maintain the connection
//* from the site to the sensor. Sensors will have the path and name provided
//* by the remote Solar Edge system.
class SensorNode extends SeBase {
  static const String isType = 'sensorNode';
  static Map<String, dynamic> definition(Sensor sensor) => {
    r'$is': isType,
    r'$name': sensor.name,
    //* @Node measurement
    //* @Parent SensorNode
    //*
    //* Measurement name that the sensor will poll for.
    //* @Value string
    'measurement' : {
      r'$name' : 'Measurement',
      r'$type' : 'string',
      r'?value' : sensor.measurement,
    },
    //* @Node senseType
    //* @Parent SensorNode
    //*
    //* The type of measurement that measurement represents.
    //* @Value string
    'senseType' : {
      r'$name' : 'Type',
      r'$type' : 'string',
      r'?value' : sensor.type,
    }
  };

  SensorNode(String path) : super(path);

  void update(Sensor sensor) {
    displayName = sensor.name;
    provider.updateValue('$path/measurement', sensor.measurement);
    provider.updateValue('$path/senseType', sensor.type);
  }
}

//* @Action Load_Sensors
//* @Is loadSensorsNode
//* @Parent sensors
//*
//* Retreives a list of Gateways and connected Sensors.
//*
//* Queries the remote Solar Edge system for a list of gateways and their
//* connected sensors.
//*
//* @Return values
//* @Column success bool Success returns true on success; false on failure.
//* @Column message string Message returns Success! on success, and an error
//* message on failure.
class LoadSensors extends SeCommand {
  static const String isType = 'loadSensorsNode';
  static const String pathName = 'Load_Sensors';

  static const String _success = 'success';
  static const String _message = 'message';

  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Load Sensors',
    r'$invokable' : 'write',
    r'$params' : [],
    r'$columns' : [
      { 'name' : _success, 'type' : 'bool', 'default' : false },
      { 'name' : _message, 'type' : 'string', 'default': '' }
    ]
  };

  final SeClient client;

  LoadSensors(String path, this.client) : super(path);

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, dynamic> params) async {
    var ret = { _success: false, _message : '' };

    var site = await getSite();
    var resp = await client.loadSensors(site);
    updateCalls();
    if (resp != null || resp.isNotEmpty) {
      ret[_success] = true;
      ret[_message] = 'Success!';
      var pPath = parent.path;
      for (var conn in resp) {
        var connName = NodeNamer.createName(conn.conenctedTo);
        //* @Node
        //* @MetaType gateway
        //* @Parent sensors
        //*
        //* Gateway is a connection point for multiple sensors.
        //*
        //* Gateway is specified by the remote Solar Edge system. It is a
        //* collection of sensors which connect to it to connect in turn to
        //* the remote Solar Edge system. Path and name are provided by the
        //* remote Solar Edge system.
        var connNode = provider.getOrCreateNode('$pPath/$connName');
        for (var sense in conn.sensors) {
          var sName = NodeNamer.createName(sense.name);
          var nd = provider.getNode('${connNode.path}/$sName') as SensorNode;
          if (nd == null) {
            provider.addNode('${connNode.path}/$sName',
                SensorNode.definition(sense));
          } else {
            nd.update(sense);
          }
        }
      }
    } else {
      ret[_message] = 'Unable to load sensors';
    }

    return ret;
  }
}

//* @Action Get_Sensor_Data
//* @Parent sensors
//* @Is getSensorData
//* @Param dateRange string Date range in the format of MM-DD-YYYY HH:mm:SS/MM-DD-YYYY HH:mm:SS
//*
//* Retrieves data which has been logged by various sensors.
//*
//* Action will get the sensor data for all connected sensors on each gateway.
//* It will verify that the date range is a valid date range, and return an
//* empty list on failure. On success it returns a list of mapped data.
//*
//* @Return table
//* @Column connectedTo string Connected to is the gateway the sensor is connected to.
//* @Column date string Date is a Date time string of when the sensor data was recorded.
//* @Column measurement string Measurement is the measurement name that the value represents.
//* @Column value number Value is the recorded data point from the sensor.
class GetSensorData extends SeCommand {
  static const String isType = 'getSensorData';
  static const String pathName = 'Get_Sensor_Data';

  static const String _dateRange = 'dateRange';
  static const String _date = 'date';
  static const String _connectedTo = 'connectedTo';
  static const String _measurement = 'measurement';
  static const String _value = 'value';
  static const Duration _weekPeriod = const Duration(days: 7);

  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Get Sensor Data',
    r'$invokable' : 'write',
    r'$params' : [
      { 'name': _dateRange, 'type': 'string', 'editor': 'daterange' }
    ],
    r'$result': 'table',
    r'$columns' : [
      { 'name': _connectedTo, 'type': 'string', 'default': '' },
      { 'name': _date, 'type': 'string', 'default': '00-00-0000 00:00:00'},
      { 'name': _measurement, 'type': 'string', 'default': '' },
      { 'name': _value, 'type': 'number', 'default': 0 }
    ]
  };

  final SeClient client;

  GetSensorData(String path, this.client) : super(path);

  @override
  Future<List<Map>> onInvoke(Map<String, dynamic> params) async {
    var ret = new List<Map>();

    var dates = params[_dateRange]?.split('/');
    if (dates == null || dates.length != 2) return ret;

    DateTime startDate;
    DateTime endDate;
    try {
      startDate = DateTime.parse(dates[0]);
      endDate = DateTime.parse(dates[1]);
    } on FormatException {
      return ret;
    }

    if (startDate.compareTo(endDate) >= 0) {
      return ret;
    }

    var diff = endDate.difference(startDate);
    if (diff.compareTo(_weekPeriod) > 0) return ret;

    var qParams = {};
    var startStr = startDate.toString();
    var endStr = endDate.toString();
    qParams['startDate'] = startStr.substring(0, startStr.length - 4);
    qParams['endDate'] = endStr.substring(0, endStr.length - 4);
    var site = await getSite();
    var result = await client.getSensorData(site, qParams);
    updateCalls();
    if (result == null) return ret;

    for (var sense in result) {
      sense.measurements.forEach((key, val) {
        var mp = {};
        mp[_connectedTo] = sense.connectedTo;
        mp[_date] = sense.date;
        mp[_measurement] = key;
        mp[_value] = val;
        ret.add(mp);
      });
    }

    return ret;
  }
}

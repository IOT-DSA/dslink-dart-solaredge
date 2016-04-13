import 'dart:async';

import 'package:dslink/nodes.dart';

import 'se_base.dart';
import '../src/client.dart';
import '../models.dart';

class SensorNode extends SeBase {
  static const String isType = 'sensorNode';
  static Map<String, dynamic> definition(Sensor sensor) => {
    r'$is': isType,
    r'$name': sensor.name,
    'measurement' : {
      r'$name' : 'Measurement',
      r'$type' : 'string',
      r'?value' : sensor.measurement,
    },
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

    var site = getSite();
    var resp = await client.loadSensors(site);
    updateCalls();
    if (resp != null || resp.isNotEmpty) {
      ret[_success] = true;
      ret[_message] = 'Success!';
      var pPath = parent.path;
      for (var conn in resp) {
        var connName = NodeNamer.createName(conn.conenctedTo);
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
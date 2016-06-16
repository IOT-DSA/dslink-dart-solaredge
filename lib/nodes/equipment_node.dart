import 'dart:async';

import 'se_base.dart';
import '../src/client.dart';
import '../models.dart';

class EquipmentNode extends SeBase {
  static const String isType = 'equipmentNode';

  static const String _isInverter = r'$$se_isinv';

  static Map<String, dynamic> definition(Equipment equipment) {
    var isInv = (equipment.manufacturer != "" && equipment.model != "");
    var ret = {
      _isInverter: isInv,
      r'$is': isType,
      r'$name': equipment.name,
      'model' : {
        r'$name' : 'Model',
        r'$type' : 'string',
        r'?value' : equipment.model,
      },
      'manufacturer' : {
        r'$name' : 'Manufacturer',
        r'$type' : 'string',
        r'?value' : equipment.manufacturer,
      },
      'serial' : {
        r'$name' : 'Serial Number',
        r'$type' : 'string',
        r'?value' : equipment.serial,
      },
    };

    if (isInv) {
      ret[GetInverterData.pathName] = GetInverterData.definition();
      ret['data'] = {};
    }

    return ret;
  }

  String serial;
  bool isInverter;

  SeClient client;
  EquipmentNode(String path, this.client) : super(path);

  @override
  void onCreated() {
    serial = provider.getNode('$path/serial').value;
    isInverter = getConfig(_isInverter) as bool;

    var dataNd = provider.getNode('$path/data');
    if (dataNd == null || dataNd.children.length > 1) return;

    getSite()
        .then((site) => client.lastInverterData(site, serial))
        .then((data) {
      if (data == null) return;

      var dp = dataNd.path;
      provider.addNode('$dp/totPower',
          InverterValue.definition('Total Active Power', data.totalPower));
      provider.addNode('$dp/dcVolt',
          InverterValue.definition('DC Voltage', data.dcVoltage));
      provider.addNode('$dp/groundRes',
          InverterValue.definition('Ground Fault Resistance',
              data.groundResistance));
      provider.addNode('$dp/powLimit',
          InverterValue.definition('Power Limit', data.powerLimit));
      provider.addNode('$dp/totEng',
          InverterValue.definition('Total Energy', data.totalEnergy));
      provider.addNode('$dp/temp',
          InverterValue.definition('Temperature', data.temperature));
      provider.addNode('$dp/vl1to2',
          InverterValue.definition('VL1To2', data.vL1to2));
      provider.addNode('$dp/vl2to3',
          InverterValue.definition('VL2To3', data.vL2to3));
      provider.addNode('$dp/vl3to1',
          InverterValue.definition('VL3To1', data.vL3to1));
      provider.addNode('$dp/mode', {
          r'$name': 'Inverter Mode',
          r'$type': 'string',
          r'?value': data.mode
      });

      if (data.phases == null || data.phases.isEmpty) return;
      for (var ph in data.phases) {
        var nd = provider.getOrCreateNode('$dp/${ph.name}');
        var pp = nd.path;
        provider.addNode('$pp/acCur',
            InverterValue.definition('AC Current', ph.acCurrent));
        provider.addNode('$pp/acVolt',
            InverterValue.definition('AC Voltage', ph.acVoltage));
        provider.addNode('$pp/acFreq',
            InverterValue.definition('AC Frequency', ph.acFrequency));
        provider.addNode('$pp/appPow',
            InverterValue.definition('Apparent Power', ph.apparentPower));
        provider.addNode('$pp/actPow',
            InverterValue.definition('Active Power', ph.activePower));
        provider.addNode('$pp/reaPow',
            InverterValue.definition('Reactive Power', ph.reactivePower));
        provider.addNode('$pp/cosPhi',
            InverterValue.definition('Cos Phi', ph.cosPhi));
      }
    });
  }
}

class InverterValue extends SeBase {
  static const String isType = 'inverterValueNode';
  static Map<String, dynamic> definition(String name, num value) => {
      r'$is': isType,
      r'$name': name,
      r'$type': 'number',
      r'?value': value
  };

  InverterValue(String path) : super(path);
}

class LoadEquipment extends SeCommand {
  static const String isType = 'getEquipmentNode';
  static const String pathName = 'Load_Equipment';

  static const String _success = 'success';
  static const String _message = 'message';

  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Load Equipment',
    r'$invokable' : 'write',
    r'$params' : [],
    r'$columns' : [
      { 'name' : _success, 'type' : 'bool', 'default' : false },
      { 'name' : _message, 'type' : 'string', 'default': '' }
    ]
  };

  SeClient client;

  LoadEquipment(String path, this.client) : super(path);

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, dynamic> params) async {
    var ret = { _success: false, _message: '' };

    var site = await getSite();

    var list = await client.loadEquipment(site);
    updateCalls();
    if (list == null) {
      ret[_message] = 'Unable to load equipment.';
      return ret;
    } else {
      ret[_success] = true;
      ret[_message] = 'Success!';
    }

    var pPath = parent.path;
    var countNode = provider.getNode('$pPath/count');
    if (countNode != null) {
      countNode.updateValue(list.length);
    }
    for (var i = 0; i < list.length; i++) {
      provider.addNode('$pPath/equip_$i', EquipmentNode.definition(list[i]));
    }

    return ret;
  }
}

class GetInverterData extends SeCommand {
  static const String isType = 'getInverterData';
  static const String pathName = 'Get_Inverter_Data';

  static const String _dateRange = 'dateRange';
  static const String _date = 'date';
  static const String _totPower = 'totalPower';
  static const String _dcVolt = 'dcVoltage';
  static const String _resistance = 'groundResistance';
  static const String _limit = 'powerLimit';
  static const String _totalEnergy = 'totalEnergy';
  static const String _phases = 'phases';
  static const Duration _weekPeriod = const Duration(days: 7);
  
  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Get Inverter Data',
    r'$invokable' : 'write',
    r'$params' : [
      { 'name': _dateRange, 'type': 'string', 'editor': 'daterange' }
    ],
    r'$result': 'table',
    r'$columns' : [
      { 'name': _date, 'type': 'string', 'default': '00-00-0000 00:00:00'},
      { 'name': _totPower, 'type': 'number', 'default': 0 },
      { 'name': _dcVolt, 'type': 'number', 'default': 0 },
      { 'name': _resistance, 'type': 'number', 'default': 0 },
      { 'name': _limit, 'type': 'number', 'default': 0 },
      { 'name': _totalEnergy, 'type': 'number', 'default': 0 },
      { 'name': _phases, 'type': 'array', 'default': [] }
    ]
  };

  final SeClient client;
  
  GetInverterData(String path, this.client) : super(path);
  
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
    qParams['startTime'] = startStr.substring(0, startStr.length - 4);
    qParams['endTime'] = endStr.substring(0, endStr.length - 4);
    var site = await getSite();
    var serial = (parent as EquipmentNode).serial;
    var result = await client.getInverterData(site, serial, qParams);
    updateCalls();
    if (result == null) return ret;

    for (var tel in result) {
      var mp = {};
      mp[_date] = tel.dateStr;
      mp[_totPower] = tel.totalPower;
      mp[_dcVolt] = tel.dcVoltage;
      mp[_resistance] = tel.groundResistance;
      mp[_limit] = tel.powerLimit;
      mp[_totalEnergy] = tel.totalEnergy;
      mp[_phases] = tel.phases.map((pd) => pd.toMap()).toList();
      ret.add(mp);
    }

    return ret;
  }
}
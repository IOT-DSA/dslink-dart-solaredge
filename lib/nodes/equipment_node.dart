import 'dart:async';

import 'package:timezone/standalone.dart';

import 'se_base.dart';
import '../src/client.dart';
import '../models.dart';

//* @Node
//* @MetaType EquipmentNode
//* @Parent equipment
//* @Is equipmentNode
//*
//* Collection of equipment values.
//*
//* Equipment values for a specific piece of equipment connected to a site. Some
//* equipment may be an inverter which has additional data. The path will be
//* equip_## where ## is the index number of the equipment in the list.
//* The display name will be the specific equipment name from the remote server.
class EquipmentNode extends SeBase {
  static const String isType = 'equipmentNode';
  static const String _isInverter = r'$$se_isinv';
  static const Duration _refreshPeriod = const Duration(minutes: 15);

  static Map<String, dynamic> definition(Equipment equipment) {
    var isInv = (equipment.manufacturer != "" && equipment.model != "");
    var ret = {
      _isInverter: isInv,
      r'$is': isType,
      r'$name': equipment.name,
      //* @Node model
      //* @Parent EquipmentNode
      //*
      //* Equipment model number.
      //* @Value string
      'model' : {
        r'$name' : 'Model',
        r'$type' : 'string',
        r'?value' : equipment.model,
      },
      //* @Node manufacturer
      //* @Parent EquipmentNode
      //*
      //* The equipment manufacturer.
      //* @Value string
      'manufacturer' : {
        r'$name' : 'Manufacturer',
        r'$type' : 'string',
        r'?value' : equipment.manufacturer,
      },
      //* @Node serial
      //* @Parent EquipmentNode
      //*
      //* Equipment's short serial number
      //* @Value string
      'serial' : {
        r'$name' : 'Serial Number',
        r'$type' : 'string',
        r'?value' : equipment.serial,
      },
    };

    if (isInv) {
      ret[GetInverterData.pathName] = GetInverterData.definition();
      //* @Node data
      //* @Parent EquipmentNode
      //*
      //* Collection of data used by inverter equipment.
      ret['data'] = {};
    }

    return ret;
  }

  String serial;
  bool isInverter;
  int _subs = 0;
  TZDateTime _lastUp;
  Timer _refreshTimer;

  SeClient client;
  EquipmentNode(String path, this.client) : super(path);

  @override
  void onCreated() {
    serial = provider.getNode('$path/serial').value;
    isInverter = getConfig(_isInverter) as bool;

    var dataNd = provider.getNode('$path/data');
    if (dataNd == null || dataNd.children.length > 1) return;

//    _lastUp = new DateTime.now();
//    getSite()
//        .then((site) => client.lastInverterData(site, serial))
//        .then(updateInvData);
    initializeTimeZone(Config.dataDir)
        .then((_) => getSite())
        .then((site) {
      var loc = getLocation(site.location.timeZone);
      _lastUp = new TZDateTime.now(loc);

      return client.lastInverterData(site, serial);
    }).then(updateInvData);
  }

  void updateInvData(InverterData data) {
    void addOrUpdate(String path, Map mp) {
      var nd = provider.getNode(path);
      if (nd != null) {
        nd.updateValue(mp['?value']);
      } else {
        provider.addNode(path, mp);
      }
    }

    if (data == null) return;

    var dataNd = provider.getNode('$path/data');
    var dp = dataNd.path;
    //* @Node totPower
    //* @Is inverterValueNode
    //* @Parent data
    //*
    //* Total active power
    //* @Value number
    addOrUpdate('$dp/totPower',
        InverterValue.definition('Total Active Power', data.totalPower));
    //* @Node dcVolt
    //* @Is inverterValueNode
    //* @Parent data
    //*
    //* DC Voltage
    //* @Value number
    addOrUpdate('$dp/dcVolt',
        InverterValue.definition('DC Voltage', data.dcVoltage));
    //* @Node groundRes
    //* @Is inverterValueNode
    //* @Parent data
    //*
    //* Ground fault resistance
    //* @Value number
    addOrUpdate('$dp/groundRes',
        InverterValue.definition('Ground Fault Resistance',
            data.groundResistance));
    //* @Node powLimit
    //* @Is inverterValueNode
    //* @Parent data
    //*
    //* Power limit percentage
    //* @Value number
    addOrUpdate('$dp/powLimit',
        InverterValue.definition('Power Limit', data.powerLimit));
    //* @Node totEng
    //* @Is inverterValueNode
    //* @Parent data
    //*
    //* Total Lifetime energy.
    //* @Value number
    addOrUpdate('$dp/totEng',
        InverterValue.definition('Total Energy', data.totalEnergy));
    //* @Node temp
    //* @Is inverterValueNode
    //* @Parent data
    //*
    //* Temperature of the device.
    //* @Value number
    addOrUpdate('$dp/temp',
        InverterValue.definition('Temperature', data.temperature));
    //* @Node vl1to2
    //* @Is inverterValueNode
    //* @Parent data
    //*
    //* vL1 to 2
    //* @Value number
    addOrUpdate('$dp/vl1to2',
        InverterValue.definition('VL1To2', data.vL1to2));
    //* @Node vl2to3
    //* @Is inverterValueNode
    //* @Parent data
    //*
    //* vL2 to 3
    //* @Value number
    addOrUpdate('$dp/vl2to3',
        InverterValue.definition('VL2To3', data.vL2to3));
    //* @Node vl3to1
    //* @Is inverterValueNode
    //* @Parent data
    //*
    //* vL3 to 1
    //* @Value number
    addOrUpdate('$dp/vl3to1',
        InverterValue.definition('VL3To1', data.vL3to1));
    //* @Node mode
    //* @Parent data
    //*
    //* Inverter mode
    //* @Value string
    addOrUpdate('$dp/mode', {
      r'$name': 'Inverter Mode',
      r'$type': 'string',
      r'?value': data.mode
    });

    if (data.phases == null || data.phases.isEmpty) return;
    for (var ph in data.phases) {
      //* @Node
      //* @MetaType dataPhase
      //* @Parent data
      //*
      //* Phase data per inverter.
      var nd = provider.getOrCreateNode('$dp/${ph.name}');
      var pp = nd.path;
      //* @Node acCur
      //* @Parent dataPhase
      //* @Is inverterValueNode
      //*
      //* AC Current
      //* @Value number
      addOrUpdate('$pp/acCur',
          InverterValue.definition('AC Current', ph.acCurrent));
      //* @Node acVolt
      //* @Parent dataPhase
      //* @Is inverterValueNode
      //*
      //* AC Voltage
      //* @Value number
      addOrUpdate('$pp/acVolt',
          InverterValue.definition('AC Voltage', ph.acVoltage));
      //* @Node acFreq
      //* @Parent dataPhase
      //* @Is inverterValueNode
      //*
      //* AC Frequency
      //* @Value number
      addOrUpdate('$pp/acFreq',
          InverterValue.definition('AC Frequency', ph.acFrequency));
      //* @Node appPow
      //* @Parent dataPhase
      //* @Is inverterValueNode
      //*
      //* Apparent Power
      //* @Value number
      addOrUpdate('$pp/appPow',
          InverterValue.definition('Apparent Power', ph.apparentPower));
      //* @Node actPower
      //* @Parent dataPhase
      //* @Is inverterValueNode
      //*
      //* Active Power
      //* @Value number
      addOrUpdate('$pp/actPow',
          InverterValue.definition('Active Power', ph.activePower));
      //* @Node reaPow
      //* @Parent dataPhase
      //* @Is inverterValueNode
      //*
      //* Reactive Power
      //* @Value number
      addOrUpdate('$pp/reaPow',
          InverterValue.definition('Reactive Power', ph.reactivePower));
      //* @Node cosPhi
      //* @Parent dataPhase
      //* @Is inverterValueNode
      //*
      //* Cos Phi
      //* @Value number
      addOrUpdate('$pp/cosPhi',
          InverterValue.definition('Cos Phi', ph.cosPhi));
    }
  }

  void childSubscribe() {
    _subs += 1;
    if ((_refreshTimer == null || !_refreshTimer.isActive) && _subs == 1) {
      _refreshData(null);
    }
  }

  void childUnsubscribe() {
    _subs -= 1;
    if (_subs <= 0 && _refreshTimer != null && _refreshTimer.isActive) {
      _refreshTimer.cancel();
    }
  }

  _refreshData(Timer t) async {
    if (t == null && (_refreshTimer == null || !_refreshTimer.isActive)) {
      // Increase timer interval by 2 seconds to help account for slightly
      // imprecise precision.
      var interval = new Duration(minutes: _refreshPeriod.inMinutes, seconds: 2);
      _refreshTimer = new Timer.periodic(interval, _refreshData);
    }

    var site = await getSite();
    var loc = getLocation(site.location.timeZone);
    var curTime = new TZDateTime.now(loc);

    if (curTime.hour < site.callStart || curTime.hour >= site.callEnd) return;
    if (_lastUp != null && curTime.difference(_lastUp) < _refreshPeriod) return;

    _lastUp = curTime;
    client.lastInverterData(site, serial).then(updateInvData);
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

  EquipmentNode _inv;
  EquipmentNode get inverter {
     if (_inv == null) {
       var p = parent;
       while (p != null && p is! EquipmentNode) {
         p = p.parent;
       }
       _inv = p;
     }
    return _inv;
  }

  @override
  void onSubscribe() {
    inverter.childSubscribe();
  }

  @override
  void onUnsubscribe() {
    inverter.childUnsubscribe();
  }
}

// Currently unused.
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

//* @Action Get_Inverter_Data
//* @Parent EquipmentNode
//* @Is getInverterData
//*
//* Retrieve inverter data for the inverter over a specified date range.
//*
//* Get Inverter Data returns inverter data for a date range no greater than
//* one week. If greater than one week or the request fails then the action
//* returns with an empty list. This action is only available on equipment
//* which is an inverter.
//*
//* @Param dateRange string Date range for the period of time to retrieve the
//* Inverter Data. Should be in the format MM-DD-YYYY HH:mm:SS/MM-DD-YYYY HH:mm:SS
//*
//* @Return table
//* @Column date string Date Time the inverter data was recorder.
//* @Column totalPower number Total active power.
//* @Column dcVoltage number DC Voltage.
//* @Column groundResistance number Total ground resistance.
//* @Column powerLimit number Power limit percentage.
//* @Column totalEnergy number Total lifetime energy.
//* @Column phases array List of maps of phase specific data
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

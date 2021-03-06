import 'dart:async';

import 'se_base.dart';
import '../client.dart';

//* @Action Get_Storage_Data
//* @Is getStorageData
//* @Parent SiteNode
//*
//* Get detailed storage information from batteries.
//*
//* Get Storage Data will retrieve the current state of the batteries connected
//* to the site over the specified time range. It will verify the date range
//* is valid. If the request fails, it returns an empty list.
//*
//* @Param dateRange string Date range for the period of time to retrieve the
//* battery usage. Should be in the format MM-DD-YYYY HH:mm:SS/MM-DD-YYYY HH:mm:SS
//*
//* @Return table
//* @Column namePlate number The nameplate capacity of the battery.
//* @Column serialNumber string Serial number of the battery.
//* @Column timeStamp string Timestamp of the data.
//* @Column power number Positive number indicates the battery is charging.
//* negative number indicates the battery is discharging.
//* @Column lifeTimeEnergyCharged number The lifetime energy charged into the
//* battery in Wh.
//* @Column batteryState string String representation of the Battery state. May
//* be one of: Invalid, Standby, Thermal Management, Enabled, Fault
class GetStorageData extends SeCommand {
  static const String isType = 'getStorageData';
  static const String pathName = 'Get_Storage_Data';

  static const String _dateRange = 'dateRange';
  static const String _namePlate = 'namePlate';
  static const String _serial = 'serialNumber';
  static const String _timestamp = 'timeStamp';
  static const String _power = 'power';
  static const String _state = 'batteryState';
  static const String _lifeTime = 'lifeTimeEnergyCharged';
  static const Duration _weekPeriod = const Duration(days: 7);

  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Get Storage Data',
    r'$invokable' : 'write',
    r'$params' : [
      { 'name': _dateRange, 'type': 'string', 'editor': 'daterange' }
    ],
    r'$result': 'table',
    r'$columns' : [
      {'name': _namePlate, 'type': 'number', 'default': 0 },
      {'name': _serial, 'type': 'string', 'default': '' },
      {'name': _timestamp, 'type': 'string', 'default': '00-00-0000 00:00:00'},
      {'name': _power, 'type': 'number', 'default': 0},
      {'name': _lifeTime, 'type': 'number', 'default': 0},
      {'name': _state, 'type': 'string', 'default': ''}
    ]
  };

  final SeClient client;

  GetStorageData(String path, this.client) : super(path);

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, dynamic> params) async {
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
    var result = await client.getStorage(site, qParams);
    updateCalls();
    if (result == null) return ret;

    for (var bat in result) {
      for (var tel in bat.telemetries) {
        var mp = {};
        mp[_namePlate] = bat.nameplate;
        mp[_serial] = bat.serial;
        mp[_timestamp] = tel.date;
        mp[_power] = tel.power;
        mp[_lifeTime] = tel.lifetimeCharge;
        mp[_state] = tel.state;
        ret.add(mp);
      }
    }

    return ret;
  }
}

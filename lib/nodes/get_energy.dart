import 'dart:async';

import 'se_base.dart';
import '../src/client.dart';

class GetEnergyMeasurements extends SeCommand {
  static const String isType = 'getEnergyMeasurements';
  static const String pathName = 'Get_Energy_Measurements';

  static const String _dateRange = 'dateRange';
  static const String _timeUnit = 'timeUnit';
  static const String _date = 'date';
  static const String _value = 'value';
  static const String _energyUnit = 'energyUnit';
  static const Duration _monthPeriod = const Duration(days: 31);
  static const Duration _yearPeriod = const Duration(days: 365);

  static const List<String> timePeriods = const <String>['Quarter_Of_An_Hour',
      'Hour', 'Day', 'Week', 'Month', 'Year' ];

  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Get Energy Measurements',
    r'$invokable' : 'write',
    r'$params' : [
      { 'name': _dateRange, 'type': 'string', 'editor': 'daterange'},
      { 'name' : _timeUnit, 'type': 'enum[${timePeriods.join(',')}]'}
    ],
    r'$result': 'table',
    r'$columns' : [
      { 'name' : _date, 'type' : 'bool', 'default' : false},
      { 'name' : _value, 'type' : 'number', 'default': 0},
      { 'name' : _energyUnit, 'type': 'string', 'default': ''}
    ]
  };

  final SeClient client;

  GetEnergyMeasurements(String path, this.client) : super(path);

  @override
  Future<List<Map>> onInvoke(Map<String, String> params) async {
    var ret = new List<Map>();

    var ind = timePeriods.indexOf(params[_timeUnit].trim());
    if (ind == -1) {
      return ret;
    }

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
    switch (ind) {
      case 0:
      case 1:
        if (diff.compareTo(_monthPeriod) > 0) return [];
        break;
      case 2:
        if (diff.compareTo(_yearPeriod) > 0) return [];
        break;
    }
    var qParams = {};
    qParams['timeUnit'] = timePeriods[ind].toUpperCase();
    qParams['startDate'] =
    '${startDate.year}-${startDate.month}-${startDate.day}';
    qParams['endDate'] = '${endDate.year}-${endDate.month}-${endDate.day}';

    var site = getSite();
    var result = await client.getSiteEnergy(site, qParams);
    updateCalls();
    if (result == null) return ret;

    for (var em in result.measurements) {
      var mp = {};
      mp[_date] = em.date;
      mp[_value] = em.value;
      mp[_energyUnit] = em.energyUnit;
      ret.add(mp);
    }

    return ret;
  }
}

class GetTotalEnergy extends SeCommand {
  static const String isType = 'getTotalEnergy';
  static const String pathName = 'Get_Total_Energy';

  static const String _dateRange = 'dateRange';
  static const String _value = 'value';
  static const String _energyUnit = 'energyUnit';

  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Get Total Energy',
    r'$invokable' : 'write',
    r'$params' : [
      { 'name' : _dateRange, 'type' : 'string', 'editor': 'daterange' }
    ],
    r'$columns' : [
      { 'name' : _value, 'type' : 'number', 'default' : 0 },
      { 'name' : _energyUnit, 'type' : 'string', 'default': '' }
    ]
  };

  SeClient client;

  GetTotalEnergy(String path, this.client) : super(path);

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, String> params) async {
    var ret = { _value: 0, _energyUnit : '' };


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

    var qParams = {};
    qParams['startDate'] =
    '${startDate.year}-${startDate.month}-${startDate.day}';
    qParams['endDate'] = '${endDate.year}-${endDate.month}-${endDate.day}';

    var site = getSite();
    var result = await client.getTotalEnergy(site, qParams);
    updateCalls();
    if (result == null) return ret;

    ret[_energyUnit] = result.energyUnit;
    ret[_value] = result.value;

    return ret;
  }
}
import 'dart:async';

import 'se_base.dart';
import '../client.dart';

//* @Action Get_Energy_Measurements
//* @Is getEnergyMeasurements
//* @Parent SiteNode
//*
//* Get Energy Measurements retrieves the sites energy measurements.
//*
//* Get Energy Measurements will return measurements for a given time range over
//* a specified time period. Action returns a list of measurements at the
//* date time with the value and measurement unit. It will verify the time range
//* is valid and the time period is permitted with the specified time range.
//* *When using time period of 1 day, the time range is limited to one year.*
//* *When using a time period of Quarter_Of_An_Hour or Hour, time range is limited
//* to one 1 month.*
//*
//* @Param dateRange string Date range for the period of time to retrieve the
//* energy measurements. Should be in the format MM-DD-YYYY HH:mm:SS/MM-DD-YYYY HH:mm:SS
//* @Param timeUnit enum[Quarter_Of_An_Hour,Hour,Day,Week,Month,Year] Time unit is
//* interval period from which measurements over the dateRange should be provided.
//*
//* @Return table
//* @Column date string Date Time of the measurement.
//* @Column value number Value of the measurement.
//* @Column energyUnity string Unit of the measurement value.
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
      { 'name' : _date, 'type' : 'string', 'default' : '00-00-0000 00:00:00'},
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
        if (diff.compareTo(_monthPeriod) > 0) return ret;
        break;
      case 2:
        if (diff.compareTo(_yearPeriod) > 0) return ret;
        break;
    }
    var qParams = {};
    qParams['timeUnit'] = timePeriods[ind].toUpperCase();
    qParams['startDate'] =
    '${startDate.year}-${startDate.month}-${startDate.day}';
    qParams['endDate'] = '${endDate.year}-${endDate.month}-${endDate.day}';

    var site = await getSite();
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

//* @Action Get_Total_Energy
//* @Is getTotalEnergy
//* @Parent SiteNode
//*
//* Gets total energy produced over specified time period.
//*
//* Get Total Energy retrieves the total energy produced over the specified
//* time period. It will validate that the time range is valid and return
//* 0 values if not valid.
//*
//* @Param dateRange string Date range for the period of time to retrieve the
//* energy produced. Should be in the format MM-DD-YYYY HH:mm:SS/MM-DD-YYYY HH:mm:SS
//*
//* @Return values
//* @Column value number Value is the total energy produced.
//* @Column energyUnit string Energy unit of the energy produced value.
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

    var site = await getSite();
    var result = await client.getTotalEnergy(site, qParams);
    updateCalls();
    if (result == null) return ret;

    ret[_energyUnit] = result.energyUnit;
    ret[_value] = result.value;

    return ret;
  }
}

//* @Action Get_Power_Measurements
//* @Is getSitePower
//* @Parent SiteNode
//*
//* Get power measurements in 15 minute resolution.
//*
//* Get Power Measurements returns the site's power measurements for the
//* specified date range in 15 minute intervals. This action is limited to
//* a date range of 1 month. It will verify the specified date range and return
//* an empty list on failure.
//*
//* @Param dateRange string Date range for the period of time to retrieve the
//* power measurements. Should be in the format MM-DD-YYYY HH:mm:SS/MM-DD-YYYY HH:mm:SS
//*
//* @Return table
//* @Column date string Date time of the power measurement.
//* @Column value number Value of the power measurement.
//* @Column energyUnit Energy Unit of the power measurement value.
class GetSitePower extends SeCommand {
  static const String isType = 'getSitePower';
  static const String pathName = 'Get_Power_Measurements';

  static const String _dateRange = 'dateRange';
  static const String _date = 'date';
  static const String _value = 'value';
  static const String _energyUnit = 'energyUnit';

  static const Duration _monthPeriod = const Duration(days: 31);

  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Get Power Measurements',
    r'$invokable' : 'write',
    r'$params' : [
      { 'name': _dateRange, 'type': 'string', 'editor': 'daterange'},
    ],
    r'$result': 'table',
    r'$columns' : [
      { 'name' : _date, 'type' : 'string', 'default' : '00-00-0000 00:00:00'},
      { 'name' : _value, 'type' : 'number', 'default': 0},
      { 'name' : _energyUnit, 'type': 'string', 'default': ''}
    ]
  };

  final SeClient client;

  GetSitePower(String path, this.client) : super(path);

  @override
  Future<List<Map>> onInvoke(Map<String, String> params) async {
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

    // Start date should be before End Date
    if (startDate.compareTo(endDate) >= 0) {
      return ret;
    }

    // No more than a month period.
    var diff = endDate.difference(startDate);
    if (diff.compareTo(_monthPeriod) > 0) return ret;

    var qParams = {};
    var startStr = startDate.toString();
    var endStr = endDate.toString();
    qParams['startTime'] = startStr.substring(0, startStr.length - 4);
    qParams['endTime'] = endStr.substring(0, endStr.length - 4);
    var site = await getSite();
    var result = await client.getSitePower(site, qParams);
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

//* @Action Get_Detailed_Power
//* @Is getDetailedPower
//* @Parent SiteNode
//*
//* Get Detailed power measurements from meters.
//*
//* Get Detailed Power retrieves measurements for consumption, production and
//* other power sources over the specified date range. The action is limited to
//* a 1 month period of measurements. It will verify the date range provided.
//* If the action fails it will return an empty list.
//*
//* @Param dateRange string Date range for the period of time to retrieve the
//* power measurements. Should be in the format MM-DD-YYYY HH:mm:SS/MM-DD-YYYY HH:mm:SS
//*
//* @Return table
//* @Column date string Date time of the power measurement.
//* @Column type string Type of power measurement. (Eg. consumption, production)
//* @Column value number Value of the power measurement.
//* @Column energyUnit Energy Unity of the power measurement value.
class GetDetailedPower extends SeCommand {
  static const String isType = 'getDetailedPower';
  static const String pathName = 'Get_Detailed_Power';

  static const String _dateRange = 'dateRange';
  static const String _date = 'date';
  static const String _type = 'type';
  static const String _value = 'value';
  static const String _energyUnit = 'energyUnit';

  static const Duration _monthPeriod = const Duration(days: 31);

  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Get Detailed Power',
    r'$invokable' : 'write',
    r'$params' : [
      { 'name': _dateRange, 'type': 'string', 'editor': 'daterange' }
    ],
    r'$result': 'table',
    r'$columns' : [
      { 'name' : _date, 'type' : 'string', 'default': '' },
      { 'name' : _type, 'type' : 'string', 'default': '' },
      { 'name' : _value, 'type': 'number', 'default': 0 },
      { 'name' : _energyUnit, 'type': 'string', 'default': '' }
    ]
  };

  final SeClient client;

  GetDetailedPower(String path, this.client) : super(path);

  @override
  Future<List<Map<String, dynamic>>> onInvoke(Map<String, dynamic> params) async {
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

    // Start date should be before End Date
    if (startDate.compareTo(endDate) >= 0) {
      return ret;
    }

    // No more than a month period.
    var diff = endDate.difference(startDate);
    if (diff.compareTo(_monthPeriod) > 0) return ret;

    var qParams = {};
    var startStr = startDate.toString();
    var endStr = endDate.toString();
    qParams['startTime'] = startStr.substring(0, startStr.length - 4);
    qParams['endTime'] = endStr.substring(0, endStr.length - 4);
    var site = await getSite();
    var result = await client.getDetailedPower(site, qParams);
    updateCalls();
    if (result == null) return ret;

    for (var em in result.measurements) {
      for (var key in em.measurements.keys) {
        var mp = {};
        mp[_date] = em.date;
        mp[_type] = key;
        mp[_value] = em.measurements[key].value;
        mp[_energyUnit] = em.measurements[key].energyUnit;
        ret.add(mp);
      }
    }

    return ret;
  }
}

//* @Action Get_Detailed_Energy
//* @Is getDetailedEnergy
//* @Parent SiteNode
//*
//* Get detailed energy produced over date range in specified intervals.
//*
//* Get Detailed Energy returns the energy usage over the specified date range
//* at given intervals. This will provide production and consumption values
//* at each time range over the specified period. *Limited to 1 year time range
//* with a time unit interval of 1 day. Limited to 1 month time range when using
//* a time unit interval of Quarter_Of_An_Hour or Hour* Lower resolutions (week,
//* month and year) have no time range limitation.
//*
//* @Param dateRange string Date range for the period of time to retrieve the
//* energy usage. Should be in the format MM-DD-YYYY HH:mm:SS/MM-DD-YYYY HH:mm:SS
//* @Param timeUnit enum[Quarter_Of_An_Hour,Hour,Day,Week,Month,Year] Time Unit
//* is the interval over which the energy usage should be displayed.
//*
//* @Return table
//* @Column date string Date time of the measurement value.
//* @Column type string Type of energy usage (eg. consumption, production)
//* @Column value number Value of the energy usage.
//* @Column energyUnit string Unit of measurement for the energy usage.
class GetDetailedEnergy extends SeCommand {
  static const String isType = 'getDetailedEnergy';
  static const String pathName = 'Get_Detailed_Energy';

  static const String _dateRange = 'dateRange';
  static const String _timeUnit = 'timeUnit';
  static const String _date = 'date';
  static const String _type = 'type';
  static const String _value = 'value';
  static const String _energyUnit = 'energyUnit';
  static const Duration _monthPeriod = const Duration(days: 31);
  static const Duration _yearPeriod = const Duration(days: 365);

  static const List<String> timePeriods = const <String>['Quarter_Of_An_Hour',
  'Hour', 'Day', 'Week', 'Month', 'Year' ];

  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Get Detailed Energy',
    r'$invokable' : 'write',
    r'$params' : [
      { 'name': _dateRange, 'type': 'string', 'editor': 'daterange'},
      {
        'name' : _timeUnit,
        'type': 'enum[${timePeriods.join(',')}]',
        'default': timePeriods[2]
      }
    ],
    r'$result': 'table',
    r'$columns' : [
      { 'name' : _date, 'type' : 'string', 'default' : '00-00-0000 00:00:00'},
      { 'name' : _type, 'type' : 'string', 'default': '' },
      { 'name' : _value, 'type' : 'number', 'default': 0},
      { 'name' : _energyUnit, 'type': 'string', 'default': ''}
    ]
  };

  final SeClient client;

  GetDetailedEnergy(String path, this.client) : super(path);

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
        if (diff.compareTo(_monthPeriod) > 0) return ret;
        break;
      case 2:
        if (diff.compareTo(_yearPeriod) > 0) return ret;
        break;
    }

    var qParams = {};
    var startStr = startDate.toString();
    var endStr = endDate.toString();
    qParams['timeUnit'] = timePeriods[ind].toUpperCase();
    qParams['startTime'] = startStr.substring(0, startStr.length - 4);
    qParams['endTime'] = endStr.substring(0, endStr.length - 4);

    var site = await getSite();
    var result = await client.getDetailedEnergy(site, qParams);
    updateCalls();
    if (result == null) return ret;

    for (var em in result.measurements) {
      for (var key in em.measurements.keys) {
        var mp = {};
        mp[_date] = em.date;
        mp[_type] = key;
        mp[_value] = em.measurements[key].value;
        mp[_energyUnit] = em.measurements[key].energyUnit;
        ret.add(mp);
      }
    }

    return ret;
  }
}

import 'dart:async';

import 'package:dslink/dslink.dart';
import 'package:timezone/standalone.dart';

import 'se_base.dart';
import '../models.dart';
import '../src/client.dart';

class OverviewNode extends SeBase {
  static const String isType = 'overviewNode';
  static const String pathName = 'Overview';
  static Map<String, dynamic> definition() => {
        r'$is': isType,
        _lastUpdateTime: OverviewValue.definition(
            'Last Update Time', 'string', '0000-00-00'),
        _currentPower: OverviewValue.definition('Current Power', 'number', 0),
        _lifeTimeData: EngRevNode.definition(),
        _lastYearData: EngRevNode.definition(),
        _lastMonthData: EngRevNode.definition(),
        _lastDayData: EngRevNode.definition(),
      };

  static const String _lastUpdateTime = 'lastUpdateTime';
  static const String _lifeTimeData = 'lifeTimeData';
  static const String _lastYearData = 'lastYearData';
  static const String _lastMonthData = 'lastMonthData';
  static const String _lastDayData = 'lastDayData';
  static const String _currentPower = 'currentPower';

  static const Duration _minInterval = const Duration(minutes: 15);

  final SeClient client;
  int subscriptions = 0;
  Timer _timer;
  Site site;
  DateTime _lastUpdate;
  bool _tzInit = false;

  final LinkProvider link;

  OverviewNode(String path, this.client, this.link) : super(path) {
    serializable = true;
  }

  @override
  void onSubscribe() {
    subscriptions += 1;
    if ((_timer == null || !_timer.isActive) && subscriptions == 1) {
      _timerUpdate(null);
    }
  }

  @override
  void onUnsubscribe() {
    subscriptions -= 1;
    if (subscriptions <= 0 && _timer != null && _timer.isActive) {
      _timer.cancel();
    }
  }

  _timerUpdate(Timer t) async {
    void updateChild(String childPath, EnergyRevenue er) {
      var data = provider.getNode('$path/$childPath') as EngRevNode;
      data?.update(er);
    }

    if (_timer == null || !_timer.isActive) {
      // Add an extra 2 seconds to help account for slightly imprecise timing
      var interval = new Duration(minutes: _minInterval.inMinutes, seconds: 2);
      _timer = new Timer.periodic(interval, _timerUpdate);
    }

    site ??= await getSite();

    if (!_tzInit) {
      await initializeTimeZone(Config.dataDir);
      _tzInit = true;
    }

    var siteTz = getLocation(site.location.timeZone);
    var curTime = new TZDateTime.now(siteTz);
//    var curTime = new DateTime.now();
    if (_lastUpdate != null && curTime.difference(_lastUpdate) < _minInterval) {
      return;
    }

    site ??= await getSite();

    if (curTime.hour < site.callStart || curTime.hour >= site.callEnd) {
      return;
    }

    var resp = await client.getOverview(site);
    updateCalls();
    _lastUpdate = curTime;
    if (resp != null) {
      provider.updateValue(
          '$path/$_lastUpdateTime', (resp.lastUpdate ?? 'null'));
      provider.updateValue('$path/$_currentPower', resp.currentPower);

      updateChild(_lifeTimeData, resp.lifeTimeData);
      updateChild(_lastYearData, resp.lastYearData);
      updateChild(_lastMonthData, resp.lastMonthData);
      updateChild(_lastDayData, resp.lastDayData);

      link.save();
    }
  }
}

class EngRevNode extends SeBase {
  static const isType = 'energyRevenueNode';
  static Map<String, dynamic> definition() => {
        r'$is': isType,
        _energy: OverviewValue.definition('Energy', 'number', 0),
        _revenue: OverviewValue.definition('Revenue', 'number', 0)
      };

  static const String _energy = 'energy';
  static const String _revenue = 'revenue';
  EngRevNode(String path) : super(path) {
    serializable = true;
  }

  void update(EnergyRevenue energyRevenue) {
    provider.updateValue('$path/$_energy', energyRevenue.energy);
    provider.updateValue('$path/$_revenue', (energyRevenue.revenue ?? 0));
  }
}

class OverviewValue extends SeBase {
  static const String isType = 'overviewValue';
  static Map<String, dynamic> definition(String name, String type, value) =>
      {r'$is': isType, r'$name': name, r'$type': type, r'?value': value};

  OverviewNode _overview;

  OverviewValue(String path) : super(path) {
    serializable = true;
  }

  OverviewNode _getOverview() {
    var p = parent;
    while (p is! OverviewNode && p != null) {
      p = p.parent;
    }

    return p;
  }

  @override
  void onSubscribe() {
    _overview ??= _getOverview();

    _overview?.onSubscribe();
  }

  @override
  void onUnsubscribe() {
    _overview ??= _getOverview();
    _overview?.onUnsubscribe();
  }
}

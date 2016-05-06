import 'dart:async';

import 'se_base.dart';
import '../models.dart';
import '../src/client.dart';

class OverviewNode extends SeBase {
  static const String isType = 'overviewNode';
  static const String pathName = 'Overview';
  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    _lastUpdate :
      OverviewValue.definition('Last Update Time', 'string', '0000-00-00'),
    _currentPower : OverviewValue.definition('Current Power', 'number', 0),
    _lifeTimeData : EngRevNode.definition(),
    _lastYearData : EngRevNode.definition(),
    _lastMonthData: EngRevNode.definition(),
    _lastDayData: EngRevNode.definition(),
  };

  static const String _lastUpdate = 'lastUpdateTime';
  static const String _lifeTimeData = 'lifeTimeData';
  static const String _lastYearData = 'lastYearData';
  static const String _lastMonthData = 'lastMonthData';
  static const String _lastDayData = 'lastDayData';
  static const String _currentPower = 'currentPower';

  final SeClient client;
  int subscriptions = 0;
  Timer _timer;
  Site site;

  OverviewNode(String path, this.client) : super(path) {
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
      _timer = new Timer.periodic(new Duration(minutes: 10), _timerUpdate);
    }

    site ??= getSite();

    var resp = await client.getOverview(site);
    updateCalls();

    if (resp != null) {
      provider.updateValue('$path/$_lastUpdate', (resp.lastUpdate ?? 'null'));
      provider.updateValue('$path/$_currentPower', resp.currentPower);

      updateChild(_lifeTimeData, resp.lifeTimeData);
      updateChild(_lastYearData, resp.lastYearData);
      updateChild(_lastMonthData, resp.lastMonthData);
      updateChild(_lastDayData, resp.lastDayData);
    }
  }
}

class EngRevNode extends SeBase {
  static const isType = 'energyRevenueNode';
  static Map<String, dynamic> definition() => {
    r'$is': isType,
    _energy : OverviewValue.definition('Energy', 'number', 0),
    _revenue : OverviewValue.definition('Revenue', 'number', 0)
  };

  static const String _energy = 'energy';
  static const String _revenue = 'revenue';
  EngRevNode(String path) : super(path);

  void update(EnergyRevenue energyRevenue) {
    provider.updateValue('$path/$_energy', energyRevenue.energy);
    provider.updateValue('$path/$_revenue', (energyRevenue.revenue ?? 0));
  }
}

class OverviewValue extends SeBase {
  static const String isType = 'overviewValue';
  static Map<String, dynamic> definition(String name, String type, value) => {
    r'$is' : isType,
    r'$name': name,
    r'$type': type,
    r'?value': value
  };

  OverviewNode _overview;

  OverviewValue(String path) : super(path);

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
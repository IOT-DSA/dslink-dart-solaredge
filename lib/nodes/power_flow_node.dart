import 'dart:async';

import 'se_base.dart';
import '../models.dart';
import '../src/client.dart';

class PowerFlowNode extends SeBase {
  static const String isType = 'powerFlowNode';
  static const String pathName = 'powerFlow';
  static Map<String, dynamic> definition() => {
    r'$is': isType,
    r'$name': 'Power Flow',
    _connectionFrom : PowerFlowValue.definition('Connection From', 'string', ''),
    _connectionTo : PowerFlowValue.definition('Connection To', 'string', ''),
    _grid : {
      r'$name': 'Grid',
      _status: PowerFlowValue.definition('Status', 'string', ''),
      _power: PowerFlowValue.definition('Current Power', 'number', 0),
      _energyUnits: PowerFlowValue.definition('Unit', 'string', '')
    },
    _load: {
      r'$name': 'Load',
      _status: PowerFlowValue.definition('Status', 'string', ''),
      _power: PowerFlowValue.definition('Current Power', 'number', 0),
      _energyUnits: PowerFlowValue.definition('Unit', 'string', '')
    },
    _pv: {
      r'$name': 'PV',
      _status: PowerFlowValue.definition('Status', 'string', ''),
      _power: PowerFlowValue.definition('Current Power', 'number', 0),
      _energyUnits: PowerFlowValue.definition('Unit', 'string', '')
    },
    _storage: {
      _status: PowerFlowValue.definition('Status', 'string', ''),
      _power: PowerFlowValue.definition('Current Power', 'number', 0),
      _charge: PowerFlowValue.definition('Charge Level', 'number', 0),
      _energyUnits: PowerFlowValue.definition('Unit', 'string', ''),
      _critical: PowerFlowValue.definition('Critical', 'bool', false)
    }
  };

  static const String _connectionTo = 'connectionTo';
  static const String _connectionFrom = 'connectionFrom';
  static const String _status = 'status';
  static const String _power = 'currentPower';
  static const String _charge = 'chargeLevel';
  static const String _critical = 'critical';
  static const String _energyUnits = 'units';
  static const String _grid = 'grid';
  static const String _load = 'load';
  static const String _pv = 'pv';
  static const String _storage = 'storage';


  final SeClient client;
  int subscriptions = 0;
  Timer _timer;
  Site site;

  PowerFlowNode(String path, this.client) : super(path) {
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
    if (_timer == null || !_timer.isActive) {
      _timer = new Timer.periodic(new Duration(minutes: 10), _timerUpdate);
    }

    site ??= getSite();

    var resp = await client.getPowerFlow(site);
    updateCalls();

    if (resp != null) {
      provider.updateValue('$path/$_connectionTo', resp.to);
      provider.updateValue('$path/$_connectionFrom', resp.from);
      if (resp.grid != null) {
        provider.updateValue('$path/$_grid/$_status', resp.grid.status);
        provider.updateValue('$path/$_grid/$_power', resp.grid.value);
        provider.updateValue(
            '$path/$_grid/$_energyUnits', resp.grid.energyUnit);
      }
      if (resp.load != null) {
        provider.updateValue('$path/$_load/$_status', resp.load.status);
        provider.updateValue('$path/$_load/$_power', resp.load.value);
        provider.updateValue(
            '$path/$_load/$_energyUnits', resp.load.energyUnit);
      }
      if (resp.pv != null) {
        provider.updateValue('$path/$_pv/$_status', resp.pv.status);
        provider.updateValue('$path/$_pv/$_power', resp.pv.value);
        provider.updateValue('$path/$_pv/$_energyUnits', resp.pv.energyUnit);
      }
      if (resp.storage != null) {
        provider.updateValue('$path/$_storage/$_status', resp.storage.status);
        provider.updateValue('$path/$_storage/$_power', resp.storage.power);
        provider.updateValue(
            '$path/$_storage/$_charge', resp.storage.chargeLevel);
        provider.updateValue(
            '$path/$_storage/$_energyUnits', resp.storage.energyUnit);
        provider.updateValue(
            '$path/$_storage/$_critical', resp.storage.critical);
      }
    }
  }
}

class PowerFlowValue extends SeBase {
  static const String isType = 'powerFlowValue';
  static Map<String, dynamic> definition(String name, String type, value) => {
    r'$is' : isType,
    r'$name': name,
    r'$type': type,
    r'?value': value
  };

  PowerFlowNode _pf;

  PowerFlowValue(String path) : super(path) {
    serializable = true;
  }

  PowerFlowNode _getPf() {
    var p = parent;
    while (p is! PowerFlowNode && p != null) {
      p = p.parent;
    }

    return p;
  }

  @override
  void onSubscribe() {
    _pf ??= _getPf();
    _pf?.onSubscribe();
  }

  @override
  void onUnsubscribe() {
    _pf ??= _getPf();
    _pf?.onUnsubscribe();
  }
}
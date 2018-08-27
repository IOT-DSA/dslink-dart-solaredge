import 'dart:async' show Future;

import 'se_base.dart';
import '../client.dart';
import '../models/environmental_benefit.dart';

class EnvironmentalBenefitsNode extends SeBase {
  static const String isType = 'environmentalBenefitsNode';
  static const String pathName = 'environmental_benefits';

  static const String _trees = 'treesPlanted';
  static const String _lights = 'lightBulbs';

  static Map<String, dynamic> def(EnvironmentalBenefit eb) => {
    r'$is': isType,
    r'$name': 'Environmental Benefits',
    RefreshBenefitsNode.pathName: RefreshBenefitsNode.def(),
    GasEmissionSavedNode.pathName: GasEmissionSavedNode.def(eb.gasEmissions),
    _trees: {
      r'$name': 'Trees Planted',
      r'$type': 'number',
      r'?value': eb.treesPlanted
    },
    _lights: {
      r'$name': 'Light Bulbs',
      r'$description': 'Number of light bulbs powered for a day',
      r'$type': 'number',
      r'?value': eb.lightBulbs
    }
  };

  EnvironmentalBenefitsNode(String path) : super(path);

  void update(EnvironmentalBenefit eb) {
    provider.updateValue('$path/$_trees', eb.treesPlanted);
    provider.updateValue('$path/$_lights', eb.lightBulbs);

    var geNode = children[GasEmissionSavedNode.pathName] as GasEmissionSavedNode;
    if (geNode != null) {
      geNode.update(eb.gasEmissions);
    }
  }
}

class RefreshBenefitsNode extends SeBase {
  static const String isType = 'refreshBenefitsNode';
  static const String pathName = 'refreshBenefits';

  static const String _systemUnits = 'systemUnits';
  static const String _units = 'enum[default,Imperial,Metrics]';
  static const String _success = 'success';
  static const String _message = 'message';

  static Map<String, dynamic> def() => {
    r'$is': isType,
    r'$name': 'Refresh Benefits',
    r'$invokable': 'write',
    r'$params': [
      {'name': _systemUnits, 'type': _units, 'default': 'default'}
    ],
    r'$columns': [
      {'name': _success, 'type': 'bool', 'default': false},
      {'name': _message, 'type': 'string', 'default': ''}
    ]
  };

  final SeClient client;
  RefreshBenefitsNode(String path, this.client): super(path);

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, dynamic> params) async {
    var ret = {_success: false, _message: ''};

    var site = await getSite();
    var parameters = <String, String>{};
    if (params[_systemUnits] == 'default' || params[_systemUnits] == null) {
      parameters = null;
    } else {
      parameters[_systemUnits] = params[_systemUnits];
    }
    var benefits = await client.getBenefits(site, parameters);
    if (benefits == null) {
      ret[_message] = 'Unable to retreive site  benefits';
    } else {
      (parent as EnvironmentalBenefitsNode).update(benefits);
      ret..[_success] = true
          ..[_message] = 'Success!';
    }

    return ret;
  }

}

class GasEmissionSavedNode extends SeBase {
  static const String isType = 'gasEmissionSavedNode';
  static const String pathName = 'gas_emission_saved';

  static const String _unit = 'units';
  static const String _co2 = 'co2';
  static const String _so2 = 'so2';
  static const String _nox = 'nox';

  static Map<String, dynamic> def(GasEmissions ge) => {
    r'$is': isType,
    r'$name': 'Gas Emission Saved',
    _unit: {
      r'$name': 'Units',
      r'$type': 'string',
      r'?value': ge.units
    },
    _co2: {
      r'$name': 'CO2',
      r'$type': 'number',
      r'?value': ge.co2
    },
    _so2: {
      r'$name': 'SO2',
      r'$type': 'number',
      r'?value': ge.so2
    },
    _nox: {
      r'$name': 'NOX',
      r'$type': 'number',
      r'?value': ge.nox
    }
  };

  GasEmissionSavedNode(String path) : super(path);

  void update(GasEmissions ge) {
    provider.updateValue('$path/$_unit', ge.units);
    provider.updateValue('$path/$_co2', ge.co2);
    provider.updateValue('$path/$_so2', ge.so2);
    provider.updateValue('$path/$_nox', ge.nox);
  }
}


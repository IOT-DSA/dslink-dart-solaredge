import 'dart:async';

import 'package:dslink/dslink.dart';
import 'package:dslink/nodes.dart' show NodeNamer;

import '../src/client.dart';
import '../models.dart';
import '../nodes.dart';
import 'se_base.dart';

class SiteNode extends SimpleNode {
  static const String isType = 'siteNode';
  static Map<String, dynamic> definition(Site site, String apiKey) => {
    r'$is': isType,
    r'$$se_id': site.id,
    r'$$se_api': apiKey,
    'siteName': {
      r'$name': 'Site Name',
      r'$type': 'string',
      r'?value': site.name
    },
    'siteId' : {
      r'$name' : 'Site ID',
      r'$type' : 'number',
      r'?value' : site.id,
    },
    'accountId' : {
      r'$name' : 'Account ID',
      r'$type' : 'number',
      r'?value' : site.accountId,
    },
    'status' : {
      r'$name' : 'Status',
      r'$type' : 'string',
      r'?value' : site.status,
    },
    'peakPower' : {
      r'$name' : 'Peak Power',
      r'$type' : 'number',
      r'?value' : site.peakPower,
    },
    'currency' : {
      r'$name' : 'Currency',
      r'$type' : 'string',
      r'?value' : site.currency,
    },
    'notes' : {
      r'$name' : 'Notes',
      r'$type' : 'string',
      r'?value' : site.notes,
    },
    'siteType' : {
      r'$name' : 'Type',
      r'$type' : 'string',
      r'?value' : site.type,
    },
    'installDate' : {
      r'$name' : 'Installation Date',
      r'$type' : 'string',
      r'?value' : site.installDate.toIso8601String(),
    },
    'location' : {
      r'$name' : 'Location',
      'address' : {
        r'$name' : 'Address',
        r'$type' : 'string',
        r'?value' : site.location.address,
      },
      'address2' : {
        r'$name' : 'Address 2',
        r'$type' : 'string',
        r'?value' : site.location.address2,
      },
      'city' : {
        r'$name' : 'City',
        r'$type' : 'string',
        r'?value' : site.location.city,
      },
      'state' : {
        r'$name' : 'State',
        r'$type' : 'string',
        r'?value' : site.location.state,
      },
      'zip' : {
        r'$name' : 'Zip Code',
        r'$type' : 'string',
        r'?value' : site.location.zip,
      },
      'country' : {
        r'$name' : 'Country',
        r'$type' : 'string',
        r'?value' : site.location.country,
      },
      'timeZone' : {
        r'$name' : 'Time Zone',
        r'$type' : 'string',
        r'?value' : site.location.timeZone,
      }
    },
    'alerts': {
      r'$name': 'Alerts',
      'numAlerts' : {
        r'$name' : 'Alert Quantity',
        r'$type' : 'number',
        r'?value' : site.numAlerts,
      },
      'alertSev' : {
        r'$name' : 'Alert Severity',
        r'$type' : 'string',
        r'?value' : site.alertSeverity,
      },
    },
    'uris' : {
      r'$name' : "URI's",
      r'$type' : 'map',
      r'?value' : site.uris,
    },
    'publicSettings': {
      r'$name': 'Public Settings',
      'pubName' : {
        r'$name' : 'Name',
        r'$type' : 'string',
        r'?value' : site.publicName,
      },
      'isPublic' : {
        r'$name' : 'Is Public',
        r'$type' : 'bool',
        r'?value' : site.isPublic,
      },
    },
    'equipment': {
      r'$name': 'Equipment',
       LoadEquipment.pathName : LoadEquipment.definition(),
      'count' : {
        r'$name' : 'Count',
        r'$type' : 'number',
        r'?value' : null,
      },
    },
    'apiCalls' : {
      'numCalls' : {
        r'$name' : 'Number of Calls',
        r'$type' : 'number',
        r'?value' : site.calls,
      },
      'startTime' : ApiCallTime.definition(site, "Start Time", false),
      'endTime': ApiCallTime.definition(site, "End Time", true)
    },
    'energyProductionDates': {
      r'$name': 'Energy Production Dates',
      'productionStart' : {
        r'$name' : 'Start',
        r'$type' : 'string',
        r'?value' : site.dataStart,
      },
      'productionEnd' : {
        r'$name' : 'End',
        r'$type' : 'string',
        r'?value' : site.dataEnd,
      },
    },
    'sensors' : {
      r'$name': 'Sensors',
      LoadSensors.pathName: LoadSensors.definition(),
      GetSensorData.pathName: GetSensorData.definition()
    },
    OverviewNode.pathName: OverviewNode.definition(),
    LoadProductionDates.pathName: LoadProductionDates.definition(),
    GetEnergyMeasurements.pathName: GetEnergyMeasurements.definition(),
    GetTotalEnergy.pathName: GetTotalEnergy.definition(),
    GetDetailedEnergy.pathName: GetDetailedEnergy.definition(),
    GetSitePower.pathName: GetSitePower.definition(),
    GetDetailedPower.pathName: GetDetailedPower.definition(),
    GetStorageData.pathName: GetStorageData.definition(),
    RemoveSiteNode.pathName: RemoveSiteNode.definition()
  };

  Future<Site> getSite() => _siteComp.future;
  Completer<Site> _siteComp;
  Site _site;
  SeClient client;

  SiteNode(String path, this.client) : super(path) {
    _siteComp = new Completer<Site>();
  }

  @override
  void onCreated() {
    var api = getConfig(r'$$se_api');
    var id = getConfig(r'$$se_id');
    client.addSite(id, api).then((Site site) {
      var nd = provider.getNode('$path/apiCalls/startTime');
      if (nd != null) {
        site.callStart = nd.value.toInt();
      }
      nd = provider.getNode('$path/apiCalls/endTime');
      if (nd != null) {
        site.callEnd = nd.value.toInt();
      }

      _site = site;
      _siteComp.complete(_site);
    });

  }

  void updateCalls() {
    if (_site != null) {
      provider.updateValue('$path/apiCalls', _site.calls);
    }
  }

  void updateCallTime(int time, bool isEnd) {
    if (isEnd) {
      _site.callEnd = time;
    } else {
      _site.callStart = time;
    }
  }
}

class ApiCallTime extends SeBase {
  static const String isType = 'apiCallTime';

  static const String _isEnd = r'$$callEnd';

  static Map<String, dynamic> definition(Site site, String name, bool end) => {
    _isEnd: end,
    r'$is' : isType,
    r'$name': name,
    r'$writable' : 'write',
    r'$type': 'number',
    r'?value': (end ? site.callEnd : site.callStart)
  };

  ApiCallTime(String path) : super(path);

  bool onSetValue(value) {
    var end = getConfig(_isEnd) as bool;
    getSiteNode().updateCallTime(value.toInt(), end);
    return false;
  }
}

class RemoveSiteNode extends SimpleNode {
  static const String isType = 'removeSiteNode';
  static const String pathName = 'Remove_Site';

  static const String _success = 'success';
  static const String _message = 'message';

  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Remove Site',
    r'$invokable' : 'write',
    r'$params' : [],
    r'$columns' : [
      { 'name' : _success, 'type' : 'bool', 'default' : false },
      { 'name' : _message, 'type' : 'string', 'default': '' }
    ]
  };

  final LinkProvider link;

  RemoveSiteNode(String path, this.link) : super(path);

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, dynamic> params) async {
    var ret = { _success: true, _message : 'Success!' };

    parent.remove();

    link.save();
    return ret;
  }
}

class AddSiteNode extends SimpleNode {
  static const String isType = 'addSiteNode';
  static const String pathName = 'Add_Site';

  // Constants for Mapping variables.
  static const String _siteName = 'siteName';
  static const String _siteId = 'siteId';
  static const String _siteApi = 'siteApiKey';
  static const String _success = 'success';
  static const String _message = 'message';

  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Add Site',
    r'$invokable' : 'write',
    r'$params' : [
      { 'name' : _siteName, 'type': 'string', 'placeholder': 'Site Name' },
      { 'name' : _siteId, 'type' : 'number', 'min': '0' },
      { 'name' : _siteApi, 'type': 'string' },
    ],
    r'$columns' : [
      { 'name' : _success, 'type' : 'bool', 'default' : false },
      { 'name' : _message, 'type' : 'string', 'default': '' }
    ]
  };

  final LinkProvider link;
  final SeClient client;

  AddSiteNode(String path, this.client, this.link) : super(path);

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, dynamic> params) async {
    var ret = { _success: false, _message: '' };

    var name = (params[_siteName] as String)?.trim();
    if (name == null || name.isEmpty) {
      ret[_message] = 'Site name is required';
      return ret;
    }

    var id = (params[_siteId] as num)?.toInt();
    if (id == null) {
      ret[_message] = 'Site ID is required';
      return ret;
    }

    var api = (params[_siteApi] as String)?.trim();
    if (api == null || api.isEmpty) {
      ret[_message] = 'Site API Key is required';
      return ret;
    }

    var site = await client.addSite(id, api);
    if (site != null) {
      ret[_success] = true;
      ret[_message] = 'Success!';

      var pPath = parent.path;
      var nName = NodeNamer.createName(name);
      provider.addNode('$pPath/$nName', SiteNode.definition(site, api));
      link.save();
    } else {
      ret[_message] = 'Unable to query site details';
    }
    return ret;
  }
}

class LoadProductionDates extends SeCommand {
  static const String isType = 'loadProductionDates';
  static const String pathName = 'Load_Production_Dates';

  static const String _success = 'success';
  static const String _message = 'message';

  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Load Production Dates',
    r'$invokable' : 'write',
    r'$params' : [],
    r'$columns' : [
      { 'name' : _success, 'type' : 'bool', 'default' : false },
      { 'name' : _message, 'type' : 'string', 'default': '' }
    ]
  };

  final SeClient client;

  LoadProductionDates(String path, this.client) : super(path);

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, dynamic> params) async {
    var ret = { _success: false, _message : '' };

    var site = await getSite();
    var result = await client.loadProductionDates(site);
    updateCalls();
    if (result != null) {
      var pPath = parent.path;
      provider.updateValue('$pPath/energyProductionDates/productionStart', site.dataStart);
      provider.updateValue('$pPath/energyProductionDates/productionEnd', site.dataEnd);
      ret[_success] = true;
      ret[_message] = 'Success!';
    } else {
      ret[_message] = 'Unable to load energy production dates';
    }

    return ret;
  }
}
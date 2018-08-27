import 'dart:async';

import 'package:dslink/dslink.dart';
import 'package:dslink/nodes.dart' show NodeNamer;

import 'se_base.dart';
import 'batteries_node.dart';
import 'equipment_node.dart';
import 'get_energy.dart';
import 'overview_node.dart';
import 'sensor_node.dart';
import '../client.dart';
import '../models/site.dart';

//* @Node
//* @MetaType SiteNode
//* @Parent Sites
//*
//* SiteNode is the remote Solar Edge site.
//*
//* The node manages equipment located at the site, as well as the number of
//* API calls this site makes to the remote Solar Edge server (as they are
//* limited by the Solar Edge systems). SiteNode will load any connected
//* equipment on initialization.
class SiteNode extends SimpleNode {
  static const String isType = 'siteNode';
  static Map<String, dynamic> definition(Site site, String apiKey) => {
    r'$is': isType,
    r'$$se_id': site.id,
    r'$$se_api': apiKey,
    //* @Node siteName
    //* @Parent SiteNode
    //*
    //* Site name specified by the remote server.
    //* @Value string
    'siteName': {
      r'$name': 'Site Name',
      r'$type': 'string',
      r'?value': site.name
    },
    //* @Node siteId
    //* @Parent SiteNode
    //*
    //* Site id specified by the remote server.
    //* @Value number
    'siteId' : {
      r'$name' : 'Site ID',
      r'$type' : 'number',
      r'?value' : site.id,
    },
    //* @Node accountId
    //* @Parent SiteNode
    //*
    //* Account ID which the site is associated with on the remote server.
    //* @Value number
    'accountId' : {
      r'$name' : 'Account ID',
      r'$type' : 'number',
      r'?value' : site.accountId,
    },
    //* @Node status
    //* @Parent SiteNode
    //*
    //* Status is the current commissioning status of the site.
    //*
    //* Status may be either Active, or Pending Communication if the site
    //* has been added to the remote Solar Edge system but has not yet
    //* communicated back to the remote server.
    //*
    //* @Value string
    'status' : {
      r'$name' : 'Status',
      r'$type' : 'string',
      r'?value' : site.status,
    },
    //* @Node peakPower
    //* @Parent SiteNode
    //*
    //* Peak power is the site's peak power output.
    //* @Value number
    'peakPower' : {
      r'$name' : 'Peak Power',
      r'$type' : 'number',
      r'?value' : site.peakPower,
    },
    //* @Node currency
    //* @Parent SiteNode
    //*
    //* Currency is the local currency used at the site.
    //* @Value string
    'currency' : {
      r'$name' : 'Currency',
      r'$type' : 'string',
      r'?value' : site.currency,
    },
    //* @Node notes
    //* @Parent SiteNode
    //*
    //* Note left after the setup of the site in the remote Solr Edge server.
    //* @Value string
    'notes' : {
      r'$name' : 'Notes',
      r'$type' : 'string',
      r'?value' : site.notes,
    },
    //* @Node siteType
    //* @Parent SiteNode
    //*
    //* Site Type is the type of equpiment at the site.
    //*
    //* Site Type may be Optimizers and Inverters, Safety and monitoring
    //* interface, or Monitoring combiner boxes.
    //*
    //* @Value string
    'siteType' : {
      r'$name' : 'Type',
      r'$type' : 'string',
      r'?value' : site.type,
    },
    //* @Node installDate
    //* @Parent SiteNode
    //*
    //* Installation date converted to an ISO8601 string.
    //* @Value string
    'installDate' : {
      r'$name' : 'Installation Date',
      r'$type' : 'string',
      r'?value' : site.installDate.toIso8601String(),
    },
    //* @Node location
    //* @Parent SiteNode
    //*
    //* Collection of location related values.
    'location' : {
      r'$name' : 'Location',
      //* @Node address
      //* @Parent location
      //*
      //* Street address line one.
      //* @Value string
      'address' : {
        r'$name' : 'Address',
        r'$type' : 'string',
        r'?value' : site.location.address,
      },
      //* @Node address2
      //* @Parent location
      //*
      //* Stress address line two.
      //* @Value string
      'address2' : {
        r'$name' : 'Address 2',
        r'$type' : 'string',
        r'?value' : site.location.address2,
      },
      //* @Node city
      //* @Parent location
      //*
      //* City name
      //* @Value string
      'city' : {
        r'$name' : 'City',
        r'$type' : 'string',
        r'?value' : site.location.city,
      },
      //* @Node state
      //* @Parent location
      //*
      //* State name
      //* @Value string
      'state' : {
        r'$name' : 'State',
        r'$type' : 'string',
        r'?value' : site.location.state,
      },
      //* @Node zip
      //* @Parent location
      //*
      //* Zip code
      //* @Value string
      'zip' : {
        r'$name' : 'Zip Code',
        r'$type' : 'string',
        r'?value' : site.location.zip,
      },
      //* @Node country
      //* @Parent location
      //*
      //* Country name
      //* @Value string
      'country' : {
        r'$name' : 'Country',
        r'$type' : 'string',
        r'?value' : site.location.country,
      },
      //* @Node timeZone
      //* @Parent location
      //*
      //* Time zone abbreviation.
      //* @Value string
      'timeZone' : {
        r'$name' : 'Time Zone',
        r'$type' : 'string',
        r'?value' : site.location.timeZone,
      }
    },
    //* @Node alerts
    //* @Parent SiteNode
    //*
    //* Alerts is a collection of alert values.
    'alerts': {
      r'$name': 'Alerts',
      //* @Node numAlerts
      //* @Parent alerts
      //*
      //* Number of alerts for this site.
      //* @Value number
      'numAlerts' : {
        r'$name' : 'Alert Quantity',
        r'$type' : 'number',
        r'?value' : site.numAlerts,
      },
      //* @Node alertSev
      //* @Parent alerts
      //*
      //* Highest severity of alerts this site has.
      //* @Value string
      'alertSev' : {
        r'$name' : 'Alert Severity',
        r'$type' : 'string',
        r'?value' : site.alertSeverity,
      },
    },
    //* @Node uris
    //* @Parent SiteNode
    //*
    //* Miscellaneous URIs related to this site, such as logo.
    //* @Value map
    'uris' : {
      r'$name' : "URI's",
      r'$type' : 'map',
      r'?value' : site.uris,
    },
    //* @Node publicSettings
    //* @Parent SiteNode
    //*
    //* Collection of values related to public settings.
    'publicSettings': {
      r'$name': 'Public Settings',
      //* @Node pubName
      //* @Parent publicSettings
      //*
      //* Publicly visible site name.
      //* @Value string
      'pubName' : {
        r'$name' : 'Name',
        r'$type' : 'string',
        r'?value' : site.publicName,
      },
      //* @Node isPublic
      //* @Parent publicSettings
      //*
      //* Is the site is publicly visible or not.
      //* @Value bool
      'isPublic' : {
        r'$name' : 'Is Public',
        r'$type' : 'bool',
        r'?value' : site.isPublic,
      },
    },
    //* @Node equipment
    //* @Parent SiteNode
    //*
    //* Collection of equipment at the site.
    'equipment': {
      r'$name': 'Equipment',
//       LoadEquipment.pathName : LoadEquipment.definition(),
      //* @Node count
      //* @Parent equipment
      //*
      //* Total count of equipment at the site.
      //* @Value number
      'count' : {
        r'$name' : 'Count',
        r'$type' : 'number',
        r'?value' : null,
      },
    },
    //* @Node apiCalls
    //* @Parent SiteNode
    //*
    //* Collection of values related to API calls to the remote Solar Edge server
    'apiCalls' : {
      //* @Node numCalls
      //* @Parent apiCalls
      //*
      //* Number of calls made to the API server in the last 24 hours.
      //* @Value number
      'numCalls' : {
        r'$name' : 'Number of Calls',
        r'$type' : 'number',
        r'?value' : site.calls,
      },
      //* @Node startTime
      //* @Parent apiCalls
      //* @Is apiCallTime
      //*
      //* Site local start time of when to start making API calls.
      //*
      //* The local start time of when API calls are being sent. Defaults to
      //* 05h00. This helps prevent API calls during times when there will be
      //* little to no change in the remote data.
      //*
      //* @Value number write
      'startTime' : ApiCallTime.definition(site, "Start Time", false),
      //* @Node endTime
      //* @Parent apiCalls
      //* @Is apiCallTime
      //* Site local end time of when to stop making API calls.
      //*
      //* The local stop to of when API calls are being sent. Defaults to 21h00.
      //* This helps prevent API calls during times when there will be little to
      //* no change in the remote data.
      //*
      //* @Value number write
      'endTime': ApiCallTime.definition(site, "End Time", true)
    },
    //* @Node energyProductionDates
    //* @Parent SiteNode
    //*
    //* Collection of values related to energy production dates for the site.
    'energyProductionDates': {
      r'$name': 'Energy Production Dates',
      //* @Node productionStart
      //* @Parent energyProductionDates
      //*
      //* Production start is the date the site started to produce energy.
      //* @Value string
      'productionStart' : {
        r'$name' : 'Start',
        r'$type' : 'string',
        r'?value' : site.dataStart,
      },
      //* @Node productionEnd
      //* @Parent energyProductionDates
      //*
      //* Production End is the last date the site produced energy.
      //* @Value string
      'productionEnd' : {
        r'$name' : 'End',
        r'$type' : 'string',
        r'?value' : site.dataEnd,
      },
    },
    //* @Node sensors
    //* @Parent SiteNode
    //*
    //* Collection of sensors located at the site.
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

  Future<Site> getSite() async {
    if (_site != null) return _site;
    return _siteComp.future;
  }
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
    client.addSite(id, api).then((Site site) async {
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

      var eqNode = provider.getNode('$path/equipment');
      print(eqNode.children.keys);
      if (eqNode.children.keys.length > 2) {
        return;
      }

      // Only 'count'
      var eq = await client.loadEquipment(_site);
      updateCalls();
      if (eq == null) return;

      var cnNode = provider.getNode('${eqNode.path}/count');
      if (cnNode != null) {
        cnNode.updateValue(eq.length);
      }

      for (var i = 0; i < eq.length; i++) {
        provider.addNode('${eqNode.path}/equip_$i',
            EquipmentNode.definition(eq[i]));
      }
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

//* @Action Remove_Site
//* @Is removeSiteNode
//* @Parent SiteNode
//*
//* Remove site from the link.
//*
//* @Return values
//* @Column success bool Success returns true on success; false on failure.
//* @Column message string Message returns Success! on success.
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

//* @Action Add_Site
//* @Is addSiteNode
//* @Parent Sites
//*
//* Add a Solar Edge Site to the link.
//*
//* Adds a site to the link based on the site ID and API key which are generated
//* within Solar Edge interface. The site will appear in the link with the
//* specified name. Action will verify with the remote server that the provided
//* credentials are valid.
//*
//* @Param siteName string Site name to appear in the link.
//* @Param siteId number Site ID generated from the remote Solar Edge system.
//* @Param siteApiKey string API Key generated from the remote Solar Edge system.
//*
//* @Return values
//* @Column success bool Success is true on success, false on failure.
//* @Column message string Message is Success! on success, and an error message
//* on failure.
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

//* @Action Load_Production_Dates
//* @Is loadProductionDates
//* @Parent SiteNode
//*
//* Populate the Production Date values on the SiteNode
//*
//* Load Production Dates will query the remote Solar Edge API for the
//* production dates for the site and populate the nodes with the values.
//*
//* @Return values
//* @Column success bool Success is true on success; false on failure.
//* @Column message string Message is Success! on success, and returns an
//* error message on failure.
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

import 'dart:async';

import 'package:dslink/dslink.dart';
import 'package:dslink/nodes.dart' show NodeNamer;

import '../src/client.dart';
import '../models.dart';
import 'equipment_node.dart';

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
    }
  };

  Site site;
  SeClient client;

  SiteNode(String path, this.client) : super(path);

  @override
  void onCreated() {
    var api = getConfig(r'$$se_api');
    var id = getConfig(r'$$se_id');
    client.addSite(id, api).then((Site site) {
      this.site = site;
    });
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
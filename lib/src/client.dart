import 'dart:async';
import 'dart:convert' show JSON;
import 'dart:io';
import 'dart:collection';

import 'package:http/http.dart';
import 'package:dslink/utils.dart' show logger;

import '../models.dart';

class SeClient {
  static const int maxConnections = 3;
  static final Uri rootHost = Uri.parse('https://monitoringapi.solaredge.com');

  static final Map<String, String> _headers =  {
    HttpHeaders.ACCEPT: ContentType.JSON.value
  };
  static const String _apiKey = 'api_key';
  static final Map<String, String> _queryParam = {
    _apiKey: ''
  };

  static SeClient _cache;
  IOClient _client;
  HashMap<int, Site> _sites;

  factory SeClient() => _cache ??= new SeClient._();

  SeClient._() {
    _sites = new HashMap<int, Site>();

    var cl = new HttpClient();
    cl.maxConnectionsPerHost = maxConnections;
    _client = new IOClient(cl);
  }

  /// Add a [Site] by site ID and API Key. If site has been loaded previously,
  /// it will provide the existing site. Otherwise it will query the monitoring
  /// server and try to fetch the site details.
  /// Returns a [Site] object containing the site's details.
  Future<Site> addSite(int id, String api) async {
    var tmp = _sites[id];
    if (tmp != null && tmp.api == api) return tmp;

    Site site;
    var respMap = await _getRequest(PathHelper.siteDetails(id), api);
    if (respMap != null) {
      site = new Site.fromJson(respMap['details'], api);
      site.addCall();
      _sites[id] = site;
    }

    return site;
  }

  /// Retrieve a [List] of [Equipment] for the specified [Site].
  /// Returns null on error, and an empty list if the site does not contain
  /// any Equipment.
  Future<List<Equipment>> loadEquipment(Site site) async {
    if (site == null) return null;

    List<Equipment> list;
    var resp = await _getRequest(PathHelper.equipmentList(site), site.api);
    if (resp != null) {
      site.addCall();
      list = new List<Equipment>();
      for (var equip in resp['list']) {
        list.add(new Equipment.fromJson(equip));
      }
      site.equipment = list;
    }

    return list;
  }

  /// Helper to simplify GET requests. Required a [String] path which should
  /// be the path part of the URL. The string API Key, and optionally any
  /// additional parameters to pass. Returns a Map result as decoded from JSON
  /// or NULL on error.
  Future<Map> _getRequest(String path, String api, {Map params}) async {
    var qParams = _queryParam;
    qParams[_apiKey] = api;
    if (params != null) {
      qParams.addAll(params);
    }

    var uri = rootHost.replace(path: path, queryParameters: params);

    Map map;
    try {
      logger.finest('Connecting to: $uri');
      var resp = await _client.get(uri, headers: _headers);
      logger.finest('Response: ${resp.statusCode}');
      logger.finest('Response: ${resp.body}');
      if (resp.statusCode == HttpStatus.OK) {
        map = JSON.decode(resp.body);
      }
    } catch (e, s) {
      logger.warning('Unable to retrieve request', e, s);
    }

    return map;
  }
}

abstract class PathHelper {
  static String siteDetails(int id) =>
      'site/$id/details.json';
  static String equipmentList(Site site) =>
      'equipment/${site.id}/list.json';
}
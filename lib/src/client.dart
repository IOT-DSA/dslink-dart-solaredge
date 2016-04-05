import 'dart:async';
import 'dart:convert' show JSON;
import 'dart:io';
import 'dart:collection';

import 'package:http/http.dart';
import 'package:dslink/utils.dart' show logger;

import 'site.dart';

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

  Future<Site> addSite(int id, String api) async {
    var tmp = _sites[id];
    if (tmp != null && tmp.api == api) return tmp;

    var params = _queryParam;
    params[_apiKey] = api;
    var url = rootHost.replace(path: 'site/$id/details.json',
              queryParameters: params);

    Site site;
    try {
      logger.finest('Trying connection to: $url');
      var resp = await _client.get(url, headers: _headers);
      logger.finest('Response: ${resp.statusCode}');
      logger.finest('Response: ${resp.body}');
      if (resp.statusCode == HttpStatus.OK) {
        var respMap = JSON.decode(resp.body);
        site = new Site.fromJson(respMap, api);
        site.addCall();
        _sites[id] = site;
      }
    } catch (e) {
      logger.warning('Error trying to retrieve site details:', e);
    }

    return site;
  }

}
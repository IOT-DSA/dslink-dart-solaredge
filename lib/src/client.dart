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
      for (var equip in resp['reporters']['list']) {
        list.add(new Equipment.fromJson(equip));
      }
      site.equipment = list;
    }

    return list;
  }

  /// Retrieve Energy Production Start and End Dates for specified [Site].
  /// Returns the specified Site.
  Future<Site> loadProductionDates(Site site) async {
    if (site == null) return null;

    var resp = await _getRequest(PathHelper.productionDates(site), site.api);
    if (resp != null) {
      site.addCall();
      site.dataStart = resp['dataPeriod']['startDate'];
      site.dataEnd = resp['dataPeriod']['endDate'];
    }

    return site;
  }

  /// Retrieves Energy Measurements for the specified [Site] from the server for
  /// the `startDate` and `endDate` specified in `params`. `timeUnit` of params
  /// must be one of: QUARTER_OF_AN_HOUR, HOUR, DAY, WEEK, MONTH, YEAR.
  ///
  /// Time period must be 1 month or less for QUARTER_OF_AN_HOUR, and HOUR.
  /// Time period must be 1 year if using `timeUnit` of DAY.
  ///
  /// Returns an [EnergyMeasurements] object with energy units and list of
  /// Energy dates, values and units.
  Future<EnergyMeasurements> getSiteEnergy(Site site, Map params) async {
    if (site == null || params == null) return null;

    EnergyMeasurements em;
    var resp = await _getRequest(PathHelper.getEnergy(site), site.api,
        params: params);
    if (resp != null) {
      site.addCall();
      em = new EnergyMeasurements.fromJson(resp['energy']);
    }

    return em;
  }

  Future<DetailedMeasurements> getDetailedEnergy(Site site, Map params) async {
    if (site == null || params == null) return null;

    DetailedMeasurements dm;
    var resp = await _getRequest(PathHelper.getDetailedEnergy(site), site.api,
        params: params);
    if (resp != null) {
      site.addCall();
      dm = new DetailedMeasurements.fromJson(resp['energyDetails']);
    }

    return dm;
  }

  Future<EnergyMeasurements> getSitePower(Site site, Map params) async {
    if (site == null || params == null) return null;

    EnergyMeasurements em;
    var resp = await _getRequest(PathHelper.getPower(site), site.api,
        params: params);
    if (resp != null) {
      site.addCall();
      em = new EnergyMeasurements.fromJson(resp['power']);
    }

    return em;
  }

  Future<DetailedMeasurements> getDetailedPower(Site site, Map params) async {
    if (site == null || params == null) return null;

    DetailedMeasurements dm;
    var resp = await _getRequest(PathHelper.getDetailedPower(site), site.api,
        params: params);
    if (resp != null) {
      site.addCall();
      dm = new DetailedMeasurements.fromJson(resp['powerDetails']);
    }

    return dm;
  }

  /// Retrieves the Total energy produced for the specified [Site] in the time
  /// period from `startDate` to `endDate` of [params].
  ///
  /// Returns a [EnergyMeasurement] object with total energy and the energy
  /// units.
  Future<EnergyMeasurement> getTotalEnergy(Site site, Map params) async {
    if (site == null || params == null) return null;

    EnergyMeasurement em;
    var resp = await _getRequest(PathHelper.getTimeFrameEnergy(site), site.api,
        params: params);
    if (resp != null) {
      site.addCall();
      em = new EnergyMeasurement.fromJson(resp['timeFrameEnergy']);
    }

    return em;
  }

  /// Retrieve [Overview] for the specified [Site]
  Future<Overview> getOverview(Site site) async {
    if (site == null) return null;

    Overview ov;
    var resp = await _getRequest(PathHelper.overview(site), site.api);
    if (resp != null) {
      site.addCall();
      ov = new Overview.fromJson(resp['overview']);
    }

    return ov;
  }

  /// Retrieve the [PowerFlow] for the specified [Site].
  Future<PowerFlow> getPowerFlow(Site site) async {
    if (site == null) return null;

    PowerFlow pf;
    var resp = await _getRequest(PathHelper.getPowerFlow(site), site.api);
    if (resp != null) {
      site.addCall();
      pf = new PowerFlow.fromJson(resp['siteCurrentPowerFlow']);
    }

    return pf;
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

    var uri = rootHost.replace(path: path, queryParameters: qParams);

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
  static String productionDates(Site site) =>
      'site/${site.id}/dataPeriod.json';
  static String getEnergy(Site site) =>
      'site/${site.id}/energy.json';
  static String getDetailedEnergy(Site site) =>
      'site/${site.id}/energyDetails';
  static String getPower(Site site) =>
      'site/${site.id}/power.json';
  static String getDetailedPower(Site site) =>
      'site/${site.id}/powerDetails';
  static String getTimeFrameEnergy(Site site) =>
      'site/${site.id}/timeFrameEnergy.json';
  static String overview(Site site) =>
      'site/${site.id}/overview';
  static String getPowerFlow(Site site) =>
      'site/${site.id}/currentPowerFlow';
}
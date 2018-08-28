import 'dart:io' show Directory;

import 'package:dslink/dslink.dart';

import 'package:dslink_solaredge/src/client.dart';
import 'package:dslink_solaredge/solar_edge.dart';
import 'package:dslink_solaredge/models.dart' show Config;
import 'package:path/path.dart' as path;


main(List<String> args) async {
  Directory curDir;
  LinkProvider link;
  SeClient client = new SeClient();

  link = new LinkProvider(args, 'SolarEdge-', autoInitialize: false, profiles: {
      AddSiteNode.isType: (String path) => new AddSiteNode(path, client, link),
      RemoveSiteNode.isType: (String path) => new RemoveSiteNode(path, link),
      SiteNode.isType: (String path) => new SiteNode(path, client),
      ApiCallTime.isType: (String path) => new ApiCallTime(path),
      LoadEquipment.isType: (String path) => new LoadEquipment(path, client),
      EquipmentNode.isType: (String path) => new EquipmentNode(path, client),
      GetInverterData.isType: (String path) => new GetInverterData(path, client),
      InverterValue.isType: (String path) => new InverterValue(path),
      LoadProductionDates.isType: (String path) =>
          new LoadProductionDates(path, client),
      GetEnergyMeasurements.isType: (String path) =>
          new GetEnergyMeasurements(path, client),
      GetTotalEnergy.isType: (String path) => new GetTotalEnergy(path, client),
      GetSitePower.isType: (String path) => new GetSitePower(path, client),
      OverviewNode.isType: (String path) => new OverviewNode(path, client, link),
      EngRevNode.isType: (String path) => new EngRevNode(path),
      OverviewValue.isType: (String path) => new OverviewValue(path),
      GetDetailedPower.isType: (String path) =>
          new GetDetailedPower(path, client),
      GetDetailedEnergy.isType: (String path) =>
          new GetDetailedEnergy(path, client),
      GetStorageData.isType: (String path) => new GetStorageData(path, client),
      LoadSensors.isType: (String path) => new LoadSensors(path, client),
      SensorNode.isType: (String path) => new SensorNode(path),
      GetSensorData.isType: (String path) => new GetSensorData(path, client),
      EnvironmentalBenefitsNode.isType: (String path) =>
          new EnvironmentalBenefitsNode(path),
      RefreshBenefitsNode.isType: (String path) =>
          new RefreshBenefitsNode(path, client),
      GasEmissionSavedNode.isType: (String path) =>
          new GasEmissionSavedNode(path)
    },
    defaultNodes: {
      //* @Node Sites
      //* @Parent root
      //*
      //* Collection of Solar Edge Sites.
      'Sites' : { AddSiteNode.pathName: AddSiteNode.definition() }
  });

  link.configure(optionsHandler: (opts) {
    if (opts != null && opts["base-path"] != null) {
      curDir = new Directory(opts["base-path"]);
    } else {
      curDir = Directory.current;
    }
  });

  Config.dataDir = path.join(curDir.path, "data", '2015b.tzf');

  link.init();
  await link.connect();
}

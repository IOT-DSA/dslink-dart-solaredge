import 'package:dslink/dslink.dart';

import 'package:dslink_solaredge/src/client.dart';
import 'package:dslink_solaredge/nodes.dart';

main(List<String> args) async {
  LinkProvider link;
  SeClient client = new SeClient();

  link = new LinkProvider(args, 'SolarEdge-', autoInitialize: false, profiles: {
      AddSiteNode.isType: (String path) => new AddSiteNode(path, client, link),
      SiteNode.isType: (String path) => new SiteNode(path, client),
      LoadEquipment.isType: (String path) => new LoadEquipment(path, client),
      LoadProductionDates.isType: (String path) =>
          new LoadProductionDates(path, client),
      GetEnergyMeasurements.isType: (String path) =>
          new GetEnergyMeasurements(path, client),
      GetTotalEnergy.isType: (String path) => new GetTotalEnergy(path, client),
      GetSitePower.isType: (String path) => new GetSitePower(path, client),
      OverviewNode.isType: (String path) => new OverviewNode(path, client),
      EngRevNode.isType: (String path) => new EngRevNode(path),
      OverviewValue.isType: (String path) => new OverviewValue(path),
      PowerFlowNode.isType: (String path) => new PowerFlowNode(path, client),
      PowerFlowValue.isType: (String path) => new PowerFlowValue(path),
      GetDetailedPower.isType: (String path) =>
          new GetDetailedPower(path, client),
      GetDetailedEnergy.isType: (String path) =>
          new GetDetailedEnergy(path, client)
    },
    defaultNodes: {
      'Sites' : { AddSiteNode.pathName: AddSiteNode.definition() }
  });

  link.init();
  await link.connect();
}
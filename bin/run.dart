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
    },
    defaultNodes: {
      'Sites' : { AddSiteNode.pathName: AddSiteNode.definition() }
  });

  link.init();
  await link.connect();
}
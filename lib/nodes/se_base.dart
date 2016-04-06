import 'package:dslink/dslink.dart';

import 'site_node.dart';
import '../models.dart';

abstract class SeBase extends SimpleNode {
  SeBase(String path) : super(path) {
    serializable = false;
  }

  Site getSite() {
    var p = parent;
    while (p is! SiteNode && p != null) {
      p = p.parent;
    }

    return (p as SiteNode).site;
  }
}

abstract class SeCommand extends SeBase {
  SeCommand(String path) : super(path) {
    serializable = true;
  }
}
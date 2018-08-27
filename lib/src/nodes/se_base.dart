import 'dart:async';

import 'package:dslink/dslink.dart';

import 'site_node.dart';
import '../models/site.dart';

abstract class SeBase extends SimpleNode {
  SeBase(String path) : super(path);

  SiteNode getSiteNode() {
    var p = parent;
    while (p is! SiteNode && p != null) {
      p = p.parent;
    }

    return p;
  }

  Future<Site> getSite() => getSiteNode()?.getSite();

  void updateCalls() => getSiteNode()?.updateCalls();
}

abstract class SeCommand extends SeBase {
  SeCommand(String path) : super(path);
}
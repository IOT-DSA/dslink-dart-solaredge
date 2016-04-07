import 'dart:async';

import 'se_base.dart';
import '../src/client.dart';
import '../models.dart';

class EquipmentNode extends SeBase {
  static const String isType = 'equipmentNode';
  static Map<String, dynamic> definition(Equipment equipment) => {
    r'$is': isType,
    r'$name': equipment.name,
    'model' : {
      r'$name' : 'Model',
      r'$type' : 'string',
      r'?value' : equipment.model,
    },
    'manufacturer' : {
      r'$name' : 'Manufacturer',
      r'$type' : 'string',
      r'?value' : equipment.manufacturer,
    },
    'serial' : {
      r'$name' : 'Serial Number',
      r'$type' : 'string',
      r'?value' : equipment.serial,
    }
  };

  SeClient client;
  EquipmentNode(String path, this.client) : super(path) {
    this.serializable = false;
  }
}

class LoadEquipment extends SeCommand {
  static const String isType = 'getEquipmentNode';
  static const String pathName = 'Load_Equipment';

  static const String _success = 'success';
  static const String _message = 'message';

  static Map<String, dynamic> definition() => {
    r'$is' : isType,
    r'$name' : 'Load Equipment',
    r'$invokable' : 'write',
    r'$params' : [],
    r'$columns' : [
      { 'name' : _success, 'type' : 'bool', 'default' : false },
      { 'name' : _message, 'type' : 'string', 'default': '' }
    ]
  };

  SeClient client;

  LoadEquipment(String path, this.client) : super(path);

  @override
  Future<Map<String, dynamic>> onInvoke(Map<String, dynamic> params) async {
    var ret = { _success: false, _message: '' };

    var site = getSite();

    var list = await client.loadEquipment(site);
    updateCalls();
    if (list == null) {
      ret[_message] = 'Unable to load equipment.';
      return ret;
    } else {
      ret[_success] = true;
      ret[_message] = 'Success!';
    }

    var pPath = parent.path;
    var countNode = provider.getNode('$pPath/count');
    if (countNode != null) {
      countNode.updateValue(list.length);
    }
    for (var i = 0; i < list.length; i++) {
      provider.addNode('$pPath/equip_$i', EquipmentNode.definition(list[i]));
    }

    return ret;
  }
}
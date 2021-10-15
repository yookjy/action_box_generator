import 'dart:convert';

import 'package:action_box/action_box.dart';
import 'package:action_box_generator/src/models/action_meta.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

const TypeChecker _actionTypeChecker = TypeChecker.fromRuntime(Action);

class ActionMetaGenerator extends GeneratorForAnnotation<ActionConfig> {

  ActionMetaGenerator(Map options);

  @override
  dynamic generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    // Action 의 서브클래스만 어노테이션 허용
    if (!_actionTypeChecker.isSuperOf(element)) {
      return '';
    }

    final descriptorName = annotation.read('descriptorName').stringValue;
    final registerTo = annotation.read('registerTo').stringValue;

    final typeArgument = <Reference>[];
    if (element is ClassElement) {
      var supertype = element.supertype;
      if (supertype != null) {
        typeArgument.addAll(
          supertype.typeArguments.map((e) =>
            refer(e.element!.name!,
              e.element!.source?.fullName.startsWith('dart:core') == true ?
              null : e.element!.source?.fullName)));
      }
    }

    final meta = ActionMeta(
      descriptorName: descriptorName,
      registerTo: registerTo,
      typeName: element.name!,
      typeImport: element.source!.uri.toString(),
      parameterTypeName: typeArgument[0].symbol!,
      parameterTypeImport: typeArgument[0].url,
      resultTypeName: typeArgument[1].symbol!,
      resultTypeImport: typeArgument[1].url
    );

    return jsonEncode(meta);
  }
}
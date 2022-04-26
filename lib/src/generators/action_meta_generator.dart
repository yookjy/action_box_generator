import 'dart:convert';

import 'package:action_box/action_box.dart';
import 'package:action_box_generator/src/import.dart';
import 'package:action_box_generator/src/models/action_meta.dart';
import 'package:action_box_generator/src/models/type_meta.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

const TypeChecker _actionTypeChecker = TypeChecker.fromRuntime(Action);

class ActionMetaGenerator extends GeneratorForAnnotation<ActionConfig> {
  ActionMetaGenerator(Map options);

  @override
  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    // Action 의 서브클래스만 어노테이션 허용
    if (!_actionTypeChecker.isSuperOf(element)) {
      return '';
    }

    final alias = annotation.read('alias').stringValue;
    final parents = annotation
        .read('parents')
        .listValue
        .map((e) => e.toStringValue())
        .cast<String>()
        .toList();

    String? getUrl(Element? element) {
      var url = element?.source?.uri.toString();
      if (url != null) {
        if (url.startsWith(coreImport)) {
          return null;
        } else if (url.startsWith('package:action_box/')) {
          return actionBoxImport;
        }
      }
      return url;
    }

    TypeMeta toTypeMeta(DartType type) {
      var typeMeta = TypeMeta(
          name: type.element?.name ??
              type.getDisplayString(withNullability: false),
          url: getUrl(type.element),
          isNullable: type.nullabilitySuffix == NullabilitySuffix.question,
          typeArguments: []);

      if (type is InterfaceType && type.typeArguments.isNotEmpty) {
        type.typeArguments.forEach((arg) {
          typeMeta.typeArguments.add(toTypeMeta(arg));
        });
      }

      return typeMeta;
    }

    final typeMetas = <TypeMeta>[];
    if (element is ClassElement && element.supertype != null) {
      element.supertype!.typeArguments.forEach((type) {
        typeMetas.add(toTypeMeta(type));
      });
    }

    final meta = ActionMeta(
      alias: alias,
      parents: parents,
      type: TypeMeta(
          name: element.name!,
          url: element.source!.uri.toString(),
          typeArguments: []),
      parameterType: typeMetas[0],
      resultType: typeMetas[1],
    );

    return jsonEncode(meta);
  }
}

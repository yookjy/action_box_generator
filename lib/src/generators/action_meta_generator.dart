import 'dart:convert';

import 'package:action_box/action_box.dart';
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
    final parents =
        annotation.read('parents').listValue.map((e) => e.toStringValue());

    String? getUrl(ClassElement element) {
      return element.source.uri.toString().startsWith('dart:core') == true
          ? null
          : element.source.uri.toString();
    }

    TypeMeta toTypeMeta(InterfaceType type) {
      return TypeMeta(
          name: type.element.name,
          url: getUrl(type.element),
          isNullable: type.nullabilitySuffix == NullabilitySuffix.question,
          typeArguments: []);
    }

    void makeTypeMetas(
        List<DartType> types, List<TypeMeta> typeMetas, TypeMeta? generic) {
      types.cast<InterfaceType>().forEach((type) {
        if (type.typeArguments.isNotEmpty) {
          final typeMeta = generic ?? toTypeMeta(type);
          makeTypeMetas(type.typeArguments, typeMetas, typeMeta);
        } else if (generic == null) {
          typeMetas.add(toTypeMeta(type));
        } else {
          generic.typeArguments.add(toTypeMeta(type));
          typeMetas.add(generic);
        }
      });
    }

    final typeMetas = <TypeMeta>[];
    if (element is ClassElement && element.supertype != null) {
      makeTypeMetas(element.supertype!.typeArguments, typeMetas, null);
    }

    final meta = ActionMeta(
      alias: alias,
      parents: parents
          .where((p) => p != null && p.isNotEmpty)
          .cast<String>()
          .toList(),
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

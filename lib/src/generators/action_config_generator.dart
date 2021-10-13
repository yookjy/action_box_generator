import 'dart:convert';

import 'package:action_box/action_box.dart';
import 'package:action_box_generator/src/annotations/action_center_config.dart';
import 'package:action_box_generator/src/models/action_meta.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';

class ActionConfigGenerator extends GeneratorForAnnotation<ActionCenterConfig> {

  final Type actionCenterType = ActionCenter;
  final String actionCenterImport = 'package:action_box/action_box.dart';

  final Type actionDirectoryType = ActionDirectory;
  final String actionDirectoryImport = 'package:action_box/action_box.dart';

  final Type actionDescriptorType = ActionDescriptor;
  final String actionDescriptorImport = 'package:action_box/action_box.dart';

  @override
  dynamic generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) async {
    final generateForDir = annotation
        .read('generateForDir')
        .listValue
        .map((e) => e.toStringValue());

    final generateActionCenterTypeName = annotation.read('actionCenterTypeName').stringValue;
    final generateActionRootTypeName = annotation.read('actionRootTypeName').stringValue;

    final dirPattern = generateForDir.length > 1
        ? '{${generateForDir.join(',')}}'
        : '${generateForDir.first}';

    final actionMetaFiles = Glob('$dirPattern/**.action.json');
    final metaDataList = <ActionMeta>[];
    await for (final id in buildStep.findAssets(actionMetaFiles)) {
      final json = jsonDecode(await buildStep.readAsString(id));
      metaDataList.add(ActionMeta.fromJson(json));
    }

    final actionRootBuilder = ClassBuilder()
      ..name = _capitalize(generateActionRootTypeName)
      ..extend = refer(_getTypeName(actionDirectoryType), actionDirectoryImport);

    final actionDirectoriesDefinitionBuilders = <ClassBuilder>[
      actionRootBuilder
    ];

    var currentDirectoryBuilder = actionRootBuilder;
    metaDataList.forEach((meta) {
      final paths = meta.registerTo.split('.');
      ClassBuilder actionDirectoryBuilder;

      paths.forEach((directoryName) {
        final methodList = currentDirectoryBuilder.methods.build().where((m) => m.name == directoryName);
        if (methodList.isEmpty) {
          // 1. 액션 디렉토리 클래스 생성
          actionDirectoryBuilder = ClassBuilder()
          ..name = _capitalize(directoryName)
          ..extend = refer(_getTypeName(actionDirectoryType), actionDirectoryImport);

          //클래스 정의 추가
          actionDirectoriesDefinitionBuilders.add(actionDirectoryBuilder);

          final actionDirectoryRefer = refer(actionDirectoryBuilder.name!);
          // 2. 액션 디렉토리를 상위 디렉토리에 추가
          currentDirectoryBuilder.methods.add(Method((m) => m
            ..returns = actionDirectoryRefer
            ..type = MethodType.getter
            ..name = directoryName
            ..body = refer('putIfAbsentDirectory').call([
              Method((m) => m
                ..lambda = true
                ..body = actionDirectoryRefer.call([]).code
              ).closure
            ]).code
          ));

        } else {
          actionDirectoryBuilder = actionDirectoriesDefinitionBuilders
            .firstWhere((def) => def.name == _capitalize(directoryName));
        }

        if (directoryName == paths.last) {
          // 3. 액션 디렉토리에 액션 디스크립터 추가
          final actionTypeRefer = refer(meta.typeName, meta.typeImport);
          //디스크립터 추가
          actionDirectoryBuilder.methods.add(Method((m) => m
            ..returns = TypeReference((t) => t
              ..symbol = _getTypeName(actionDescriptorType)
              ..url = actionDescriptorImport
              ..types.addAll([
                actionTypeRefer,
                refer(meta.parameterTypeName, meta.parameterTypeImport),
                refer(meta.resultTypeName, meta.resultTypeImport),
              ])
            )
            ..name = meta.descriptorName
            ..type = MethodType.getter
            ..lambda = true
            ..body = refer('putIfAbsentDescriptor').call([
              literalString(meta.descriptorName),
              Method((m) => m
                ..lambda = true
                ..body = actionTypeRefer.call([]).code
                ).closure
            ]).code
          ));

          if (methodList.isEmpty) {
          }
        } else {
          currentDirectoryBuilder = actionDirectoryBuilder;
        }
      });
    });

    final generated = Library((lib) => lib
      ..body.addAll([
        ...actionDirectoriesDefinitionBuilders.map((b) => b.build()),
        Class((cls) => cls
          ..name = _capitalize(generateActionCenterTypeName)
          ..extend = TypeReference((t) => t
            ..symbol = _getTypeName(actionCenterType)
            ..url = actionCenterImport
            ..types.add(refer(actionRootBuilder.name!))
          )
          ..constructors.add(Constructor((ctr) => ctr
            ..body = refer('${_getTypeName(actionCenterType)}.setActionDirectory', actionCenterImport)
              .call([refer('${actionRootBuilder.name!}').call([])]).statement
          ))
        )
      ])
    );

    final emitter = DartEmitter.scoped();
    final formatted = DartFormatter().format('${generated.accept(emitter)}');
    return formatted;
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  String _getTypeName(Type t) {
    var typeName = t.toString();
    if (typeName.trim().endsWith('>')) {
      typeName = typeName.substring(0, typeName.indexOf('<'));
    }
    return typeName;
  }

}
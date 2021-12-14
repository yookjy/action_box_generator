import 'dart:async';
import 'dart:convert';

import 'package:action_box/action_box.dart';
import 'package:action_box_generator/src/models/action_meta.dart';
import 'package:action_box_generator/src/models/type_meta.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';

class ActionConfigGenerator extends GeneratorForAnnotation<ActionBoxConfig> {
  final Type actionBoxType = ActionBoxBase;
  final Type actionDirType = ActionDirectory;
  final Type actionDescriptorType = ActionDescriptor;
  final defaultTimeoutType = Duration;
  final streamControllerType = StreamController;
  final cacheStorageType = CacheStorage;

  final String actionBoxImport = 'package:action_box/action_box.dart';
  final asyncImport = 'dart:async';

  final errFactoryName = 'errorStreamFactory';
  final defaultTimeoutName = 'defaultTimeout';
  final cacheStoragesName = 'cacheStorages';
  final constructorName = 'shared';
  final instanceName = '_instance';
  final disposerName = 'dispose';
  final internalConstructorName = '_';

  @override
  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    final generateSourceDir = annotation
        .read('generateSourceDir')
        .listValue
        .map((e) => e.toStringValue());

    final actionBoxTypeName =
        _capitalizeTypeName(annotation.read('actionBoxType').stringValue);
    final actionRootTypeName = _makePrivateType(
        _capitalizeTypeName(annotation.read('actionRootType').stringValue));

    final dirPattern = generateSourceDir.length > 1
        ? '{${generateSourceDir.join(',')}}'
        : '${generateSourceDir.first}';

    final actionMetaFiles = Glob('$dirPattern/**.a.b.json');
    final metaDataList = <ActionMeta>[];
    await for (final id in buildStep.findAssets(actionMetaFiles)) {
      final json = jsonDecode(await buildStep.readAsString(id));
      metaDataList.add(ActionMeta.fromJson(json));
    }

    final actionRootBuilder = ClassBuilder()
      ..name = actionRootTypeName
      ..extend = refer(_getTypeName(actionDirType), actionBoxImport);

    final actionDirectoriesDefinitionBuilders = <ClassBuilder>[
      actionRootBuilder
    ];

    final inputUri = buildStep.inputId.uri;
    String? asset;
    if (inputUri.scheme == 'asset') {
      asset = inputUri.toString();
      asset = asset.substring(0, asset.lastIndexOf('/'));
    }

    metaDataList.forEach((meta) {
      var currentDirectoryBuilder = actionRootBuilder;
      meta.parents.forEach((parent) {
        ClassBuilder actionDirectoryBuilder;
        final paths = parent.split('.');

        paths.asMap().forEach((index, directoryName) {
          var directoryTypeName =
              _makePrivateType(_capitalizeTypeName(directoryName));
          final methodList = currentDirectoryBuilder.methods
              .build()
              .where((m) => m.name == directoryName);
          if (methodList.isEmpty) {
            // 1. 액션 디렉토리 클래스 생성
            while (actionDirectoriesDefinitionBuilders
                .any((dir) => dir.name == directoryTypeName)) {
              directoryTypeName = directoryTypeName + r'$';
            }

            actionDirectoryBuilder = ClassBuilder()
              ..name = directoryTypeName
              ..extend = refer(_getTypeName(actionDirType), actionBoxImport);

            //클래스 정의 추가
            actionDirectoriesDefinitionBuilders.add(actionDirectoryBuilder);

            final actionDirectoryRefer = refer(actionDirectoryBuilder.name!);
            // 2. 액션 디렉토리를 상위 디렉토리에 추가
            currentDirectoryBuilder.methods.add(Method((m) => m
              ..returns = actionDirectoryRefer
              ..type = MethodType.getter
              ..name = directoryName
              ..body = refer('putIfAbsentDirectory').call([
                literalString(directoryName),
                Method((m) => m
                  ..lambda = true
                  ..body = actionDirectoryRefer.call([]).code).closure
              ]).code));
          } else {
            actionDirectoryBuilder = actionDirectoriesDefinitionBuilders
                .firstWhere((def) => def.name == directoryTypeName);
          }

          if (index == paths.length - 1) {
            // 3. 액션 디렉토리에 액션 디스크립터 추가
            var typeImport = meta.type.url;
            if (asset?.isNotEmpty == true &&
                typeImport != null &&
                typeImport.startsWith(RegExp(asset!))) {
              typeImport = typeImport.replaceAll(RegExp(asset), '.');
            }

            TypeReference getReference(TypeMeta typeMeta) {
              var url = typeMeta.url;
              if (asset?.isNotEmpty == true &&
                  url != null &&
                  url.startsWith(asset!)) {
                url = url.replaceAll(RegExp(asset), '.');
              }

              final typeArgs = <Reference>[];
              typeMeta.typeArguments.forEach((typeArg) {
                typeArgs.add(getReference(typeArg));
              });

              return TypeReference((t) => t
                ..symbol = typeMeta.name
                ..url = url
                ..isNullable = typeMeta.isNullable
                ..types.addAll(typeArgs));
            }

            final actionTypeRefer = refer(meta.type.name, typeImport);
            //디스크립터 추가
            actionDirectoryBuilder.methods.add(Method((m) => m
              ..returns = TypeReference((t) => t
                ..symbol = _getTypeName(actionDescriptorType)
                ..url = actionBoxImport
                ..types.addAll([
                  actionTypeRefer,
                  getReference(meta.parameterType),
                  getReference(meta.resultType)
                ]))
              ..name = meta.alias
              ..type = MethodType.getter
              ..lambda = true
              ..body = refer('putIfAbsentDescriptor').call([
                literalString(meta.alias),
                Method((m) => m
                  ..lambda = true
                  ..body = actionTypeRefer.call([]).code).closure
              ]).code));
          } else {
            currentDirectoryBuilder = actionDirectoryBuilder;
          }
        });
      });
    });

    final generated = Library((lib) => lib
      ..body.addAll([
        ...actionDirectoriesDefinitionBuilders.map((b) => b.build()),
        Class((cls) => cls
          ..name = actionBoxTypeName
          ..extend = TypeReference((t) => t
            ..symbol = _getTypeName(actionBoxType)
            ..url = actionBoxImport
            ..types.add(refer(actionRootBuilder.name!)))
          ..fields.add(Field((f) => f
            ..static = true
            ..type = TypeReference((t) => t
              ..symbol = actionBoxTypeName
              ..isNullable = true)
            ..name = instanceName))
          ..constructors.addAll([
            Constructor((ctr) => ctr
              ..name = internalConstructorName
              ..requiredParameters.addAll([
                Parameter((p) => p
                  ..name = errFactoryName
                  ..type = FunctionType((f) => f
                    ..returnType = TypeReference((t) => t
                      ..symbol = '$streamControllerType'
                      ..url = asyncImport)
                    ..isNullable = true)),
                Parameter((p) => p
                  ..name = defaultTimeoutName
                  ..type = TypeReference((t) => t
                    ..symbol = '$defaultTimeoutType'
                    ..isNullable = true)),
                Parameter((p) => p
                  ..name = cacheStoragesName
                  ..type = TypeReference((t) => t
                    ..symbol = _getTypeName(List)
                    ..types.add(refer('$cacheStorageType', actionBoxImport))
                    ..isNullable = true))
              ])
              ..initializers.add(refer(Keyword.SUPER.stringValue!).call([
                Method((m) => m
                  ..lambda = true
                  ..body = Code(actionRootBuilder.name!)).closure.call([]),
              ], //positional parameters
                  {
                    '$errFactoryName': refer('$errFactoryName'),
                    '$defaultTimeoutName': refer('$defaultTimeoutName'),
                    '$cacheStoragesName': refer('$cacheStoragesName')
                  } //named parameters
                  ).code)),
            Constructor((ctr) => ctr
              ..factory = true
              ..name = constructorName
              ..optionalParameters.addAll([
                Parameter((p) => p
                  ..name = errFactoryName
                  ..named = true
                  ..type = FunctionType((f) => f
                    ..returnType = TypeReference((t) => t
                      ..symbol = '$streamControllerType'
                      ..url = asyncImport)
                    ..isNullable = true)),
                Parameter((p) => p
                  ..name = defaultTimeoutName
                  ..type = TypeReference((t) => t
                    ..symbol = '$defaultTimeoutType'
                    ..isNullable = true)),
                Parameter((p) => p
                  ..name = cacheStoragesName
                  ..type = TypeReference((t) => t
                    ..symbol = _getTypeName(List)
                    ..types.add(refer('$cacheStorageType', actionBoxImport))
                    ..isNullable = true))
              ])
              ..lambda = true
              ..body = refer(instanceName)
                  .assignNullAware(refer('$actionBoxTypeName')
                      .property(internalConstructorName)
                      .call([
                    refer(errFactoryName),
                    refer(defaultTimeoutName),
                    refer(cacheStoragesName)
                  ]))
                  .code)
          ])
          ..methods.add(Method.returnsVoid((m) => m
            ..name = disposerName
            ..annotations.add(refer('override'))
            ..body = Block((b) => b
              ..statements.addAll([
                refer(Keyword.SUPER.stringValue!)
                    .property(disposerName)
                    .call([]).statement,
                refer(instanceName)
                    .assign(refer(Keyword.NULL.stringValue!))
                    .statement
              ])))))
      ]));

    final emitter = DartEmitter.scoped(useNullSafetySyntax: true);
    final formatted = DartFormatter().format('${generated.accept(emitter)}');
    return formatted;
  }

  String _capitalizeTypeName(String s) {
    var index = s[0] != '_' ? 0 : 1;
    return s[index].toUpperCase() + s.substring(index + 1);
  }

  String _makePrivateType(String s) {
    return s[0] == '_' ? s : '_' + s;
  }

  String _getTypeName(Type t) {
    var typeName = t.toString();
    if (typeName.trim().endsWith('>')) {
      typeName = typeName.substring(0, typeName.indexOf('<'));
    }
    return typeName;
  }
}

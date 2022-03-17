import 'dart:async';
import 'dart:convert';

import 'package:action_box/action_box.dart';
import 'package:action_box_generator/src/import.dart';
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
  final Type actionErrorType = ActionError;
  final defaultTimeoutType = Duration;
  final streamControllerType = StreamController;
  final eventSinkType = EventSink;
  final cacheStorageType = CacheStorage;

  final createUniversalStreamControllerName = 'createUniversalStreamController';
  final handleCommonErrorName = 'handleCommonError';
  final defaultTimeoutName = 'defaultTimeout';
  final cacheStoragesName = 'cacheStorages';
  final constructorName = 'shared';
  final instanceName = '_instance';
  final putIfAbsentDirectoryName = 'putIfAbsentDirectory';
  final putIfAbsentDescriptorName = 'putIfAbsentDescriptor';
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

    var aliasMap = <String, String>{'': '$actionRootTypeName'};
    metaDataList
        .map((e) => e.parents)
        .expand((path) => path)
        .toSet()
        .forEach((p) {
      var split = p.split('.');
      split.asMap().forEach((index, dirName) {
        var key = split.getRange(0, index + 1).join('.');
        if (!aliasMap.containsKey(key)) {
          var clsName = _makePrivateType(_capitalizeTypeName(dirName));
          //이름이 중복되면 이름 뒤에 $를 계속 붙임
          while (aliasMap.containsValue(clsName)) {
            clsName = '$clsName\$';
          }
          aliasMap[key] = clsName;
          var actionDirectoryBuilder = ClassBuilder()
            ..name = clsName
            ..extend = refer(_getTypeName(actionDirType), actionBoxImport);
          //모든 디렉토리 정의 등록
          actionDirectoriesDefinitionBuilders.add(actionDirectoryBuilder);

          var parentBuilder = actionRootBuilder;
          if (index > 0) {
            var parent = split.getRange(0, index).join('.');
            //변경된 이름으로 디렉토리 정의에서 획득
            parentBuilder = actionDirectoriesDefinitionBuilders
                .firstWhere((e) => e.name == aliasMap[parent]);
          }

          final actionDirectoryRefer = refer(actionDirectoryBuilder.name!);
          // 2. 액션 디렉토리를 상위 디렉토리에 추가
          parentBuilder.methods.add(Method((m) => m
            ..returns = actionDirectoryRefer
            ..type = MethodType.getter
            ..name = dirName
            ..body = refer(putIfAbsentDirectoryName).call([
              literalString(dirName),
              Method((m) => m
                ..lambda = true
                ..body = actionDirectoryRefer.call([]).code).closure
            ]).code));
        }
      });
    });

    metaDataList.forEach((meta) {
      meta.parents.forEach((parent) {
        var alias = aliasMap[parent];
        var directoryBuilder = actionDirectoriesDefinitionBuilders
            .firstWhere((b) => b.name == alias);

        // 액션 디렉토리에 액션 디스크립터 추가
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
        directoryBuilder.methods.add(Method((m) => m
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
          ..body = refer(putIfAbsentDescriptorName).call([
            literalString(meta.alias),
            Method((m) => m
              ..lambda = true
              ..body = actionTypeRefer.call([]).code).closure
          ]).code));
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
                  ..name = createUniversalStreamControllerName
                  ..type = FunctionType((f) => f
                    ..returnType = TypeReference((t) => t
                      ..symbol = '$streamControllerType'
                      ..url = asyncImport)
                    ..isNullable = true)),
                Parameter((p) => p
                  ..name = handleCommonErrorName
                  ..type = FunctionType((f) => f
                    ..requiredParameters.addAll([
                      TypeReference((t) => t
                        ..symbol = '$actionErrorType'
                        ..url = actionBoxImport),
                      TypeReference((t) => t
                        ..symbol = '$eventSinkType'
                        ..url = asyncImport)
                    ])
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
                    createUniversalStreamControllerName:
                        refer(createUniversalStreamControllerName),
                    handleCommonErrorName: refer(handleCommonErrorName),
                    defaultTimeoutName: refer(defaultTimeoutName),
                    cacheStoragesName: refer(cacheStoragesName)
                  } //named parameters
                  ).code)),
            Constructor((ctr) => ctr
              ..factory = true
              ..name = constructorName
              ..optionalParameters.addAll([
                Parameter((p) => p
                  ..name = createUniversalStreamControllerName
                  ..named = true
                  ..type = FunctionType((f) => f
                    ..returnType = TypeReference((t) => t
                      ..symbol = '$streamControllerType'
                      ..url = asyncImport)
                    ..isNullable = true)),
                Parameter((p) => p
                  ..name = handleCommonErrorName
                  ..type = FunctionType((f) => f
                    ..requiredParameters.addAll([
                      TypeReference((t) => t
                        ..symbol = '$actionErrorType'
                        ..url = actionBoxImport),
                      TypeReference((t) => t
                        ..symbol = '$eventSinkType'
                        ..url = asyncImport)
                    ])
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
                    refer(createUniversalStreamControllerName),
                    refer(handleCommonErrorName),
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

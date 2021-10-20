import 'package:action_box_generator/src/models/type_meta.dart';

class ActionMeta {
  final String alias;
  final List<String> parents;

  final TypeMeta type;
  final TypeMeta parameterType;
  final TypeMeta resultType;

  const ActionMeta({
    required this.alias,
    required this.parents,
    required this.type,
    required this.parameterType,
    required this.resultType,
  });

  Map<String, dynamic> toJson() {
    // ignore: unnecessary_cast
    return {
      'alias': alias,
      'parents': parents,
      'type': type,
      'parameterType': parameterType,
      'resultType': resultType
    } as Map<String, dynamic>;
  }

  factory ActionMeta.fromJson(Map<String, dynamic> json) {
    return ActionMeta(
        alias: json['alias'],
        parents: List<String>.from(json['parents']),
        type: TypeMeta.fromJson(json['type']),
        parameterType: TypeMeta.fromJson(json['parameterType']),
        resultType: TypeMeta.fromJson(json['resultType']));
  }
}

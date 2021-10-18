import 'package:action_box_generator/src/models/type_meta.dart';

class ActionMeta {

  final String descriptorName;
  final String registerTo;

  final TypeMeta type;
  final TypeMeta parameterType;
  final TypeMeta resultType;

  const ActionMeta({
    required this.descriptorName,
    required this.registerTo,
    required this.type,
    required this.parameterType,
    required this.resultType,
  });

  Map<String, dynamic> toJson() {
    // ignore: unnecessary_cast
    return {
      'descriptorName': descriptorName,
      'registerTo': registerTo,
      'type': type,
      'parameterType': parameterType,
      'resultType': resultType
    } as Map<String, dynamic>;
  }

  factory ActionMeta.fromJson(Map<String, dynamic> json) {
    return ActionMeta(
      descriptorName: json['descriptorName'],
      registerTo: json['registerTo'],
      type: TypeMeta.fromJson(json['type']),
      parameterType: TypeMeta.fromJson(json['parameterType']),
      resultType: TypeMeta.fromJson(json['resultType'])
    );
  }

}
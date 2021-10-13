class ActionMeta {

  final String descriptorName;
  final String registerTo;

  final String typeName;
  final String typeImport;

  final String parameterTypeName;
  final String? parameterTypeImport;

  final String resultTypeName;
  final String? resultTypeImport;

  const ActionMeta({
    required this.descriptorName,
    required this.registerTo,
    required this.typeName,
    required this.typeImport,
    required this.parameterTypeName,
    required this.parameterTypeImport,
    required this.resultTypeName,
    required this.resultTypeImport,
  });

  Map<String, dynamic> toJson() {
    // ignore: unnecessary_cast
    return {
      'descriptorName': descriptorName,
      'registerTo': registerTo,
      'typeName': typeName,
      'typeImport': typeImport,
      'parameterTypeName': parameterTypeName,
      'parameterTypeImport': parameterTypeImport,
      'resultTypeName': resultTypeName,
      'resultTypeImport': resultTypeImport,
    } as Map<String, dynamic>;
  }

  factory ActionMeta.fromJson(Map<String, dynamic> json) {
    return ActionMeta(
      descriptorName: json['descriptorName'],
      registerTo: json['registerTo'],
      typeName: json['typeName'],
      typeImport: json['typeImport'],
      parameterTypeName: json['parameterTypeName'],
      parameterTypeImport: json['parameterTypeImport'],
      resultTypeName: json['resultTypeName'],
      resultTypeImport: json['resultTypeImport'],
    );
  }

}
class TypeMeta {
  final String name;
  final String? url;
  final bool isNullable;
  final List<TypeMeta> typeArguments;

  TypeMeta({
    required this.name,
    this.url,
    this.isNullable = false,
    required this.typeArguments,
  });

  Map<String, dynamic> toJson() {
    // ignore: unnecessary_cast
    return {
      'name': name,
      'url': url,
      'isNullable': isNullable,
      'typeArguments': typeArguments
    } as Map<String, dynamic>;
  }

  factory TypeMeta.fromJson(Map<String, dynamic> json) {
    final list = json['typeArguments'] as List;
    return TypeMeta(
      name: json['name'],
      url: json['url'],
      isNullable: json['isNullable'],
      typeArguments: list.map((e) => TypeMeta.fromJson(e)).toList(),
    );
  }
}
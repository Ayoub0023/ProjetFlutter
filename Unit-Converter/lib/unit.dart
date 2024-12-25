// Required for ColorSwatch

class Unit {
  final String name;
  final double conversion;

  const Unit({
    required this.name, // Use `required` instead of @required
    required this.conversion, // Use `required` instead of @required
  });

  Unit.fromJson(Map<String, dynamic> jsonMap)
      : assert(jsonMap['name'] != null),
        assert(jsonMap['conversion'] != null),
        name = jsonMap['name'],
        conversion = jsonMap['conversion'].toDouble();
}

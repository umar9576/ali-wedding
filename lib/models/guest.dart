class Guest {
  const Guest({
    required this.id,
    required this.prefix,
    required this.name,
    required this.searchableText,
  });

  final String id;
  final String prefix;
  final String name;
  final String searchableText;

  String get displayName => '$prefix $name'.trim();
}

enum ConcertEditFailureKind {
  invalid,
  forbidden,
  authentication,
  missing,
  conflict,
  uncertain,
}

class ConcertEditFailure implements Exception {
  const ConcertEditFailure(this.kind, {this.fields = const {}});

  final ConcertEditFailureKind kind;
  final Map<String, String> fields;
}

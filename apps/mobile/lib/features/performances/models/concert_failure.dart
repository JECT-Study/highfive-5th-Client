enum ConcertFailureKind {
  rejected,
  forbidden,
  authentication,
  notSent,
  uncertain,
}

class ConcertFailure implements Exception {
  const ConcertFailure(this.kind, {this.fields = const {}});

  final ConcertFailureKind kind;
  final Map<String, String> fields;
}

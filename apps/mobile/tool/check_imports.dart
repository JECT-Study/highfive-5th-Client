// lib/ 안 import·export가 docs/mobile-architecture.md 2절의 방향 규칙을 지키는지 검사한다.
// 실행: fvm dart run tool/check_imports.dart   (위반이 있으면 종료 코드 1)
import 'dart:io';

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('lib/ 폴더가 없다. apps/mobile 에서 실행한다.');
    exit(2);
  }
  final files = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  final violations = <String>[];
  for (final file in files) {
    final from = _libRelative(file.path);
    for (final v in findViolations(from, file.readAsStringSync())) {
      violations.add('${file.path}:${v.line}  → ${v.target}\n    ${v.reason}');
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('import 방향 OK (${files.length} files)');
    return;
  }
  stderr.writeln(
    'import 방향 위반 ${violations.length}건 (docs/mobile-architecture.md 2절)',
  );
  violations.forEach(stderr.writeln);
  exit(1);
}

class Violation {
  const Violation(this.line, this.target, this.reason);

  final int line;
  final String target;
  final String reason;
}

/// `import`·`export` 지시문 하나 (키워드부터 `;`까지, 여러 줄 가능).
final _directive = RegExp(r'^[ \t]*(?:import|export)\b[^;]*;', multiLine: true);

/// 지시문 안의 모든 URI. 조건부 import의 `if (...) 'uri'`도 포함한다.
final _uri = RegExp(r'''(['"])(.*?)\1''');

/// [from](lib 기준 경로) 파일의 [source]에서 방향 규칙 위반을 찾는다.
List<Violation> findViolations(String from, String source) {
  final code = _blankComments(source);
  final found = <Violation>[];
  for (final d in _directive.allMatches(code)) {
    final line = '\n'.allMatches(code.substring(0, d.start)).length + 1;
    for (final u in _uri.allMatches(d.group(0)!)) {
      final uri = u.group(2)!;
      final to = _resolve(from, uri);
      final reason = to == null
          ? _packageViolation(from, uri)
          : _violation(from, to);
      if (reason != null) found.add(Violation(line, to ?? uri, reason));
    }
  }
  return found;
}

/// 주석을 같은 길이의 공백으로 바꾼다(줄 번호 유지). 따옴표 안의 `//`·`/*`는 건드리지 않는다.
String _blankComments(String s) {
  final b = StringBuffer();
  String? quote;
  var i = 0;
  while (i < s.length) {
    final c = s[i];
    if (quote != null) {
      if (c == r'\' && i + 1 < s.length) {
        b.write(s.substring(i, i + 2));
        i += 2;
        continue;
      }
      if (c == quote) quote = null;
      b.write(c);
      i++;
    } else if (c == "'" || c == '"') {
      quote = c;
      b.write(c);
      i++;
    } else if (s.startsWith('//', i)) {
      final end = s.indexOf('\n', i);
      final stop = end == -1 ? s.length : end;
      b.write(' ' * (stop - i));
      i = stop;
    } else if (s.startsWith('/*', i)) {
      final end = s.indexOf('*/', i + 2);
      final stop = end == -1 ? s.length : end + 2;
      b.write(s.substring(i, stop).replaceAll(RegExp(r'[^\n]'), ' '));
      i = stop;
    } else {
      b.write(c);
      i++;
    }
  }
  return b.toString();
}

String _libRelative(String path) {
  final idx = path.indexOf('lib/');
  return path.substring(idx + 4).replaceAll(r'\', '/');
}

/// `package:highfive/...` 와 상대 경로만 lib 기준 경로로 바꾼다. 그 외(dart:, 다른 패키지)는 null.
String? _resolve(String from, String uri) {
  const pkg = 'package:highfive/';
  if (uri.startsWith(pkg)) return uri.substring(pkg.length);
  if (uri.contains(':')) return null;
  final parts = from.split('/')..removeLast();
  for (final seg in uri.split('/')) {
    if (seg == '..') {
      if (parts.isEmpty) return null;
      parts.removeLast();
    } else if (seg != '.') {
      parts.add(seg);
    }
  }
  return parts.join('/');
}

/// 외부 패키지 규칙: models는 flutter를 모른다.
String? _packageViolation(String from, String uri) {
  final f = _Layer.of(from);
  final isFlutter = uri.startsWith('package:flutter/') || uri == 'dart:ui';
  if (isFlutter && f != null && f.name == 'features' && f.sub == 'models') {
    return 'models는 flutter를 import하지 않는다 (패키지만)';
  }
  return null;
}

String? _violation(String from, String to) {
  final f = _Layer.of(from);
  final t = _Layer.of(to);
  if (f == null || t == null) return null;

  return switch (f.name) {
    'core' when t.name != 'core' =>
      'core는 ${t.name}을 import하지 않는다 (core는 맨 아래층)',
    'shared' when t.name == 'app' || t.name == 'features' =>
      'shared는 ${t.name}을 import하지 않는다',
    'features' => _featureViolation(f, t),
    _ => null,
  };
}

/// 같은 기능 안에서 각 층이 import할 수 있는 층 (mobile-architecture 2절의 화살표).
const _allowedInFeature = <String, Set<String>>{
  'presentation/views': {
    'presentation/views',
    'presentation/widgets',
    'presentation/view_models',
    'presentation/providers',
    'models',
  },
  'presentation/widgets': {
    'presentation/widgets',
    'presentation/view_models',
    'presentation/providers',
    'models',
  },
  'presentation/view_models': {
    'presentation/view_models',
    'presentation/providers',
    'data/repositories',
    'models',
  },
  'presentation/providers': {
    'presentation/providers',
    'presentation/view_models',
    'data/repositories',
    'data/services',
    'models',
  },
  'data/repositories': {
    'data/repositories',
    'data/services',
    'data/dto',
    'models',
  },
  'data/services': {'data/services', 'data/dto'},
  'data/dto': {'data/dto', 'models'},
  'models': {'models'},
};

/// 다른 기능에서 가져다 쓸 수 있는 계약.
const _crossFeatureContracts = {'data/repositories', 'models'};

String? _featureViolation(_Layer f, _Layer t) {
  if (t.name == 'app') {
    return 'features는 app을 import하지 않는다 (연결 Provider는 presentation/providers 에)';
  }
  if (f.sub == 'models' && t.name != 'features') {
    return 'models는 패키지만 import한다';
  }
  if (t.name != 'features') return null;
  if (f.feature != t.feature) {
    if (_crossFeatureContracts.contains(t.sub)) return null;
    return '다른 기능은 data/repositories·models만 import한다 (${t.sub} 금지)';
  }
  final allowed = _allowedInFeature[f.sub];
  if (allowed != null) {
    return allowed.contains(t.sub) ? null : '${f.sub}는 ${t.sub}를 import하지 않는다';
  }
  if (f.sub.startsWith('data') && t.sub.startsWith('presentation')) {
    return 'data는 presentation을 모른다';
  }
  return null;
}

class _Layer {
  const _Layer(this.name, {this.feature = '', this.sub = ''});

  final String name;
  final String feature;
  final String sub;

  static _Layer? of(String path) {
    final parts = path.split('/');
    switch (parts.first) {
      case 'app':
      case 'core':
      case 'shared':
        return _Layer(parts.first);
      case 'features':
        if (parts.length < 3) return null;
        final layered = parts[2] == 'data' || parts[2] == 'presentation';
        final sub = layered && parts.length > 4
            ? '${parts[2]}/${parts[3]}'
            : parts[2];
        return _Layer('features', feature: parts[1], sub: sub);
      default:
        return null;
    }
  }
}

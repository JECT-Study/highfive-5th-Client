import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/di.dart';
import 'app/env.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDi(AppEnv.fromEnvironment());
  runApp(const ProviderScope(child: HighfiveApp()));
}

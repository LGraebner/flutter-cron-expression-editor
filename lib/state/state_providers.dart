import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cron_expression_editor/state/cron_expression_notifier.dart';

final cronExpressionProvider = StateNotifierProvider((ref) => CronExpressionNotifier());
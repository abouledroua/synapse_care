import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/timeout_controller.dart';
import '../../core/constant/layout_constants.dart';
import '../../l10n/app_localizations.dart';
import '../widget/brand_header.dart';
import '../widget/app_background.dart';

class TimeoutPage extends StatefulWidget {
  const TimeoutPage({super.key});

  @override
  State<TimeoutPage> createState() => _TimeoutPageState();
}

class _TimeoutPageState extends State<TimeoutPage> {
  final TimeoutController _controller = TimeoutController();

  @override
  void initState() {
    super.initState();
    _controller.start(
      duration: const Duration(seconds: 5),
      onTimeout: () {
        if (mounted) {
          context.go('/auth/login');
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= LayoutConstants.wideBreakpoint;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BrandHeader(isWide: isWide),
                      const SizedBox(height: 24),
                      Icon(Icons.timer_off_outlined, size: 54, color: scheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        l10n.timeoutTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isWide ? 26 : 22,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.timeoutBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

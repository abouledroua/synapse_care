import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../controller/cabinet_create_controller.dart';
import '../../core/constant/layout_constants.dart';
import '../../services/cabinet_service.dart';
import '../widget/cabinet_create_form.dart';
import '../widget/app_background.dart';

class CabinetCreatePage extends StatefulWidget {
  const CabinetCreatePage({super.key});

  @override
  State<CabinetCreatePage> createState() => _CabinetCreatePageState();
}

class _CabinetCreatePageState extends State<CabinetCreatePage> {
  final CabinetCreateController _controller = CabinetCreateController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(CabinetCreatePayload payload) async {
    final createResponse = await _controller.submit(
      name: payload.name,
      specialty: payload.specialty,
      address: payload.address,
      phone: payload.phone,
      nationalitePatientDefaut: payload.nationalitePatientDefaut,
      defaultCurrency: payload.defaultCurrency,
      photoBytes: payload.photoBytes,
      photoExtension: payload.photoExtension,
    );

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (createResponse.result == CabinetCreateResult.success) {
      messenger.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.cabinetAddSuccess)));
      context.go('/cabinet/select');
      return;
    }
    if (_controller.nameAlreadyExists) {
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.cabinetAddFailed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= LayoutConstants.wideBreakpoint;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Scaffold(
        body: Stack(
          children: [
            const AppBackground(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 120),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: _controller.submitting ? null : () => context.pop(true),
                            icon: const Icon(Icons.arrow_back),
                            color: scheme.primary,
                          ),
                        ),
                        Text(
                          l10n.cabinetCreateTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isWide ? 26 : 22,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (_controller.submitting) ...[
                          const LinearProgressIndicator(),
                          const SizedBox(height: 12),
                        ],
                        CabinetCreateForm(
                          l10n: l10n,
                          scheme: scheme,
                          onSubmit: _handleSubmit,
                          isSubmitting: _controller.submitting,
                          nameErrorText: _controller.nameAlreadyExists ? l10n.cabinetAddExists : null,
                          onNameChanged: (_) => _controller.clearNameError(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

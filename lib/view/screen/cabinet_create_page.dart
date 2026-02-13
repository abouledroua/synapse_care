import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
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
  final CabinetService _service = CabinetService();
  bool _submitting = false;
  String? _nameServerError;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleSubmit(CabinetCreatePayload payload) async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _nameServerError = null;
    });

    final photoBase64 = payload.photoBytes == null ? null : base64Encode(payload.photoBytes!);
    final createResponse = await _service.createCabinet(
      name: payload.name,
      specialty: payload.specialty,
      address: payload.address,
      phone: payload.phone,
      nationalitePatientDefaut: payload.nationalitePatientDefaut,
      defaultCurrency: payload.defaultCurrency,
      photoBase64: photoBase64,
      photoExtension: payload.photoExtension,
    );

    if (!mounted) return;
    setState(() {
      _submitting = false;
    });

    final messenger = ScaffoldMessenger.of(context);
    if (createResponse.result == CabinetCreateResult.success) {
      messenger.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.cabinetAddSuccess)));
      context.go('/cabinet/select');
      return;
    }
    if (createResponse.result == CabinetCreateResult.exists) {
      setState(() {
        _nameServerError = AppLocalizations.of(context)!.cabinetAddExists;
      });
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

    return Scaffold(
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => context.pop(true),
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
                      CabinetCreateForm(
                        l10n: l10n,
                        scheme: scheme,
                        onSubmit: _handleSubmit,
                        nameErrorText: _nameServerError,
                        onNameChanged: (_) {
                          if (_nameServerError != null) {
                            setState(() {
                              _nameServerError = null;
                            });
                          }
                        },
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

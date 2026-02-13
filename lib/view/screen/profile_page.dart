import 'package:flutter/material.dart';

import '../../controller/auth_controller.dart';
import '../../core/config/api_config.dart';
import '../../l10n/app_localizations.dart';
import '../widget/app_background.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final user = AuthController.globalUser;
    final clinic = AuthController.globalClinic;
    final fullName = (user?['fullname'] ?? '').toString().trim();
    final email = (user?['email'] ?? '').toString().trim();
    final phone = (user?['phone'] ?? '').toString().trim();
    final specialty = (user?['speciality'] ?? user?['specialty'] ?? '').toString().trim();
    final clinicName = (clinic?['nom_cabinet'] ?? '').toString().trim();
    final photoFile = (user?['photo_url'] ?? '').toString();
    final photoUrl = photoFile.isEmpty ? null : '${ApiConfig.resolveBaseUrl()}/photos/$photoFile';

    return Scaffold(
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeMenuProfile,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: scheme.primary.withValues(alpha: 0.5), width: 2),
                            boxShadow: const [
                              BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 10)),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 56,
                            backgroundColor: scheme.primary.withValues(alpha: 0.15),
                            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                            child: photoUrl == null
                                ? Icon(Icons.person_outline, size: 56, color: scheme.primary)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          fullName.isEmpty ? l10n.patientHeaderFullName : fullName,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (specialty.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            specialty,
                            style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.surface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 10))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileInfoRow(label: l10n.profileFullNameLabel, value: fullName),
                        _ProfileInfoRow(label: l10n.profileEmailLabel, value: email),
                        _ProfileInfoRow(label: l10n.profilePhoneLabel, value: phone),
                        _ProfileInfoRow(label: l10n.profileSpecialtyLabel, value: specialty),
                        _ProfileInfoRow(label: l10n.profileClinicLabel, value: clinicName),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final displayValue = value.trim().isEmpty ? '—' : value.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.65),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

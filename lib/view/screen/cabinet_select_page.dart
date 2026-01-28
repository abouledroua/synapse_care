import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../controller/auth_controller.dart';
import '../../l10n/app_localizations.dart';
import '../widget/synapse_background.dart';

class CabinetSelectPage extends StatefulWidget {
  const CabinetSelectPage({super.key});

  @override
  State<CabinetSelectPage> createState() => _CabinetSelectPageState();
}

class _CabinetSelectPageState extends State<CabinetSelectPage> {
  late final Future<List<Map<String, dynamic>>> _cabinetFuture;

  @override
  void initState() {
    super.initState();
    _cabinetFuture = _fetchCabinets();
  }

  Future<List<Map<String, dynamic>>> _fetchCabinets() async {
    final userId = AuthController.globalUserId;
    if (userId == null) return [];
    final baseUrl = AuthController.resolveApiBaseUrl();
    final uri = Uri.parse('$baseUrl/cabinet/by-user/$userId');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load cabinets');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];
    return decoded.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 720;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          const SynapseBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.cabinetSelectTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isWide ? 26 : 22,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.cabinetSelectBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/cabinet/search'),
                          icon: const Icon(Icons.search_rounded),
                          label: Text(l10n.cabinetSelectFind),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: scheme.primary.withValues(alpha: 0.6)),
                            foregroundColor: scheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Divider(color: scheme.onSurfaceVariant.withValues(alpha: 0.2)),
                      const SizedBox(height: 10),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _cabinetFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                l10n.loginNetworkError,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: scheme.error),
                              ),
                            );
                          }

                          final cabinets = snapshot.data ?? [];
                          if (cabinets.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                l10n.cabinetSelectEmpty,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cabinets.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = cabinets[index];
                              final name = (item['nom_cabinet'] ?? '').toString();
                              final specialty = (item['specialite_cabinet'] ?? '').toString();
                              final photoFile = (item['photo_url'] ?? '').toString();
                              final baseUrl = AuthController.resolveApiBaseUrl();
                              final imageUrl = photoFile.isEmpty
                                  ? null
                                  : '$baseUrl/IMAGES/Cabinets/$photoFile';
                              return _CabinetCard(
                                name: name.isEmpty ? l10n.cabinetSelectUnnamed : name,
                                specialty: specialty.isEmpty ? l10n.cabinetSelectSampleSpecialty : specialty,
                                imageUrl: imageUrl,
                                onTap: () => context.push('/cabinet/search'),
                              );
                            },
                          );
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

class _CabinetCard extends StatelessWidget {
  const _CabinetCard({
    required this.name,
    required this.specialty,
    required this.onTap,
    this.imageUrl,
  });

  final String name;
  final String specialty;
  final VoidCallback onTap;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 10))],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: scheme.primary.withValues(alpha: 0.15),
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
              child: imageUrl == null
                  ? Icon(Icons.local_hospital_outlined, color: scheme.primary)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialty,
                    style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: scheme.primary.withValues(alpha: 0.8)),
          ],
        ),
      ),
    );
  }
}

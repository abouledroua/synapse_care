import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../controller/auth_controller.dart';
import '../../l10n/app_localizations.dart';
import '../widget/input_card.dart';
import '../widget/synapse_background.dart';

class CabinetSearchPage extends StatefulWidget {
  const CabinetSearchPage({super.key});

  @override
  State<CabinetSearchPage> createState() => _CabinetSearchPageState();
}

class _CabinetSearchPageState extends State<CabinetSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _results = [];
  int? _submittingId;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _search('');
  }

  Future<void> _search(String value) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final query = value.trim();
      setState(() {
        _loading = true;
        _error = null;
      });

      final baseUrl = AuthController.resolveApiBaseUrl();
      final uri = Uri.parse('$baseUrl/cabinet/search?q=${Uri.encodeQueryComponent(query)}');
      try {
        final response = await http.get(uri);
        if (!mounted) return;
        if (response.statusCode != 200) {
          setState(() {
            _error = 'error';
            _loading = false;
          });
          return;
        }
        final decoded = jsonDecode(response.body);
        final items = decoded is List
            ? decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
            : <Map<String, dynamic>>[];
        setState(() {
          _results = items;
          _loading = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _error = 'error';
          _loading = false;
        });
      }
    });
  }

  Future<void> _assignCabinet(int cabinetId) async {
    final userId = AuthController.globalUserId;
    if (userId == null) {
      setState(() {
        _error = 'error';
      });
      return;
    }

    setState(() => _submittingId = cabinetId);
    final baseUrl = AuthController.resolveApiBaseUrl();
    final uri = Uri.parse('$baseUrl/cabinet/assign');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_user': userId,
          'id_cabinet': cabinetId,
          'type_access': 1,
          'etat': 1,
        }),
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      if (response.statusCode == 201) {
        messenger.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.cabinetAddSuccess)));
        context.pop();
      } else if (response.statusCode == 409) {
        messenger.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.cabinetAddExists)));
      } else {
        messenger.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.cabinetAddFailed)));
      }
    } catch (_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.loginNetworkError)));
    } finally {
      if (mounted) setState(() => _submittingId = null);
    }
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
                        l10n.cabinetSearchTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isWide ? 26 : 22,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 18),
                      InputCard(
                        icon: Icons.search,
                        hintText: l10n.cabinetSearchHint,
                        keyboardType: TextInputType.text,
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onChanged: _search,
                        onSubmitted: _search,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.cabinetSearchHelper,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant.withValues(alpha: 0.65)),
                      ),
                      const SizedBox(height: 18),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(),
                        )
                      else if (_error != null)
                        Text(
                          l10n.loginNetworkError,
                          style: TextStyle(color: scheme.error),
                        )
                      else if (_searchController.text.trim().isNotEmpty && _results.isEmpty)
                        Text(
                          l10n.cabinetSearchEmpty,
                          style: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _results.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = _results[index];
                            final name = (item['nom_cabinet'] ?? '').toString();
                            final specialty = (item['specialite_cabinet'] ?? '').toString();
                            final address = (item['adresse_cabinet'] ?? '').toString();
                            final photoFile = (item['photo_url'] ?? '').toString();
                            final cabinetId = int.tryParse('${item['id_cabinet'] ?? ''}');
                            final baseUrl = AuthController.resolveApiBaseUrl();
                            final imageUrl = photoFile.isEmpty
                                ? null
                                : '$baseUrl/IMAGES/Cabinets/$photoFile';
                            return InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: cabinetId == null || _submittingId == cabinetId
                                  ? null
                                  : () => _assignCabinet(cabinetId),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                decoration: BoxDecoration(
                                  color: scheme.surface.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 10)),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 32,
                                      backgroundColor: scheme.primary.withValues(alpha: 0.15),
                                      backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
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
                                            name.isEmpty ? l10n.cabinetSelectUnnamed : name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: scheme.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            specialty.isEmpty ? l10n.cabinetSelectSampleSpecialty : specialty,
                                            style: TextStyle(
                                              color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                                              fontSize: 13,
                                            ),
                                          ),
                                          if (address.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              address,
                                              style: TextStyle(
                                                color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (_submittingId == cabinetId)
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: scheme.primary,
                                        ),
                                      )
                                    else
                                      Icon(Icons.add, color: scheme.primary.withValues(alpha: 0.8)),
                                  ],
                                ),
                              ),
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

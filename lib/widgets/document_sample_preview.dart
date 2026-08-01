import 'package:flutter/material.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/models/document.dart';

enum _SampleTemplate { idCard, certificate, photo, marksheet }

const Map<String, _SampleTemplate> _templateFor = {
  'nid_copy': _SampleTemplate.idCard,
  'nid_birth_certificate': _SampleTemplate.idCard,
  'ssc_registration_card': _SampleTemplate.idCard,
  'ssc_admit_card': _SampleTemplate.idCard,
  'hsc_registration_card': _SampleTemplate.idCard,
  'hsc_admit_card': _SampleTemplate.idCard,
  'income_certificate': _SampleTemplate.certificate,
  'agricultural_certificate': _SampleTemplate.certificate,
  'union_paurosova_certificate': _SampleTemplate.certificate,
  'land_ownership': _SampleTemplate.certificate,
  'ward_union_certificate': _SampleTemplate.certificate,
  'ssc_certificate': _SampleTemplate.certificate,
  'hsc_certificate': _SampleTemplate.certificate,
  'recent_photo': _SampleTemplate.photo,
  'ssc_marksheet': _SampleTemplate.marksheet,
  'hsc_marksheet': _SampleTemplate.marksheet,
};

/// Shows an illustrative sample layout for [docType] so a citizen unsure
/// what a required document looks like can confirm before uploading.
void showDocumentSample(BuildContext context, String docType) {
  final template = _templateFor[docType] ?? _SampleTemplate.certificate;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DocumentSampleSheet(docType: docType, template: template),
  );
}

class _DocumentSampleSheet extends StatelessWidget {
  const _DocumentSampleSheet({required this.docType, required this.template});

  final String docType;
  final _SampleTemplate template;

  String _hintKey() {
    switch (template) {
      case _SampleTemplate.idCard:
        return 'document_sample_hint_id_card';
      case _SampleTemplate.certificate:
        return 'document_sample_hint_certificate';
      case _SampleTemplate.photo:
        return 'document_sample_hint_photo';
      case _SampleTemplate.marksheet:
        return 'document_sample_hint_marksheet';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        decoration: const BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.trsp('document_sample_sheet_title', {
                  'name': documentTypeLabel(docType),
                }),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Center(child: _SampleArt(template: template)),
              const SizedBox(height: 16),
              Text(
                context.trs(_hintKey()),
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.trs('close_action')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SampleArt extends StatelessWidget {
  const _SampleArt({required this.template});

  final _SampleTemplate template;

  @override
  Widget build(BuildContext context) {
    switch (template) {
      case _SampleTemplate.idCard:
        return const _IdCardArt();
      case _SampleTemplate.certificate:
        return const _CertificateArt();
      case _SampleTemplate.photo:
        return const _PhotoArt();
      case _SampleTemplate.marksheet:
        return const _MarksheetArt();
    }
  }
}

Widget _line({double width = double.infinity, double height = 8}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppTheme.divider,
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

class _SampleBadge extends StatelessWidget {
  const _SampleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        context.trs('document_sample_badge'),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _IdCardArt extends StatelessWidget {
  const _IdCardArt();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.surfaceLight, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _line(width: 90, height: 9),
                const Spacer(),
                const _SampleBadge(),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppTheme.textTertiary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _line(width: 120),
                        _line(width: 90),
                        _line(width: 140),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertificateArt extends StatelessWidget {
  const _CertificateArt();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.75,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.inputBorder),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.account_balance_rounded,
                  color: AppTheme.textTertiary,
                  size: 20,
                ),
                const _SampleBadge(),
              ],
            ),
            const SizedBox(height: 6),
            Center(child: _line(width: 130, height: 9)),
            const SizedBox(height: 4),
            Center(child: _line(width: 80)),
            const SizedBox(height: 18),
            for (final w in [double.infinity, 220.0, double.infinity, 180.0, double.infinity, 150.0]) ...[
              _line(width: w),
              const SizedBox(height: 8),
            ],
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _line(width: 70),
                const Spacer(),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.textTertiary,
                      width: 1.4,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.approval_rounded,
                    size: 20,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoArt extends StatelessWidget {
  const _PhotoArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: AspectRatio(
        aspectRatio: 0.78,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.inputBorder),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.person_rounded,
                size: 76,
                color: AppTheme.textTertiary,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: const _SampleBadge(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarksheetArt extends StatelessWidget {
  const _MarksheetArt();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.75,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.inputBorder),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.fact_check_rounded,
                  color: AppTheme.textTertiary,
                  size: 20,
                ),
                const _SampleBadge(),
              ],
            ),
            const SizedBox(height: 6),
            Center(child: _line(width: 130, height: 9)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(flex: 2, child: _line(height: 10)),
                const SizedBox(width: 8),
                Expanded(child: _line(height: 10)),
              ],
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < 5; i++) ...[
              Row(
                children: [
                  Expanded(flex: 2, child: _line(width: 90 + (i * 6.0))),
                  const SizedBox(width: 8),
                  Expanded(child: _line(width: 30)),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

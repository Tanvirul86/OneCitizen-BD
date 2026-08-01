import 'package:flutter/material.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/models/document.dart';

/// Illustrative "what should this document look like" previews shown when a
/// citizen taps a requirement in the apply-for-card flow. Content here is
/// fabricated placeholder data (clearly watermarked SAMPLE/নমুনা) — swap the
/// `_idCardContent` / `_certificateContent` / `_marksheetContent` entries for
/// `Image.asset(...)` renders of real sample documents once those are
/// available, without touching the call sites in apply_card_screen.dart.

enum _SampleTemplate { idCard, certificate, photo, marksheet }

/// Document types with a real sample image asset — rendered in place of the
/// vector mockup below. Add more entries here as real sample scans/photos
/// become available.
const Map<String, String> _imageAssetFor = {
  'nid_copy': 'assets/images/samples/NID.jpeg',
  'nid_birth_certificate': 'assets/images/samples/birth.jpeg',
  'ssc_registration_card': 'assets/images/samples/ssc_reg.jpeg',
  'ssc_admit_card': 'assets/images/samples/ssc_admit.jpeg',
  'ssc_certificate': 'assets/images/samples/ssc_certi.jpeg',
  'hsc_registration_card': 'assets/images/samples/hsc_reg.jpeg',
  'hsc_admit_card': 'assets/images/samples/hsc_admit.jpeg',
  'hsc_certificate': 'assets/images/samples/hsc_certi.jpeg',
  'agricultural_certificate': 'assets/images/samples/agriculture.jpeg',
  'income_certificate': 'assets/images/samples/income.jpeg',
  'union_paurosova_certificate': 'assets/images/samples/union_parishad.jpeg',
};

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

class _IdCardContent {
  const _IdCardContent({
    required this.title,
    required this.name,
    required this.idLabel,
    required this.idValue,
    required this.subLabel,
    required this.subValue,
  });

  final String title;
  final String name;
  final String idLabel;
  final String idValue;
  final String subLabel;
  final String subValue;
}

const Map<String, _IdCardContent> _idCardContent = {
  'nid_copy': _IdCardContent(
    title: 'জাতীয় পরিচয়পত্র',
    name: 'মোঃ করিম উদ্দিন',
    idLabel: 'NID No',
    idValue: '১২৩৪ ৫৬৭৮ ৯০১২',
    subLabel: 'জন্ম তারিখ',
    subValue: '০১ জানুয়ারি ১৯৯০',
  ),
  'nid_birth_certificate': _IdCardContent(
    title: 'জন্ম নিবন্ধন সনদ',
    name: 'মোঃ করিম উদ্দিন',
    idLabel: 'জন্ম নিবন্ধন নং',
    idValue: '২০০৫৩৩৩৩৩৩৩৩৩৩৩',
    subLabel: 'জন্ম তারিখ',
    subValue: '০১ জানুয়ারি ২০০৫',
  ),
  'ssc_registration_card': _IdCardContent(
    title: 'এসএসসি রেজিস্ট্রেশন কার্ড',
    name: 'মোঃ করিম উদ্দিন',
    idLabel: 'রেজিস্ট্রেশন নং',
    idValue: '১২৩৪৫৬৭৮৯০',
    subLabel: 'বোর্ড',
    subValue: 'ঢাকা',
  ),
  'ssc_admit_card': _IdCardContent(
    title: 'এসএসসি প্রবেশপত্র',
    name: 'মোঃ করিম উদ্দিন',
    idLabel: 'রোল নং',
    idValue: '১২৩৪৫৬',
    subLabel: 'সেশন',
    subValue: '২০২৪',
  ),
  'hsc_registration_card': _IdCardContent(
    title: 'এইচএসসি রেজিস্ট্রেশন কার্ড',
    name: 'মোঃ করিম উদ্দিন',
    idLabel: 'রেজিস্ট্রেশন নং',
    idValue: '৯৮৭৬৫৪৩২১০',
    subLabel: 'বোর্ড',
    subValue: 'ঢাকা',
  ),
  'hsc_admit_card': _IdCardContent(
    title: 'এইচএসসি প্রবেশপত্র',
    name: 'মোঃ করিম উদ্দিন',
    idLabel: 'রোল নং',
    idValue: '৬৫৪৩২১',
    subLabel: 'সেশন',
    subValue: '২০২৪',
  ),
};

class _CertificateContent {
  const _CertificateContent({
    required this.issuer,
    required this.title,
    required this.body,
    required this.signerLabel,
  });

  final String issuer;
  final String title;
  final List<String> body;
  final String signerLabel;
}

const Map<String, _CertificateContent> _certificateContent = {
  'income_certificate': _CertificateContent(
    issuer: 'ইউনিয়ন পরিষদ কার্যালয়',
    title: 'আয়ের সনদপত্র',
    body: [
      'এই মর্মে প্রত্যয়ন করা যাইতেছে যে,',
      'জনাব মোঃ করিম উদ্দিন এর বার্ষিক আয়',
      'আনুমানিক ৳ ৮০,০০০ (আশি হাজার) মাত্র।',
    ],
    signerLabel: 'চেয়ারম্যান',
  ),
  'agricultural_certificate': _CertificateContent(
    issuer: 'কৃষি সম্প্রসারণ অধিদপ্তর',
    title: 'কৃষি প্রত্যয়নপত্র',
    body: [
      'প্রত্যয়ন করা যাইতেছে যে, জনাব মোঃ করিম',
      'উদ্দিন একজন নিবন্ধিত কৃষক এবং তাহার',
      'জমির পরিমাণ আনুমানিক ১.৫০ একর।',
    ],
    signerLabel: 'কৃষি কর্মকর্তা',
  ),
  'union_paurosova_certificate': _CertificateContent(
    issuer: 'ইউনিয়ন পরিষদ / পৌরসভা কার্যালয়',
    title: 'বাসিন্দা সনদপত্র',
    body: [
      'প্রত্যয়ন করা যাইতেছে যে, জনাব মোঃ করিম',
      'উদ্দিন এই ইউনিয়ন/পৌরসভার একজন স্থায়ী',
      'বাসিন্দা।',
    ],
    signerLabel: 'চেয়ারম্যান/মেয়র',
  ),
  'land_ownership': _CertificateContent(
    issuer: 'ভূমি অফিস',
    title: 'জমির মালিকানার দলিল',
    body: [
      'দাগ নং: ১২৩',
      'খতিয়ান নং: ৪৫৬',
      'জমির পরিমাণ: ১.৫০ একর',
    ],
    signerLabel: 'সাব-রেজিস্ট্রার',
  ),
  'ward_union_certificate': _CertificateContent(
    issuer: 'ওয়ার্ড/ইউনিয়ন কার্যালয়',
    title: 'ওয়ার্ড/ইউনিয়ন কর্তৃপক্ষ সনদ',
    body: [
      'প্রত্যয়ন করা যাইতেছে যে, জনাব মোঃ করিম',
      'উদ্দিন এই ওয়ার্ডের একজন স্থায়ী বাসিন্দা।',
    ],
    signerLabel: 'ওয়ার্ড কাউন্সিলর',
  ),
  'ssc_certificate': _CertificateContent(
    issuer: 'মাধ্যমিক ও উচ্চ মাধ্যমিক শিক্ষা বোর্ড',
    title: 'মাধ্যমিক স্কুল সার্টিফিকেট',
    body: [
      'জনাব মোঃ করিম উদ্দিন',
      'রোল: ১২৩৪৫৬   পাসের সন: ২০২৪',
      'জিপিএ: ৫.০০',
    ],
    signerLabel: 'নিয়ন্ত্রক (পরীক্ষা)',
  ),
  'hsc_certificate': _CertificateContent(
    issuer: 'মাধ্যমিক ও উচ্চ মাধ্যমিক শিক্ষা বোর্ড',
    title: 'উচ্চ মাধ্যমিক সার্টিফিকেট',
    body: [
      'জনাব মোঃ করিম উদ্দিন',
      'রোল: ৬৫৪৩২১   পাসের সন: ২০২৪',
      'জিপিএ: ৫.০০',
    ],
    signerLabel: 'নিয়ন্ত্রক (পরীক্ষা)',
  ),
};

class _MarksheetContent {
  const _MarksheetContent({
    required this.title,
    required this.board,
    required this.subjects,
    required this.result,
  });

  final String title;
  final String board;
  final List<(String, String)> subjects;
  final String result;
}

const Map<String, _MarksheetContent> _marksheetContent = {
  'ssc_marksheet': _MarksheetContent(
    title: 'এসএসসি মার্কশিট',
    board: 'ঢাকা শিক্ষা বোর্ড',
    subjects: [
      ('বাংলা', '৮৫'),
      ('ইংরেজি', '৭৮'),
      ('গণিত', '৯০'),
      ('বিজ্ঞান', '৮৮'),
      ('সমাজবিজ্ঞান', '৮০'),
    ],
    result: 'জিপিএ: ৫.০০',
  ),
  'hsc_marksheet': _MarksheetContent(
    title: 'এইচএসসি মার্কশিট',
    board: 'ঢাকা শিক্ষা বোর্ড',
    subjects: [
      ('বাংলা', '৮২'),
      ('ইংরেজি', '৮০'),
      ('পদার্থবিজ্ঞান', '৮৫'),
      ('রসায়ন', '৮৩'),
      ('উচ্চতর গণিত', '৮৮'),
    ],
    result: 'জিপিএ: ৫.০০',
  ),
};

/// Shows an illustrative sample for [docType] so a citizen unsure what a
/// required document looks like can confirm before uploading.
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
              Center(child: _SampleArt(docType: docType, template: template)),
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

/// Diagonal "SAMPLE / নমুনা" watermark so the fabricated demo content is
/// never mistaken for a real citizen's document.
class _SampleWatermark extends StatelessWidget {
  const _SampleWatermark();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Transform.rotate(
          angle: -0.45,
          child: Opacity(
            opacity: 0.14,
            child: Text(
              '${context.trs('document_sample_badge')} • নমুনা',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.errorRed,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SampleArt extends StatelessWidget {
  const _SampleArt({required this.docType, required this.template});

  final String docType;
  final _SampleTemplate template;

  @override
  Widget build(BuildContext context) {
    final imageAsset = _imageAssetFor[docType];
    if (imageAsset != null) {
      return _RealSampleImage(
        assetPath: imageAsset,
        fallback: _VectorSampleArt(docType: docType, template: template),
      );
    }
    return _VectorSampleArt(docType: docType, template: template);
  }
}

/// The illustrated vector mockup, used directly when no real sample image
/// exists for [docType] yet, and as the fallback if one fails to load.
class _VectorSampleArt extends StatelessWidget {
  const _VectorSampleArt({required this.docType, required this.template});

  final String docType;
  final _SampleTemplate template;

  @override
  Widget build(BuildContext context) {
    switch (template) {
      case _SampleTemplate.idCard:
        final content = _idCardContent[docType];
        return content == null
            ? const SizedBox.shrink()
            : _IdCardArt(content: content);
      case _SampleTemplate.certificate:
        final content = _certificateContent[docType];
        return content == null
            ? const SizedBox.shrink()
            : _CertificateArt(content: content);
      case _SampleTemplate.photo:
        return const _PhotoArt();
      case _SampleTemplate.marksheet:
        final content = _marksheetContent[docType];
        return content == null
            ? const SizedBox.shrink()
            : _MarksheetArt(content: content);
    }
  }
}

/// Renders a real sample document image (e.g. a photo of an actual sample
/// NID card), falling back to the vector mockup if the asset is missing.
class _RealSampleImage extends StatelessWidget {
  const _RealSampleImage({required this.assetPath, required this.fallback});

  final String assetPath;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    // Height-bounded rather than a fixed aspect ratio, since real samples
    // range from landscape ID cards to portrait certificate/admit-card pages.
    return SizedBox(
      height: 340,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => fallback,
        ),
      ),
    );
  }
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
  const _IdCardArt({required this.content});

  final _IdCardContent content;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.surfaceLight, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.inputBorder),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _SampleWatermark()),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          content.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
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
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                content.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              _kv(content.idLabel, content.idValue),
                              _kv(content.subLabel, content.subValue),
                            ],
                          ),
                        ),
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

  Widget _kv(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 10.5, color: AppTheme.textSecondary),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificateArt extends StatelessWidget {
  const _CertificateArt({required this.content});

  final _CertificateContent content;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.72,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.inputBorder),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _SampleWatermark()),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  Text(
                    content.issuer,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(width: 60, height: 2, color: AppTheme.primaryGreen),
                  const SizedBox(height: 16),
                  ...content.body.map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        line,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 60, height: 1, color: AppTheme.textTertiary),
                          const SizedBox(height: 4),
                          Text(
                            content.signerLabel,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
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
      width: 170,
      child: AspectRatio(
        aspectRatio: 0.78,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFDCEBFA), Color(0xFFEFF6FC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.inputBorder),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: _SampleWatermark()),
              // Head-and-shoulders silhouette, cropped like a passport photo.
              Align(
                alignment: const Alignment(0, 0.55),
                child: Icon(
                  Icons.person_rounded,
                  size: 118,
                  color: AppTheme.textTertiary.withValues(alpha: 0.85),
                ),
              ),
              // Face-position guide oval.
              const Align(
                alignment: Alignment(0, -0.08),
                child: CustomPaint(
                  size: Size(72, 92),
                  painter: _DashedOvalPainter(),
                ),
              ),
              // Camera-frame corner guides.
              const Positioned(top: 8, left: 8, child: _CornerBracket(corner: _Corner.topLeft)),
              const Positioned(top: 8, right: 8, child: _CornerBracket(corner: _Corner.topRight)),
              const Positioned(bottom: 8, left: 8, child: _CornerBracket(corner: _Corner.bottomLeft)),
              const Positioned(bottom: 8, right: 8, child: _CornerBracket(corner: _Corner.bottomRight)),
              Positioned(top: 8, right: 34, child: const _SampleBadge()),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: const Text(
                    'সাদা/হালকা ব্যাকগ্রাউন্ড',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

/// Small L-shaped bracket, like a camera viewfinder frame guide.
class _CornerBracket extends StatelessWidget {
  const _CornerBracket({required this.corner});

  final _Corner corner;

  @override
  Widget build(BuildContext context) {
    const length = 14.0;
    const thickness = 2.5;
    const color = AppTheme.primaryGreen;
    final isTop = corner == _Corner.topLeft || corner == _Corner.topRight;
    final isLeft = corner == _Corner.topLeft || corner == _Corner.bottomLeft;

    return SizedBox(
      width: length,
      height: length,
      child: Stack(
        children: [
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(width: length, height: thickness, color: color),
          ),
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(width: thickness, height: length, color: color),
          ),
        ],
      ),
    );
  }
}

/// Dashed oval outline marking where the face should be centered.
class _DashedOvalPainter extends CustomPainter {
  const _DashedOvalPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()..addOval(rect);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MarksheetArt extends StatelessWidget {
  const _MarksheetArt({required this.content});

  final _MarksheetContent content;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.72,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.inputBorder),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _SampleWatermark()),
            Padding(
              padding: const EdgeInsets.all(16),
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
                  Text(
                    content.title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    content.board,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text(
                            'বিষয়',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'নম্বর',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (final subject in content.subjects)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              subject.$1,
                              style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              subject.$2,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      content.result,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryGreen,
                      ),
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

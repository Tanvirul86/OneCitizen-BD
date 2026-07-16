import 'package:flutter/widgets.dart';
import 'package:onecitizen/providers/locale_provider.dart';
import 'package:provider/provider.dart';

/// Minimal key → {en, bn} string dictionary. Screens opt in one at a time by
/// swapping a literal `'...'` for `context.tr('some_key')`; screens that
/// haven't been migrated yet are unaffected and simply stay English.
///
/// Unknown keys fall back to the key itself (visibly wrong instead of
/// crashing), so a typo'd key is easy to spot while testing.
class AppStrings {
  AppStrings._();

  static const Map<String, Map<AppLanguage, String>> _strings = {
    // ── Home / landing page ──────────────────────────────────────────────
    'about': {AppLanguage.en: 'About', AppLanguage.bn: 'সম্পর্কে'},
    'gov_badge': {
      AppLanguage.en: 'Government of Bangladesh  •  Official Platform',
      AppLanguage.bn: 'বাংলাদেশ সরকার  •  অফিসিয়াল প্ল্যাটফর্ম',
    },
    'hero_title': {
      AppLanguage.en: 'Your Welfare,\nSimplified.',
      AppLanguage.bn: 'আপনার কল্যাণ,\nসহজ করা হলো।',
    },
    'hero_subtitle': {
      AppLanguage.en:
          'Check eligibility, apply for welfare cards, upload documents, and track your application — all from your phone.',
      AppLanguage.bn:
          'যোগ্যতা যাচাই করুন, কল্যাণ কার্ডের জন্য আবেদন করুন, ডকুমেন্ট আপলোড করুন এবং আবেদনের অবস্থা ট্র্যাক করুন — সবকিছু আপনার ফোন থেকেই।',
    },
    'sign_in': {AppLanguage.en: 'Sign In', AppLanguage.bn: 'সাইন ইন'},
    'create_account': {AppLanguage.en: 'Create Account', AppLanguage.bn: 'অ্যাকাউন্ট তৈরি করুন'},
    'stat_card_types': {AppLanguage.en: 'Card Types', AppLanguage.bn: 'কার্ডের ধরন'},
    'stat_digital': {AppLanguage.en: 'Digital', AppLanguage.bn: 'ডিজিটাল'},
    'stat_free': {AppLanguage.en: 'Free', AppLanguage.bn: 'ফ্রি'},
    'stat_service': {AppLanguage.en: 'Service', AppLanguage.bn: 'সেবা'},
    'available_cards_title': {
      AppLanguage.en: 'Available Welfare Cards',
      AppLanguage.bn: 'উপলব্ধ কল্যাণ কার্ড',
    },
    'available_cards_subtitle': {
      AppLanguage.en: 'Check if you qualify for any of these benefits',
      AppLanguage.bn: 'আপনি এই সুবিধাগুলোর জন্য যোগ্য কিনা যাচাই করুন',
    },
    'card_farmer_title': {AppLanguage.en: 'Farmer Card', AppLanguage.bn: 'কৃষক কার্ড'},
    'card_farmer_subtitle': {
      AppLanguage.en: 'For registered farmers with a valid ward/union certificate.',
      AppLanguage.bn: 'বৈধ ওয়ার্ড/ইউনিয়ন সনদধারী নিবন্ধিত কৃষকদের জন্য।',
    },
    'card_family_title': {AppLanguage.en: 'Family Card', AppLanguage.bn: 'পারিবারিক কার্ড'},
    'card_family_subtitle': {
      AppLanguage.en: 'For low-income families within land and income limits.',
      AppLanguage.bn: 'জমি ও আয়ের সীমার মধ্যে থাকা স্বল্প আয়ের পরিবারের জন্য।',
    },
    'card_education_title': {AppLanguage.en: 'Education Card', AppLanguage.bn: 'শিক্ষা কার্ড'},
    'card_education_subtitle': {
      AppLanguage.en: 'For students achieving GPA 5.00 in both SSC and HSC.',
      AppLanguage.bn: 'SSC ও HSC উভয় পরীক্ষায় GPA ৫.০০ অর্জনকারী শিক্ষার্থীদের জন্য।',
    },
    'how_it_works_title': {AppLanguage.en: 'How It Works', AppLanguage.bn: 'যেভাবে কাজ করে'},
    'how_it_works_subtitle': {
      AppLanguage.en: 'Four simple steps to get your welfare card',
      AppLanguage.bn: 'আপনার কল্যাণ কার্ড পেতে চারটি সহজ ধাপ',
    },
    'step1_title': {AppLanguage.en: 'Register & Set Up', AppLanguage.bn: 'রেজিস্ট্রেশন ও প্রোফাইল তৈরি'},
    'step1_subtitle': {
      AppLanguage.en: 'Create your account and complete your profile details.',
      AppLanguage.bn: 'আপনার অ্যাকাউন্ট তৈরি করুন এবং প্রোফাইলের তথ্য পূরণ করুন।',
    },
    'step2_title': {AppLanguage.en: 'Check Eligibility', AppLanguage.bn: 'যোগ্যতা যাচাই করুন'},
    'step2_subtitle': {
      AppLanguage.en: 'Submit your details for admin review and confirmation.',
      AppLanguage.bn: 'অ্যাডমিন পর্যালোচনা ও নিশ্চিতকরণের জন্য আপনার তথ্য জমা দিন।',
    },
    'step3_title': {AppLanguage.en: 'Apply & Upload', AppLanguage.bn: 'আবেদন ও ডকুমেন্ট আপলোড'},
    'step3_subtitle': {
      AppLanguage.en: 'Submit your card application and upload required documents.',
      AppLanguage.bn: 'আপনার কার্ডের আবেদন জমা দিন এবং প্রয়োজনীয় ডকুমেন্ট আপলোড করুন।',
    },
    'step4_title': {AppLanguage.en: 'Get Approved', AppLanguage.bn: 'অনুমোদন পান'},
    'step4_subtitle': {
      AppLanguage.en: 'Admin reviews your application and you receive your benefit.',
      AppLanguage.bn: 'অ্যাডমিন আপনার আবেদন পর্যালোচনা করবে এবং আপনি সুবিধা পাবেন।',
    },
    'footer_tagline': {
      AppLanguage.en: 'A unified welfare card management platform\nfor the People\'s Republic of Bangladesh.',
      AppLanguage.bn: 'গণপ্রজাতন্ত্রী বাংলাদেশের জন্য একটি একীভূত\nকল্যাণ কার্ড ব্যবস্থাপনা প্ল্যাটফর্ম।',
    },
    'footer_copyright': {
      AppLanguage.en: '© 2025 Government of Bangladesh. All rights reserved.',
      AppLanguage.bn: '© ২০২৫ বাংলাদেশ সরকার। সর্বস্বত্ব সংরক্ষিত।',
    },
  };

  static String of(String key, AppLanguage language) {
    final entry = _strings[key];
    if (entry == null) return key;
    return entry[language] ?? entry[AppLanguage.en] ?? key;
  }
}

extension AppLocalization on BuildContext {
  /// Translated string for [key] in the currently selected app language.
  /// Rebuilds automatically when the language toggle changes.
  String tr(String key) => AppStrings.of(key, watch<LocaleProvider>().language);
}

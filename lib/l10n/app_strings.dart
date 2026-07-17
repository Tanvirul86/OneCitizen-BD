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

    // ── About page ────────────────────────────────────────────────────────
    'about_intro': {
      AppLanguage.en:
          'OneCitizen BD digitizes and centralizes Bangladesh\'s welfare card '
              'management system into a single, transparent, and accessible platform. '
              'Millions of eligible citizens — farmers, low-income families, and '
              'high-achieving students — are entitled to government welfare support '
              'through card-based subsidy programs, but the existing process is '
              'manual, paper-based, and fragmented across disconnected offices.',
      AppLanguage.bn:
          'OneCitizen BD বাংলাদেশের কল্যাণ কার্ড ব্যবস্থাপনা ব্যবস্থাকে ডিজিটালাইজ করে '
              'একটি একক, স্বচ্ছ ও সহজলভ্য প্ল্যাটফর্মে নিয়ে এসেছে। লক্ষ লক্ষ যোগ্য নাগরিক '
              '— কৃষক, স্বল্প আয়ের পরিবার এবং কৃতিত্বপূর্ণ ফলাফলধারী শিক্ষার্থীরা — কার্ড-ভিত্তিক '
              'ভর্তুকি কর্মসূচির মাধ্যমে সরকারি কল্যাণ সহায়তা পাওয়ার যোগ্য, কিন্তু বিদ্যমান প্রক্রিয়াটি '
              'ম্যানুয়াল, কাগজ-নির্ভর এবং বিচ্ছিন্ন অফিসগুলোতে খণ্ডিত অবস্থায় রয়েছে।',
    },
    'about_citizens_title': {
      AppLanguage.en: 'What citizens can do',
      AppLanguage.bn: 'নাগরিকরা যা করতে পারবেন',
    },
    'about_citizens_item1': {
      AppLanguage.en: 'Register, complete a profile, and run a smart eligibility check',
      AppLanguage.bn: 'রেজিস্ট্রেশন করুন, প্রোফাইল পূরণ করুন, এবং স্মার্ট যোগ্যতা যাচাই করুন',
    },
    'about_citizens_item2': {
      AppLanguage.en: 'Apply online for the Farmer, Family, or Education Card',
      AppLanguage.bn: 'কৃষক, পারিবারিক বা শিক্ষা কার্ডের জন্য অনলাইনে আবেদন করুন',
    },
    'about_citizens_item3': {
      AppLanguage.en: 'Track application status in real time',
      AppLanguage.bn: 'রিয়েল টাইমে আবেদনের অবস্থা ট্র্যাক করুন',
    },
    'about_citizens_item4': {
      AppLanguage.en: 'Receive in-app notifications on review, validation, and disbursement',
      AppLanguage.bn: 'পর্যালোচনা, যাচাই ও অর্থ বিতরণ সংক্রান্ত নোটিফিকেশন অ্যাপেই পান',
    },
    'about_admins_title': {
      AppLanguage.en: 'What admins can do',
      AppLanguage.bn: 'অ্যাডমিনরা যা করতে পারবেন',
    },
    'about_admins_item1': {
      AppLanguage.en: 'Review applications and validate uploaded documents',
      AppLanguage.bn: 'আবেদন পর্যালোচনা করুন এবং আপলোড করা ডকুমেন্ট যাচাই করুন',
    },
    'about_admins_item2': {
      AppLanguage.en: 'Approve or reject applications with a reason',
      AppLanguage.bn: 'কারণ উল্লেখ করে আবেদন অনুমোদন বা প্রত্যাখ্যান করুন',
    },
    'about_admins_item3': {
      AppLanguage.en: 'Disburse welfare funds online or offline and keep an auditable record',
      AppLanguage.bn: 'অনলাইন বা অফলাইনে কল্যাণ তহবিল বিতরণ করুন এবং নিরীক্ষাযোগ্য রেকর্ড রাখুন',
    },
    'about_admins_item4': {
      AppLanguage.en: 'Monitor platform-wide analytics',
      AppLanguage.bn: 'পুরো প্ল্যাটফর্মের অ্যানালিটিক্স পর্যবেক্ষণ করুন',
    },

    // ── Login page ────────────────────────────────────────────────────────
    'welcome_back': {AppLanguage.en: 'Welcome back', AppLanguage.bn: 'আবার স্বাগতম'},
    'login_subtitle': {
      AppLanguage.en: 'Sign in to access your welfare account',
      AppLanguage.bn: 'আপনার কল্যাণ অ্যাকাউন্টে প্রবেশ করতে সাইন ইন করুন',
    },
    'role_citizen': {AppLanguage.en: 'Citizen', AppLanguage.bn: 'নাগরিক'},
    'role_admin': {AppLanguage.en: 'Admin', AppLanguage.bn: 'অ্যাডমিন'},
    'email_label': {AppLanguage.en: 'Email address', AppLanguage.bn: 'ইমেইল ঠিকানা'},
    'email_required_login': {
      AppLanguage.en: 'Please enter your email',
      AppLanguage.bn: 'অনুগ্রহ করে আপনার ইমেইল দিন',
    },
    'password_label': {AppLanguage.en: 'Password', AppLanguage.bn: 'পাসওয়ার্ড'},
    'password_required': {
      AppLanguage.en: 'Please enter your password',
      AppLanguage.bn: 'অনুগ্রহ করে আপনার পাসওয়ার্ড দিন',
    },
    'login_failed': {
      AppLanguage.en: 'Login failed. Please try again.',
      AppLanguage.bn: 'লগইন ব্যর্থ হয়েছে। আবার চেষ্টা করুন।',
    },
    'no_account': {AppLanguage.en: "Don't have an account? ", AppLanguage.bn: 'অ্যাকাউন্ট নেই? '},
    'register_link': {AppLanguage.en: 'Register', AppLanguage.bn: 'রেজিস্টার করুন'},
    'back_to_home': {AppLanguage.en: 'Back to Home', AppLanguage.bn: 'হোমে ফিরে যান'},

    // ── Register page ────────────────────────────────────────────────────
    'create_account_title': {
      AppLanguage.en: 'Create your account',
      AppLanguage.bn: 'আপনার অ্যাকাউন্ট তৈরি করুন',
    },
    'register_subtitle': {
      AppLanguage.en: 'Register to apply for welfare cards and track benefits',
      AppLanguage.bn: 'কল্যাণ কার্ডের জন্য আবেদন করতে ও সুবিধা ট্র্যাক করতে রেজিস্ট্রেশন করুন',
    },
    'nid_label': {AppLanguage.en: 'NID Number', AppLanguage.bn: 'জাতীয় পরিচয়পত্র নম্বর'},
    'nid_required': {AppLanguage.en: 'NID is required', AppLanguage.bn: 'জাতীয় পরিচয়পত্র নম্বর আবশ্যক'},
    'first_name_label': {AppLanguage.en: 'First Name', AppLanguage.bn: 'নামের প্রথম অংশ'},
    'last_name_label': {AppLanguage.en: 'Last Name', AppLanguage.bn: 'নামের শেষ অংশ'},
    'field_required': {AppLanguage.en: 'Required', AppLanguage.bn: 'আবশ্যক'},
    'email_required_register': {
      AppLanguage.en: 'Email is required',
      AppLanguage.bn: 'ইমেইল আবশ্যক',
    },
    'phone_label': {AppLanguage.en: 'Phone Number', AppLanguage.bn: 'ফোন নম্বর'},
    'phone_required': {AppLanguage.en: 'Phone number is required', AppLanguage.bn: 'ফোন নম্বর আবশ্যক'},
    'password_min_length': {
      AppLanguage.en: 'Password must be at least 6 characters',
      AppLanguage.bn: 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে',
    },
    'account_created_snackbar': {
      AppLanguage.en: 'Account created! Please sign in to continue.',
      AppLanguage.bn: 'অ্যাকাউন্ট তৈরি হয়েছে! চালিয়ে যেতে সাইন ইন করুন।',
    },
    'registration_failed': {
      AppLanguage.en: 'Registration failed',
      AppLanguage.bn: 'রেজিস্ট্রেশন ব্যর্থ হয়েছে',
    },
    'already_have_account': {
      AppLanguage.en: 'Already have an account? ',
      AppLanguage.bn: 'অ্যাকাউন্ট আছে? ',
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
  /// Rebuilds automatically when the language toggle changes. Call this
  /// only from build() — Provider's `watch` requires it.
  String tr(String key) => AppStrings.of(key, watch<LocaleProvider>().language);

  /// Same lookup but non-reactive (`read`) — safe from callbacks, event
  /// handlers, or anywhere outside build() (e.g. a SnackBar fallback
  /// message built inside an onPressed handler).
  String trs(String key) => AppStrings.of(key, read<LocaleProvider>().language);
}

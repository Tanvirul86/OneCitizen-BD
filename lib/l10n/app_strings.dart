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
    'hero_title_main': {
      AppLanguage.en: 'Your welfare, ',
      AppLanguage.bn: 'আপনার কল্যাণ, ',
    },
    'hero_title_accent': {
      AppLanguage.en: 'simplified.',
      AppLanguage.bn: 'সহজ হলো।',
    },
    'hero_subtitle': {
      AppLanguage.en:
          'Check eligibility, apply for your welfare card and track your application — all from your phone.',
      AppLanguage.bn:
          'যোগ্যতা যাচাই করুন, কল্যাণ কার্ডের জন্য আবেদন করুন এবং আবেদনের অবস্থা ট্র্যাক করুন — সবকিছু আপনার ফোন থেকেই।',
    },
    'sign_in': {AppLanguage.en: 'Sign In', AppLanguage.bn: 'সাইন ইন'},
    'create_account': {
      AppLanguage.en: 'Create Account',
      AppLanguage.bn: 'অ্যাকাউন্ট তৈরি করুন',
    },
    'stat_card_types': {
      AppLanguage.en: 'Card Types',
      AppLanguage.bn: 'কার্ডের ধরন',
    },
    'stat_digital': {AppLanguage.en: 'Digital', AppLanguage.bn: 'ডিজিটাল'},
    'stat_free': {AppLanguage.en: 'Free', AppLanguage.bn: 'ফ্রি'},
    'stat_service': {AppLanguage.en: 'Service', AppLanguage.bn: 'সেবা'},
    'cards_section_eyebrow': {
      AppLanguage.en: 'WELFARE CARDS',
      AppLanguage.bn: 'কল্যাণ কার্ড',
    },
    'available_cards_title': {
      AppLanguage.en: 'Find your card',
      AppLanguage.bn: 'আপনার কার্ড খুঁজুন',
    },
    'available_cards_subtitle': {
      AppLanguage.en: 'Check if you qualify for any of these benefits',
      AppLanguage.bn: 'আপনি এই সুবিধাগুলোর জন্য যোগ্য কিনা যাচাই করুন',
    },
    'welcome_banner_title': {
      AppLanguage.en: 'Welcome to OneCitizen BD',
      AppLanguage.bn: 'ওয়ানসিটিজেন বিডি-তে স্বাগতম',
    },
    'welcome_banner_subtitle': {
      AppLanguage.en: "One account for every welfare card you're entitled to. Open yours today.",
      AppLanguage.bn: 'আপনার প্রাপ্য সব কল্যাণ কার্ডের জন্য একটি অ্যাকাউন্ট। আজই খুলুন।',
    },
    'card_farmer_title': {
      AppLanguage.en: 'Farmer Card',
      AppLanguage.bn: 'কৃষক কার্ড',
    },
    'card_farmer_subtitle': {
      AppLanguage.en:
          'For registered farmers with a valid ward/union certificate.',
      AppLanguage.bn: 'বৈধ ওয়ার্ড/ইউনিয়ন সনদধারী নিবন্ধিত কৃষকদের জন্য।',
    },
    'card_family_title': {
      AppLanguage.en: 'Family Card',
      AppLanguage.bn: 'পারিবারিক কার্ড',
    },
    'card_family_subtitle': {
      AppLanguage.en: 'For low-income families within land and income limits.',
      AppLanguage.bn:
          'জমি ও আয়ের সীমার মধ্যে থাকা স্বল্প আয়ের পরিবারের জন্য।',
    },
    'card_education_title': {
      AppLanguage.en: 'Education Card',
      AppLanguage.bn: 'শিক্ষা কার্ড',
    },
    'card_education_subtitle': {
      AppLanguage.en: 'For students achieving GPA 5.00 in both SSC and HSC.',
      AppLanguage.bn:
          'SSC ও HSC উভয় পরীক্ষায় GPA ৫.০০ অর্জনকারী শিক্ষার্থীদের জন্য।',
    },
    'footer_tagline': {
      AppLanguage.en:
          'A unified welfare card management platform\nfor the People\'s Republic of Bangladesh.',
      AppLanguage.bn:
          'গণপ্রজাতন্ত্রী বাংলাদেশের জন্য একটি একীভূত\nকল্যাণ কার্ড ব্যবস্থাপনা প্ল্যাটফর্ম।',
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
      AppLanguage.en:
          'Register, complete a profile, and run a smart eligibility check',
      AppLanguage.bn:
          'রেজিস্ট্রেশন করুন, প্রোফাইল পূরণ করুন, এবং স্মার্ট যোগ্যতা যাচাই করুন',
    },
    'about_citizens_item2': {
      AppLanguage.en: 'Apply online for the Farmer, Family, or Education Card',
      AppLanguage.bn:
          'কৃষক, পারিবারিক বা শিক্ষা কার্ডের জন্য অনলাইনে আবেদন করুন',
    },
    'about_citizens_item3': {
      AppLanguage.en: 'Track application status in real time',
      AppLanguage.bn: 'রিয়েল টাইমে আবেদনের অবস্থা ট্র্যাক করুন',
    },
    'about_citizens_item4': {
      AppLanguage.en:
          'Receive in-app notifications on review, validation, and disbursement',
      AppLanguage.bn:
          'পর্যালোচনা, যাচাই ও অর্থ বিতরণ সংক্রান্ত নোটিফিকেশন অ্যাপেই পান',
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
      AppLanguage.en:
          'Disburse welfare funds online or offline and keep an auditable record',
      AppLanguage.bn:
          'অনলাইন বা অফলাইনে কল্যাণ তহবিল বিতরণ করুন এবং নিরীক্ষাযোগ্য রেকর্ড রাখুন',
    },
    'about_admins_item4': {
      AppLanguage.en: 'Monitor platform-wide analytics',
      AppLanguage.bn: 'পুরো প্ল্যাটফর্মের অ্যানালিটিক্স পর্যবেক্ষণ করুন',
    },

    // ── Login page ────────────────────────────────────────────────────────
    'welcome_back': {
      AppLanguage.en: 'Welcome back',
      AppLanguage.bn: 'আবার স্বাগতম',
    },
    'login_subtitle': {
      AppLanguage.en: 'Sign in to access your welfare account',
      AppLanguage.bn: 'আপনার কল্যাণ অ্যাকাউন্টে প্রবেশ করতে সাইন ইন করুন',
    },
    'role_citizen': {AppLanguage.en: 'Citizen', AppLanguage.bn: 'নাগরিক'},
    'role_admin': {AppLanguage.en: 'Admin', AppLanguage.bn: 'অ্যাডমিন'},
    'email_label': {
      AppLanguage.en: 'Email address',
      AppLanguage.bn: 'ইমেইল ঠিকানা',
    },
    'email_required_login': {
      AppLanguage.en: 'Please enter your email',
      AppLanguage.bn: 'অনুগ্রহ করে আপনার ইমেইল দিন',
    },
    'password_label': {
      AppLanguage.en: 'Password',
      AppLanguage.bn: 'পাসওয়ার্ড',
    },
    'password_required': {
      AppLanguage.en: 'Please enter your password',
      AppLanguage.bn: 'অনুগ্রহ করে আপনার পাসওয়ার্ড দিন',
    },
    'login_failed': {
      AppLanguage.en: 'Login failed. Please try again.',
      AppLanguage.bn: 'লগইন ব্যর্থ হয়েছে। আবার চেষ্টা করুন।',
    },
    'no_account': {
      AppLanguage.en: "Don't have an account? ",
      AppLanguage.bn: 'অ্যাকাউন্ট নেই? ',
    },
    'register_link': {
      AppLanguage.en: 'Register',
      AppLanguage.bn: 'রেজিস্টার করুন',
    },
    'back_to_home': {
      AppLanguage.en: 'Back to Home',
      AppLanguage.bn: 'হোমে ফিরে যান',
    },

    // ── Register page ────────────────────────────────────────────────────
    'create_account_title': {
      AppLanguage.en: 'Create your account',
      AppLanguage.bn: 'আপনার অ্যাকাউন্ট তৈরি করুন',
    },
    'register_subtitle': {
      AppLanguage.en: 'Register to apply for welfare cards and track benefits',
      AppLanguage.bn:
          'কল্যাণ কার্ডের জন্য আবেদন করতে ও সুবিধা ট্র্যাক করতে রেজিস্ট্রেশন করুন',
    },
    'nid_label': {
      AppLanguage.en: 'NID Number',
      AppLanguage.bn: 'জাতীয় পরিচয়পত্র নম্বর',
    },
    'nid_required': {
      AppLanguage.en: 'NID is required',
      AppLanguage.bn: 'জাতীয় পরিচয়পত্র নম্বর আবশ্যক',
    },
    'first_name_label': {
      AppLanguage.en: 'First Name',
      AppLanguage.bn: 'নামের প্রথম অংশ',
    },
    'last_name_label': {
      AppLanguage.en: 'Last Name',
      AppLanguage.bn: 'নামের শেষ অংশ',
    },
    'field_required': {AppLanguage.en: 'Required', AppLanguage.bn: 'আবশ্যক'},
    'email_required_register': {
      AppLanguage.en: 'Email is required',
      AppLanguage.bn: 'ইমেইল আবশ্যক',
    },
    'phone_label': {
      AppLanguage.en: 'Phone Number',
      AppLanguage.bn: 'ফোন নম্বর',
    },
    'phone_required': {
      AppLanguage.en: 'Phone number is required',
      AppLanguage.bn: 'ফোন নম্বর আবশ্যক',
    },
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

    // ── Admin shell (nav + app bar) ──────────────────────────────────────
    'admin_nav_dashboard': {
      AppLanguage.en: 'Dashboard',
      AppLanguage.bn: 'ড্যাশবোর্ড',
    },
    'admin_nav_new_applications': {
      AppLanguage.en: 'New Applications',
      AppLanguage.bn: 'নতুন আবেদন',
    },
    'admin_nav_document_validation': {
      AppLanguage.en: 'Document Validation',
      AppLanguage.bn: 'ডকুমেন্ট যাচাই',
    },
    'admin_nav_approved_cards': {
      AppLanguage.en: 'Approved Cards',
      AppLanguage.bn: 'অনুমোদিত কার্ড',
    },
    'admin_nav_fund_distribution': {
      AppLanguage.en: 'Fund Distribution',
      AppLanguage.bn: 'তহবিল বিতরণ',
    },
    'admin_nav_distribution_records': {
      AppLanguage.en: 'Distribution Records',
      AppLanguage.bn: 'বিতরণ রেকর্ড',
    },
    'admin_nav_citizen_accounts': {
      AppLanguage.en: 'Citizen Accounts',
      AppLanguage.bn: 'নাগরিক অ্যাকাউন্ট',
    },
    'admin_nav_analytics': {
      AppLanguage.en: 'Analytics',
      AppLanguage.bn: 'অ্যানালিটিক্স',
    },
    'admin_badge': {AppLanguage.en: 'Admin', AppLanguage.bn: 'অ্যাডমিন'},
    'logout': {AppLanguage.en: 'Logout', AppLanguage.bn: 'লগ আউট'},
    'administrator': {
      AppLanguage.en: 'Administrator',
      AppLanguage.bn: 'প্রশাসক',
    },

    // ── Admin dashboard ───────────────────────────────────────────────────
    'greeting_morning': {
      AppLanguage.en: 'Good morning 👋',
      AppLanguage.bn: 'শুভ সকাল 👋',
    },
    'greeting_afternoon': {
      AppLanguage.en: 'Good afternoon 👋',
      AppLanguage.bn: 'শুভ বিকাল 👋',
    },
    'greeting_evening': {
      AppLanguage.en: 'Good evening 👋',
      AppLanguage.bn: 'শুভ সন্ধ্যা 👋',
    },
    'hero_pending_applications': {
      AppLanguage.en: 'Pending Applications',
      AppLanguage.bn: 'অপেক্ষমাণ আবেদন',
    },
    'hero_docs_to_review': {
      AppLanguage.en: 'Docs to Review',
      AppLanguage.bn: 'পর্যালোচনার জন্য ডকুমেন্ট',
    },
    'stat_total_applications': {
      AppLanguage.en: 'Total Applications',
      AppLanguage.bn: 'মোট আবেদন',
    },
    'stat_approved': {AppLanguage.en: 'Approved', AppLanguage.bn: 'অনুমোদিত'},
    'stat_pending_review': {
      AppLanguage.en: 'Pending Review',
      AppLanguage.bn: 'পর্যালোচনাধীন',
    },
    'stat_total_disbursed': {
      AppLanguage.en: 'Total Disbursed',
      AppLanguage.bn: 'মোট বিতরণকৃত',
    },
    'stat_rejected': {
      AppLanguage.en: 'Rejected',
      AppLanguage.bn: 'প্রত্যাখ্যাত',
    },
    'quick_actions_title': {
      AppLanguage.en: 'Quick Actions',
      AppLanguage.bn: 'দ্রুত পদক্ষেপ',
    },
    'action_review_decide': {
      AppLanguage.en: 'Review & decide',
      AppLanguage.bn: 'পর্যালোচনা ও সিদ্ধান্ত নিন',
    },
    'action_verify_uploads': {
      AppLanguage.en: 'Verify uploads',
      AppLanguage.bn: 'আপলোড যাচাই করুন',
    },
    'action_view_issued_cards': {
      AppLanguage.en: 'View issued cards',
      AppLanguage.bn: 'ইস্যুকৃত কার্ড দেখুন',
    },
    'action_disburse_funds': {
      AppLanguage.en: 'Disburse funds',
      AppLanguage.bn: 'তহবিল বিতরণ করুন',
    },
    'action_disbursement_history': {
      AppLanguage.en: 'Disbursement history',
      AppLanguage.bn: 'বিতরণের ইতিহাস',
    },
    'action_manage_citizens': {
      AppLanguage.en: 'Manage citizens',
      AppLanguage.bn: 'নাগরিক পরিচালনা করুন',
    },
    'action_program_insights': {
      AppLanguage.en: 'Program insights',
      AppLanguage.bn: 'প্রোগ্রাম বিশ্লেষণ',
    },

    // ── Citizen accounts (admin) ─────────────────────────────────────────
    'search_by_name_nid': {
      AppLanguage.en: 'Search by name or NID',
      AppLanguage.bn: 'নাম বা এনআইডি দিয়ে খুঁজুন',
    },
    'no_citizen_accounts': {
      AppLanguage.en: 'No citizen accounts found.',
      AppLanguage.bn: 'কোনো নাগরিক অ্যাকাউন্ট পাওয়া যায়নি।',
    },
    'deactivate_account_title': {
      AppLanguage.en: 'Deactivate Account',
      AppLanguage.bn: 'অ্যাকাউন্ট নিষ্ক্রিয় করুন',
    },
    'freeze_account_title': {
      AppLanguage.en: 'Freeze Account',
      AppLanguage.bn: 'অ্যাকাউন্ট ফ্রিজ করুন',
    },
    'activate_account_title': {
      AppLanguage.en: 'Activate Account',
      AppLanguage.bn: 'অ্যাকাউন্ট সক্রিয় করুন',
    },
    'confirm_deactivate_body': {
      AppLanguage.en:
          "Deactivate {name}'s account? They will no longer be able to log in.",
      AppLanguage.bn:
          '{name}-এর অ্যাকাউন্ট নিষ্ক্রিয় করবেন? তিনি আর লগইন করতে পারবেন না।',
    },
    'confirm_freeze_body': {
      AppLanguage.en:
          "Freeze {name}'s account? They will be temporarily blocked until you unfreeze it.",
      AppLanguage.bn:
          '{name}-এর অ্যাকাউন্ট ফ্রিজ করবেন? আনফ্রিজ না করা পর্যন্ত তিনি সাময়িকভাবে ব্লক থাকবেন।',
    },
    'confirm_activate_body': {
      AppLanguage.en:
          "Activate {name}'s account? They will be able to log in again.",
      AppLanguage.bn:
          '{name}-এর অ্যাকাউন্ট সক্রিয় করবেন? তিনি আবার লগইন করতে পারবেন।',
    },
    'cancel': {AppLanguage.en: 'Cancel', AppLanguage.bn: 'বাতিল'},
    'freeze_action': {AppLanguage.en: 'Freeze', AppLanguage.bn: 'ফ্রিজ'},
    'unfreeze_action': {AppLanguage.en: 'Unfreeze', AppLanguage.bn: 'আনফ্রিজ'},
    'deactivate_action': {
      AppLanguage.en: 'Deactivate',
      AppLanguage.bn: 'নিষ্ক্রিয় করুন',
    },
    'activate_action': {
      AppLanguage.en: 'Activate',
      AppLanguage.bn: 'সক্রিয় করুন',
    },
    'status_inactive': {
      AppLanguage.en: 'Inactive',
      AppLanguage.bn: 'নিষ্ক্রিয়',
    },
    'status_frozen': {AppLanguage.en: 'Frozen', AppLanguage.bn: 'ফ্রিজড'},

    // ── New applications (admin) ─────────────────────────────────────────
    'showing_card_type_applications': {
      AppLanguage.en: 'Showing "{type}" applications',
      AppLanguage.bn: '"{type}" আবেদন দেখানো হচ্ছে',
    },
    'showing_scoped_applications': {
      AppLanguage.en: 'Showing "{scope}" applications',
      AppLanguage.bn: '"{scope}" আবেদন দেখানো হচ্ছে',
    },
    'filtered_label': {
      AppLanguage.en: 'filtered',
      AppLanguage.bn: 'ফিল্টার করা',
    },
    'clear': {AppLanguage.en: 'Clear', AppLanguage.bn: 'মুছুন'},
    'filter_all': {AppLanguage.en: 'All', AppLanguage.bn: 'সব'},
    'no_applications_found': {
      AppLanguage.en: 'No applications found.',
      AppLanguage.bn: 'কোনো আবেদন পাওয়া যায়নি।',
    },
    'status_submitted': {
      AppLanguage.en: 'Submitted',
      AppLanguage.bn: 'জমা দেওয়া হয়েছে',
    },
    'status_request': {AppLanguage.en: 'Request', AppLanguage.bn: 'অনুরোধ'},
    'status_under_review': {
      AppLanguage.en: 'Under Review',
      AppLanguage.bn: 'পর্যালোচনাধীন',
    },

    // ── Document validation ──────────────────────────────────────────────
    'mark_document_invalid_title': {
      AppLanguage.en: 'Mark Document Invalid',
      AppLanguage.bn: 'ডকুমেন্ট অবৈধ চিহ্নিত করুন',
    },
    'remark_label': {AppLanguage.en: 'Remark', AppLanguage.bn: 'মন্তব্য'},
    'remark_required': {
      AppLanguage.en: 'A remark is required',
      AppLanguage.bn: 'একটি মন্তব্য আবশ্যক',
    },
    'mark_invalid_action': {
      AppLanguage.en: 'Mark Invalid',
      AppLanguage.bn: 'অবৈধ চিহ্নিত করুন',
    },
    'no_documents_to_review': {
      AppLanguage.en: 'No documents to review.',
      AppLanguage.bn: 'পর্যালোচনার জন্য কোনো ডকুমেন্ট নেই।',
    },
    'doc_validation_tab_pending': {
      AppLanguage.en: 'Pending',
      AppLanguage.bn: 'অপেক্ষমাণ',
    },
    'doc_validation_tab_reviewed': {
      AppLanguage.en: 'Reviewed',
      AppLanguage.bn: 'পর্যালোচিত',
    },
    'no_reviewed_documents': {
      AppLanguage.en: 'No reviewed documents yet.',
      AppLanguage.bn: 'এখনো কোনো পর্যালোচিত ডকুমেন্ট নেই।',
    },
    'citizen_prefix': {
      AppLanguage.en: 'Citizen: {name}',
      AppLanguage.bn: 'নাগরিক: {name}',
    },
    'remark_prefix': {
      AppLanguage.en: 'Remark: {remark}',
      AppLanguage.bn: 'মন্তব্য: {remark}',
    },
    'view_document': {
      AppLanguage.en: 'View document',
      AppLanguage.bn: 'ডকুমেন্ট দেখুন',
    },
    'invalid_action': {AppLanguage.en: 'Invalid', AppLanguage.bn: 'অবৈধ'},
    'valid_action': {AppLanguage.en: 'Valid', AppLanguage.bn: 'বৈধ'},

    // ── Approved cards ────────────────────────────────────────────────────
    'search_by_citizen_name': {
      AppLanguage.en: 'Search by citizen name',
      AppLanguage.bn: 'নাগরিকের নাম দিয়ে খুঁজুন',
    },
    'no_approved_cards': {
      AppLanguage.en: 'No approved cards yet.',
      AppLanguage.bn: 'এখনো কোনো অনুমোদিত কার্ড নেই।',
    },
    'nid_approved_date': {
      AppLanguage.en: 'NID: {nid} • Approved: {date}',
      AppLanguage.bn: 'এনআইডি: {nid} • অনুমোদিত: {date}',
    },

    // ── Fund distribution ─────────────────────────────────────────────────
    'select_card_holder_error': {
      AppLanguage.en: 'Please select an approved card holder',
      AppLanguage.bn: 'একজন অনুমোদিত কার্ডধারী নির্বাচন করুন',
    },
    'approved_card_holder_label': {
      AppLanguage.en: 'Approved Card Holder',
      AppLanguage.bn: 'অনুমোদিত কার্ডধারী',
    },
    'online_method_full': {
      AppLanguage.en: 'Online (bKash/Nagad/Bank)',
      AppLanguage.bn: 'অনলাইন (বিকাশ/নগদ/ব্যাংক)',
    },
    'offline': {AppLanguage.en: 'Offline', AppLanguage.bn: 'অফলাইন'},
    'online': {AppLanguage.en: 'Online', AppLanguage.bn: 'অনলাইন'},
    'amount_bdt_label': {
      AppLanguage.en: 'Amount (BDT)',
      AppLanguage.bn: 'পরিমাণ (টাকা)',
    },
    'amount_invalid': {
      AppLanguage.en: 'Enter a valid amount',
      AppLanguage.bn: 'সঠিক পরিমাণ লিখুন',
    },
    'note_optional_label': {
      AppLanguage.en: 'Note (optional)',
      AppLanguage.bn: 'মন্তব্য (ঐচ্ছিক)',
    },
    'disburse_funds_action': {
      AppLanguage.en: 'Disburse Funds',
      AppLanguage.bn: 'তহবিল বিতরণ করুন',
    },
    'funds_disbursed_success': {
      AppLanguage.en: 'Funds disbursed successfully',
      AppLanguage.bn: 'তহবিল সফলভাবে বিতরণ হয়েছে',
    },
    'disburse_failed': {
      AppLanguage.en: 'Failed to disburse funds',
      AppLanguage.bn: 'তহবিল বিতরণ ব্যর্থ হয়েছে',
    },
    'distribution_mode_individual': {
      AppLanguage.en: 'Individual',
      AppLanguage.bn: 'একক',
    },
    'distribution_mode_bulk': {
      AppLanguage.en: 'By Card Type',
      AppLanguage.bn: 'কার্ড অনুযায়ী',
    },
    'select_card_type_error': {
      AppLanguage.en: 'Please select a card type',
      AppLanguage.bn: 'একটি কার্ডের ধরন নির্বাচন করুন',
    },
    'no_approved_holders_for_card': {
      AppLanguage.en: 'No approved holders for this card type yet.',
      AppLanguage.bn: 'এই কার্ডের জন্য এখনো কোনো অনুমোদিত হোল্ডার নেই।',
    },
    'bulk_recipients_summary': {
      AppLanguage.en:
          '{count} approved {name} holders will each receive ৳{amount}.',
      AppLanguage.bn:
          '{count} জন অনুমোদিত {name} হোল্ডার প্রত্যেকে ৳{amount} পাবেন।',
    },
    'bulk_distribute_action': {
      AppLanguage.en: 'Distribute to All ({count})',
      AppLanguage.bn: 'সবাইকে পাঠান ({count})',
    },
    'bulk_distribute_confirm_title': {
      AppLanguage.en: 'Confirm Bulk Distribution',
      AppLanguage.bn: 'বাল্ক বিতরণ নিশ্চিত করুন',
    },
    'bulk_distribute_confirm_body': {
      AppLanguage.en:
          'Send ৳{amount} to each of the {count} approved {name} holders (total ৳{total})? This cannot be undone.',
      AppLanguage.bn:
          '{count} জন অনুমোদিত {name} হোল্ডারের প্রত্যেককে ৳{amount} করে (মোট ৳{total}) পাঠাতে চান? এটি পূর্বাবস্থায় ফেরানো যাবে না।',
    },
    'confirm_send_action': {
      AppLanguage.en: 'Yes, Send',
      AppLanguage.bn: 'হ্যাঁ, পাঠান',
    },
    'bulk_distribute_result': {
      AppLanguage.en: '{success} sent successfully, {failed} failed.',
      AppLanguage.bn: '{success} জনকে সফলভাবে পাঠানো হয়েছে, {failed} জন ব্যর্থ হয়েছে।',
    },

    // ── Distribution records ─────────────────────────────────────────────
    'no_distribution_records': {
      AppLanguage.en: 'No distribution records.',
      AppLanguage.bn: 'কোনো বিতরণ রেকর্ড নেই।',
    },

    // ── Analytics ─────────────────────────────────────────────────────────
    'pending_documents': {
      AppLanguage.en: 'Pending Documents',
      AppLanguage.bn: 'অপেক্ষমাণ ডকুমেন্ট',
    },
    'applications_by_card_type': {
      AppLanguage.en: 'Applications by Card Type',
      AppLanguage.bn: 'কার্ডের ধরন অনুযায়ী আবেদন',
    },

    // ── Notifications (shared citizen/admin) ─────────────────────────────
    'notifications_title': {
      AppLanguage.en: 'Notifications',
      AppLanguage.bn: 'নোটিফিকেশন',
    },
    'no_notifications_yet': {
      AppLanguage.en: 'No notifications yet.',
      AppLanguage.bn: 'এখনো কোনো নোটিফিকেশন নেই।',
    },

    // ── Admin quick search ────────────────────────────────────────────────
    'search_by_nid_or_app_id': {
      AppLanguage.en: 'Search by NID or Application ID',
      AppLanguage.bn: 'এনআইডি বা আবেদন আইডি দিয়ে খুঁজুন',
    },
    'search_applications_title': {
      AppLanguage.en: 'Search Applications',
      AppLanguage.bn: 'আবেদন খুঁজুন',
    },
    'search_hint_nid_or_id': {
      AppLanguage.en: 'Enter NID or Application ID',
      AppLanguage.bn: 'এনআইডি বা আবেদন আইডি লিখুন',
    },
    'search_prompt': {
      AppLanguage.en: 'Type an NID or Application ID to search.',
      AppLanguage.bn: 'খুঁজতে একটি এনআইডি বা আবেদন আইডি লিখুন।',
    },
    'no_matching_applications': {
      AppLanguage.en: 'No matching applications found.',
      AppLanguage.bn: 'কোনো মিলযুক্ত আবেদন পাওয়া যায়নি।',
    },
    'open_application_id_exact': {
      AppLanguage.en: 'Open Application ID exactly as typed',
      AppLanguage.bn: 'ঠিক যেমন লিখেছেন সেভাবে আবেদন আইডি খুলুন',
    },

    // ── Application review ────────────────────────────────────────────────
    'application_approved': {
      AppLanguage.en: 'Application approved',
      AppLanguage.bn: 'আবেদন অনুমোদিত হয়েছে',
    },
    'documents_must_be_reviewed_hint': {
      AppLanguage.en:
          'All citizen documents must be marked Valid before you can approve this application. If any document is Invalid, this application cannot be approved.',
      AppLanguage.bn:
          'এই আবেদন অনুমোদন করতে হলে নাগরিকের সব ডকুমেন্ট অবশ্যই Valid হিসেবে চিহ্নিত থাকতে হবে। কোনো ডকুমেন্ট Invalid থাকলে এই আবেদন অনুমোদন করা যাবে না।',
    },
    'application_rejected': {
      AppLanguage.en: 'Application rejected',
      AppLanguage.bn: 'আবেদন প্রত্যাখ্যান করা হয়েছে',
    },
    'failed': {AppLanguage.en: 'Failed', AppLanguage.bn: 'ব্যর্থ হয়েছে'},
    'reject_application_title': {
      AppLanguage.en: 'Reject Application',
      AppLanguage.bn: 'আবেদন প্রত্যাখ্যান করুন',
    },
    'reason_label': {AppLanguage.en: 'Reason', AppLanguage.bn: 'কারণ'},
    'reason_required': {
      AppLanguage.en: 'A reason is required',
      AppLanguage.bn: 'একটি কারণ আবশ্যক',
    },
    'reject_action': {
      AppLanguage.en: 'Reject',
      AppLanguage.bn: 'প্রত্যাখ্যান করুন',
    },
    'application_review_title': {
      AppLanguage.en: 'Application Review',
      AppLanguage.bn: 'আবেদন পর্যালোচনা',
    },
    'application_not_found': {
      AppLanguage.en: 'Application not found.',
      AppLanguage.bn: 'আবেদন পাওয়া যায়নি।',
    },
    'applicant_label': {
      AppLanguage.en: 'Applicant',
      AppLanguage.bn: 'আবেদনকারী',
    },
    'nid_short_label': {AppLanguage.en: 'NID', AppLanguage.bn: 'এনআইডি'},
    'email_short_label': {AppLanguage.en: 'Email', AppLanguage.bn: 'ইমেইল'},
    'submitted_label': {
      AppLanguage.en: 'Submitted',
      AppLanguage.bn: 'জমা দেওয়া হয়েছে',
    },
    'request_received_label': {
      AppLanguage.en: 'Request Received',
      AppLanguage.bn: 'অনুরোধ গ্রহণ করা হয়েছে',
    },
    'review_citizen_documents': {
      AppLanguage.en: 'Review Citizen Documents',
      AppLanguage.bn: 'নাগরিকের ডকুমেন্ট পর্যালোচনা করুন',
    },
    'approve_action': {
      AppLanguage.en: 'Approve',
      AppLanguage.bn: 'অনুমোদন করুন',
    },

    // ── Citizen shell (bottom nav) ───────────────────────────────────────
    'citizen_nav_applications': {
      AppLanguage.en: 'Applications',
      AppLanguage.bn: 'আবেদনসমূহ',
    },
    'citizen_nav_funds': {AppLanguage.en: 'Funds', AppLanguage.bn: 'তহবিল'},
    'citizen_nav_profile': {
      AppLanguage.en: 'Profile',
      AppLanguage.bn: 'প্রোফাইল',
    },

    // ── Citizen dashboard ─────────────────────────────────────────────────
    'complete_profile_title': {
      AppLanguage.en: 'Complete Your Profile',
      AppLanguage.bn: 'আপনার প্রোফাইল সম্পূর্ণ করুন',
    },
    'complete_profile_subtitle': {
      AppLanguage.en:
          'Profile completion is required to check eligibility for welfare cards.',
      AppLanguage.bn:
          'কল্যাণ কার্ডের যোগ্যতা যাচাই করতে প্রোফাইল সম্পূর্ণ করা আবশ্যক।',
    },
    'complete_now_action': {
      AppLanguage.en: 'Complete Now',
      AppLanguage.bn: 'এখনই সম্পূর্ণ করুন',
    },
    'complete_profile_before_apply': {
      AppLanguage.en: 'Please complete your profile before applying for a card.',
      AppLanguage.bn: 'কার্ডের জন্য আবেদন করার আগে আপনার প্রোফাইল সম্পূর্ণ করুন।',
    },
    'docs_need_reupload_title': {
      AppLanguage.en: '{count} Document(s) Need Re-upload',
      AppLanguage.bn: '{count}টি ডকুমেন্ট পুনরায় আপলোড করা প্রয়োজন',
    },
    'docs_need_reupload_subtitle': {
      AppLanguage.en:
          '{doc} was marked invalid for your {card} request. Open the request to re-upload it.',
      AppLanguage.bn:
          'আপনার {card} আবেদনের জন্য {doc} অবৈধ চিহ্নিত করা হয়েছে। পুনরায় আপলোড করতে আবেদনটি খুলুন।',
    },
    'review_request_action': {
      AppLanguage.en: 'Review Request',
      AppLanguage.bn: 'আবেদন পর্যালোচনা করুন',
    },
    'quick_action_title': {
      AppLanguage.en: 'Quick Action',
      AppLanguage.bn: 'দ্রুত পদক্ষেপ',
    },
    'apply_for_card_title': {
      AppLanguage.en: 'Apply for Card',
      AppLanguage.bn: 'কার্ডের জন্য আবেদন করুন',
    },
    'apply_for_card_hint': {
      AppLanguage.en:
          'Select a card, review required documents, fill the form, upload files, and preview before submit.',
      AppLanguage.bn:
          'একটি কার্ড নির্বাচন করুন, প্রয়োজনীয় ডকুমেন্ট দেখুন, ফর্ম পূরণ করুন, ফাইল আপলোড করুন এবং জমা দেওয়ার আগে প্রিভিউ দেখুন।',
    },
    'my_applications_title': {
      AppLanguage.en: 'My Applications',
      AppLanguage.bn: 'আমার আবেদনসমূহ',
    },
    'view_all_action': {AppLanguage.en: 'View All', AppLanguage.bn: 'সব দেখুন'},
    'no_applications_yet': {
      AppLanguage.en: 'No applications yet',
      AppLanguage.bn: 'এখনো কোনো আবেদন নেই',
    },
    'no_applications_yet_subtitle': {
      AppLanguage.en:
          'Start one guided application and upload every required document there.',
      AppLanguage.bn:
          'একটি নির্দেশিত আবেদন শুরু করুন এবং সেখানে প্রয়োজনীয় সব ডকুমেন্ট আপলোড করুন।',
    },

    // ── Apply for card ────────────────────────────────────────────────────
    'select_card_title': {
      AppLanguage.en: 'Select Card',
      AppLanguage.bn: 'কার্ড নির্বাচন করুন',
    },
    'card_requirements_title': {
      AppLanguage.en: '{name} requirements',
      AppLanguage.bn: '{name}-এর প্রয়োজনীয়তা',
    },
    'documents_required_label': {
      AppLanguage.en: 'Documents required:',
      AppLanguage.bn: 'প্রয়োজনীয় ডকুমেন্ট:',
    },
    'tap_to_see_sample_hint': {
      AppLanguage.en: 'Tap a document to see a sample',
      AppLanguage.bn: 'নমুনা দেখতে যেকোনো ডকুমেন্টে ট্যাপ করুন',
    },
    'document_sample_sheet_title': {
      AppLanguage.en: 'Sample: {name}',
      AppLanguage.bn: 'নমুনা: {name}',
    },
    'document_sample_badge': {
      AppLanguage.en: 'SAMPLE',
      AppLanguage.bn: 'নমুনা',
    },
    'document_sample_hint_id_card': {
      AppLanguage.en:
          'Submit a clear scan/photo where the photo, name, and number are all readable.',
      AppLanguage.bn:
          'ছবি, নাম ও নম্বর স্পষ্টভাবে দেখা যায় এমন একটি স্ক্যান/ছবি জমা দিন।',
    },
    'document_sample_hint_certificate': {
      AppLanguage.en:
          'Submit a clear scan/photo of the full page, including the office seal and signature.',
      AppLanguage.bn:
          'অফিসের সিলমোহর ও স্বাক্ষরসহ সম্পূর্ণ পাতার একটি স্পষ্ট স্ক্যান/ছবি জমা দিন।',
    },
    'document_sample_hint_photo': {
      AppLanguage.en:
          'A recent photo on a plain white/light background, facing the camera, without sunglasses or a cap.',
      AppLanguage.bn:
          'সাদা বা হালকা ব্যাকগ্রাউন্ডে সম্মুখ থেকে তোলা সাম্প্রতিক ছবি (রোদচশমা/টুপি ছাড়া) জমা দিন।',
    },
    'document_sample_hint_marksheet': {
      AppLanguage.en:
          'Submit a clear scan/photo of the full marksheet with all subject-wise marks visible.',
      AppLanguage.bn:
          'সকল বিষয়ের নম্বরসহ সম্পূর্ণ মার্কশিটের একটি স্পষ্ট স্ক্যান/ছবি জমা দিন।',
    },
    'close_action': {
      AppLanguage.en: 'Close',
      AppLanguage.bn: 'বন্ধ করুন',
    },
    'proceed_action': {
      AppLanguage.en: 'Proceed',
      AppLanguage.bn: 'এগিয়ে যান',
    },
    'application_preview_title': {
      AppLanguage.en: 'Application Preview',
      AppLanguage.bn: 'আবেদনের প্রিভিউ',
    },
    'card_type_label': {
      AppLanguage.en: 'Card type',
      AppLanguage.bn: 'কার্ডের ধরন',
    },
    'not_filled_value': {
      AppLanguage.en: 'Not filled',
      AppLanguage.bn: 'পূরণ করা হয়নি',
    },
    'division_label': {AppLanguage.en: 'Division', AppLanguage.bn: 'বিভাগ'},
    'district_label': {AppLanguage.en: 'District', AppLanguage.bn: 'জেলা'},
    'upazila_label': {AppLanguage.en: 'Upazila', AppLanguage.bn: 'উপজেলা'},
    'union_label': {AppLanguage.en: 'Union', AppLanguage.bn: 'ইউনিয়ন'},
    'ward_number_label': {
      AppLanguage.en: 'Ward number',
      AppLanguage.bn: 'ওয়ার্ড নম্বর',
    },
    'not_selected_value': {
      AppLanguage.en: 'Not selected',
      AppLanguage.bn: 'নির্বাচন করা হয়নি',
    },
    'missing_value': {
      AppLanguage.en: 'Missing',
      AppLanguage.bn: 'অনুপস্থিত',
    },
    'back_to_form_action': {
      AppLanguage.en: 'Back to form',
      AppLanguage.bn: 'ফর্মে ফিরে যান',
    },
    'please_select_card_type': {
      AppLanguage.en: 'Please select a card type',
      AppLanguage.bn: 'অনুগ্রহ করে একটি কার্ডের ধরন নির্বাচন করুন',
    },
    'please_upload_all_documents': {
      AppLanguage.en:
          'Please upload every required document before submitting.',
      AppLanguage.bn: 'জমা দেওয়ার আগে সব প্রয়োজনীয় ডকুমেন্ট আপলোড করুন।',
    },
    'please_complete_all_fields': {
      AppLanguage.en: 'Please complete all required form fields.',
      AppLanguage.bn: 'অনুগ্রহ করে ফর্মের সব প্রয়োজনীয় ঘর পূরণ করুন।',
    },
    'please_select_address_fields': {
      AppLanguage.en:
          'Please select division, district, upazila, union, and ward.',
      AppLanguage.bn:
          'অনুগ্রহ করে বিভাগ, জেলা, উপজেলা, ইউনিয়ন ও ওয়ার্ড নির্বাচন করুন।',
    },
    'application_submitted_success': {
      AppLanguage.en: 'Application submitted successfully!',
      AppLanguage.bn: 'আবেদন সফলভাবে জমা হয়েছে!',
    },
    'application_submit_failed': {
      AppLanguage.en: 'Failed to submit application',
      AppLanguage.bn: 'আবেদন জমা দেওয়া ব্যর্থ হয়েছে',
    },
    'document_uploaded_success': {
      AppLanguage.en: 'Document uploaded successfully',
      AppLanguage.bn: 'ডকুমেন্ট সফলভাবে আপলোড হয়েছে',
    },
    'upload_failed_generic': {
      AppLanguage.en: 'Upload failed',
      AppLanguage.bn: 'আপলোড ব্যর্থ হয়েছে',
    },
    'submitting_label': {
      AppLanguage.en: 'Submitting...',
      AppLanguage.bn: 'জমা দেওয়া হচ্ছে...',
    },
    'submit_application_action': {
      AppLanguage.en: 'Submit Application',
      AppLanguage.bn: 'আবেদন জমা দিন',
    },
    'application_form_title': {
      AppLanguage.en: '{name} application form',
      AppLanguage.bn: '{name} আবেদন ফর্ম',
    },
    'fill_details_subtitle': {
      AppLanguage.en: 'Fill the details required for this card type.',
      AppLanguage.bn: 'এই কার্ডের জন্য প্রয়োজনীয় তথ্য পূরণ করুন।',
    },
    'ssc_exam_info_title': {
      AppLanguage.en: 'SSC examination information',
      AppLanguage.bn: 'এসএসসি পরীক্ষার তথ্য',
    },
    'hsc_exam_info_title': {
      AppLanguage.en: 'HSC examination information',
      AppLanguage.bn: 'এইচএসসি পরীক্ষার তথ্য',
    },
    'required_documents_title': {
      AppLanguage.en: 'Required documents',
      AppLanguage.bn: 'প্রয়োজনীয় ডকুমেন্ট',
    },
    'upload_preview_documents_subtitle': {
      AppLanguage.en: 'Upload and preview documents before submitting.',
      AppLanguage.bn: 'জমা দেওয়ার আগে ডকুমেন্ট আপলোড ও প্রিভিউ করুন।',
    },
    'preview_application_action': {
      AppLanguage.en: 'Preview Application',
      AppLanguage.bn: 'আবেদন প্রিভিউ করুন',
    },
    'field_required_full': {
      AppLanguage.en: 'This field is required',
      AppLanguage.bn: 'এই ঘরটি পূরণ করা আবশ্যক',
    },
    'loading_location_data': {
      AppLanguage.en: 'Loading Bangladesh location data...',
      AppLanguage.bn: 'বাংলাদেশের ঠিকানার তথ্য লোড হচ্ছে...',
    },
    'location_data_load_error': {
      AppLanguage.en:
          'Could not load verified location data. Check internet and try again.',
      AppLanguage.bn:
          'যাচাইকৃত ঠিকানার তথ্য লোড করা যায়নি। ইন্টারনেট সংযোগ যাচাই করে আবার চেষ্টা করুন।',
    },
    'documents_required_count': {
      AppLanguage.en: '{count} documents required',
      AppLanguage.bn: '{count}টি ডকুমেন্ট প্রয়োজন',
    },
    'change_action': {
      AppLanguage.en: 'Change',
      AppLanguage.bn: 'পরিবর্তন করুন',
    },
    'extensions_only_format': {
      AppLanguage.en: '{ext} only',
      AppLanguage.bn: 'শুধুমাত্র {ext}',
    },
    'uploaded_document_available': {
      AppLanguage.en: 'Uploaded document available',
      AppLanguage.bn: 'আপলোড করা ডকুমেন্ট রয়েছে',
    },
    'blank_required_option': {
      AppLanguage.en: 'Blank required option - {format}',
      AppLanguage.bn: 'পূরণ করা হয়নি - {format}',
    },
    'preview_document_tooltip': {
      AppLanguage.en: 'Preview document',
      AppLanguage.bn: 'ডকুমেন্ট প্রিভিউ করুন',
    },
    'preview_unavailable_tooltip': {
      AppLanguage.en: 'Preview unavailable',
      AppLanguage.bn: 'প্রিভিউ উপলব্ধ নেই',
    },
    'replace_document_tooltip': {
      AppLanguage.en: 'Replace document',
      AppLanguage.bn: 'ডকুমেন্ট প্রতিস্থাপন করুন',
    },
    'upload_document_tooltip': {
      AppLanguage.en: 'Upload document',
      AppLanguage.bn: 'ডকুমেন্ট আপলোড করুন',
    },
    'opening_preview_for': {
      AppLanguage.en: 'Opening preview for {label}',
      AppLanguage.bn: '{label}-এর প্রিভিউ খোলা হচ্ছে',
    },
    'file_selected_label': {
      AppLanguage.en: 'File selected',
      AppLanguage.bn: 'ফাইল নির্বাচিত হয়েছে',
    },
    'close_preview_action': {
      AppLanguage.en: 'Close Preview',
      AppLanguage.bn: 'প্রিভিউ বন্ধ করুন',
    },
    'loading_pdf_preview': {
      AppLanguage.en: 'Loading PDF preview...',
      AppLanguage.bn: 'পিডিএফ প্রিভিউ লোড হচ্ছে...',
    },
    'pdf_preview_unavailable': {
      AppLanguage.en: 'PDF preview unavailable',
      AppLanguage.bn: 'পিডিএফ প্রিভিউ উপলব্ধ নেই',
    },
    'selected_document_fallback': {
      AppLanguage.en: 'Selected document',
      AppLanguage.bn: 'নির্বাচিত ডকুমেন্ট',
    },

    // ── My applications / application detail ────────────────────────────
    'no_applications_submitted_yet': {
      AppLanguage.en: 'No applications submitted yet.',
      AppLanguage.bn: 'এখনো কোনো আবেদন জমা দেওয়া হয়নি।',
    },
    'no_applications_with_status': {
      AppLanguage.en: 'No applications with this status.',
      AppLanguage.bn: 'এই অবস্থার কোনো আবেদন নেই।',
    },
    'apply_for_new_card_action': {
      AppLanguage.en: 'Apply for a new card',
      AppLanguage.bn: 'নতুন কার্ডের জন্য আবেদন করুন',
    },
    'submitted_date_prefix': {
      AppLanguage.en: 'Submitted: {date}',
      AppLanguage.bn: 'জমা দেওয়া হয়েছে: {date}',
    },
    'status_pending': {AppLanguage.en: 'Pending', AppLanguage.bn: 'অপেক্ষমাণ'},
    'status_resubmit': {
      AppLanguage.en: 'Resubmit',
      AppLanguage.bn: 'পুনরায় জমা দিন',
    },
    'please_resubmit_document': {
      AppLanguage.en: 'Please resubmit this document.',
      AppLanguage.bn: 'অনুগ্রহ করে এই ডকুমেন্টটি পুনরায় জমা দিন।',
    },
    'document_validation_status_title': {
      AppLanguage.en: 'Document Validation Status',
      AppLanguage.bn: 'ডকুমেন্ট যাচাইয়ের অবস্থা',
    },
    'no_documents_uploaded_yet': {
      AppLanguage.en: 'No documents uploaded yet.',
      AppLanguage.bn: 'এখনো কোনো ডকুমেন্ট আপলোড করা হয়নি।',
    },
    'application_id_prefix': {
      AppLanguage.en: 'Application ID: {id}',
      AppLanguage.bn: 'আবেদন আইডি: {id}',
    },
    'submitted_on_prefix': {
      AppLanguage.en: 'Submitted On: {date}',
      AppLanguage.bn: 'জমা দেওয়ার তারিখ: {date}',
    },
    'last_updated_prefix': {
      AppLanguage.en: 'Last Updated: {date}',
      AppLanguage.bn: 'সর্বশেষ আপডেট: {date}',
    },
    'application_details_title': {
      AppLanguage.en: 'Application Details',
      AppLanguage.bn: 'আবেদনের বিস্তারিত',
    },
    'reupload_action': {
      AppLanguage.en: 'Re-upload',
      AppLanguage.bn: 'পুনরায় আপলোড করুন',
    },

    // ── Document upload ──────────────────────────────────────────────────
    'document_upload_title': {
      AppLanguage.en: 'Document Upload',
      AppLanguage.bn: 'ডকুমেন্ট আপলোড',
    },
    'card_documents_title': {
      AppLanguage.en: '{name} Documents',
      AppLanguage.bn: '{name} ডকুমেন্ট',
    },
    'document_progress_title': {
      AppLanguage.en: 'Document Progress',
      AppLanguage.bn: 'ডকুমেন্ট অগ্রগতি',
    },
    'uploaded_label': {
      AppLanguage.en: 'Uploaded',
      AppLanguage.bn: 'আপলোড হয়েছে',
    },
    'verified_label': {
      AppLanguage.en: 'Verified',
      AppLanguage.bn: 'যাচাইকৃত',
    },
    'accepted_formats_hint': {
      AppLanguage.en: 'Accepted formats: PDF, JPG, PNG. Max size 5MB per file.',
      AppLanguage.bn: 'গ্রহণযোগ্য ফরম্যাট: PDF, JPG, PNG। প্রতি ফাইল সর্বোচ্চ ৫MB।',
    },
    'upload_failed_retry': {
      AppLanguage.en: 'Upload failed. Please try again.',
      AppLanguage.bn: 'আপলোড ব্যর্থ হয়েছে। আবার চেষ্টা করুন।',
    },
    'status_not_uploaded': {
      AppLanguage.en: 'Not Uploaded',
      AppLanguage.bn: 'আপলোড করা হয়নি',
    },
    'tap_upload_hint': {
      AppLanguage.en: 'Tap upload to add this document',
      AppLanguage.bn: 'এই ডকুমেন্ট যোগ করতে আপলোডে ট্যাপ করুন',
    },
    'status_pending_review': {
      AppLanguage.en: 'Pending Review',
      AppLanguage.bn: 'পর্যালোচনাধীন',
    },
    'pending_review_subtext': {
      AppLanguage.en: 'Uploaded — awaiting admin verification',
      AppLanguage.bn: 'আপলোড হয়েছে — অ্যাডমিনের যাচাইয়ের অপেক্ষায়',
    },
    'document_accepted_subtext': {
      AppLanguage.en: 'This document has been accepted',
      AppLanguage.bn: 'এই ডকুমেন্টটি গৃহীত হয়েছে',
    },
    'please_reupload_valid_document': {
      AppLanguage.en: 'Please re-upload a valid document',
      AppLanguage.bn: 'অনুগ্রহ করে একটি বৈধ ডকুমেন্ট পুনরায় আপলোড করুন',
    },
    'view_action': {AppLanguage.en: 'View', AppLanguage.bn: 'দেখুন'},
    'opening_document_preview': {
      AppLanguage.en: 'Opening document preview…',
      AppLanguage.bn: 'ডকুমেন্ট প্রিভিউ খোলা হচ্ছে…',
    },
    'replace_action': {
      AppLanguage.en: 'Replace',
      AppLanguage.bn: 'প্রতিস্থাপন করুন',
    },
    'upload_action': {
      AppLanguage.en: 'Upload',
      AppLanguage.bn: 'আপলোড করুন',
    },

    // ── Eligibility check ─────────────────────────────────────────────────
    'check_eligibility_title': {
      AppLanguage.en: 'Check Eligibility',
      AppLanguage.bn: 'যোগ্যতা যাচাই করুন',
    },
    'eligibility_approved_title': {
      AppLanguage.en: 'Eligibility Approved',
      AppLanguage.bn: 'যোগ্যতা অনুমোদিত হয়েছে',
    },
    'eligibility_request_submitted_title': {
      AppLanguage.en: 'Request Submitted',
      AppLanguage.bn: 'অনুরোধ জমা দেওয়া হয়েছে',
    },
    'eligibility_request_rejected_title': {
      AppLanguage.en: 'Request Rejected',
      AppLanguage.bn: 'অনুরোধ প্রত্যাখ্যান করা হয়েছে',
    },
    'eligibility_approved_message': {
      AppLanguage.en:
          'Your eligibility has been confirmed by the admin. You can now apply for the cards you are eligible for.',
      AppLanguage.bn:
          'অ্যাডমিন আপনার যোগ্যতা নিশ্চিত করেছেন। এখন আপনি যোগ্য কার্ডগুলোর জন্য আবেদন করতে পারবেন।',
    },
    'eligibility_pending_message': {
      AppLanguage.en:
          'Your eligibility request has been submitted successfully. An admin will review your details and notify you of the decision.',
      AppLanguage.bn:
          'আপনার যোগ্যতা যাচাইয়ের অনুরোধ সফলভাবে জমা হয়েছে। একজন অ্যাডমিন আপনার তথ্য পর্যালোচনা করে সিদ্ধান্ত জানাবেন।',
    },
    'eligibility_rejected_message': {
      AppLanguage.en:
          'Your eligibility request was not approved. Please contact your local authority for assistance.',
      AppLanguage.bn:
          'আপনার যোগ্যতার অনুরোধ অনুমোদিত হয়নি। সহায়তার জন্য আপনার স্থানীয় কর্তৃপক্ষের সাথে যোগাযোগ করুন।',
    },
    'eligibility_notify_hint': {
      AppLanguage.en:
          'You will receive a notification once the admin reviews your request.',
      AppLanguage.bn:
          'অ্যাডমিন আপনার অনুরোধ পর্যালোচনা করলে আপনি একটি নোটিফিকেশন পাবেন।',
    },
    'apply_for_a_card_action': {
      AppLanguage.en: 'Apply for a Card',
      AppLanguage.bn: 'একটি কার্ডের জন্য আবেদন করুন',
    },
    'edit_resubmit_action': {
      AppLanguage.en: 'Edit & Resubmit',
      AppLanguage.bn: 'সম্পাদনা ও পুনরায় জমা দিন',
    },
    'eligibility_form_hint': {
      AppLanguage.en:
          'Choose one card type, then fill only the fields required for that card.',
      AppLanguage.bn:
          'একটি কার্ডের ধরন নির্বাচন করুন, তারপর শুধু সেই কার্ডের জন্য প্রয়োজনীয় ঘরগুলো পূরণ করুন।',
    },
    'select_card_type_title': {
      AppLanguage.en: 'Select Card Type',
      AppLanguage.bn: 'কার্ডের ধরন নির্বাচন করুন',
    },
    'occupation_label': {
      AppLanguage.en: 'Occupation',
      AppLanguage.bn: 'পেশা',
    },
    'occupation_required': {
      AppLanguage.en: 'Occupation is required',
      AppLanguage.bn: 'পেশা উল্লেখ করা আবশ্যক',
    },
    'monthly_income_label': {
      AppLanguage.en: 'Monthly Household Income (BDT)',
      AppLanguage.bn: 'মাসিক পারিবারিক আয় (টাকা)',
    },
    'income_hint_example': {
      AppLanguage.en: 'e.g. 10000',
      AppLanguage.bn: 'যেমন ১০০০০',
    },
    'income_required': {
      AppLanguage.en: 'Income is required',
      AppLanguage.bn: 'আয়ের তথ্য আবশ্যক',
    },
    'farmer_card_eligibility_subtitle': {
      AppLanguage.en: 'Must be ≤ 0.50 acres land, monthly income ≤ BDT 12,000',
      AppLanguage.bn: 'জমি সর্বোচ্চ ০.৫০ একর, মাসিক আয় সর্বোচ্চ ১২,০০০ টাকা হতে হবে',
    },
    'land_owned_label': {
      AppLanguage.en: 'Land Owned (Acres)',
      AppLanguage.bn: 'জমির পরিমাণ (একর)',
    },
    'land_hint_example': {
      AppLanguage.en: 'e.g. 0.50 (enter 0 if none)',
      AppLanguage.bn: 'যেমন ০.৫০ (না থাকলে ০ লিখুন)',
    },
    'land_required': {
      AppLanguage.en: 'Land information is required',
      AppLanguage.bn: 'জমির তথ্য আবশ্যক',
    },
    'enter_valid_number': {
      AppLanguage.en: 'Enter a valid number',
      AppLanguage.bn: 'সঠিক সংখ্যা লিখুন',
    },
    'has_farmer_cert_title': {
      AppLanguage.en: 'I have an Agricultural Farmer Certificate',
      AppLanguage.bn: 'আমার কৃষি কৃষক সনদ আছে',
    },
    'farmer_cert_subtitle': {
      AppLanguage.en: 'Issued by local union/ward parishad',
      AppLanguage.bn: 'স্থানীয় ইউনিয়ন/ওয়ার্ড পরিষদ কর্তৃক প্রদত্ত',
    },
    'has_ward_cert_title': {
      AppLanguage.en: 'I have a Ward/Union Certificate',
      AppLanguage.bn: 'আমার ওয়ার্ড/ইউনিয়ন সনদ আছে',
    },
    'ward_cert_subtitle': {
      AppLanguage.en: 'Confirming land holding and residence',
      AppLanguage.bn: 'জমি ও বসবাসের প্রমাণকারী',
    },
    'education_card_eligibility_subtitle': {
      AppLanguage.en: 'Requires GPA 5.00 in both SSC and HSC',
      AppLanguage.bn: 'SSC ও HSC উভয় পরীক্ষায় GPA ৫.০০ প্রয়োজন',
    },
    'ssc_gpa_optional_label': {
      AppLanguage.en: 'SSC GPA (leave blank if not applicable)',
      AppLanguage.bn: 'SSC জিপিএ (প্রযোজ্য না হলে খালি রাখুন)',
    },
    'gpa_hint_example': {
      AppLanguage.en: 'e.g. 5.00',
      AppLanguage.bn: 'যেমন ৫.০০',
    },
    'gpa_range_error': {
      AppLanguage.en: 'Enter GPA between 0.00 and 5.00',
      AppLanguage.bn: '০.০০ থেকে ৫.০০-এর মধ্যে জিপিএ লিখুন',
    },
    'hsc_gpa_optional_label': {
      AppLanguage.en: 'HSC GPA (leave blank if not applicable)',
      AppLanguage.bn: 'HSC জিপিএ (প্রযোজ্য না হলে খালি রাখুন)',
    },
    'submit_eligibility_request_action': {
      AppLanguage.en: 'Submit Eligibility Request',
      AppLanguage.bn: 'যোগ্যতা যাচাইয়ের অনুরোধ জমা দিন',
    },
    'eligibility_review_time_note': {
      AppLanguage.en:
          'Your information will be reviewed by the admin within 2–3 working days.',
      AppLanguage.bn: 'আপনার তথ্য অ্যাডমিন ২-৩ কর্মদিবসের মধ্যে পর্যালোচনা করবেন।',
    },
    'eligibility_submit_failed': {
      AppLanguage.en: 'Submission failed. Please try again.',
      AppLanguage.bn: 'জমা দেওয়া ব্যর্থ হয়েছে। আবার চেষ্টা করুন।',
    },

    // ── Profile completion ───────────────────────────────────────────────
    'skip_action': {AppLanguage.en: 'Skip', AppLanguage.bn: 'বাদ দিন'},
    'profile_completion_hint': {
      AppLanguage.en:
          'These details are used to check your eligibility for the Farmer, Family, and Education cards.',
      AppLanguage.bn:
          'এই তথ্যগুলো কৃষক, পারিবারিক ও শিক্ষা কার্ডের যোগ্যতা যাচাইয়ে ব্যবহৃত হয়।',
    },
    'date_of_birth_label': {
      AppLanguage.en: 'Date of Birth',
      AppLanguage.bn: 'জন্ম তারিখ',
    },
    'select_date_placeholder': {
      AppLanguage.en: 'Select date',
      AppLanguage.bn: 'তারিখ নির্বাচন করুন',
    },
    'gender_label': {AppLanguage.en: 'Gender', AppLanguage.bn: 'লিঙ্গ'},
    'gender_male': {AppLanguage.en: 'Male', AppLanguage.bn: 'পুরুষ'},
    'gender_female': {AppLanguage.en: 'Female', AppLanguage.bn: 'মহিলা'},
    'gender_other': {AppLanguage.en: 'Other', AppLanguage.bn: 'অন্যান্য'},
    'address_label': {AppLanguage.en: 'Address', AppLanguage.bn: 'ঠিকানা'},
    'address_required': {
      AppLanguage.en: 'Address is required',
      AppLanguage.bn: 'ঠিকানা আবশ্যক',
    },
    'ssc_gpa_label': {AppLanguage.en: 'SSC GPA', AppLanguage.bn: 'SSC জিপিএ'},
    'hsc_gpa_label': {AppLanguage.en: 'HSC GPA', AppLanguage.bn: 'HSC জিপিএ'},
    'save_continue_action': {
      AppLanguage.en: 'Save & Continue',
      AppLanguage.bn: 'সংরক্ষণ করে এগিয়ে যান',
    },
    'please_select_dob': {
      AppLanguage.en: 'Please select your date of birth',
      AppLanguage.bn: 'অনুগ্রহ করে আপনার জন্ম তারিখ নির্বাচন করুন',
    },
    'failed_save_profile': {
      AppLanguage.en: 'Failed to save profile',
      AppLanguage.bn: 'প্রোফাইল সংরক্ষণ ব্যর্থ হয়েছে',
    },

    // ── Profile ───────────────────────────────────────────────────────────
    'change_password_title': {
      AppLanguage.en: 'Change Password',
      AppLanguage.bn: 'পাসওয়ার্ড পরিবর্তন করুন',
    },
    'current_password_label': {
      AppLanguage.en: 'Current Password',
      AppLanguage.bn: 'বর্তমান পাসওয়ার্ড',
    },
    'new_password_label': {
      AppLanguage.en: 'New Password',
      AppLanguage.bn: 'নতুন পাসওয়ার্ড',
    },
    'at_least_6_chars': {
      AppLanguage.en: 'At least 6 characters',
      AppLanguage.bn: 'কমপক্ষে ৬ অক্ষর',
    },
    'save_action': {AppLanguage.en: 'Save', AppLanguage.bn: 'সংরক্ষণ করুন'},
    'password_changed_success': {
      AppLanguage.en: 'Password changed successfully',
      AppLanguage.bn: 'পাসওয়ার্ড সফলভাবে পরিবর্তিত হয়েছে',
    },
    'failed_change_password': {
      AppLanguage.en: 'Failed to change password',
      AppLanguage.bn: 'পাসওয়ার্ড পরিবর্তন ব্যর্থ হয়েছে',
    },
    'phone_field_label': {AppLanguage.en: 'Phone', AppLanguage.bn: 'ফোন'},
    'edit_profile_action': {
      AppLanguage.en: 'Edit Profile',
      AppLanguage.bn: 'প্রোফাইল সম্পাদনা করুন',
    },

    // ── Distribution history (citizen) ──────────────────────────────────
    'distribution_history_title': {
      AppLanguage.en: 'Distribution History',
      AppLanguage.bn: 'বিতরণের ইতিহাস',
    },
    'no_fund_disbursements_yet': {
      AppLanguage.en: 'No fund disbursements yet.',
      AppLanguage.bn: 'এখনো কোনো তহবিল বিতরণ হয়নি।',
    },

    // ── Shared widgets (citizen/admin) ──────────────────────────────────
    'try_again_action': {
      AppLanguage.en: 'Try Again',
      AppLanguage.bn: 'আবার চেষ্টা করুন',
    },
    'error_prefix': {
      AppLanguage.en: 'Error: {message}',
      AppLanguage.bn: 'ত্রুটি: {message}',
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

  /// [tr] with `{placeholder}` substitution, e.g.
  /// `context.trp('confirm_deactivate_body', {'name': citizen.fullName})`.
  String trp(String key, Map<String, String> params) {
    var value = tr(key);
    for (final entry in params.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }
    return value;
  }

  /// Non-reactive version of [trp], safe outside build().
  String trsp(String key, Map<String, String> params) {
    var value = trs(key);
    for (final entry in params.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }
    return value;
  }
}

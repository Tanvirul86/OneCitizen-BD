import 'package:flutter/material.dart';
import 'package:onecitizen/config/app_theme.dart';

/// Small floating chat bubble for the landing page — answers basic
/// app-related questions (what is this app / what services / what to do)
/// from a canned FAQ set. Understands Bangla, English, and Banglish input.
class ChatbotFab extends StatelessWidget {
  const ChatbotFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'chatbot-fab',
      onPressed: () => _openChat(context),
      backgroundColor: AppTheme.primaryGreen,
      child: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
    );
  }

  void _openChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChatSheet(),
    );
  }
}

class _ChatMessage {
  const _ChatMessage(this.text, this.fromUser);
  final String text;
  final bool fromUser;
}

class _ChatSheet extends StatefulWidget {
  const _ChatSheet();

  @override
  State<_ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<_ChatSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      "Hi! I'm the OneCitizen BD assistant 🙂 Ask me anything about the app "
      "— Bangla, English, or Banglish all work.\n\n"
      "আমি OneCitizen BD সহকারী। বাংলা, ইংরেজি বা বাংলিশ — যেকোনো ভাষায় প্রশ্ন করতে পারেন।",
      false,
    ),
  ];

  static const _suggestions = [
    'What type of app is this?',
    'What services can I get?',
    'What do I need to do?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send([String? preset]) {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text, true));
      _messages.add(_ChatMessage(_botReply(text), false));
      _controller.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: FractionallySizedBox(
        heightFactor: 0.78,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.support_agent_rounded, color: AppTheme.primaryGreen),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OneCitizen BD Assistant',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          Text(
                            'Usually replies instantly',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) => _Bubble(message: _messages[index]),
                ),
              ),
              if (_messages.length <= 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestions
                        .map(
                          (q) => ActionChip(
                            label: Text(q, style: const TextStyle(fontSize: 12)),
                            backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.08),
                            side: BorderSide(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                            onPressed: () => _send(q),
                          ),
                        )
                        .toList(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Type your question…',
                          filled: true,
                          fillColor: AppTheme.surfaceLight,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryGreen,
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        onPressed: _send,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.fromUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryGreen : AppTheme.surfaceLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : AppTheme.textPrimary,
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

/// Keyword-matched FAQ engine — no network call, just canned bilingual
/// answers, since this is a static in-app assistant, not a real LLM chat.
String _botReply(String rawInput) {
  final input = rawInput.toLowerCase();
  bool has(List<String> keywords) => keywords.any(input.contains);

  if (has(['hi', 'hello', 'hey', 'assalamualaikum', 'আসসালামু', 'সালাম', 'হ্যালো', 'হাই'])) {
    return "Hello! 👋 How can I help you with OneCitizen BD today?\n"
        "হ্যালো! আজ আমি আপনাকে কীভাবে সাহায্য করতে পারি?";
  }

  if (has(['thank', 'dhonnobad', 'ধন্যবাদ'])) {
    return "You're welcome! Let me know if you have more questions.\n"
        "আপনাকে স্বাগতম! আরও কিছু জানতে চাইলে জিজ্ঞেস করুন।";
  }

  if (has([
    'what type', 'what kind', 'ki type', 'ki dhoroner', 'কী ধরনের', 'কি ধরনের',
    'what is this app', 'what is onecitizen', 'ei app ki', 'app ta ki', 'app ki',
  ])) {
    return "OneCitizen BD is an official Government of Bangladesh platform for "
        "managing welfare cards — Farmer, Family, and Education cards — all in "
        "one mobile app.\n\n"
        "OneCitizen BD হলো বাংলাদেশ সরকারের একটি অফিসিয়াল প্ল্যাটফর্ম, যেখানে Farmer, "
        "Family ও Education কার্ড একটি অ্যাপ থেকেই পরিচালনা করা যায়।";
  }

  if (has(['service', 'সার্ভিস', 'সেবা', 'card', 'কার্ড', 'ki ki pabo', 'কী কী পাব', 'কি কি পাবো', 'benefit'])) {
    return "You can get 3 welfare cards:\n"
        "🌾 Farmer Card — for registered farmers\n"
        "👨‍👩‍👧 Family Card — for low-income families\n"
        "🎓 Education Card — for students with GPA 5.00 in SSC & HSC\n\n"
        "আপনি ৩টি কার্ড পেতে পারেন — Farmer, Family এবং Education Card, শর্ত পূরণ সাপেক্ষে।";
  }

  if (has([
    'ki korte hobe', 'কী করতে হবে', 'কি করতে হবে', 'what do i need to do',
    'how to start', 'কিভাবে শুরু', 'kivabe shuru', 'steps', 'how does it work',
  ])) {
    return "Just 4 steps:\n"
        "1️⃣ Register & complete your profile\n"
        "2️⃣ Check eligibility\n"
        "3️⃣ Apply & upload documents\n"
        "4️⃣ Get approved & receive your card\n\n"
        "চারটি ধাপ — Register করুন, Eligibility চেক করুন, Apply করে ডকুমেন্ট Upload করুন, "
        "এবং Approval পেলে কার্ড পাবেন।";
  }

  if (has(['register', 'sign up', 'রেজিস্ট্রেশন', 'রেজিস্টার', 'akaunt', 'account khulbo'])) {
    return "Tap \"Create Account\" on this page and fill in your NID, name, "
        "email, phone, and a password to register.\n\n"
        "এই পেজে \"Create Account\"-এ ট্যাপ করে আপনার NID, নাম, ইমেইল, ফোন ও পাসওয়ার্ড "
        "দিয়ে রেজিস্ট্রেশন করুন।";
  }

  if (has(['log in', 'login', 'সাইন ইন', 'sign in', 'লগইন', 'লগ ইন'])) {
    return "Tap \"Sign In\" and enter the email and password you registered with.\n\n"
        "\"Sign In\"-এ ট্যাপ করে আপনার রেজিস্টার করা ইমেইল ও পাসওয়ার্ড দিয়ে লগইন করুন।";
  }

  if (has(['eligib', 'যোগ্য', 'qualify', 'jogyo'])) {
    return "After logging in, go to \"Check Eligibility\", fill in your "
        "occupation, income, land, or GPA info, and submit — the admin will "
        "review and confirm.\n\n"
        "লগইন করার পর \"Check Eligibility\"-তে গিয়ে পেশা, আয়, জমি বা GPA তথ্য দিয়ে জমা "
        "দিন — অ্যাডমিন যাচাই করে নিশ্চিত করবে।";
  }

  if (has(['document', 'ডকুমেন্ট', 'কাগজ', 'upload', 'আপলোড'])) {
    return "Once your eligibility is approved, upload required documents "
        "(like NID or certificates) from the \"Upload Docs\" section.\n\n"
        "Eligibility অনুমোদিত হলে \"Upload Docs\" থেকে প্রয়োজনীয় ডকুমেন্ট (NID, "
        "সার্টিফিকেট ইত্যাদি) আপলোড করুন।";
  }

  if (has(['free', 'cost', 'টাকা', 'ফি', 'fee', 'price', 'koto taka', 'কত টাকা'])) {
    return "OneCitizen BD is completely free to use — no charges for "
        "registration, application, or tracking.\n\n"
        "OneCitizen BD সম্পূর্ণ বিনামূল্যে — রেজিস্ট্রেশন, আবেদন বা ট্র্যাকিং করার জন্য কোনো "
        "টাকা লাগে না।";
  }

  return "Sorry, I didn't quite catch that 🙏 Try asking things like "
      "\"What type of app is this?\", \"What services can I get?\", or "
      "\"What do I need to do?\"\n\n"
      "দুঃখিত, বুঝতে পারিনি। এভাবে জিজ্ঞেস করে দেখুন — \"এটা কী ধরনের অ্যাপ?\", \"কী কী "
      "সেবা পাব?\", অথবা \"কী করতে হবে?\"";
}

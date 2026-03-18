import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Data model ────────────────────────────────────────────────────────────────
class LegalSection {
  final String title;
  final String body;
  const LegalSection({required this.title, required this.body});
}

// ── Reusable bottom sheet ─────────────────────────────────────────────────────
class LegalSheet extends StatelessWidget {
  final String title;
  final List<LegalSection> sections;

  const LegalSheet({super.key, required this.title, required this.sections});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Handle + header ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.onSurface.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: scheme.onSurface.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Divider(
                        color: scheme.onSurface.withValues(alpha: 0.10)),
                  ],
                ),
              ),

              // ── Scrollable content ───────────────────────────────────
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  itemCount: sections.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 24),
                  itemBuilder: (_, i) {
                    final s = sections[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.body,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 13.5,
                            height: 1.7,
                            color:
                                scheme.onSurface.withValues(alpha: 0.70),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Static legal content for Loomeé ──────────────────────────────────────────
class LegalContent {
  LegalContent._();

  static const List<LegalSection> termsOfService = [
    LegalSection(
      title: 'Effective Date',
      body:
          'These Terms of Service ("Terms") are effective as of March 2026 and '
          'apply to all users of the Loomeé mobile application ("App"). By '
          'creating an account or using the App, you agree to be bound by these '
          'Terms. If you do not agree, please do not use the App.',
    ),
    LegalSection(
      title: '1. Description of Service',
      body:
          'Loomeé provides a virtual fashion try-on platform that allows users to '
          'upload personal photos, input body measurements, and digitally overlay '
          'clothing items onto their images. The App is intended for personal, '
          'non-commercial use only.',
    ),
    LegalSection(
      title: '2. User Accounts',
      body:
          'You must create an account to access the App\'s features. You are '
          'responsible for maintaining the confidentiality of your login '
          'credentials and for all activity that occurs under your account. You '
          'must be at least 16 years of age to create an account. You agree to '
          'provide accurate and complete information during registration and to '
          'keep it up to date.',
    ),
    LegalSection(
      title: '3. User Content & Uploaded Photos',
      body:
          'When you upload photos or provide body measurements ("User Content"), '
          'you grant Loomeé a limited, non-exclusive licence to process and store '
          'that content solely for the purpose of delivering the virtual try-on '
          'service to you. You retain full ownership of your User Content. '
          'You must only upload photos of yourself. You must not upload photos '
          'of third parties without their explicit consent. Loomeé does not sell '
          'or share your photos with third parties for marketing purposes.',
    ),
    LegalSection(
      title: '4. Intellectual Property',
      body:
          'All clothing catalogue images, brand assets, software, and content '
          'within the App (excluding User Content) are the property of Loomeé '
          'or its licensors and are protected by applicable intellectual property '
          'laws. You may not reproduce, distribute, or create derivative works '
          'from any App content without prior written permission.',
    ),
    LegalSection(
      title: '5. Prohibited Use',
      body:
          'You agree not to: (a) use the App for any unlawful purpose; '
          '(b) attempt to reverse-engineer or tamper with the App; '
          '(c) upload content that is offensive, defamatory, or infringes '
          'third-party rights; (d) use automated tools to scrape or extract data '
          'from the App; or (e) circumvent any access controls or security '
          'measures.',
    ),
    LegalSection(
      title: '6. Disclaimer of Warranties',
      body:
          'The App is provided on an "as is" and "as available" basis. Loomeé '
          'makes no warranties, express or implied, including fitness for a '
          'particular purpose or that the App will be error-free or '
          'uninterrupted. Virtual try-on results are approximations and may not '
          'perfectly represent how a garment will fit or look in reality.',
    ),
    LegalSection(
      title: '7. Limitation of Liability',
      body:
          'To the fullest extent permitted by law, Loomeé shall not be liable '
          'for any indirect, incidental, or consequential damages arising from '
          'your use of the App, including but not limited to purchasing decisions '
          'made based on virtual try-on results.',
    ),
    LegalSection(
      title: '8. Changes to These Terms',
      body:
          'Loomeé may update these Terms from time to time. Continued use of the '
          'App after changes are posted constitutes your acceptance of the '
          'revised Terms. We will notify users of material changes via in-app '
          'notification or email.',
    ),
    LegalSection(
      title: '9. Governing Law',
      body:
          'These Terms are governed by the laws of the jurisdiction in which '
          'Loomeé is incorporated, without regard to conflict of law principles.',
    ),
    LegalSection(
      title: '10. Contact Us',
      body: 'If you have any questions about these Terms, please contact us at:\n'
          'support@loomeeapp.com',
    ),
  ];

  static const List<LegalSection> privacyPolicy = [
    LegalSection(
      title: 'Effective Date',
      body:
          'This Privacy Policy ("Policy") is effective as of March 2026. It '
          'describes how Loomeé ("we", "us") collects, uses, and protects your '
          'personal information when you use our App. We are committed to '
          'handling your data with transparency and care.',
    ),
    LegalSection(
      title: '1. Information We Collect',
      body: 'We collect the following categories of information:\n\n'
          '• Account Information: Name and email address provided at registration.\n\n'
          '• Body Measurements: Height, weight, chest, waist, hips, and shoulder '
          'width that you voluntarily input to personalise your experience.\n\n'
          '• Uploaded Photos: Images you upload to use as the base for virtual '
          'try-ons. These are stored securely and linked only to your account.\n\n'
          '• Try-On History: Records of garments you have virtually tried on, '
          'including generated result images.\n\n'
          '• Usage Data: Anonymous analytics such as feature interactions and '
          'session duration, used to improve the App.',
    ),
    LegalSection(
      title: '2. How We Use Your Information',
      body: 'Your information is used to:\n\n'
          '• Authenticate your account and maintain session security.\n'
          '• Process virtual try-ons by overlaying clothing onto your uploaded '
          'photos using your body measurements.\n'
          '• Provide personalised size recommendations and clothing suggestions.\n'
          '• Improve the accuracy and performance of our try-on technology.\n'
          '• Send transactional communications (e.g. password reset emails).\n'
          '• Comply with legal obligations.',
    ),
    LegalSection(
      title: '3. Body Measurements & Photos',
      body:
          'We treat your body measurements and photos as sensitive personal data. '
          'They are encrypted at rest and in transit, accessible only to you and '
          'the systems required to deliver the try-on service. We do not use your '
          'photos to train external AI models or share them with third-party '
          'advertisers under any circumstances.',
    ),
    LegalSection(
      title: '4. Data Retention',
      body:
          'We retain your account data and uploaded photos for as long as your '
          'account is active. You may delete your photos or measurements at any '
          'time within the App. Upon account deletion, all personally identifiable '
          'data is permanently removed within 30 days, except where retention is '
          'required by law.',
    ),
    LegalSection(
      title: '5. Data Sharing',
      body: 'We do not sell your personal data. We may share data with:\n\n'
          '• Cloud infrastructure providers (e.g. storage, compute) under strict '
          'data processing agreements.\n'
          '• Analytics services that process only anonymised, aggregated data.\n'
          '• Law enforcement or regulatory bodies when required by applicable law.',
    ),
    LegalSection(
      title: '6. Security',
      body:
          'We implement industry-standard security measures including TLS '
          'encryption for data in transit, AES-256 encryption for data at rest, '
          'and access controls limiting who can view your data. However, no '
          'method of transmission over the internet is completely secure, and we '
          'cannot guarantee absolute security.',
    ),
    LegalSection(
      title: '7. Your Rights',
      body: 'Depending on your jurisdiction, you may have the right to:\n\n'
          '• Access the personal data we hold about you.\n'
          '• Request correction of inaccurate data.\n'
          '• Request deletion of your data ("right to be forgotten").\n'
          '• Object to or restrict certain processing activities.\n'
          '• Receive your data in a portable format.\n\n'
          'To exercise any of these rights, contact us at privacy@loomeeapp.com.',
    ),
    LegalSection(
      title: '8. Cookies & Analytics',
      body:
          'The App uses local storage and anonymous analytics to remember your '
          'preferences and understand usage patterns. No third-party advertising '
          'cookies are used. Analytics data is aggregated and cannot be used to '
          'identify you individually.',
    ),
    LegalSection(
      title: '9. Children\'s Privacy',
      body:
          'The App is not intended for users under the age of 16. We do not '
          'knowingly collect personal information from children. If we become '
          'aware that a child under 16 has provided us with personal data, we '
          'will promptly delete it.',
    ),
    LegalSection(
      title: '10. Changes to This Policy',
      body:
          'We may update this Privacy Policy periodically. We will notify you of '
          'significant changes via in-app notification or email. Your continued '
          'use of the App after changes are posted constitutes acceptance of the '
          'updated Policy.',
    ),
    LegalSection(
      title: '11. Contact Us',
      body:
          'For privacy-related enquiries or to exercise your data rights, '
          'please contact:\n'
          'privacy@loomeeapp.com',
    ),
  ];
}

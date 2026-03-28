import 'package:flutter/material.dart';

class WebviewPage extends StatelessWidget {
  final String title;

  const WebviewPage({
    super.key,
    required this.title,
    // The url parameter is kept for compatibility with the router signature,
    // but we use native Flutter widgets instead of a webview now.
    String url = '', 
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Generate some placeholder legal text based on the title
    final isPrivacy = title.toLowerCase().contains('privacy');
    final contentText = isPrivacy
        ? '1. Introduction\nWelcome to SabiStyle. We are committed to protecting your personal information and your right to privacy.\n\n2. Information we collect\nWe collect personal information that you provide to us when you register, such as your name, email, and address.\n\n3. How we use your info\nWe use your information to fulfill orders, provide support, and send promotional offers if you opted in.'
        : '1. Agreement to Terms\nBy using SabiStyle, you agree to these Terms and Conditions. Please read them carefully.\n\n2. User Accounts\nYou are responsible for safeguarding the password that you use to access the service and for any activities or actions under your password.\n\n3. Purchases\nIf you wish to purchase any product made available through the app, you may be asked to supply certain information relevant to your Purchase.';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              contentText,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


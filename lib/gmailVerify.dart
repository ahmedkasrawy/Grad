import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class SendMailScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  Future<void> sendMail(String recipientEmail) async {
    const String senderEmail = 'ahmed.amr7007@gmail.com'; // Replace with your Gmail
    const String senderPassword = '751953'; // Replace with an app password

    // Configure the Gmail SMTP server
    final smtpServer = gmail(senderEmail, senderPassword);

    // Create the email message
    final message = Message()
      ..from = Address(senderEmail, 'Your App Name')
      ..recipients.add(recipientEmail)
      ..subject = 'Glooko Verification'
      ..text = 'Welcome to Glooko!';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: $sendReport');
    } on MailerException catch (e) {
      print('Message not sent: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Enter recipient email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final email = emailController.text.trim();
                if (email.isNotEmpty) {
                  sendMail(email);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter an email address')),
                  );
                }
              },
              child: const Text('Send Email'),
            ),
          ],
        ),
      ),
    );
  }
}

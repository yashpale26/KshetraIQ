import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kshetraiq/screens/ai_chatbot_screen.dart';
import 'package:kshetraiq/theme/app_colors.dart';

class AiChatHistoryScreen extends StatelessWidget {
  const AiChatHistoryScreen({super.key});

  static const LinearGradient _bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFA2E1BA),
      Color(0xFFFCF3CF),
      Color(0xFFEADBC8),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: _bgGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.forestGreen),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'AI Chat History',
            style: TextStyle(
              color: AppColors.forestGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PREVIOUS CONVERSATIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestGreen,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('ai_chat_history')
                      .orderBy('lastUpdated', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.forestGreen,
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No saved chat conversations.',
                          style: TextStyle(color: AppColors.burntUmber),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data();
                        final title = data['title'] ?? 'Chat Conversation';
                        final sessionId = data['sessionId'] ?? '';
                        final Timestamp? ts =
                        data['lastUpdated'] as Timestamp?;
                        final dateStr = ts != null
                            ? DateFormat('dd MMM yyyy, hh:mm a')
                            .format(ts.toDate())
                            : 'Recently';

                        final messages = (data['messages'] as List?)
                            ?.map((m) => Map<String, String>.from(m))
                            .toList() ??
                            [];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBackground
                                .withOpacity(0.85),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.sageBorder.withOpacity(0.6),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.forestGreen.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_rounded,
                                color: AppColors.forestGreen,
                                size: 22,
                              ),
                            ),
                            title: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.burntUmber,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                '$dateStr • ${messages.length} messages',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.burntUmber.withOpacity(0.8),
                                ),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.softTerracotta,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AiChatbotScreen(
                                    initialMessages: messages,
                                    initialSessionId: sessionId,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
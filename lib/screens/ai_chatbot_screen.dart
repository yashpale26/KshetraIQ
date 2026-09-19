import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kshetraiq/screens/ai_chat_history_screen.dart';
import 'package:kshetraiq/services/ai_service_open_router.dart';
import 'package:kshetraiq/theme/app_colors.dart';

class AiChatbotScreen extends StatefulWidget {
  final List<Map<String, String>>? initialMessages;
  final String? initialSessionId;

  const AiChatbotScreen({
    super.key,
    this.initialMessages,
    this.initialSessionId,
  });

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  static const LinearGradient _bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFA2E1BA),
      Color(0xFFFCF3CF),
      Color(0xFFEADBC8),
    ],
  );

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String? _sessionId;

  // Selected context parameters
  String? _selectedFarmName;
  Map<String, dynamic>? _selectedFarmData;

  String? _selectedAnalysisTitle;
  Map<String, dynamic>? _selectedAnalysisData;

  @override
  void initState() {
    super.initState();
    if (widget.initialMessages != null && widget.initialMessages!.isNotEmpty) {
      _messages = List.from(widget.initialMessages!);
      _sessionId = widget.initialSessionId;
    } else {
      _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _messages.add({
        'role': 'assistant',
        'content':
        'Hello! I am your KshetraIQ Assistant. Select a farm or an analysis record from the suggestions below, or feel free to ask me any agricultural question directly!',
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _messageController.clear();

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final aiResponse = await AIService.chatWithAssistant(
        messages: _messages,
        selectedFarmData: _selectedFarmData,
        selectedAnalysisData: _selectedAnalysisData,
      );

      setState(() {
        _messages.add({'role': 'assistant', 'content': aiResponse});
      });

      // Save/Update chat history to Firestore
      await _saveChatToFirestore();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chat Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  Future<void> _saveChatToFirestore() async {
    if (_sessionId == null || _messages.length <= 1) return;

    final firstUserMsg = _messages.firstWhere(
          (m) => m['role'] == 'user',
      orElse: () => {'content': 'General Conversation'},
    )['content']!;

    final title = firstUserMsg.length > 30
        ? '${firstUserMsg.substring(0, 30)}...'
        : firstUserMsg;

    await FirebaseFirestore.instance
        .collection('ai_chat_history')
        .doc(_sessionId)
        .set({
      'sessionId': _sessionId,
      'title': title,
      'lastUpdated': FieldValue.serverTimestamp(),
      'messages': _messages,
      'selectedFarm': _selectedFarmName,
      'selectedAnalysis': _selectedAnalysisTitle,
    }, SetOptions(merge: true));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

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
            'KshetraIQ Assistant',
            style: TextStyle(
              color: AppColors.forestGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.history_rounded,
                color: AppColors.forestGreen,
                size: 26,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AiChatHistoryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // SUGGESTIONS BAR (FARMS & ANALYSIS HISTORY)
              _buildSuggestionsSection(),

              // CHAT MESSAGES LIST
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg['role'] == 'user';
                    return _buildChatBubble(msg['content'] ?? '', isUser);
                  },
                ),
              ),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.forestGreen,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'KshetraIQ is thinking...',
                        style: TextStyle(
                          color: AppColors.forestGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // INPUT BAR
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CONTEXT SUGGESTIONS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestGreen,
                    letterSpacing: 1.0,
                  ),
                ),
                if (_selectedFarmName != null || _selectedAnalysisTitle != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFarmName = null;
                        _selectedFarmData = null;
                        _selectedAnalysisTitle = null;
                        _selectedAnalysisData = null;
                      });
                    },
                    child: const Text(
                      'Clear Active Context',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.softTerracotta,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // STREAM FOR FARMS MODULE DATA
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('farms')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    final docs = snapshot.data!.docs;
                    return Row(
                      children: docs.map((doc) {
                        final data = doc.data();
                        final farmName = data['farmName'] ?? 'Farm';
                        final isSelected = _selectedFarmName == farmName;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            avatar: const Icon(Icons.agriculture_rounded,
                                size: 16, color: AppColors.forestGreen),
                            label: Text('Farm: $farmName'),
                            selected: isSelected,
                            selectedColor: AppColors.forestGreen.withOpacity(0.25),
                            backgroundColor:
                            AppColors.secondaryBackground.withOpacity(0.9),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.forestGreen
                                  : AppColors.burntUmber,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedFarmName = farmName;
                                  _selectedFarmData = data;
                                  _selectedAnalysisTitle = null;
                                  _selectedAnalysisData = null;
                                } else {
                                  _selectedFarmName = null;
                                  _selectedFarmData = null;
                                }
                              });
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                // STREAM FOR ANALYSIS HISTORY SUGGESTIONS
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('ai_history')
                      .orderBy('timestamp', descending: true)
                      .limit(5)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    final docs = snapshot.data!.docs;
                    return Row(
                      children: docs.map((doc) {
                        final data = doc.data();
                        final title = data['title'] ?? 'Analysis';
                        final type = data['type'] ?? 'ANALYSIS';
                        final isSelected = _selectedAnalysisTitle == title;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            avatar: Icon(
                              type == 'IMAGE_ANALYSIS'
                                  ? Icons.image_search_rounded
                                  : Icons.analytics_rounded,
                              size: 16,
                              color: AppColors.forestGreen,
                            ),
                            label: Text('Report: $title'),
                            selected: isSelected,
                            selectedColor: AppColors.forestGreen.withOpacity(0.25),
                            backgroundColor:
                            AppColors.secondaryBackground.withOpacity(0.9),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.forestGreen
                                  : AppColors.burntUmber,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedAnalysisTitle = title;
                                  _selectedAnalysisData =
                                  Map<String, dynamic>.from(
                                      data['resultData'] ?? {});
                                  _selectedFarmName = null;
                                  _selectedFarmData = null;
                                } else {
                                  _selectedAnalysisTitle = null;
                                  _selectedAnalysisData = null;
                                }
                              });
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.forestGreen
              : AppColors.secondaryBackground.withOpacity(0.95),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: Border.all(
            color: isUser
                ? AppColors.forestGreen
                : AppColors.sageBorder.withOpacity(0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : AppColors.burntUmber,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white.withOpacity(0.4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: AppColors.burntUmber),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: _selectedFarmName != null
                    ? 'Ask about $_selectedFarmName...'
                    : _selectedAnalysisTitle != null
                    ? 'Ask about $_selectedAnalysisTitle report...'
                    : 'Ask KshetraIQ AI anything...',
                hintStyle: TextStyle(
                  color: AppColors.burntUmber.withOpacity(0.5),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: AppColors.secondaryBackground.withOpacity(0.9),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.sageBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.forestGreen),
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.forestGreen,
            radius: 22,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
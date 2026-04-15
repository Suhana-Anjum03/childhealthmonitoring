import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class ParentChatbotScreen extends StatefulWidget {
  const ParentChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ParentChatbotScreen> createState() => _ParentChatbotScreenState();
}

class _ParentChatbotScreenState extends State<ParentChatbotScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      'Hello! I\'m your medical assistant chatbot. I can provide basic first-aid guidance and home remedies.\n\n'
      '⚠️ IMPORTANT: For serious medical issues, please consult your doctor immediately.\n\n'
      'How can I help you today?',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add({
        'isUser': false,
        'message': message,
        'time': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add({
        'isUser': true,
        'message': message,
        'time': DateTime.now(),
      });
    });
    _scrollToBottom();
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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _addUserMessage(userMessage);
    _messageController.clear();

    // Simulate bot response
    Future.delayed(const Duration(milliseconds: 500), () {
      final response = _getBotResponse(userMessage.toLowerCase());
      _addBotMessage(response);
    });
  }

  String _getBotResponse(String message) {
    // Simple keyword-based responses
    if (message.contains('fever')) {
      return '🌡️ For Fever:\n\n'
          '• Keep the child hydrated with plenty of fluids\n'
          '• Use a cool compress on the forehead\n'
          '• Dress in light clothing\n'
          '• Monitor temperature regularly\n'
          '• Give paracetamol as per doctor\'s advice\n\n'
          '⚠️ Consult doctor if fever is above 102°F or lasts more than 3 days.';
    } else if (message.contains('cough') || message.contains('cold')) {
      return '🤧 For Cough & Cold:\n\n'
          '• Keep the child warm\n'
          '• Give warm liquids like soup or warm water\n'
          '• Use a humidifier in the room\n'
          '• Ensure adequate rest\n'
          '• Honey (for children above 1 year) can help soothe throat\n\n'
          '⚠️ Consult doctor if symptoms worsen or persist beyond a week.';
    } else if (message.contains('vomit') || message.contains('nausea')) {
      return '🤢 For Vomiting:\n\n'
          '• Give small sips of water frequently\n'
          '• Avoid solid food initially\n'
          '• Try ORS (Oral Rehydration Solution)\n'
          '• Keep the child in a comfortable position\n'
          '• Gradually introduce bland foods\n\n'
          '⚠️ Seek immediate medical help if there\'s blood in vomit or severe dehydration.';
    } else if (message.contains('diarrhea') || message.contains('loose motion')) {
      return '💧 For Diarrhea:\n\n'
          '• Give ORS frequently to prevent dehydration\n'
          '• Continue breastfeeding (for infants)\n'
          '• Avoid dairy products temporarily\n'
          '• Give BRAT diet (Banana, Rice, Applesauce, Toast)\n'
          '• Maintain hygiene\n\n'
          '⚠️ Consult doctor if diarrhea persists for more than 2 days or if there\'s blood in stool.';
    } else if (message.contains('rash') || message.contains('skin')) {
      return '🩹 For Skin Rash:\n\n'
          '• Keep the affected area clean and dry\n'
          '• Avoid scratching\n'
          '• Use mild, fragrance-free soap\n'
          '• Apply calamine lotion if itchy\n'
          '• Dress in loose, cotton clothing\n\n'
          '⚠️ Consult doctor if rash spreads, has pus, or is accompanied by fever.';
    } else if (message.contains('cut') || message.contains('wound') || message.contains('injury')) {
      return '🩹 For Minor Cuts & Wounds:\n\n'
          '• Clean the wound with clean water\n'
          '• Apply gentle pressure to stop bleeding\n'
          '• Apply antiseptic cream\n'
          '• Cover with a clean bandage\n'
          '• Change bandage daily\n\n'
          '⚠️ Seek immediate medical help for deep cuts, excessive bleeding, or signs of infection.';
    } else if (message.contains('burn')) {
      return '🔥 For Minor Burns:\n\n'
          '• Immediately cool the burn with running water (10-15 minutes)\n'
          '• Do NOT apply ice directly\n'
          '• Cover with a clean, dry cloth\n'
          '• Do NOT pop blisters\n'
          '• Give pain relief as advised by doctor\n\n'
          '⚠️ For severe burns, seek immediate medical attention.';
    } else if (message.contains('stomach') || message.contains('pain')) {
      return '🤕 For Stomach Pain:\n\n'
          '• Let the child rest\n'
          '• Give small amounts of clear fluids\n'
          '• Avoid heavy or spicy foods\n'
          '• Apply a warm compress on the stomach\n'
          '• Monitor for other symptoms\n\n'
          '⚠️ Consult doctor immediately if pain is severe, persistent, or accompanied by vomiting/fever.';
    } else if (message.contains('sleep') || message.contains('insomnia')) {
      return '😴 For Better Sleep:\n\n'
          '• Maintain a regular sleep schedule\n'
          '• Create a calm bedtime routine\n'
          '• Ensure the room is dark and quiet\n'
          '• Avoid screen time before bed\n'
          '• Give a warm bath before sleep\n\n'
          '💡 Consistent routine helps children sleep better.';
    } else if (message.contains('appetite') || message.contains('eating')) {
      return '🍽️ For Poor Appetite:\n\n'
          '• Offer small, frequent meals\n'
          '• Make food visually appealing\n'
          '• Avoid forcing the child to eat\n'
          '• Include favorite healthy foods\n'
          '• Ensure adequate hydration\n\n'
          '⚠️ Consult doctor if poor appetite persists or child loses weight.';
    } else if (message.contains('thank')) {
      return 'You\'re welcome! Remember, I\'m here for basic guidance only. For any serious concerns, please consult your doctor. Stay healthy! 😊';
    } else if (message.contains('hello') || message.contains('hi')) {
      return 'Hello! How can I assist you today? You can ask me about common childhood health issues, first aid, or home remedies.';
    } else {
      return 'I can help you with:\n\n'
          '• Fever management\n'
          '• Cough & cold remedies\n'
          '• Stomach issues\n'
          '• Minor injuries & burns\n'
          '• Skin rashes\n'
          '• Sleep problems\n'
          '• Appetite issues\n\n'
          'Please ask me about any specific concern, or type your symptoms.\n\n'
          '⚠️ Remember: For serious issues, always consult your doctor!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.info.withOpacity(0.1),
          child: Row(
            children: const [
              Icon(Icons.info_outline, color: AppColors.info, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This chatbot provides basic guidance only. For serious issues, consult your doctor.',
                  style: TextStyle(fontSize: 12, color: AppColors.info),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.smart_toy_outlined,
                        size: 80,
                        color: AppColors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Medical Assistant Chatbot',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ask me about first aid and home remedies',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessageBubble(
                      message['message'],
                      message['isUser'],
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your question...',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppColors.parentColor,
                child: IconButton(
                  icon: const Icon(Icons.send, color: AppColors.white),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.parentColor : AppColors.greyLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const Icon(Icons.smart_toy, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                message,
                style: TextStyle(
                  color: isUser ? AppColors.white : AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

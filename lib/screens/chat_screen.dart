import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../services/guide_chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({this.pathTitle, super.key});

  final String? pathTitle;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _service = GuideChatService();
  final List<({String role, String text})> _messages = [
    (
      role: 'assistant',
      text:
          'Merhaba! Kariyer hedefini netleştirmek veya öğrenme yolundaki '
          'bir sonraki adımı seçmek için buradayım. Nereden başlamak istersin?',
    ),
  ];
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? suggestion]) async {
    final text = (suggestion ?? _controller.text).trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _messages.add((role: 'user', text: text));
      _controller.clear();
      _sending = true;
      _error = null;
    });
    _scrollToEnd();

    try {
      final answer = await _service.reply(
        history: List.unmodifiable(_messages),
        pathTitle: widget.pathTitle,
      );
      if (!mounted) return;
      setState(() => _messages.add((role: 'assistant', text: answer)));
      _scrollToEnd();
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Firebase yanıtı alınamadı: ${error.message}');
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Rehber yanıt veremedi: $error');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.pathTitle == null ? 'Akıllı Eğitim Asistanı' : 'Yol Rehberi';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 14),
          child: Row(
            children: [
              if (widget.pathTitle != null) ...[
                IconButton(
                  tooltip: 'Öğrenme yoluna dön',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 4),
              ],
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4E9FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF335CFF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      widget.pathTitle ?? 'Öğrenme yolculuğunda yanında',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF74756F)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            itemCount: _messages.length + (_sending ? 1 : 0),
            itemBuilder: (context, index) {
              if (_sending && index == _messages.length) {
                return const _TypingIndicator();
              }
              final message = _messages[index];
              return _MessageBubble(message: message);
            },
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
            child: Text(
              _error!,
              style: const TextStyle(color: Color(0xFFB3261E), fontSize: 12),
            ),
          ),
        if (_messages.length == 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionChip(
                  text: 'Hangi alandan başlamalıyım?',
                  onTap: () => _send('Hangi alandan başlamalıyım?'),
                ),
                _SuggestionChip(
                  text: 'Haftalık plan öner',
                  onTap: () => _send(
                    'Bana başlangıç için haftalık bir plan '
                    'önerir misin?',
                  ),
                ),
              ],
            ),
          ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Aklındaki soruyu yaz...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sending ? null : _send,
                  tooltip: 'Gönder',
                  icon: const Icon(Icons.arrow_upward_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ({String role, String text}) message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF335CFF) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(19),
            topRight: const Radius.circular(19),
            bottomLeft: Radius.circular(isUser ? 19 : 5),
            bottomRight: Radius.circular(isUser ? 5 : 19),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : const Color(0xFF252620),
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 12, left: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('Rehber düşünüyor...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(text),
      onPressed: onTap,
      backgroundColor: Colors.white,
      side: BorderSide.none,
    );
  }
}

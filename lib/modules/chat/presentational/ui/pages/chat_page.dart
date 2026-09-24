import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import '../../bloc/chat_cubit.dart';
import '../../bloc/chat_state.dart';

class ChatPage extends StatefulWidget {
  final String ticketId;
  const ChatPage({super.key, required this.ticketId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatCubit _chatCubit;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Obtém o Cubit passando o ticketId caso necessário,
    // ou se o Modular não aceitar param direto sem factory especifica, instanciamos com os adapters:
    _chatCubit = Modular.get<ChatCubit>();
    _chatCubit.initChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStandardPage(
      title: 'Chat #${widget.ticketId}',
      actions: [
        IconButton(
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          tooltip: 'Finalizar Chamado',
          onPressed: () {
            _chatCubit.finalizarTicket();
            Modular.to.pop(); // Volta para a lista de tickets após finalizar
          },
        )
      ],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                bloc: _chatCubit,
                listener: (context, state) {
                  if (state is ChatLoaded) {
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
                },
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ChatError) {
                    return Center(child: Text('Erro: ${state.message}'));
                  } else if (state is ChatLoaded) {
                    final messages = state.messages;
                    if (messages.isEmpty) {
                      return const Center(child: Text('Nenhuma mensagem ainda.'));
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.sender == 'ATENDENTE' || 
                                     msg.sender.toUpperCase() == 'BOT' || 
                                     msg.sender.toUpperCase() == 'SISTEMA';
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.only(
                              top: 4,
                              bottom: 4,
                              left: isMe ? 64 : 16,
                              right: isMe ? 16 : 64,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.secondary : Colors.grey[200],
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isMe ? 16 : 0),
                                bottomRight: Radius.circular(isMe ? 0 : 16),
                              ),
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Digite sua mensagem...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: AppColors.secondary),
            onPressed: () {
              _chatCubit.sendMessage(_messageController.text);
              _messageController.clear();
            },
          ),
        ],
      ),
    );
  }
}

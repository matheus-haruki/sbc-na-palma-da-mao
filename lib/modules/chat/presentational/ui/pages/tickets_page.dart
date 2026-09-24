import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import '../../../domain/models/ticket_model.dart';
import '../../bloc/tickets_cubit.dart';
import '../../bloc/tickets_state.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  late final TicketsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = Modular.get<TicketsCubit>();
    _cubit.iniciarPolling();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: AppStandardPage(
        title: 'Meus Chamados',
        bottom: const TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: 'Abertos'),
            Tab(text: 'Atendimento'),
            Tab(text: 'Finalizados'),
          ],
        ),
        body: BlocBuilder<TicketsCubit, TicketsState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state is TicketsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TicketsError) {
              return Center(child: Text('Erro: ${state.message}'));
            } else if (state is TicketsLoaded) {
              final abertos = state.tickets.where((t) {
                final s = t.status.toLowerCase();
                return s.contains('aberto') ||
                    s.contains('aguardando') ||
                    s.contains('open');
              }).toList();
              final emAndamento = state.tickets.where((t) {
                final s = t.status.toLowerCase();
                return s.contains('andamento') ||
                    s.contains('progress') ||
                    s.contains('atendimento');
              }).toList();
              final finalizados = state.tickets.where((t) {
                final s = t.status.toLowerCase();
                return s.contains('finalizado') ||
                    s.contains('fechado') ||
                    s.contains('closed');
              }).toList();

              return TabBarView(
                children: [
                  _buildList(abertos),
                  _buildList(emAndamento),
                  _buildList(finalizados),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildList(List<TicketModel> list) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          'Nenhum chamado nesta categoria.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final ticket = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              ticket.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('ID: ${ticket.id} • Status: ${ticket.status}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navega para a tela de Chat (sala)
              Modular.to.pushNamed('/chat/sala', arguments: ticket.id);
            },
          ),
        );
      },
    );
  }
}

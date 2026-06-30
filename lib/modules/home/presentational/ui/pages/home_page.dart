import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'package:palma_da_mao/modules/home/presentational/controllers/home_cubit.dart';
import 'package:palma_da_mao/modules/home/presentational/controllers/home_state.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeCubit _cubit = Modular.get<HomeCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.carregarDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text(
              'SBC na Palma da Mão',
              style: TextStyle(
                fontFamily: 'Parkinsans',
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),),
            floating: true,
          ),
          SliverFillRemaining(
            child: BlocBuilder<HomeCubit, HomeState>(
              bloc: _cubit,
              builder: (context, state) {
                return switch (state) {
                  HomeInitial() || HomeLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  HomeError(message: final msg) => Center(
                      child: Text(msg),
                    ),
                  HomeSuccess(atalhos: final atalhos) => ListView.builder(
                      itemCount: atalhos.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.shortcut),
                          title: Text(atalhos[index]),
                        );
                      },
                    ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
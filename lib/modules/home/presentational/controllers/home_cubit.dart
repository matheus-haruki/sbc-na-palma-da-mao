import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palma_da_mao/core/design_system/app_assets.dart';

// Ajuste o caminho de importação conforme a localização do seu AppAssets
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> carregarDashboard() async {
    emit(HomeLoading());

    // Simula o tempo de requisição de uma API
    await Future.delayed(const Duration(seconds: 1));

    // Mapeamento dos serviços baseados nos ícones recém-adicionados
    emit(
      HomeSuccess(
        atalhos: [
          AtalhoModel(titulo: 'Saúde', iconePath: AppAssets.iconeSaude2),
          AtalhoModel(titulo: 'Tributos', iconePath: AppAssets.iconeTributo),
          AtalhoModel(titulo: 'Meio-Ambiente', iconePath: AppAssets.iconePata),
          AtalhoModel(
            titulo: 'Fiscalização',
            iconePath: AppAssets.iconeAltoFalante,
          ),
          AtalhoModel(
            titulo: 'Cultura e Novidades',
            iconePath: AppAssets.iconeCultura,
          ),
          AtalhoModel(
            titulo: 'Cidadania e Perfil',
            iconePath: AppAssets.iconePessoa,
          ),
        ],
      ),
    );
  }
}

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
    emit(HomeSuccess(
      atalhos: [
        AtalhoModel(titulo: 'Saúde', iconePath: AppAssets.iconeSaude),
        AtalhoModel(titulo: 'Tributos', iconePath: AppAssets.iconeTributo),
        AtalhoModel(titulo: 'Educação', iconePath: AppAssets.iconeEducacao),
        AtalhoModel(titulo: 'Transporte', iconePath: AppAssets.iconeTransporte),
        AtalhoModel(titulo: 'Ambiente', iconePath: AppAssets.iconeMeioAmbiente),
        AtalhoModel(titulo: 'Alertas', iconePath: AppAssets.iconeAlerta),
      ],
    ));
  }
}
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
          AtalhoModel(
            idCategoria: 'saude',
            titulo: 'Saúde',
            iconePath: AppAssets.iconeSaude2,
          ),
          AtalhoModel(
            idCategoria: 'tributos',
            titulo: 'Tributos',
            iconePath: AppAssets.iconeTributo,
          ),
          AtalhoModel(
            idCategoria: 'meio_ambiente',
            titulo: 'Meio-Ambiente',
            iconePath: AppAssets.iconePata,
          ),
          AtalhoModel(
            idCategoria: 'fiscalizacao',
            titulo: 'Fiscalização',
            iconePath: AppAssets.iconeAltoFalante,
          ),
          AtalhoModel(
            idCategoria: 'cultura',
            titulo: 'Cultura e Novidades',
            iconePath: AppAssets.iconeCultura,
          ),
          AtalhoModel(
            idCategoria: 'cidadania',
            titulo: 'Cidadania e Perfil',
            iconePath: AppAssets.iconePessoa,
          ),
        ],
        maisUtilizados: [
          AtalhoModel(
            idCategoria:
                'tributos', // Vai abrir a lista de Tributos (onde está o IPTU)
            titulo: '2ª Via do IPTU',
            iconePath: AppAssets.iconeHome,
          ),
          AtalhoModel(
            idCategoria:
                'cultura', // Vai abrir a lista de Cultura (onde colocamos as Notícias no JSON)
            titulo: 'Notícias',
            iconePath: AppAssets
                .iconeJornal, // Troque se tiver um ícone específico para notícias
          ),
          AtalhoModel(
            idCategoria:
                'cidadania', // Cidadania geralmente engloba atendimento/ouvidoria
            titulo: 'Fale Conosco',
            iconePath: AppAssets
                .iconeTelefone, // Troque se tiver um ícone de balão de fala/chat
          ),
        ],
      ),
    );
  }
}

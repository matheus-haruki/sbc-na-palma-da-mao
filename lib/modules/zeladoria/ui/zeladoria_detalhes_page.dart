import 'package:flutter/material.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/core/components/app_input_container.dart';

class ZeladoriaDetalhesPage extends StatelessWidget {
  final Map<String, dynamic> solicitacao;

  const ZeladoriaDetalhesPage({super.key, required this.solicitacao});

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.darkBlue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cpf = solicitacao['cpf_usuario'] ?? '';
    final cpfFormatado = cpf.length == 11 
        ? '${cpf.substring(0,3)}.${cpf.substring(3,6)}.${cpf.substring(6,9)}-${cpf.substring(9,11)}' 
        : cpf;
    
    final categoriaNome = solicitacao['categorias']?['nome'] ?? 'Desconhecida';
    final List<dynamic> fotosDyn = solicitacao['fotos'] ?? [];
    final List<String> fotos = fotosDyn.map((e) => e.toString()).toList();

    return AppStandardPage(
      title: 'Detalhes da Solicitação',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Protocolo:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
                Text(
                  solicitacao['protocolo'] ?? '-',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildLabel('CPF do Solicitante'),
            AppInputContainer(
              child: TextFormField(
                initialValue: cpfFormatado,
                readOnly: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel('Categoria do Problema'),
            AppInputContainer(
              child: TextFormField(
                initialValue: categoriaNome,
                readOnly: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel('Título'),
            AppInputContainer(
              child: TextFormField(
                initialValue: solicitacao['titulo'],
                readOnly: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel('Descrição detalhada'),
            AppInputContainer(
              child: TextFormField(
                initialValue: solicitacao['descricao'],
                readOnly: true,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (fotos.isNotEmpty) ...[
              const Text(
                'Fotos anexadas',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: fotos.map((url) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey.shade100,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }
}

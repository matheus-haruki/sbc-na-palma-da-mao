abstract class FaqContent {
  const FaqContent(); 
}

class FaqText extends FaqContent {
  final String texto;
  const FaqText(this.texto);
}

class FaqImage extends FaqContent {
  final String assetPath;
  const FaqImage(this.assetPath);
}

class FaqItem {
  final String pergunta;
  final List<FaqContent> conteudo;

  const FaqItem({
    required this.pergunta,
    required this.conteudo,
  });
}
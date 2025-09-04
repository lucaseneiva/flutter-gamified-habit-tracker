enum GrowthStage { baby, child, teen, adult, dead }
enum FeedingStatus { fed, notFed, justFed }

class PetState {
  final GrowthStage stage;
  final FeedingStatus? status;


  PetState(this.stage, [this.status]);

  bool get isFed => status == FeedingStatus.fed;
  bool get isHungry => status == FeedingStatus.notFed;
  bool get isDead => stage == GrowthStage.dead;
  bool get isJustFed => status == FeedingStatus.justFed;

  // Isso vai nos ajudar a pegar a imagem SVG correta
  String get imagePath {
    if (isDead) return 'assets/dead.svg';
    // if (isJustFed) return 'assets/happy.svg';

    // Converte o enum para string: 'GrowthStage.baby' -> 'baby'
    final stageString = stage.toString().split('.').last;
    final statusString = isFed
        ? 'fed'
        : isJustFed
        ? 'just_fed'
        : 'not_fed';

    return 'assets/${stageString}_$statusString.svg';
  }

  // Sobrescrever '==' e 'hashCode' para facilitar os testes
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetState &&
          runtimeType == other.runtimeType &&
          stage == other.stage &&
          status == other.status;

  @override
  int get hashCode => stage.hashCode ^ status.hashCode;
}

enum GrowthStage {
  egg,
  baby,
  child,
  teen,
  adult,
  dead,
}

enum FeedingStatus {
  fed,
  notFed,
}

class PetState {
  final GrowthStage stage;
  final FeedingStatus? status; // Pode ser nulo para EGG e DEAD

  // Construtor
  PetState(this.stage, [this.status]); // O status é opcional

  // Getters para facilitar a vida!
  bool get isFed => status == FeedingStatus.fed;
  bool get isHungry => status == FeedingStatus.notFed;
  bool get isDead => stage == GrowthStage.dead;
  bool get isEgg => stage == GrowthStage.egg;

  // Isso vai nos ajudar a pegar a imagem SVG correta
  String get imagePath {
    if (isEgg) return 'assets/egg.svg';
    if (isDead) return 'assets/dead.svg';
    
    // Converte o enum para string: 'GrowthStage.baby' -> 'baby'
    final stageString = stage.toString().split('.').last; 
    final statusString = isFed ? 'fed' : 'not_fed';

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
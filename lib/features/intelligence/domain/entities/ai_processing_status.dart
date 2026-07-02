enum AiProcessingState { idle, processing, done, error }

class AiZoneStatus {
  final int zoneId;
  final String zoneName;
  final String? imageUrl;
  final DateTime lastUpdate;
  final String currentStage;
  final AiProcessingState processingState;

  // ── Campos de IA ─────────────────────────────────────────────────────────
  final int? healthScore;
  final String? aiObservaciones;

  // Status de IA
  const AiZoneStatus({
    required this.zoneId,
    required this.zoneName,
    this.imageUrl,
    required this.lastUpdate,
    required this.currentStage,
    this.processingState = AiProcessingState.idle,
    this.healthScore,
    this.aiObservaciones,
  });

  bool get isProcessing => processingState == AiProcessingState.processing;
  bool get isDone => processingState == AiProcessingState.done;
}

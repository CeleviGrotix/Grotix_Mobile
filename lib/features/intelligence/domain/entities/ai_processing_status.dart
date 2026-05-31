enum AiProcessingState { idle, processing, done, failed }

class AiZoneStatus {
  final int zoneId;
  final String zoneName;
  final String? imageUrl;
  final DateTime lastUpdate;
  final String currentStage; // e.g. "SEED", "GERMINATION", "VEGETATIVE"
  final AiProcessingState processingState;

  const AiZoneStatus({
    required this.zoneId,
    required this.zoneName,
    this.imageUrl,
    required this.lastUpdate,
    required this.currentStage,
    this.processingState = AiProcessingState.idle,
  });

  bool get isProcessing => processingState == AiProcessingState.processing;
}
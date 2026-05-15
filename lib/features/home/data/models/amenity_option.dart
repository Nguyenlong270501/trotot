class AmenityOption {
  const AmenityOption({
    required this.emoji,
    required this.label,
    this.initiallyActive = false,
  });

  final String emoji;
  final String label;
  final bool initiallyActive;
}
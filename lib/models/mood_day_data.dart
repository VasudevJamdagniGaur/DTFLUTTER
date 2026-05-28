class MoodDayData {
  const MoodDayData({
    required this.date,
    required this.dayLabel,
    this.happiness = 0,
    this.anxiety = 0,
    this.stress = 0,
    this.energy = 0,
  });

  final String date;
  final String dayLabel;
  final double happiness;
  final double anxiety;
  final double stress;
  final double energy;
}

class EmotionalBalanceDay {
  const EmotionalBalanceDay({
    required this.date,
    required this.dayLabel,
    this.positive = 0,
    this.negative = 0,
    this.neutral = 0,
  });

  final String date;
  final String dayLabel;
  final double positive;
  final double negative;
  final double neutral;
}

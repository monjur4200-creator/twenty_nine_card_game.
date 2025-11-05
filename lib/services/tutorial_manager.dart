class TutorialManager {
  int currentStep = 0;
  final List<String> steps = [
    'Welcome to 29! Let’s learn bidding.',
    'Now reveal the trump suit.',
    'Play your first card in a trick.',
    'See how scoring works.',
    'You’re ready to play!'
  ];

  bool get isTutorialActive => currentStep < steps.length;

  String get currentHint => isTutorialActive ? steps[currentStep] : 'Tutorial complete.';

  void nextStep() {
    if (isTutorialActive) currentStep++;
  }

  void reset() {
    currentStep = 0;
  }
}
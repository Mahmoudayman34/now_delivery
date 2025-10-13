class OnboardingPageData {
  final String title;
  final String description;
  final String imagePath;
  final bool isLastPage;

  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.imagePath,
    this.isLastPage = false,
  });
}

// Onboarding pages data based on the images
final List<OnboardingPageData> onboardingPages = [
  const OnboardingPageData(
    title: 'Deliver Smarter, Faster',
    description: 'Boost your performance and deliver with confidence every time.',
    imagePath: 'assets/images/on boarding- 1.png',
  ),
  const OnboardingPageData(
    title: 'Track Every Shipment in Real Time',
    description: 'Stay updated with precise, real-time route tracking.',
    imagePath: 'assets/images/on boarding- 2.png',
  ),
  const OnboardingPageData(
    title: 'Simplify Your Workday',
    description: 'Handle all your tasks from one smart, easy-to-use app.',
    imagePath: 'assets/images/on boarding- 3.png',
    isLastPage: true,
  ),
];



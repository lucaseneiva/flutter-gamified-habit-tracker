import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firy_streak/presentation/providers/onboarding_providers.dart';

class OnboardingItem {
  final String title;
  final String description;
  final Widget imageWidget;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.imageWidget,
  });
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final List<OnboardingItem> _onboardingPages;

  @override
  void initState() {
    super.initState();
    _onboardingPages = [
      OnboardingItem(
        title: 'Bem-vindo ao Chaminhas!',
        description: 'Crie hábitos com seu novos pets, as Chaminhas!',
        imageWidget: SvgPicture.asset('assets/egg.svg', height: 150),
      ),
      OnboardingItem(
        title: 'Alimente as Chaminhas!',
        description: 'Complete seus hábitos diários e mantenha a chama acesa!',
        imageWidget: _buildFeedFiryWidget(),
      ),
      OnboardingItem(
        title: 'Veja as Chaminhas crescerem!',
        description: 'Consistência faz sua Chaminha evoluir com você.',
        imageWidget: _buildGrowFiryWidget(),
      ),
    ];
  }

  // Widget customizado para a segunda tela
  Widget _buildFeedFiryWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;

        // ajuste proporcional (pode afinar depois)
        double iconLarge = width * 0.36;
        double iconSmall = width * 0.15;
        double fontSize = width * 0.12;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/not_fed.svg', height: iconLarge),
            const SizedBox(width: 6),
            Text(
              '+',
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            SvgPicture.asset('assets/log.svg', height: iconSmall),
            const SizedBox(width: 6),
            Text(
              '=',
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            SvgPicture.asset('assets/happy.svg', height: iconLarge),
          ],
        );
      },
    );
  }

  // Widget customizado para a terceira tela
  Widget _buildGrowFiryWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 30.0,
          ), // <-- A MÁGICA ACONTECE AQUI (150 - 120 = 30)
          child: SvgPicture.asset('assets/fed.svg', height: 100),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.arrow_forward, size: 60, color: Colors.black54),
        const SizedBox(width: 12),
        SvgPicture.asset(
          'assets/adult_fed.svg',
          height: 130,
        ), // Você precisará adicionar esta imagem
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Um cinza bem claro
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingPages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(item: _onboardingPages[index]);
                },
              ),
            ),
            // Indicadores e botão
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingPages.length,
                      (index) => _buildDot(index: index),
                    ),
                  ),

                  // Botão de Próximo / Concluir
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                        backgroundColor: const Color(0xFFF9703B),
                      ),
                      onPressed: () {
                        if (_currentPage == _onboardingPages.length - 1) {
                          ref.read(onboardingProvider.notifier).completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Constrói os pontinhos indicadores
  AnimatedContainer _buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFFF9703B)
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// Widget para o conteúdo de cada página
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPageWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF333333),
            ),
          ),
          const Spacer(flex: 1),
          item.imageWidget,
          const Spacer(flex: 1),

          Text(
            item.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

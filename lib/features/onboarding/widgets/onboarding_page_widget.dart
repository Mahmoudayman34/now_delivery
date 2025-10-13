import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/onboarding_page.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPageData pageData;

  const OnboardingPageWidget({
    super.key,
    required this.pageData,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer 1: Full background image covering entire screen
        Image.asset(
          pageData.imagePath,
          fit: BoxFit.cover,
        ),
        
        // Layer 2: Orange gradient overlay
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFFF29620).withOpacity(0.3),
                  const Color(0xFFF29620).withOpacity(0.7),
                  const Color(0xFFF29620),
                ],
                stops: const [0.0, 0.5, 0.8, 1.0],
              ),
            ),
          ),
        ),
        
        // Layer 3: Text content at the bottom (on top of everything)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.only(
              left: 32,
              right: 32,
              top: 100,
              bottom: 140,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  pageData.title,
                  style: GoogleFonts.manrope(
                    fontSize: 32,
                    fontWeight: FontWeight.w800, // ExtraBold
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Description
                Text(
                  pageData.description,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


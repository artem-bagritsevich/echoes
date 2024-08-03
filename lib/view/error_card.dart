import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorCard extends StatelessWidget {
  final String errorMessage;

  const ErrorCard(
      {super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 4.0, // Add some shadow effect
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Center(
                child: Text(errorMessage,
                    style:
                        GoogleFonts.gfsNeohellenic(color: Colors.red, fontSize: 20))),
          ],
        ),
      ),
    );
  }
}

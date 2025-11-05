import 'package:flutter/widgets.dart';
import '../models/card_model.dart';

class CardLoader extends StatelessWidget {
  final CardModel card;
  final double width;
  final double height;

  const CardLoader({
    super.key,
    required this.card,
    this.width = 80,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      card.imagePath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: const Color(0xFFE0E0E0),
          alignment: Alignment.center,
          child: Text(
            '${card.rankLabel} ${card.suitLabel}',
            style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
          ),
        );
      },
    );
  }
}

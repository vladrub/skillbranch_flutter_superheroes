import 'package:flutter/material.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/widgets/action_button.dart';

class InfoWithButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final String assetImage;
  final double imageWidth;
  final double imageHeight;
  final double imageTopPadding;

  const InfoWithButton({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.assetImage,
    required this.imageWidth,
    required this.imageHeight,
    required this.imageTopPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 108,
                height: 108,
                decoration: const BoxDecoration(
                  color: SuperheroesColors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: imageTopPadding),
                child: Image.asset(
                  assetImage,
                  width: imageWidth,
                  height: imageHeight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            subtitle.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 30),
          ActionButton(
            onTap: () {},
            text: buttonText,
          )
        ],
      ),
    );
  }
}

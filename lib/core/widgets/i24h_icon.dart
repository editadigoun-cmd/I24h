import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class I24HIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color? color;

  const I24HIcon(this.asset, {super.key, this.size = 22, this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/$asset.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color ?? AppColors.navy, BlendMode.srcIn),
      semanticsLabel: asset,
    );
  }
}

class I24HLogo extends StatelessWidget {
  final double size;
  const I24HLogo({super.key, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(size * .28),
      ),
      alignment: Alignment.center,
      child: Text(
        '24',
        style: TextStyle(color: Colors.white, fontSize: size * .32, fontWeight: FontWeight.w800, letterSpacing: -1),
      ),
    );
  }
}

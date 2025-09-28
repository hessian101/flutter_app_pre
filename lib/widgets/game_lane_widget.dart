import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class GameLaneWidget extends StatelessWidget {
  final int laneCount;
  final double judgmentLinePosition; // 0.0-1.0 (画面上の位置)

  const GameLaneWidget({
    super.key,
    this.laneCount = 4,
    this.judgmentLinePosition = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final laneWidth = screenWidth / laneCount;

    return Stack(
      children: [
        // レーンの縦線
        ...List.generate(laneCount + 1, (index) {
          return Positioned(
            left: index * laneWidth,
            top: 0,
            child: Container(
              width: index == 0 || index == laneCount ? 3 : 1,
              height: screenHeight,
              color: index == 0 || index == laneCount
                  ? Color(AppColors.primaryColor).withValues(alpha: 0.6)
                  : Color(AppColors.secondaryTextColor).withValues(alpha: 0.3),
            ),
          );
        }),

        // 判定ライン
        Positioned(
          left: 0,
          top: screenHeight * judgmentLinePosition,
          child: Container(
            width: screenWidth,
            height: 4,
            decoration: BoxDecoration(
              color: Color(AppColors.goldColor),
              boxShadow: [
                BoxShadow(
                  color: Color(AppColors.goldColor).withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),

        // 判定エリア（4つの個別コンテナ）
        ...List.generate(laneCount, (index) {
          return Positioned(
            left: index * laneWidth,
            top: screenHeight * judgmentLinePosition - 40,
            child: Container(
              width: laneWidth,
              height: 80,
              decoration: BoxDecoration(
                color: Color(AppColors.primaryColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color(AppColors.primaryColor).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class TapEffectWidget extends StatefulWidget {
  final double laneX;
  final double laneY;
  final Color effectColor;
  final VoidCallback? onComplete;

  const TapEffectWidget({
    super.key,
    required this.laneX,
    required this.laneY,
    required this.effectColor,
    this.onComplete,
  });

  @override
  State<TapEffectWidget> createState() => _TapEffectWidgetState();
}

class _TapEffectWidgetState extends State<TapEffectWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 30.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.laneX,
      top: widget.laneY,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.effectColor.withValues(alpha: 0.3),
                  border: Border.all(color: widget.effectColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: widget.effectColor.withValues(alpha: 0.6),
                      blurRadius: _glowAnimation.value,
                      spreadRadius: _glowAnimation.value / 3,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(Icons.star, color: widget.effectColor, size: 30),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

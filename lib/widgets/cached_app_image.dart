import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Network image with cache and placeholder. Reduces memory and improves scroll perf on low-spec devices.
class CachedAppImage extends StatelessWidget {
  const CachedAppImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  static const _placeholderColor = AppColors.surfaceVariant;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return _placeholder(width: width, height: height, borderRadius: borderRadius);
    }
    final cacheWidth = (width != null && width!.isFinite && width! > 0)
        ? (width! * 2).round()
        : null;
    final cacheHeight = (height != null && height!.isFinite && height! > 0)
        ? (height! * 2).round()
        : null;
    Widget child = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      placeholder: (_, __) => _placeholder(
        width: width,
        height: height,
        borderRadius: borderRadius,
      ),
      errorWidget: (_, __, ___) => _placeholder(
        width: width,
        height: height,
        borderRadius: borderRadius,
        icon: Icons.image_not_supported_outlined,
      ),
    );
    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  static Widget _placeholder({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    IconData icon = Icons.image_outlined,
  }) {
    Widget w = Container(
      width: width,
      height: height,
      color: _placeholderColor,
      child: Center(
        child: Icon(icon, color: AppColors.whiteOpacity(0.25), size: 32),
      ),
    );
    if (borderRadius != null) {
      w = ClipRRect(borderRadius: borderRadius, child: w);
    }
    return w;
  }
}

import 'package:flutter/material.dart';

import '../../../shared/models/gift_product.dart';
import '../data/category_visuals.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.product,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.semanticLabel,
  });

  final GiftProduct product;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final String? semanticLabel;

  String? _resolveAsset() {
    final override = product.imageAsset?.trim();
    if (override != null && override.isNotEmpty) {
      return override;
    }

    return CategoryVisuals.bundledAssetFor(product.category);
  }

  @override
  Widget build(BuildContext context) {
    final asset = _resolveAsset();
    final fallback = _CategoryFallback(
      product: product,
      width: width,
      height: height,
    );
    final image = asset == null
        ? fallback
        : Image.asset(
            asset,
            fit: fit,
            cacheWidth: _cacheWidth(context),
            errorBuilder: (_, _, _) => fallback,
          );

    final content = semanticLabel == null
        ? image
        : Semantics(
            image: true,
            label: semanticLabel,
            child: ExcludeSemantics(child: image),
          );

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(borderRadius: borderRadius, child: content),
    );
  }

  int? _cacheWidth(BuildContext context) {
    final logicalWidth = width != null && width!.isFinite
        ? width!
        : MediaQuery.sizeOf(context).width;
    final cacheWidth = (logicalWidth * MediaQuery.devicePixelRatioOf(context))
        .round();
    return cacheWidth > 0 ? cacheWidth : null;
  }
}

class _CategoryFallback extends StatelessWidget {
  const _CategoryFallback({
    required this.product,
    required this.width,
    required this.height,
  });

  final GiftProduct product;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final tone = CategoryVisuals.colorsFor(context, product.category);
    final basis = height != null && height!.isFinite
        ? height!
        : width != null && width!.isFinite
        ? width!
        : 40.0;
    final iconSize = (basis * 0.38).clamp(18.0, 64.0).toDouble();

    return ColoredBox(
      color: tone.background,
      child: Center(
        child: Icon(
          CategoryVisuals.iconFor(product.category),
          color: tone.foreground,
          size: iconSize,
        ),
      ),
    );
  }
}

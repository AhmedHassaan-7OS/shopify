import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../data/models/product_model.dart';
import '../widgets/product_card.dart';

class ProductGallery extends StatefulWidget {
  const ProductGallery({required this.product, super.key});

  static const double dotSize = 8.0;
  static const double activeDotWidth = 24.0;

  final ProductModel product;

  static List<String> imagesOf(ProductModel product) => product.galleryImages;
  static bool showsIndicator(ProductModel product) => product.images.length > 1;

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  final PageController _controller = PageController();
  final ValueNotifier<int> _page = ValueNotifier<int>(0);

  @override
  void dispose() {
    _controller.dispose();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> images = ProductGallery.imagesOf(widget.product);
    final bool showsIndicator = ProductGallery.showsIndicator(widget.product);

    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: AppDimens.productImageAspectRatio,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.productCardSurfaceOf(context),
              borderRadius: AppDimens.brFeature,
            ),
            child: ClipRRect(
              borderRadius: AppDimens.brFeature,
              child: PageView.builder(
                controller: _controller,
                itemCount: images.length,
                onPageChanged: (int index) => _page.value = index,
                itemBuilder: (BuildContext context, int index) {
                  final Widget image = AppNetworkImage(
                    url: images[index],
                    fit: BoxFit.contain,
                    backgroundColor: AppColors.productCardSurfaceOf(context),
                    semanticLabel: widget.product.title,
                  );
                  if (index == 0) {
                    return Hero(
                      tag: ProductCard.heroTag(widget.product.id),
                      child: image,
                    );
                  }
                  return image;
                },
              ),
            ),
          ),
        ),
        if (showsIndicator) ...<Widget>[
          const SizedBox(height: AppDimens.s16),
          ValueListenableBuilder<int>(
            valueListenable: _page,
            builder: (BuildContext context, int current, Widget? _) =>
                _PageDots(count: images.length, current: current),
          ),
        ],
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppDimens.s8 / 2,
      runSpacing: AppDimens.s8 / 2,
      children: <Widget>[
        for (int index = 0; index < count; index++)
          Container(
            width: index == current
                ? ProductGallery.activeDotWidth
                : ProductGallery.dotSize,
            height: ProductGallery.dotSize,
            decoration: BoxDecoration(
              color: index == current ? colors.primary : colors.outlineVariant,
              borderRadius: const BorderRadius.all(
                Radius.circular(ProductGallery.dotSize / 2),
              ),
            ),
          ),
      ],
    );
  }
}

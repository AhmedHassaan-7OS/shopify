import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/widgets/app_empty_view.dart';
import '../../core/widgets/app_error_view.dart';
import '../../core/widgets/shimmer_views.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../logic/search/search_cubit.dart';
import '../../logic/search/search_state.dart';
import '../products/product_details_screen.dart';
import '../products/products_screen.dart';
import 'widgets/search_result_sections.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.focusNode});

  static const String searchHint = 'ابحث عن منتج أو قسم';

  static const String minLengthPrompt = 'اكتب حرفين على الأقل لبدء البحث';

  final FocusNode? focusNode;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  FocusNode? _internalFocusNode;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void dispose() {
    _controller.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) =>
      context.read<SearchCubit>().onQueryChanged(query);

  void _onSubmitted(String query) => context.read<SearchCubit>().search(query);

  void _onClear() {
    _controller.clear();
    _onQueryChanged('');
  }

  void _openCategory(CategoryModel category) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => ProductsScreen(category: category),
      ),
    );
  }

  void _openProduct(ProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => ProductDetailsScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: AppDimens.s24,
                end: AppDimens.s24,
                top: AppDimens.s16,
                bottom: AppDimens.s16,
              ),
              child: _SearchField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: _onQueryChanged,
                onSubmitted: _onSubmitted,
                onClear: _onClear,
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (BuildContext context, SearchState state) =>
                    _buildBody(context, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SearchState state) => switch (state) {
    SearchIdle() => const AppEmptyView(
      message: SearchScreen.minLengthPrompt,
      icon: Symbols.search,
    ),
    SearchLoading() => const SingleChildScrollView(
      child: SearchShimmer(
        padding: EdgeInsetsDirectional.only(
          start: AppDimens.s24,
          end: AppDimens.s24,
          top: AppDimens.s8,
          bottom: AppDimens.s32,
        ),
      ),
    ),
    SearchLoaded(
      :final List<CategoryModel> categories,
      :final List<ProductModel> products,
    ) =>
      SearchResultSections(
        categories: categories,
        products: products,
        onCategorySelected: _openCategory,
        onProductSelected: _openProduct,
      ),
    SearchEmpty(:final String query) => AppEmptyView(
      message: 'لا توجد نتائج للبحث عن «$query»',
      icon: Symbols.search_off,
    ),
    SearchError(:final String message) => AppErrorView(
      message: message,
      onRetry: () => context.read<SearchCubit>().retry(),
    ),
  };
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, Widget? _) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.search,
          textAlign: TextAlign.start,
          style: theme.textTheme.bodyMedium,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: SearchScreen.searchHint,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerLow,
            prefixIcon: const Icon(Symbols.search),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    onPressed: onClear,
                    tooltip: 'مسح البحث',
                    icon: const Icon(Symbols.close),
                  ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:farma_di_mobile/core/di/injection.dart';
import 'package:farma_di_mobile/data/models/brand_model.dart';
import 'package:farma_di_mobile/data/models/category_model.dart';
import 'package:farma_di_mobile/data/models/catalog_view_model.dart';
import 'package:farma_di_mobile/presentation/providers/catalog_provider.dart';
import 'package:farma_di_mobile/presentation/widgets/error_view.dart';
import 'package:farma_di_mobile/presentation/widgets/loading_view.dart';
import 'package:farma_di_mobile/presentation/widgets/routes.dart';

class _PillIcon extends StatelessWidget {
  final String categoryName;

  const _PillIcon({required this.categoryName});

  String _resolveEmoji(String category) {
    switch (category) {
      case 'Analgésicos':
        return '💊';
      case 'Antibióticos':
        return '🧪';
      case 'Vitaminas':
        return '🍊';
      case 'Antihistamínicos':
        return '🌬️';
      case 'Antidiabéticos':
        return '🩺';
      case 'Gastrointestinal':
        return '🫁';
      case 'Cardiovascular':
        return '❤️';
      default:
        return '💊';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46.0,
      height: 46.0,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4F8),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _resolveEmoji(categoryName),
          style: const TextStyle(fontSize: 22.0),
        ),
      ),
    );
  }
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final CatalogProvider _provider = getIt<CatalogProvider>();

  @override
  void initState() {
    super.initState();
    _provider.refreshAll();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  String _formatCurrentDate() {
    final DateTime now = DateTime.now();
    final String day = now.day.toString().padLeft(2, '0');
    final String month = now.month.toString().padLeft(2, '0');
    return 'Fecha actual: $day/$month/${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  ProductsTab(provider: _provider),
                  CategoriesTab(provider: _provider),
                  BrandsTab(provider: _provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      shadowColor: const Color(0x1A000000),
      toolbarHeight: 70.0,
      titleSpacing: 16.0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatCurrentDate(),
            style: const TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF90A4AE),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 1.0),
          const Text(
            'Catálogos',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          },
          icon: const Icon(
            Icons.logout_rounded,
            size: 16.0,
            color: Color(0xFF607D8B),
          ),
          label: const Text(
            'Salir',
            style: TextStyle(fontSize: 13.0, color: Color(0xFF607D8B)),
          ),
        ),
        const SizedBox(width: 4.0),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4F8),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: TabBar(
          indicator: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(30.0),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF546E7A),
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Productos'),
            Tab(text: 'Categorías'),
            Tab(text: 'Marcas'),
          ],
        ),
      ),
    );
  }
}

class ProductsTab extends StatefulWidget {
  final CatalogProvider provider;

  const ProductsTab({super.key, required this.provider});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      widget.provider.setSearchText(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final provider = widget.provider;

        return Column(
          children: [
            _SearchBar(controller: _searchController),
            _FilterRow(
              selected: provider.selectedStockFilter,
              total: provider.products.length,
              inStock: provider.inStockCount,
              lowStock: provider.lowStockCount,
              outOfStock: provider.outOfStockCount,
              onSelected: (filter) => provider.setSelectedStockFilter(filter),
            ),
            Expanded(
              child: _buildBody(provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(CatalogProvider provider) {
    if (provider.productsStatus == CatalogStatus.loading) {
      return const LoadingView(message: 'Cargando productos...');
    }

    if (provider.productsStatus == CatalogStatus.error) {
      return ErrorView(
        message: provider.productsError ?? 'Error al cargar productos.',
        onRetry: () => provider.fetchProducts(),
      );
    }

    final filtered = provider.filteredProducts;

    if (filtered.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => provider.fetchProducts(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 80),
            Center(
              child: Text(
                'No se encontraron productos.',
                style: TextStyle(color: Color(0xFF90A4AE)),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchProducts(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        itemCount: filtered.length,
        itemBuilder: (BuildContext context, int index) =>
            _ProductCard(product: filtered[index]),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextField(
                controller: controller,
                style: const TextStyle(fontSize: 13.0),
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre, marca o categ...',
                  hintStyle: TextStyle(
                    color: Color(0xFFB0BEC5),
                    fontSize: 13.0,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFFB0BEC5),
                    size: 20.0,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 20.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final String selected;
  final int total;
  final int inStock;
  final int lowStock;
  final int outOfStock;
  final ValueChanged<String> onSelected;

  const _FilterRow({
    required this.selected,
    required this.total,
    required this.inStock,
    required this.lowStock,
    required this.outOfStock,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Chip(
              label: 'Todos ($total)',
              isSelected: selected == 'Todos',
              dotColor: null,
              onTap: () => onSelected('Todos'),
            ),
            const SizedBox(width: 6.0),
            _Chip(
              label: 'En stock ($inStock)',
              isSelected: selected == 'En stock',
              dotColor: const Color(0xFF2E7D32),
              onTap: () => onSelected('En stock'),
            ),
            const SizedBox(width: 6.0),
            _Chip(
              label: 'Stock bajo ($lowStock)',
              isSelected: selected == 'Stock bajo',
              dotColor: const Color(0xFFE65100),
              onTap: () => onSelected('Stock bajo'),
            ),
            const SizedBox(width: 6.0),
            _Chip(
              label: 'Agotado ($outOfStock)',
              isSelected: selected == 'Agotado',
              dotColor: const Color(0xFFC62828),
              onTap: () => onSelected('Agotado'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? dotColor;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.dotColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1A2E) : const Color(0xFFF0F4F8),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 7.0,
                height: 7.0,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5.0),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF546E7A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final CatalogProductViewModel product;
  const _ProductCard({required this.product});

  _StatusStyle _resolveStyle(String status) {
    switch (status) {
      case 'En stock':
        return const _StatusStyle(
          text: Color(0xFF2E7D32),
          bg: Color(0xFFE8F5E9),
        );
      case 'Stock bajo':
        return const _StatusStyle(
          text: Color(0xFFE65100),
          bg: Color(0xFFFFF3E0),
        );
      default:
        return const _StatusStyle(
          text: Color(0xFFC62828),
          bg: Color(0xFFFFEBEE),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _StatusStyle style = _resolveStyle(product.stockStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PillIcon(categoryName: product.categoryName),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.tradeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      '${product.brandName} · ${product.categoryName}',
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Color(0xFF78909C),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      product.barcode,
                      style: const TextStyle(
                        fontSize: 11.0,
                        color: Color(0xFFB0BEC5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                'C\$ ${product.unitPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 3.0,
                ),
                decoration: BoxDecoration(
                  color: style.bg,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  product.stockStatus,
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: style.text,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                '${product.totalQuantity} uds.',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Color(0xFF607D8B),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.more_horiz,
                color: Color(0xFFB0BEC5),
                size: 20.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  final Color text;
  final Color bg;
  const _StatusStyle({required this.text, required this.bg});
}

class CategoriesTab extends StatelessWidget {
  final CatalogProvider provider;

  const CategoriesTab({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        if (provider.categoriesStatus == CatalogStatus.loading) {
          return const LoadingView(message: 'Cargando categorías...');
        }

        if (provider.categoriesStatus == CatalogStatus.error) {
          return ErrorView(
            message: provider.categoriesError ?? 'Error al cargar categorías.',
            onRetry: () => provider.fetchCategories(),
          );
        }

        final categories = provider.categories;

        if (categories.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => provider.fetchCategories(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 80),
                Center(
                  child: Text(
                    'No hay categorías registradas.',
                    style: TextStyle(color: Color(0xFF90A4AE)),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchCategories(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final CategoryModel cat = categories[index];
              final int count = provider.getProductCountByCategory(cat.name);
              return _CategoryCard(categoryName: cat.name, productCount: count);
            },
          ),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String categoryName;
  final int productCount;
  const _CategoryCard({required this.categoryName, required this.productCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _PillIcon(categoryName: categoryName),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              categoryName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          Text(
            '$productCount productos',
            style: const TextStyle(color: Color(0xFF78909C), fontSize: 12.0),
          ),
        ],
      ),
    );
  }
}

class BrandsTab extends StatelessWidget {
  final CatalogProvider provider;

  const BrandsTab({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        if (provider.brandsStatus == CatalogStatus.loading) {
          return const LoadingView(message: 'Cargando marcas...');
        }

        if (provider.brandsStatus == CatalogStatus.error) {
          return ErrorView(
            message: provider.brandsError ?? 'Error al cargar marcas.',
            onRetry: () => provider.fetchBrands(),
          );
        }

        final brands = provider.brands;

        if (brands.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => provider.fetchBrands(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 80),
                Center(
                  child: Text(
                    'No hay marcas registradas.',
                    style: TextStyle(color: Color(0xFF90A4AE)),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchBrands(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            itemCount: brands.length,
            itemBuilder: (context, index) => _BrandCard(brand: brands[index]),
          ),
        );
      },
    );
  }
}

class _BrandCard extends StatelessWidget {
  final BrandModel brand;
  const _BrandCard({required this.brand});

  String _initials() => brand.brandName.length >= 2
      ? brand.brandName.substring(0, 2).toUpperCase()
      : brand.brandName.toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.0,
            backgroundColor: const Color(0xFFF0F4F8),
            child: Text(
              _initials(),
              style: const TextStyle(
                color: Color(0xFF1565C0),
                fontWeight: FontWeight.bold,
                fontSize: 13.0,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand.brandName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                if (brand.brandDescription.isNotEmpty) ...[
                  const SizedBox(height: 2.0),
                  Text(
                    brand.brandDescription,
                    style: const TextStyle(
                      color: Color(0xFF78909C),
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: brand.isActive
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              brand.isActive ? 'Activa' : 'Inactiva',
              style: TextStyle(
                color: brand.isActive
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF9E9E9E),
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

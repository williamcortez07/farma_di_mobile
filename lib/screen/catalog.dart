import 'package:flutter/material.dart';

class ProductModel {
  final int productId;
  final String tradeName;
  final String genericName;
  final String categoryName;
  final String presentationName;
  final String supplierName;
  final String brandName;
  final String barcode;
  final int criticalStock;
  final bool isActive;

  const ProductModel({
    required this.productId,
    required this.tradeName,
    required this.genericName,
    required this.categoryName,
    required this.presentationName,
    required this.supplierName,
    required this.brandName,
    required this.barcode,
    required this.criticalStock,
    required this.isActive,
  });
}

class BrandModel {
  final int brandId;
  final String brandName;
  final String brandDescription;
  final bool isActive;

  const BrandModel({
    required this.brandId,
    required this.brandName,
    required this.brandDescription,
    required this.isActive,
  });
}

class InventoryModel {
  final int inventoryId;
  final int productId;
  final double unitPrice;

  const InventoryModel({
    required this.inventoryId,
    required this.productId,
    required this.unitPrice,
  });
}

class ProductBatchModel {
  final int batchId;
  final int productId;
  final int quantity;
  final DateTime expirationDate;

  ProductBatchModel({
    required this.batchId,
    required this.productId,
    required this.quantity,
    required this.expirationDate,
  });
}

class CatalogProductViewModel {
  final String tradeName;
  final String brandName;
  final String categoryName;
  final String barcode;
  final double unitPrice;
  final int totalQuantity;
  final String stockStatus;

  const CatalogProductViewModel({
    required this.tradeName,
    required this.brandName,
    required this.categoryName,
    required this.barcode,
    required this.unitPrice,
    required this.totalQuantity,
    required this.stockStatus,
  });
}

class CatalogService {
  List<ProductModel> getProducts() => _mockProducts;
  List<BrandModel> getBrands() => _mockBrands;

  List<CatalogProductViewModel> getProductCatalogView() {
    return _mockProducts.map(_buildProductView).toList();
  }

  CatalogProductViewModel _buildProductView(ProductModel product) {
    final InventoryModel inv = _mockInventory.firstWhere(
      (InventoryModel i) => i.productId == product.productId,
    );
    final int totalQuantity = _calculateTotalQuantity(product.productId);
    return CatalogProductViewModel(
      tradeName: product.tradeName,
      brandName: product.brandName,
      categoryName: product.categoryName,
      barcode: product.barcode,
      unitPrice: inv.unitPrice,
      totalQuantity: totalQuantity,
      stockStatus: _resolveStockStatus(totalQuantity, product.criticalStock),
    );
  }

  int _calculateTotalQuantity(int productId) {
    return _mockProductBatches
        .where((ProductBatchModel b) => b.productId == productId)
        .fold<int>(0, (int total, ProductBatchModel b) => total + b.quantity);
  }

  String _resolveStockStatus(int totalQuantity, int criticalStock) {
    if (totalQuantity == 0) return 'Agotado';
    if (totalQuantity <= criticalStock) return 'Stock bajo';
    return 'En stock';
  }

  static const List<ProductModel> _mockProducts = [
    ProductModel(productId: 1, tradeName: 'Paracetamol 500mg',  genericName: 'Paracetamol',   categoryName: 'Analgésicos',      presentationName: 'Tableta',              supplierName: 'Distribuidora Central', brandName: 'Bayer',   barcode: 'BAR-7481928374', criticalStock: 20, isActive: true),
    ProductModel(productId: 2, tradeName: 'Ibuprofeno 400mg',   genericName: 'Ibuprofeno',    categoryName: 'Analgésicos',      presentationName: 'Tableta',              supplierName: 'Distribuidora Central', brandName: 'Genfar',  barcode: 'BAR-9932139012', criticalStock: 15, isActive: true),
    ProductModel(productId: 3, tradeName: 'Amoxicilina 500mg',  genericName: 'Amoxicilina',   categoryName: 'Antibióticos',     presentationName: 'Cápsula',              supplierName: 'Farma Import',          brandName: 'MK',      barcode: 'BAR-5544213731', criticalStock: 20, isActive: true),
    ProductModel(productId: 4, tradeName: 'Vitamina C 1g',      genericName: 'Ác. ascórbico', categoryName: 'Vitaminas',        presentationName: 'Tableta efervescente', supplierName: 'Nutrisalud',            brandName: 'Redoxon', barcode: 'BAR-3385984221', criticalStock: 10, isActive: true),
    ProductModel(productId: 5, tradeName: 'Loratadina 10mg',    genericName: 'Loratadina',    categoryName: 'Antihistamínicos', presentationName: 'Tableta',              supplierName: 'Distribuidora Central', brandName: 'Bayer',   barcode: 'BAR-1192137450', criticalStock: 30, isActive: true),
    ProductModel(productId: 6, tradeName: 'Metformina 850mg',   genericName: 'Metformina',    categoryName: 'Antidiabéticos',   presentationName: 'Tableta',              supplierName: 'Farma Import',          brandName: 'MK',      barcode: 'BAR-6672849103', criticalStock: 25, isActive: true),
    ProductModel(productId: 7, tradeName: 'Omeprazol 20mg',     genericName: 'Omeprazol',     categoryName: 'Gastrointestinal', presentationName: 'Cápsula',              supplierName: 'Distribuidora Central', brandName: 'Genfar',  barcode: 'BAR-7723918264', criticalStock: 15, isActive: true),
    ProductModel(productId: 8, tradeName: 'Atorvastatina 20mg', genericName: 'Atorvastatina', categoryName: 'Cardiovascular',   presentationName: 'Tableta',              supplierName: 'Farma Import',          brandName: 'Pfizer',  barcode: 'BAR-8841029374', criticalStock: 10, isActive: true),
  ];

  static const List<BrandModel> _mockBrands = [
    BrandModel(brandId: 1, brandName: 'Bayer',    brandDescription: 'Laboratorio farmacéutico alemán',         isActive: true),
    BrandModel(brandId: 2, brandName: 'Genfar',   brandDescription: 'Laboratorio farmacéutico colombiano',     isActive: true),
    BrandModel(brandId: 3, brandName: 'MK',       brandDescription: 'Laboratorio farmacéutico colombiano',     isActive: true),
    BrandModel(brandId: 4, brandName: 'Pfizer',   brandDescription: 'Laboratorio farmacéutico estadounidense', isActive: true),
    BrandModel(brandId: 5, brandName: 'Redoxon',  brandDescription: 'Marca de suplementos vitamínicos suiza',  isActive: true),
    BrandModel(brandId: 6, brandName: 'Novartis', brandDescription: 'Laboratorio farmacéutico suizo',          isActive: false),
  ];

  static const List<InventoryModel> _mockInventory = [
    InventoryModel(inventoryId: 1, productId: 1, unitPrice: 12.50),
    InventoryModel(inventoryId: 2, productId: 2, unitPrice: 9.75),
    InventoryModel(inventoryId: 3, productId: 3, unitPrice: 24.00),
    InventoryModel(inventoryId: 4, productId: 4, unitPrice: 18.50),
    InventoryModel(inventoryId: 5, productId: 5, unitPrice: 7.25),
    InventoryModel(inventoryId: 6, productId: 6, unitPrice: 32.00),
    InventoryModel(inventoryId: 7, productId: 7, unitPrice: 15.80),
    InventoryModel(inventoryId: 8, productId: 8, unitPrice: 45.00),
  ];

  static final List<ProductBatchModel> _mockProductBatches = [
    ProductBatchModel(batchId: 1, productId: 1, quantity: 142, expirationDate: DateTime(2027, 6, 1)),
    ProductBatchModel(batchId: 2, productId: 2, quantity: 8,   expirationDate: DateTime(2027, 3, 1)),
    ProductBatchModel(batchId: 3, productId: 3, quantity: 55,  expirationDate: DateTime(2027, 9, 1)),
    ProductBatchModel(batchId: 4, productId: 4, quantity: 0,   expirationDate: DateTime(2026, 12, 1)),
    ProductBatchModel(batchId: 5, productId: 5, quantity: 230, expirationDate: DateTime(2028, 1, 1)),
    ProductBatchModel(batchId: 6, productId: 6, quantity: 88,  expirationDate: DateTime(2027, 5, 1)),
    ProductBatchModel(batchId: 7, productId: 7, quantity: 17,  expirationDate: DateTime(2027, 4, 1)),
    ProductBatchModel(batchId: 8, productId: 8, quantity: 0,   expirationDate: DateTime(2026, 11, 1)),
  ];
}

class _PillIcon extends StatelessWidget {
  final String categoryName;

  const _PillIcon({required this.categoryName});

  String _resolveEmoji(String category) {
    switch (category) {
      case 'Analgésicos':      return '💊';
      case 'Antibióticos':     return '🧪';
      case 'Vitaminas':        return '🍊';
      case 'Antihistamínicos': return '🌬️';
      case 'Antidiabéticos':   return '🩺';
      case 'Gastrointestinal': return '🫁';
      case 'Cardiovascular':   return '❤️';
      default:                 return '💊';
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

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  String _formatCurrentDate() {
    final DateTime now = DateTime.now();
    final String day   = now.day.toString().padLeft(2, '0');
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
            const Expanded(
              child: TabBarView(
                children: [
                  ProductsTab(),
                  CategoriesTab(),
                  BrandsTab(),
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
          onPressed: () {},
          icon: const Icon(Icons.logout_rounded, size: 16.0, color: Color(0xFF607D8B)),
          label: const Text('Salir', style: TextStyle(fontSize: 13.0, color: Color(0xFF607D8B))),
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
          labelStyle: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w500),
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
  const ProductsTab({super.key});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  final CatalogService _catalogService = CatalogService();
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchText = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<CatalogProductViewModel> all = _catalogService.getProductCatalogView();
    final int inStockCount    = all.where((p) => p.stockStatus == 'En stock').length;
    final int lowStockCount   = all.where((p) => p.stockStatus == 'Stock bajo').length;
    final int outOfStockCount = all.where((p) => p.stockStatus == 'Agotado').length;
    final List<CatalogProductViewModel> filtered = _filterProducts(all);

    return Column(
      children: [
        _SearchBar(controller: _searchController),
        _FilterRow(
          selected: _selectedFilter,
          total: all.length,
          inStock: inStockCount,
          lowStock: lowStockCount,
          outOfStock: outOfStockCount,
          onSelected: (String f) => setState(() => _selectedFilter = f),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text('No se encontraron productos.',
                      style: TextStyle(color: Color(0xFF90A4AE))),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                  itemCount: filtered.length,
                  itemBuilder: (BuildContext context, int index) =>
                      _ProductCard(product: filtered[index]),
                ),
        ),
      ],
    );
  }

  List<CatalogProductViewModel> _filterProducts(List<CatalogProductViewModel> list) {
    return list.where((CatalogProductViewModel p) {
      final bool matchesSearch = _searchText.isEmpty ||
          p.tradeName.toLowerCase().contains(_searchText.toLowerCase()) ||
          p.brandName.toLowerCase().contains(_searchText.toLowerCase()) ||
          p.categoryName.toLowerCase().contains(_searchText.toLowerCase());
      final bool matchesFilter = _selectedFilter == 'Todos' || p.stockStatus == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
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
                  hintStyle: TextStyle(color: Color(0xFFB0BEC5), fontSize: 13.0),
                  prefixIcon: Icon(Icons.search, color: Color(0xFFB0BEC5), size: 20.0),
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
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20.0),
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
            _Chip(label: 'Todos ($total)',        isSelected: selected == 'Todos',      dotColor: null,                    onTap: () => onSelected('Todos')),
            const SizedBox(width: 6.0),
            _Chip(label: 'En stock ($inStock)',   isSelected: selected == 'En stock',   dotColor: const Color(0xFF2E7D32), onTap: () => onSelected('En stock')),
            const SizedBox(width: 6.0),
            _Chip(label: 'Stock bajo $lowStock',  isSelected: selected == 'Stock bajo', dotColor: const Color(0xFFE65100), onTap: () => onSelected('Stock bajo')),
            const SizedBox(width: 6.0),
            _Chip(label: 'Agotado $outOfStock',   isSelected: selected == 'Agotado',    dotColor: const Color(0xFFC62828), onTap: () => onSelected('Agotado')),
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

  const _Chip({required this.label, required this.isSelected, required this.dotColor, required this.onTap});

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
              Container(width: 7.0, height: 7.0, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
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
      case 'En stock':   return const _StatusStyle(text: Color(0xFF2E7D32), bg: Color(0xFFE8F5E9));
      case 'Stock bajo': return const _StatusStyle(text: Color(0xFFE65100), bg: Color(0xFFFFF3E0));
      default:           return const _StatusStyle(text: Color(0xFFC62828), bg: Color(0xFFFFEBEE));
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
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8.0, offset: Offset(0, 2))],
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
                    Text(product.tradeName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 2.0),
                    Text('${product.brandName} · ${product.categoryName}',
                        style: const TextStyle(fontSize: 12.0, color: Color(0xFF78909C))),
                    const SizedBox(height: 2.0),
                    Text(product.barcode,
                        style: const TextStyle(fontSize: 11.0, color: Color(0xFFB0BEC5))),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                'C\$ ${product.unitPrice.toStringAsFixed(2)}',
                style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold, fontSize: 14.0),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(color: style.bg, borderRadius: BorderRadius.circular(20.0)),
                child: Text(product.stockStatus,
                    style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w600, color: style.text)),
              ),
              const SizedBox(width: 8.0),
              Text('${product.totalQuantity} uds.',
                  style: const TextStyle(fontSize: 12.0, color: Color(0xFF607D8B))),
              const Spacer(),
              const Icon(Icons.more_horiz, color: Color(0xFFB0BEC5), size: 20.0),
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
  const CategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> products = CatalogService().getProducts();
    final List<String> categories = products.map((p) => p.categoryName).toSet().toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final String cat = categories[index];
        final int count = products.where((p) => p.categoryName == cat).length;
        return _CategoryCard(categoryName: cat, productCount: count);
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
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 6.0, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          _PillIcon(categoryName: categoryName),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(categoryName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Color(0xFF1A1A2E))),
          ),
          Text('$productCount productos', style: const TextStyle(color: Color(0xFF78909C), fontSize: 12.0)),
        ],
      ),
    );
  }
}

class BrandsTab extends StatelessWidget {
  const BrandsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<BrandModel> brands = CatalogService().getBrands();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      itemCount: brands.length,
      itemBuilder: (context, index) => _BrandCard(brand: brands[index]),
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
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 6.0, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.0,
            backgroundColor: const Color(0xFFF0F4F8),
            child: Text(_initials(),
                style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold, fontSize: 13.0)),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(brand.brandName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 2.0),
                Text(brand.brandDescription,
                    style: const TextStyle(color: Color(0xFF78909C), fontSize: 12.0)),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: brand.isActive ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              brand.isActive ? 'Activa' : 'Inactiva',
              style: TextStyle(
                color: brand.isActive ? const Color(0xFF2E7D32) : const Color(0xFF9E9E9E),
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
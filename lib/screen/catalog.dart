import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Product {
  final int productId;
  final String tradeName;
  final String genericName;
  final String categoryName;
  final String presentationName;
  final String supplierName;
  final String brandName;
  final int criticalStock;
  final bool isActive;

  Product({
    required this.productId,
    required this.tradeName,
    required this.genericName,
    required this.categoryName,
    required this.presentationName,
    required this.supplierName,
    required this.brandName,
    required this.criticalStock,
    required this.isActive,
  });
}

class Brand {
  final int brandId;
  final String brandName;
  final String brandDescription;
  final bool isActive;

  Brand({
    required this.brandId,
    required this.brandName,
    required this.brandDescription,
    required this.isActive,
  });
}

class Inventory {
  final int inventoryId;
  final int productId;
  final double unitPrice;

  Inventory({
    required this.inventoryId,
    required this.productId,
    required this.unitPrice,
  });
}

class ProductBatch {
  final int batchId;
  final int productId;
  final int quantity;
  final DateTime expirationDate;

  ProductBatch({
    required this.batchId,
    required this.productId,
    required this.quantity,
    required this.expirationDate,
  });
}

class CatalogoProductoVista {
  final String nombre;
  final String marca;
  final String categoria;
  final double precio;
  final int cantidad;
  final String estado;

  CatalogoProductoVista({
    required this.nombre,
    required this.marca,
    required this.categoria,
    required this.precio,
    required this.cantidad,
    required this.estado,
  });
}

final List<Product> listaProducts = [
  Product(
      productId: 1,
      tradeName: 'Paracetamol 500mg',
      genericName: 'Paracetamol',
      categoryName: 'Analgésicos',
      presentationName: 'Tableta',
      supplierName: 'Distribuidora Central',
      brandName: 'Bayer',
      criticalStock: 20,
      isActive: true),
  Product(
      productId: 2,
      tradeName: 'Ibuprofeno 400mg',
      genericName: 'Ibuprofeno',
      categoryName: 'Analgésicos',
      presentationName: 'Tableta',
      supplierName: 'Distribuidora Central',
      brandName: 'Genfar',
      criticalStock: 15,
      isActive: true),
  Product(
      productId: 3,
      tradeName: 'Amoxicilina 500mg',
      genericName: 'Amoxicilina',
      categoryName: 'Antibióticos',
      presentationName: 'Cápsula',
      supplierName: 'Farma Import',
      brandName: 'MK',
      criticalStock: 20,
      isActive: true),
  Product(
      productId: 4,
      tradeName: 'Vitamina C 1g',
      genericName: 'Ácido ascórbico',
      categoryName: 'Vitaminas',
      presentationName: 'Tableta efervescente',
      supplierName: 'Nutrisalud',
      brandName: 'Redoxon',
      criticalStock: 10,
      isActive: true),
  Product(
      productId: 5,
      tradeName: 'Loratadina 10mg',
      genericName: 'Loratadina',
      categoryName: 'Antihistamínicos',
      presentationName: 'Tableta',
      supplierName: 'Distribuidora Central',
      brandName: 'Bayer',
      criticalStock: 30,
      isActive: true),
  Product(
      productId: 6,
      tradeName: 'Metformina 850mg',
      genericName: 'Metformina',
      categoryName: 'Antidiabéticos',
      presentationName: 'Tableta',
      supplierName: 'Farma Import',
      brandName: 'MK',
      criticalStock: 25,
      isActive: true),
  Product(
      productId: 7,
      tradeName: 'Omeprazol 20mg',
      genericName: 'Omeprazol',
      categoryName: 'Gastrointestinal',
      presentationName: 'Cápsula',
      supplierName: 'Distribuidora Central',
      brandName: 'Genfar',
      criticalStock: 15,
      isActive: true),
  Product(
      productId: 8,
      tradeName: 'Atorvastatina 20mg',
      genericName: 'Atorvastatina',
      categoryName: 'Cardiovascular',
      presentationName: 'Tableta',
      supplierName: 'Farma Import',
      brandName: 'Pfizer',
      criticalStock: 10,
      isActive: true),
];

final List<Brand> listaBrands = [
  Brand(
      brandId: 1,
      brandName: 'Bayer',
      brandDescription: 'Laboratorio farmacéutico alemán',
      isActive: true),
  Brand(
      brandId: 2,
      brandName: 'Genfar',
      brandDescription: 'Laboratorio farmacéutico colombiano',
      isActive: true),
  Brand(
      brandId: 3,
      brandName: 'MK',
      brandDescription: 'Laboratorio farmacéutico colombiano',
      isActive: true),
  Brand(
      brandId: 4,
      brandName: 'Pfizer',
      brandDescription: 'Laboratorio farmacéutico estadounidense',
      isActive: true),
  Brand(
      brandId: 5,
      brandName: 'Redoxon',
      brandDescription: 'Marca de suplementos vitamínicos suiza',
      isActive: true),
  Brand(
      brandId: 6,
      brandName: 'Novartis',
      brandDescription: 'Laboratorio farmacéutico suizo',
      isActive: false),
];

final List<Inventory> listaInventory = [
  Inventory(inventoryId: 1, productId: 1, unitPrice: 12.50),
  Inventory(inventoryId: 2, productId: 2, unitPrice: 9.75),
  Inventory(inventoryId: 3, productId: 3, unitPrice: 24.00),
  Inventory(inventoryId: 4, productId: 4, unitPrice: 18.50),
  Inventory(inventoryId: 5, productId: 5, unitPrice: 7.25),
  Inventory(inventoryId: 6, productId: 6, unitPrice: 32.00),
  Inventory(inventoryId: 7, productId: 7, unitPrice: 15.80),
  Inventory(inventoryId: 8, productId: 8, unitPrice: 45.00),
];

final List<ProductBatch> listaProductBatches = [
  ProductBatch(batchId: 1, productId: 1, quantity: 142, expirationDate: DateTime(2027, 6, 1)),
  ProductBatch(batchId: 2, productId: 2, quantity: 8, expirationDate: DateTime(2027, 3, 1)),
  ProductBatch(batchId: 3, productId: 3, quantity: 55, expirationDate: DateTime(2027, 9, 1)),
  ProductBatch(batchId: 4, productId: 4, quantity: 0, expirationDate: DateTime(2026, 12, 1)),
  ProductBatch(batchId: 5, productId: 5, quantity: 230, expirationDate: DateTime(2028, 1, 1)),
  ProductBatch(batchId: 6, productId: 6, quantity: 88, expirationDate: DateTime(2027, 5, 1)),
  ProductBatch(batchId: 7, productId: 7, quantity: 17, expirationDate: DateTime(2027, 4, 1)),
  ProductBatch(batchId: 8, productId: 8, quantity: 0, expirationDate: DateTime(2026, 11, 1)),
];

final NumberFormat formatoCordobas = NumberFormat.currency(locale: 'es_NI', symbol: 'C\$ ');

List<CatalogoProductoVista> construirVistaProductos() {
  return listaProducts.map((producto) {
    final inventario = listaInventory.firstWhere((i) => i.productId == producto.productId);
    final cantidadTotal = listaProductBatches
        .where((b) => b.productId == producto.productId)
        .fold<int>(0, (suma, lote) => suma + lote.quantity);

    String estado;
    if (cantidadTotal == 0) {
      estado = 'Agotado';
    } else if (cantidadTotal <= producto.criticalStock) {
      estado = 'Stock bajo';
    } else {
      estado = 'En stock';
    }

    return CatalogoProductoVista(
      nombre: producto.tradeName,
      marca: producto.brandName,
      categoria: producto.categoryName,
      precio: inventario.unitPrice,
      cantidad: cantidadTotal,
      estado: estado,
    );
  }).toList();
}

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Catálogos',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2A45),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const TabBar(
                    indicator: BoxDecoration(
                      color: Color(0xFF1E2A45),
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Color(0xFF1E2A45),
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(text: 'Productos'),
                      Tab(text: 'Categorías'),
                      Tab(text: 'Marcas'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Expanded(
                child: TabBarView(
                  children: [
                    ProductosTab(),
                    CategoriasTab(),
                    MarcasTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductosTab extends StatefulWidget {
  const ProductosTab({super.key});

  @override
  State<ProductosTab> createState() => _ProductosTabState();
}

class _ProductosTabState extends State<ProductosTab> {
  String textoBusqueda = '';
  String filtroSeleccionado = 'Todos';

  final List<String> filtros = ['Todos', 'En stock', 'Stock bajo', 'Agotado'];

  @override
  Widget build(BuildContext context) {
    final vistaProductos = construirVistaProductos();

    List<CatalogoProductoVista> productosFiltrados = vistaProductos.where((producto) {
      final coincideTexto = producto.nombre
              .toLowerCase()
              .contains(textoBusqueda.toLowerCase()) ||
          producto.marca.toLowerCase().contains(textoBusqueda.toLowerCase()) ||
          producto.categoria
              .toLowerCase()
              .contains(textoBusqueda.toLowerCase());

      final coincideFiltro =
          filtroSeleccionado == 'Todos' || producto.estado == filtroSeleccionado;

      return coincideTexto && coincideFiltro;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            onChanged: (valor) {
              setState(() {
                textoBusqueda = valor;
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, marca o categoría',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: filtros.map((filtro) {
              final estaSeleccionado = filtroSeleccionado == filtro;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filtro),
                  selected: estaSeleccionado,
                  selectedColor: const Color(0xFF1E2A45),
                  labelStyle: TextStyle(
                    color: estaSeleccionado ? Colors.white : Colors.black87,
                  ),
                  backgroundColor: Colors.white,
                  onSelected: (_) {
                    setState(() {
                      filtroSeleccionado = filtro;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: productosFiltrados.isEmpty
              ? const Center(child: Text('No se encontraron productos'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: productosFiltrados.length,
                  itemBuilder: (context, index) {
                    return TarjetaProducto(producto: productosFiltrados[index]);
                  },
                ),
        ),
      ],
    );
  }
}

class TarjetaProducto extends StatelessWidget {
  final CatalogoProductoVista producto;
  const TarjetaProducto({super.key, required this.producto});

  Color colorEstado() {
    switch (producto.estado) {
      case 'En stock':
        return Colors.green;
      case 'Stock bajo':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEEF3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication, color: Colors.deepOrange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  '${producto.marca} · ${producto.categoria}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorEstado().withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        producto.estado,
                        style: TextStyle(
                          color: colorEstado(),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${producto.cantidad} uds.',
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Text(
            formatoCordobas.format(producto.precio),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E2A45),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoriasTab extends StatelessWidget {
  const CategoriasTab({super.key});

  @override
  Widget build(BuildContext context) {
    final categoriasUnicas = listaProducts.map((p) => p.categoryName).toSet().toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: categoriasUnicas.length,
      itemBuilder: (context, index) {
        final categoria = categoriasUnicas[index];
        final cantidad =
            listaProducts.where((p) => p.categoryName == categoria).length;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.category, color: Color(0xFF1E2A45)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(categoria,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              Text('$cantidad productos',
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }
}

class MarcasTab extends StatelessWidget {
  const MarcasTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: listaBrands.length,
      itemBuilder: (context, index) {
        final marca = listaBrands[index];
        final iniciales = marca.brandName.length >= 2
            ? marca.brandName.substring(0, 2)
            : marca.brandName;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFEDEEF3),
                foregroundColor: const Color(0xFF1E2A45),
                child: Text(iniciales),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(marca.brandName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(marca.brandDescription,
                        style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (marca.isActive ? Colors.green : Colors.grey)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  marca.isActive ? 'Activa' : 'Inactiva',
                  style: TextStyle(
                    color: marca.isActive ? Colors.green : Colors.grey[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 
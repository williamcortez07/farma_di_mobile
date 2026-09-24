import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Producto {
  final String nombre;
  final String marca;
  final String categoria;
  final double precio;
  final int cantidad;
  final String estado;

  Producto({
    required this.nombre,
    required this.marca,
    required this.categoria,
    required this.precio,
    required this.cantidad,
    required this.estado,
  });
}

class Marca {
  final String nombre;
  final String pais;
  final int totalProductos;
  final bool activa;

  Marca({
    required this.nombre,
    required this.pais,
    required this.totalProductos,
    required this.activa,
  });
}

final List<Producto> listaProductos = [
  Producto(
      nombre: 'Paracetamol 500mg',
      marca: 'Bayer',
      categoria: 'Analgésicos',
      precio: 12.50,
      cantidad: 142,
      estado: 'En stock'),
  Producto(
      nombre: 'Ibuprofeno 400mg',
      marca: 'Genfar',
      categoria: 'Analgésicos',
      precio: 9.75,
      cantidad: 8,
      estado: 'Stock bajo'),
  Producto(
      nombre: 'Amoxicilina 500mg',
      marca: 'MK',
      categoria: 'Antibióticos',
      precio: 24.00,
      cantidad: 55,
      estado: 'En stock'),
  Producto(
      nombre: 'Vitamina C 1g',
      marca: 'Redoxon',
      categoria: 'Vitaminas',
      precio: 18.50,
      cantidad: 0,
      estado: 'Agotado'),
  Producto(
      nombre: 'Loratadina 10mg',
      marca: 'Bayer',
      categoria: 'Antihistamínicos',
      precio: 7.25,
      cantidad: 230,
      estado: 'En stock'),
  Producto(
      nombre: 'Metformina 850mg',
      marca: 'MK',
      categoria: 'Antidiabéticos',
      precio: 32.00,
      cantidad: 88,
      estado: 'En stock'),
  Producto(
      nombre: 'Omeprazol 20mg',
      marca: 'Genfar',
      categoria: 'Gastrointestinal',
      precio: 15.80,
      cantidad: 17,
      estado: 'Stock bajo'),
  Producto(
      nombre: 'Atorvastatina 20mg',
      marca: 'Pfizer',
      categoria: 'Cardiovascular',
      precio: 45.00,
      cantidad: 0,
      estado: 'Agotado'),
];

final List<Marca> listaMarcas = [
  Marca(nombre: 'Bayer', pais: 'Alemania', totalProductos: 48, activa: true),
  Marca(nombre: 'Genfar', pais: 'Colombia', totalProductos: 62, activa: true),
  Marca(nombre: 'MK', pais: 'Colombia', totalProductos: 35, activa: true),
  Marca(nombre: 'Pfizer', pais: 'EE.UU.', totalProductos: 29, activa: true),
  Marca(nombre: 'Redoxon', pais: 'Suiza', totalProductos: 11, activa: true),
  Marca(nombre: 'Novartis', pais: 'Suiza', totalProductos: 22, activa: false),
];

final NumberFormat formatoCordobas = NumberFormat.currency(locale: 'es_NI', symbol: 'C\$ ');

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Catálogos',
                    style: Theme.of(context).textTheme.headlineMedium,
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
    List<Producto> productosFiltrados = listaProductos.where((producto) {
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
  final Producto producto;
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
    final categoriasUnicas = listaProductos.map((p) => p.categoria).toSet().toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: categoriasUnicas.length,
      itemBuilder: (context, index) {
        final categoria = categoriasUnicas[index];
        final cantidad =
            listaProductos.where((p) => p.categoria == categoria).length;

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
      itemCount: listaMarcas.length,
      itemBuilder: (context, index) {
        final marca = listaMarcas[index];
        final iniciales = marca.nombre.length >= 2
            ? marca.nombre.substring(0, 2)
            : marca.nombre;

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
                    Text(marca.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${marca.pais} · ${marca.totalProductos} productos',
                        style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (marca.activa ? Colors.green : Colors.grey)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  marca.activa ? 'Activa' : 'Inactiva',
                  style: TextStyle(
                    color: marca.activa ? Colors.green : Colors.grey[700],
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
import 'package:flutter/material.dart';
import 'theme.dart';

// ============================================================
// MAIN SCREEN
// ============================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // ==========================================================
  // VARIABLES
  // ==========================================================

  String ocasionSeleccionada = 'Cumpleaños';

  final List<String> ocasiones = [
    'Cumpleaños',
    'Aniversario',
    'Graduación',
    'Amistad',
  ];

  // ==========================================================
  // MENSAJE INFERIOR
  // ==========================================================

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ==========================================================
  // PERFIL DEL USUARIO
  // ==========================================================

  void mostrarPerfil() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 5, 22, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 38,
                  backgroundColor: verdeClaro,
                  child: Icon(
                    Icons.person_rounded,
                    size: 42,
                    color: verdePrincipal,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'José María',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textoPrincipal,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'JM@gmail.com',
                  style: TextStyle(
                    color: textoSecundario,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: fondoPrincipal,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: verdeClaro,
                          child: Icon(
                            Icons.location_on_outlined,
                            color: verdePrincipal,
                          ),
                        ),
                        title: const Text('Mis direcciones'),
                        subtitle: const Text(
                          'Administrar lugares de entrega',
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          mostrarMensaje(
                            'Aquí se administrarían las direcciones.',
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: rosaClaro,
                          child: Icon(
                            Icons.credit_card_rounded,
                            color: rosaPrincipal,
                          ),
                        ),
                        title: const Text('Métodos de pago'),
                        subtitle: const Text(
                          'Administrar formas de pago',
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          mostrarMensaje(
                            'Aquí se administrarían los métodos de pago.',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // ACCION PRINCIPAL
  // ==========================================================

  void mostrarBusqueda() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 5, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: rosaClaro,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: rosaPrincipal,
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '¡Empecemos!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textoPrincipal,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'En la aplicación completa, este botón abrirá la pantalla donde podrás indicar para quién es el regalo, la ocasión y tu presupuesto.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: textoSecundario,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);

                    mostrarMensaje(
                      'Se abriría la pantalla de personalización.',
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: rosaPrincipal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // INTERFAZ PRINCIPAL
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ======================================================
      // BARRA SUPERIOR
      // ======================================================

      appBar: AppBar(
        backgroundColor: fondoPrincipal,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 65,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_horiz_rounded,
              size: 30,
              color: textoPrincipal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (opcion) {
              if (opcion == 'vista') {
                mostrarMensaje(
                  'Configuración de vista seleccionada.',
                );
              }

              if (opcion == 'soporte') {
                mostrarMensaje(
                  'Se abriría la sección de soporte.',
                );
              }

              if (opcion == 'salir') {
                mostrarMensaje(
                  'Cerrar sesión seleccionado.',
                );
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'vista',
                  child: ListTile(
                    leading: Icon(Icons.palette_outlined),
                    title: Text('Configurar vista'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'soporte',
                  child: ListTile(
                    leading: Icon(Icons.help_outline_rounded),
                    title: Text('Soporte'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 'salir',
                  child: ListTile(
                    leading: Icon(Icons.logout_rounded),
                    title: Text('Cerrar sesión'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ];
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: mostrarPerfil,
              style: IconButton.styleFrom(
                backgroundColor: verdeClaro,
              ),
              icon: const Icon(
                Icons.person_outline_rounded,
                color: verdeOscuro,
              ),
            ),
          ),
        ],
      ),

      // ======================================================
      // CONTENIDO
      // ======================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            22,
            10,
            22,
            35,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // ENCABEZADO
              // ==================================================

              const Text(
                'ENCUENTRA TU REGALO PERFECTO',
                style: TextStyle(
                  color: textoSecundario,
                  fontSize: 12,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '¿Qué estás\nbuscando?',
                style: TextStyle(
                  color: verdePrincipal,
                  fontSize: 34,
                  height: 1.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Encontrar el regalo ideal puede ser más sencillo. '
                'Personaliza tu búsqueda y descubre diferentes opciones.',
                style: TextStyle(
                  color: textoSecundario,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // TARJETA PRINCIPAL
              // ==================================================

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      rosaPrincipal,
                      Color(0xFFF47CC4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: rosaPrincipal.withValues(
                        alpha: 0.20,
                      ),
                      blurRadius: 15,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                  alpha: 0.20,
                                ),
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Regalos personalizados',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Encuentra algo\nespecial',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                height: 1.15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Ideas para cada persona y ocasión.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 90,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.18,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.redeem_rounded,
                          color: Colors.white,
                          size: 58,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // OCASIONES
              // ==================================================

              const Text(
                '¿Tienes una ocasión en mente?',
                style: TextStyle(
                  color: textoPrincipal,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Selecciona una opción para personalizar la experiencia.',
                style: TextStyle(
                  color: textoSecundario,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ocasiones.map((ocasion) {
                    final bool seleccionada =
                        ocasionSeleccionada == ocasion;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(ocasion),
                        selected: seleccionada,
                        showCheckmark: false,
                        selectedColor: verdePrincipal,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: seleccionada
                              ? verdePrincipal
                              : const Color(0xFFE1E6E3),
                        ),
                        labelStyle: TextStyle(
                          color: seleccionada
                              ? Colors.white
                              : textoPrincipal,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (seleccionado) {
                          setState(() {
                            ocasionSeleccionada = ocasion;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 32),

              // ==================================================
              // CATALOGO
              // ==================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visita nuestro catálogo',
                        style: TextStyle(
                          color: textoPrincipal,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Algunas ideas para ti',
                        style: TextStyle(
                          color: textoSecundario,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      mostrarMensaje(
                        'Se abriría el catálogo completo.',
                      );
                    },
                    child: const Text('Ver todo'),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              const Row(
                children: [
                  Expanded(
                    child: ProductoCard(
                      icono: Icons.watch_rounded,
                      nombre: 'Accesorios',
                      descripcion: 'Detalles especiales',
                      color: rosaClaro,
                      colorIcono: rosaPrincipal,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ProductoCard(
                      icono: Icons.spa_rounded,
                      nombre: 'Bienestar',
                      descripcion: 'Para consentir',
                      color: verdeClaro,
                      colorIcono: verdePrincipal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const Row(
                children: [
                  Expanded(
                    child: ProductoCard(
                      icono: Icons.local_cafe_rounded,
                      nombre: 'Detalles',
                      descripcion: 'Pequeños regalos',
                      color: Color(0xFFFFF5D8),
                      colorIcono: Color(0xFFC58D16),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ProductoCard(
                      icono: Icons.devices_rounded,
                      nombre: 'Tecnología',
                      descripcion: 'Ideas modernas',
                      color: Color(0xFFEDEBFF),
                      colorIcono: Color(0xFF6759C8),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ==================================================
              // COMO FUNCIONA
              // ==================================================

              const Text(
                '¿Cómo funciona?',
                style: TextStyle(
                  color: textoPrincipal,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Conoce rápidamente el proceso para encontrar tu regalo.',
                style: TextStyle(
                  color: textoSecundario,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 15),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE4E8E6),
                  ),
                ),
                child: const Column(
                  children: [
                    PasoTile(
                      numero: '1',
                      titulo: 'Cuéntanos qué necesitas',
                      descripcion:
                          'Selecciona la ocasión, destinatario, tipo de regalo y presupuesto.',
                    ),
                    Divider(
                      height: 1,
                      indent: 70,
                    ),
                    PasoTile(
                      numero: '2',
                      titulo: 'Recibe recomendaciones',
                      descripcion:
                          'La aplicación mostrará diferentes opciones relacionadas con tu búsqueda.',
                    ),
                    Divider(
                      height: 1,
                      indent: 70,
                    ),
                    PasoTile(
                      numero: '3',
                      titulo: 'Elige tu favorito',
                      descripcion:
                          'Explora los resultados y selecciona el regalo que prefieras.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // INFORMACION DESPLEGABLE
              // ==================================================

              Card(
                elevation: 0,
                color: verdeClaro,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const ExpansionTile(
                  shape: Border(),
                  collapsedShape: Border(),
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: verdePrincipal,
                    ),
                  ),
                  title: Text(
                    'Sobre Regalo Ideal',
                    style: TextStyle(
                      color: verdeOscuro,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Conoce el propósito de la aplicación',
                  ),
                  childrenPadding:
                      EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    Text(
                      'Regalo Ideal está pensado para ayudar al usuario '
                      'a descubrir opciones de regalos según la persona, '
                      'ocasión y presupuesto. También permite explorar '
                      'un catálogo y administrar datos relacionados con '
                      'la compra desde el perfil.',
                      style: TextStyle(
                        color: textoSecundario,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // BOTON PRINCIPAL
              // ==================================================

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: mostrarBusqueda,
                  style: FilledButton.styleFrom(
                    backgroundColor: rosaPrincipal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 17,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  icon: const Icon(
                    Icons.search_rounded,
                  ),
                  label: const Text(
                    'Encontrar mi regalo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 13),

              Center(
                child: TextButton.icon(
                  onPressed: () {
                    mostrarMensaje(
                      'Se abriría directamente el catálogo.',
                    );
                  },
                  icon: const Icon(
                    Icons.storefront_outlined,
                  ),
                  label: const Text(
                    'Explorar catálogo sin personalizar',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TARJETA DE PRODUCTO
// ============================================================

class ProductoCard extends StatelessWidget {
  final IconData icono;
  final String nombre;
  final String descripcion;
  final Color color;
  final Color colorIcono;

  const ProductoCard({
    super.key,
    required this.icono,
    required this.nombre,
    required this.descripcion,
    required this.color,
    required this.colorIcono,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(19),
        side: const BorderSide(
          color: Color(0xFFE4E8E6),
        ),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context)
              .hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Categoría seleccionada: $nombre',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 105,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icono,
                  color: colorIcono,
                  size: 45,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                nombre,
                style: const TextStyle(
                  color: textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                descripcion,
                style: const TextStyle(
                  color: textoSecundario,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PASOS DE FUNCIONAMIENTO
// ============================================================

class PasoTile extends StatelessWidget {
  final String numero;
  final String titulo;
  final String descripcion;

  const PasoTile({
    super.key,
    required this.numero,
    required this.titulo,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      shape: const Border(),
      collapsedShape: const Border(),
      leading: CircleAvatar(
        backgroundColor: rosaClaro,
        child: Text(
          numero,
          style: const TextStyle(
            color: rosaPrincipal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        titulo,
        style: const TextStyle(
          color: textoPrincipal,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(
        70,
        0,
        20,
        18,
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            descripcion,
            style: const TextStyle(
              color: textoSecundario,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
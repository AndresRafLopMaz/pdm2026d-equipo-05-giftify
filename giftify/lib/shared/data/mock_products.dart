import '../enums/gift_availability.dart';
import '../models/gift_product.dart';

/// Catálogo temporal utilizado durante el desarrollo frontend.
///
/// Estos datos deben sustituirse o adaptarse cuando Giftify cuente
/// con una fuente de datos real.
const List<GiftProduct> mockProducts = [
  GiftProduct(
    id: 'gift-001',
    name: 'Pulsera artesanal',
    description:
        'Pulsera elaborada artesanalmente, apropiada para un detalle '
        'pequeño y fácil de transportar.',
    price: 125.00,
    category: 'Joyería',
    size: 'Pequeño',
    availability: GiftAvailability.inStock,
    sellerName: 'Detalles Xela',
    sellerRating: 4.7,
    suggestedOccasions: ['Aniversario', 'Cumpleaños', 'Amistad'],
    estimatedDeliveryDays: 1,
  ),
  GiftProduct(
    id: 'gift-002',
    name: 'Caja de chocolates artesanales',
    description:
        'Selección de chocolates artesanales presentada en una caja '
        'para regalo.',
    price: 95.00,
    category: 'Alimentos',
    size: 'Pequeño',
    availability: GiftAvailability.inStock,
    sellerName: 'Dulce Detalle',
    sellerRating: 4.5,
    suggestedOccasions: ['Cumpleaños', 'Aniversario', 'Amistad'],
    estimatedDeliveryDays: 1,
  ),
  GiftProduct(
    id: 'gift-003',
    name: 'Taza térmica',
    description: 'Taza térmica reutilizable para bebidas calientes y frías.',
    price: 180.00,
    category: 'Accesorios',
    size: 'Mediano',
    availability: GiftAvailability.lowStock,
    sellerName: 'Urban Gifts',
    sellerRating: 4.3,
    suggestedOccasions: ['Graduación', 'Cumpleaños', 'Trabajo'],
    estimatedDeliveryDays: 2,
  ),
  GiftProduct(
    id: 'gift-004',
    name: 'Bolsa típica con productos guatemaltecos',
    description:
        'Bolsa de tela típica con una selección de productos '
        'representativos de Guatemala.',
    price: 210.00,
    category: 'Artesanías',
    size: 'Mediano',
    availability: GiftAvailability.inStock,
    sellerName: 'Raíces de Guatemala',
    sellerRating: 4.8,
    suggestedOccasions: ['Despedida', 'Amistad', 'Viaje'],
    estimatedDeliveryDays: 2,
  ),
  GiftProduct(
    id: 'gift-005',
    name: 'Marco fotográfico personalizado',
    description: 'Marco decorativo personalizable para fotografías y mensajes.',
    price: 160.00,
    category: 'Personalizados',
    size: 'Mediano',
    availability: GiftAvailability.outOfStock,
    sellerName: 'Momentos',
    sellerRating: 4.1,
    suggestedOccasions: ['Aniversario', 'Graduación', 'Cumpleaños'],
    estimatedDeliveryDays: 4,
  ),
  GiftProduct(
    id: 'gift-006',
    name: 'Set de café guatemalteco',
    description:
        'Presentación de café guatemalteco seleccionada para obsequio.',
    price: 145.00,
    category: 'Alimentos',
    size: 'Pequeño',
    availability: GiftAvailability.unknown,
    sellerName: 'Café de Los Altos',
    sellerRating: 4.6,
    suggestedOccasions: ['Despedida', 'Trabajo', 'Amistad'],
    estimatedDeliveryDays: 2,
  ),
];

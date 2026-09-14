import 'vehicle.dart';

class OrderItem {
  const OrderItem({required this.vehicle, required this.quantity, this.price = 0});
  final Vehicle vehicle;
  final int quantity;
  final double price;
  double get subtotal => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> j) {
    Vehicle v;
    if (j['vehicle'] is Map) {
      v = Vehicle.fromJson(Map<String, dynamic>.from(j['vehicle'] as Map));
    } else {
      v = Vehicle(
        id: (j['vehicle_id'] ?? '').toString(),
        categoryId: '',
        name: j['vehicle_name'] ?? j['name'] ?? '',
        slug: j['slug'] ?? '',
        brand: j['brand'] ?? '',
        model: j['model'] ?? '',
        year: asInt(j['year']),
        price: asDouble(j['price']),
        stock: asInt(j['stock']),
        images: j['image'] != null ? [j['image'].toString()] : const [],
      );
    }
    return OrderItem(
      vehicle: v,
      quantity: asInt(j['quantity']),
      price: asDouble(j['price']),
    );
  }
}

class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.total,
    this.items = const [],
    this.createdAt,
    this.paymentStatus = 'pending',
    this.userName,
    this.paymentMethod,
  });
  final String id;
  final String orderNumber;
  final String status;
  final double total;
  final List<OrderItem> items;
  final DateTime? createdAt;
  final String paymentStatus;
  final String? userName;
  final String? paymentMethod;

  String get statusLabel => switch (status) {
    'pending' => 'Pending',
    'confirmed' => 'Confirmed',
    'processing' => 'Processing',
    'completed' => 'Completed',
    'cancelled' => 'Cancelled',
    _ => status,
  };

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'].toString(),
        orderNumber: j['order_number'] ?? '',
        status: j['status'] ?? 'pending',
        total: asDouble(j['total_amount'] ?? j['total']),
        items: j['items'] is List
            ? (j['items'] as List).map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e))).toList()
            : [],
        createdAt: j['created_at'] != null ? (DateTime.tryParse(j['created_at'].toString()) ?? DateTime.now()) : null,
        paymentStatus: j['payment_status'] ?? j['paymentStatus'] ?? 'pending',
        userName: j['user_name'] ?? (j['user'] is Map ? (j['user'] as Map)['name']?.toString() : null),
        paymentMethod: j['payment_method']?.toString(),
      );
}

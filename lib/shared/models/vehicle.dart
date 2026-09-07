class VehicleCategory {
  const VehicleCategory({required this.id, required this.name, required this.slug, this.description, this.imageUrl});
  final String id; final String name; final String slug; final String? description; final String? imageUrl;
  factory VehicleCategory.fromJson(Map<String,dynamic> j) => VehicleCategory(
    id: j['id'].toString(), name: j['name']??'', slug: j['slug']??'', description: j['description'], imageUrl: j['image_url']??j['imageUrl']);
  Map<String,dynamic> toJson()=>{'id':id,'name':name,'slug':slug,'description':description};
}

class Vehicle {
  const Vehicle({
    required this.id, required this.categoryId, required this.name, required this.slug,
    required this.brand, required this.model, required this.year, required this.price,
    required this.stock, this.description, this.engine, this.transmission, this.fuelType,
    this.color, this.isAvailable=true, this.images=const [], this.category,
  });
  final String id; final String categoryId; final String name; final String slug;
  final String brand; final String model; final int year; final double price; final int stock;
  final String? description; final String? engine; final String? transmission; final String? fuelType;
  final String? color; final bool isAvailable; final List<String> images; final VehicleCategory? category;

  String get primaryImage => images.isNotEmpty ? images.first : '';
  String get displayPrice => 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m)=>'${m[1]}.')}';

  factory Vehicle.fromJson(Map<String,dynamic> j) => Vehicle(
    id: j['id'].toString(), categoryId: (j['category_id']??j['categoryId']??'').toString(),
    name: j['name']??'', slug: j['slug']??'', brand: j['brand']??'', model: j['model']??'',
    year: (j['year'] as num?)?.toInt()??0, price: (j['price'] as num?)?.toDouble()??0,
    stock: (j['stock'] as num?)?.toInt()??0, description: j['description'],
    engine: j['engine'], transmission: j['transmission'], fuelType: j['fuel_type']??j['fuelType'],
    color: j['color'], isAvailable: j['is_available']??j['isAvailable']??true,
    images: ((j['images']??j['image_urls']) is List) ? List<String>.from((j['images']??j['image_urls']).map((e)=> e is String? e : e['image_url']?.toString()??'')) : <String>[],
    category: j['category']!=null ? VehicleCategory.fromJson(j['category']) : null,
  );
}

class Paginated<T> {
  const Paginated({required this.data, required this.page, required this.limit, required this.total});
  final List<T> data; final int page; final int limit; final int total;
  int get totalPages => (total/limit).ceil();
}

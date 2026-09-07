import '../../shared/models/vehicle.dart';

class MockData {
  MockData._();
  static final categories = [
    VehicleCategory(id:'1', name:'SUV', slug:'suv', description:'Sport Utility Vehicle'),
    VehicleCategory(id:'2', name:'Sedan', slug:'sedan', description:'Sedan premium'),
    VehicleCategory(id:'3', name:'Electric Vehicle', slug:'ev', description:'Kendaraan listrik'),
    VehicleCategory(id:'4', name:'Motorcycle', slug:'motorcycle', description:'Sepeda motor'),
    VehicleCategory(id:'5', name:'Commercial', slug:'commercial', description:'Kendaraan niaga'),
    VehicleCategory(id:'6', name:'Car', slug:'car', description:'Mobil penumpang'),
  ];

  static final vehicles = [
    Vehicle(
      id:'1', categoryId:'1', name:'GR Supra', slug:'gr-supra', brand:'Toyota', model:'GR Supra', year:2025,
      price:1200000000, stock:5, engine:'3.0L Inline-6 Turbo', transmission:'Automatic', fuelType:'Petrol', color:'Hitam',
      description:'Ikon sports car Toyota dengan performa tinggi, desain futuristik, dan teknologi GR terbaru. Cocok untuk yang mencari sensasi berkendara maksimal.',
      images:['https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800','https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800'],
    ),
    Vehicle(
      id:'2', categoryId:'2', name:'Camry Hybrid', slug:'camry-hybrid', brand:'Toyota', model:'Camry', year:2024,
      price:820000000, stock:12, engine:'2.5L Hybrid', transmission:'e-CVT', fuelType:'Hybrid', color:'Putih',
      description:'Sedan hybrid premium dengan efisiensi dan kenyamanan kelas atas.',
      images:['https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800'],
    ),
    Vehicle(
      id:'3', categoryId:'3', name:'IONIQ 6', slug:'ioniq-6', brand:'Hyundai', model:'IONIQ 6', year:2025,
      price:1250000000, stock:8, engine:'77.4 kWh Electric', transmission:'Automatic', fuelType:'Electric', color:'Silver',
      description:'Sedan listrik aerodinamis dengan jarak tempuh hingga 610 km.',
      images:['https://images.unsplash.com/photo-1617704548623-340376564e68?w=800'],
    ),
    Vehicle(
      id:'4', categoryId:'1', name:'CR-V e:HEV', slug:'crv-hev', brand:'Honda', model:'CR-V', year:2024,
      price:750000000, stock:20, engine:'2.0L e:HEV', transmission:'e-CVT', fuelType:'Hybrid', color:'Abu',
      description:'SUV hybrid keluarga dengan kabin lega dan fitur Honda Sensing.',
      images:['https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800'],
    ),
    Vehicle(
      id:'5', categoryId:'4', name:'XMAX 250', slug:'xmax-250', brand:'Yamaha', model:'XMAX', year:2024,
      price:65000000, stock:30, engine:'250cc', transmission:'CVT', fuelType:'Petrol', color:'Biru',
      description:'Skuter premium 250cc untuk mobilitas urban yang nyaman.',
      images:['https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=800'],
    ),
    Vehicle(
      id:'6', categoryId:'3', name:'Model Y', slug:'model-y', brand:'Tesla', model:'Model Y', year:2025,
      price:1450000000, stock:6, engine:'Dual Motor AWD', transmission:'Automatic', fuelType:'Electric', color:'Putih',
      description:'SUV listrik dengan autopilot dan akselerasi 0-100 dalam 3.7 detik.',
      images:['https://images.unsplash.com/photo-1619317920424-a236612cf29d?w=800'],
    ),
    Vehicle(
      id:'7', categoryId:'2', name:'Civic RS', slug:'civic-rs', brand:'Honda', model:'Civic', year:2024,
      price:580000000, stock:10, engine:'1.5L VTEC Turbo', transmission:'CVT', fuelType:'Petrol', color:'Merah',
      description:'Sedan sporty dengan handling lincah dan desain agresif.',
      images:['https://images.unsplash.com/photo-1603386329225-868f99ae1a88?w=800'],
    ),
    Vehicle(
      id:'8', categoryId:'5', name:'Hilux D-Cab', slug:'hilux-dcab', brand:'Toyota', model:'Hilux', year:2024,
      price:520000000, stock:15, engine:'2.4L Diesel', transmission:'Manual', fuelType:'Diesel', color:'Hitam',
      description:'Double cabin tangguh untuk kerja dan petualangan.',
      images:['https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=800'],
    ),
  ];
}

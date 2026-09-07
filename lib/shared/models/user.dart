class User {
  const User({required this.id, required this.name, required this.email, this.phone, required this.role, this.avatar, this.createdAt});
  final String id; final String name; final String email; final String? phone; final String role; final String? avatar; final DateTime? createdAt;
  bool get isAdmin => role == 'admin';
  factory User.fromJson(Map<String,dynamic> j) => User(
    id: j['id'].toString(), name: j['name']??'', email: j['email']??'',
    phone: j['phone'], role: j['role']??'user', avatar: j['avatar'],
    createdAt: j['created_at']!=null ? DateTime.tryParse(j['created_at'].toString()) : null,
  );
  Map<String,dynamic> toJson()=>{'id':id,'name':name,'email':email,'phone':phone,'role':role,'avatar':avatar};
  User copyWith({String? name, String? phone, String? avatar}) => User(
    id:id, name:name??this.name, email:email, phone:phone??this.phone, role:role, avatar:avatar??this.avatar, createdAt: createdAt);
}

class AuthResponse {
  const AuthResponse({required this.user, required this.token});
  final User user; final String token;
  factory AuthResponse.fromJson(Map<String,dynamic> j) {
    final data = j['data'] is Map ? j['data'] as Map<String,dynamic> : j;
    return AuthResponse(
      user: User.fromJson(data['user'] is Map ? data['user'] : data),
      token: (data['token']??data['access_token']??'').toString(),
    );
  }
}

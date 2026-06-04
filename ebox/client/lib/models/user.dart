class User {
  final String id;
  final String name;
  final String? primaryImageTag;
  final bool hasPassword;
  final bool isAdmin;
  final bool isDisabled;
  
  const User({
    required this.id,
    required this.name,
    this.primaryImageTag,
    this.hasPassword = false,
    this.isAdmin = false,
    this.isDisabled = false,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['Id'] as String,
      name: json['Name'] as String,
      primaryImageTag: json['PrimaryImageTag'] as String?,
      hasPassword: json['HasPassword'] as bool? ?? false,
      isAdmin: json['Policy']['IsAdministrator'] as bool? ?? false,
      isDisabled: json['Policy']['IsDisabled'] as bool? ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'PrimaryImageTag': primaryImageTag,
      'HasPassword': hasPassword,
      'IsAdmin': isAdmin,
      'IsDisabled': isDisabled,
    };
  }
  
  String get avatarUrl => 'https://via.placeholder.com/100?text=${name[0].toUpperCase()}';
}

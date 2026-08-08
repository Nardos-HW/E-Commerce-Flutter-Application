// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  username: json['username'] as String,
  name: Name.fromJson(json['name'] as Map<String, dynamic>),
  address: Address.fromJson(json['address'] as Map<String, dynamic>),
  phone: json['phone'] as String,
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'name': instance.name,
      'address': instance.address,
      'phone': instance.phone,
    };

_Name _$NameFromJson(Map<String, dynamic> json) => _Name(
  firstname: json['firstname'] as String,
  lastname: json['lastname'] as String,
);

Map<String, dynamic> _$NameToJson(_Name instance) => <String, dynamic>{
  'firstname': instance.firstname,
  'lastname': instance.lastname,
};

_Address _$AddressFromJson(Map<String, dynamic> json) => _Address(
  city: json['city'] as String,
  street: json['street'] as String,
  number: (json['number'] as num).toInt(),
  zipcode: json['zipcode'] as String,
);

Map<String, dynamic> _$AddressToJson(_Address instance) => <String, dynamic>{
  'city': instance.city,
  'street': instance.street,
  'number': instance.number,
  'zipcode': instance.zipcode,
};

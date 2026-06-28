class ClientCreateRequest {
  final String documentType;
  final String documentNumber;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? address;
  final double monthlyIncome;
  final VehicleCreateRequest? vehicle;

  ClientCreateRequest({
    required this.documentType,
    required this.documentNumber,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.address,
    required this.monthlyIncome,
    this.vehicle,
  });

  Map<String, dynamic> toJson() => {
        'documentType': documentType,
        'documentNumber': documentNumber,
        'firstName': firstName,
        'lastName': lastName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        'monthlyIncome': monthlyIncome,
        if (vehicle != null) 'vehicle': vehicle!.toJson(),
      };
}

class ClientUpdateRequest {
  final String documentType;
  final String documentNumber;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? address;
  final double monthlyIncome;
  final String status;
  final VehicleUpdateRequest? vehicle;

  ClientUpdateRequest({
    required this.documentType,
    required this.documentNumber,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.address,
    required this.monthlyIncome,
    required this.status,
    this.vehicle,
  });

  Map<String, dynamic> toJson() => {
        'documentType': documentType,
        'documentNumber': documentNumber,
        'firstName': firstName,
        'lastName': lastName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        'monthlyIncome': monthlyIncome,
        'status': status,
        if (vehicle != null) 'vehicle': vehicle!.toJson(),
      };
}

class VehicleCreateRequest {
  final String brand;
  final String model;
  final int? year;
  final double price;
  final String currency;
  final String status;
  final String? fuelType;
  final String? transmission;
  final String? engine;

  VehicleCreateRequest({
    required this.brand,
    required this.model,
    this.year,
    required this.price,
    required this.currency,
    required this.status,
    this.fuelType,
    this.transmission,
    this.engine,
  });

  Map<String, dynamic> toJson() => {
        'brand': brand,
        'model': model,
        if (year != null) 'year': year,
        'price': price,
        'currency': currency,
        'status': status,
        if (fuelType != null) 'fuelType': fuelType,
        if (transmission != null) 'transmission': transmission,
        if (engine != null) 'engine': engine,
      };
}

class VehicleUpdateRequest {
  final String brand;
  final String model;
  final int? year;
  final double price;
  final String currency;
  final String status;
  final String? fuelType;
  final String? transmission;
  final String? engine;

  VehicleUpdateRequest({
    required this.brand,
    required this.model,
    this.year,
    required this.price,
    required this.currency,
    required this.status,
    this.fuelType,
    this.transmission,
    this.engine,
  });

  Map<String, dynamic> toJson() => {
        'brand': brand,
        'model': model,
        if (year != null) 'year': year,
        'price': price,
        'currency': currency,
        'status': status,
        if (fuelType != null) 'fuelType': fuelType,
        if (transmission != null) 'transmission': transmission,
        if (engine != null) 'engine': engine,
      };
}

class ClientResponse {
  final int id;
  final String documentType;
  final String documentNumber;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? email;
  final String? phone;
  final String? address;
  final double monthlyIncome;
  final String status;
  final DateTime createdAt;
  final VehicleResponse? vehicle;

  ClientResponse({
    required this.id,
    required this.documentType,
    required this.documentNumber,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.email,
    this.phone,
    this.address,
    required this.monthlyIncome,
    required this.status,
    required this.createdAt,
    this.vehicle,
  });

  factory ClientResponse.fromJson(Map<String, dynamic> json) {
    return ClientResponse(
      id: json['id'] as int,
      documentType: json['documentType'] as String,
      documentNumber: json['documentNumber'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      monthlyIncome: (json['monthlyIncome'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      vehicle: json['vehicle'] != null
          ? VehicleResponse.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ClientListResponse {
  final int id;
  final String fullName;
  final String documentNumber;
  final String? email;
  final String status;
  final String? vehicleName;
  final double? vehiclePrice;
  final String? vehicleCurrency;

  ClientListResponse({
    required this.id,
    required this.fullName,
    required this.documentNumber,
    this.email,
    required this.status,
    this.vehicleName,
    this.vehiclePrice,
    this.vehicleCurrency,
  });

  factory ClientListResponse.fromJson(Map<String, dynamic> json) {
    return ClientListResponse(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      documentNumber: json['documentNumber'] as String,
      email: json['email'] as String?,
      status: json['status'] as String,
      vehicleName: json['vehicleName'] as String?,
      vehiclePrice: json['vehiclePrice'] != null ? (json['vehiclePrice'] as num).toDouble() : null,
      vehicleCurrency: json['vehicleCurrency'] as String?,
    );
  }
}

class VehicleResponse {
  final int id;
  final String brand;
  final String model;
  final int? year;
  final double price;
  final String currency;
  final String status;
  final String? fuelType;
  final String? transmission;
  final String? engine;

  VehicleResponse({
    required this.id,
    required this.brand,
    required this.model,
    this.year,
    required this.price,
    required this.currency,
    required this.status,
    this.fuelType,
    this.transmission,
    this.engine,
  });

  factory VehicleResponse.fromJson(Map<String, dynamic> json) {
    return VehicleResponse(
      id: json['id'] as int,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int?,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      fuelType: json['fuelType'] as String?,
      transmission: json['transmission'] as String?,
      engine: json['engine'] as String?,
    );
  }
}

class PagedResponse<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  PagedResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory PagedResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return PagedResponse(
      items: (json['items'] as List).map((e) => fromJsonT(e as Map<String, dynamic>)).toList(),
      totalCount: json['totalCount'] as int,
      page: json['currentPage'] as int,
      pageSize: json['pageSize'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

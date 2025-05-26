import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Pharmacy {
  final String name;
  final String address;
  final double distanceInKm;

  Pharmacy({
    required this.name,
    required this.address,
    required this.distanceInKm,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'distanceInKm': distanceInKm,
    };
  }

  factory Pharmacy.fromMap(Map<String, dynamic> map) {
    return Pharmacy(
      name: map['name'],
      address: map['address'],
      distanceInKm: map['distanceInKm'],
    );
  }
}

class PharmacyService {
  // TO DO : https://console.cloud.google.com/apis/library/places-backend.googleapis.com  pour recuperer l'api
  static const String _apiKey = 'VOTRE_CLE_API'; // à remplacer
  static const String _cacheKey = 'cached_pharmacies';
  static const String _cacheTimestampKey = 'cached_timestamp';
  static const String _cacheLocationKey = 'cached_location';

  static Future<List<Pharmacy>> fetchNearbyPharmacies() async {
    final Position position = await _getCurrentLocation();
    final double userLat = position.latitude;
    final double userLng = position.longitude;

    // Vérifier le cache
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    final cachedTimestamp = prefs.getInt(_cacheTimestampKey);
    final cachedLocation = prefs.getString(_cacheLocationKey);

    final now = DateTime.now();
    final currentLocationKey = "$userLat,$userLng";

    // Si cache existe, date < 10 min et même position
    if (cachedData != null &&
        cachedTimestamp != null &&
        cachedLocation == currentLocationKey &&
        now.difference(DateTime.fromMillisecondsSinceEpoch(cachedTimestamp)).inMinutes < 10) {
      final List decoded = jsonDecode(cachedData);
      return decoded.map((e) => Pharmacy.fromMap(e)).toList();
    }

    // Sinon, appeler l'API
    final url = Uri.parse('https://places.googleapis.com/v1/places:searchNearby');
    final body = {
      "includedTypes": ["pharmacy"],
      "maxResultCount": 20,
      "locationRestriction": {
        "circle": {
          "center": {"latitude": userLat, "longitude": userLng},
          "radius": 4000.0
        }
      }
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask': 'places.displayName,places.formattedAddress,places.location',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la récupération des pharmacies');
    }

    final data = jsonDecode(response.body);
    final List places = data['places'] ?? [];

    final Distance distance = const Distance();

    final List<Pharmacy> pharmacies = places.map<Pharmacy>((place) {
      final name = place['displayName']?['text'] ?? 'Pharmacie inconnue';
      final address = place['formattedAddress'] ?? 'Adresse inconnue';
      final lat = place['location']?['latitude'];
      final lng = place['location']?['longitude'];

      double dist = 0;
      if (lat != null && lng != null) {
        dist = distance.as(
          LengthUnit.Kilometer,
          LatLng(userLat, userLng),
          LatLng(lat, lng),
        );
      }

      return Pharmacy(
        name: name,
        address: address,
        distanceInKm: double.parse(dist.toStringAsFixed(2)),
      );
    }).where((pharmacy) => pharmacy.distanceInKm <= 4).toList();

    // Cacher le résultat
    prefs.setString(_cacheKey, jsonEncode(pharmacies.map((e) => e.toMap()).toList()));
    prefs.setInt(_cacheTimestampKey, now.millisecondsSinceEpoch);
    prefs.setString(_cacheLocationKey, currentLocationKey);

    return pharmacies;
  }

  static Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Services de localisation désactivés');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission de localisation refusée');
      }
    }

    return await Geolocator.getCurrentPosition(locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high
    ));
  }
}

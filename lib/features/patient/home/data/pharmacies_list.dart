final List<Pharmacy> pharmacies = [
  Pharmacy(
    name: "Pharmacie St Pierre",
    address: "Rue 12, Cocody",
    distanceInKm: 0.8,
  ),
  Pharmacy(
    name: "Pharmacie Centrale",
    address: "Avenue du marché, Treichville",
    distanceInKm: 1.4,
  ),
  Pharmacy(
    name: "Pharmacie de Nuit",
    address: "Bd de la Paix, Yopougon",
    distanceInKm: 2.1,
  ),
  Pharmacy(
    name: "Pharmacie Lafayette",
    address: "Rue des écoles, Plateau",
    distanceInKm: 0.9,
  ),
  Pharmacy(
    name: "Pharmacie 24/7",
    address: "Rue des Hôpitaux, Marcory",
    distanceInKm: 1.8,
  ),
];

class Pharmacy {
  final String name;
  final String address;
  final double distanceInKm;

  Pharmacy({
    required this.name,
    required this.address,
    required this.distanceInKm,
  });
}


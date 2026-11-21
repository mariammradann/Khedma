import 'package:material_ui/material_ui.dart';

class ServiceCategory {
  const ServiceCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Service categories, taken from the photos in the deck's introduction
/// (babysitting, tidying, lawn mowing, games) plus the mockup examples
/// (rides, car wash).
const serviceCategories = <ServiceCategory>[
  ServiceCategory('Ride', Icons.directions_car_outlined),
  ServiceCategory('Car wash', Icons.local_car_wash_outlined),
  ServiceCategory('Groceries', Icons.shopping_basket_outlined),
  ServiceCategory('Tidying', Icons.cleaning_services_outlined),
  ServiceCategory('Gardening', Icons.grass_outlined),
  ServiceCategory('Babysitting', Icons.child_care_outlined),
  ServiceCategory('Pet care', Icons.pets_outlined),
  ServiceCategory('Moving help', Icons.local_shipping_outlined),
];

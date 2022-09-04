
import 'package:flutter/foundation.dart';

class PlaceLocation {
  final double latitude;
  final double longitude;
  

  const PlaceLocation({
    @required this.latitude,
    @required this.longitude,
   
  });
}

class Place {
  
  final PlaceLocation location;
  

  Place({
   
    @required this.location,
   
  });
}

import 'dart:convert';
import 'package:http/http.dart' as http;

// const GOOGLE_API_KEY = 'AIzaSyCAsTAm9AE0bZulYclrNITKy6Vq-tQOD4A';
const GOOGLE_API_KEY = 'AIzaSyCiNRfD39BXa1SkG5GXUGefm4IHwVIEOVI';

class LocationHelper {
  static String generateLocationPreviewImage(
      double latitude, double longitude) {
    //named argument
    return 'https://maps.googleapis.com/maps/api/staticmap?center=&$latitude,$longitude&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$latitude,$longitude&key=$GOOGLE_API_KEY';
  }

  static Future<String> getPlaceAddress(double lat, double long) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=$GOOGLE_API_KEY');
    final response = await http.get(url);
    return json.decode(response.body)['results'][0]['formatted_address'];
  }

  static Future<List<dynamic>> getPlaceLatLong(String address) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${address}&key=$GOOGLE_API_KEY');
    final response = await http.get(url);
    final lat =
        json.decode(response.body)['results'][0]['geometry']['location']['lat'];
    final lng =
        json.decode(response.body)['results'][0]['geometry']['location']['lng'];
    // final result = {'lat': lat, 'lng': lng};
    // print(result);
    print(lat);
    print(lng);
    List<dynamic> result=[lat, lng];

    return result;
  }
}

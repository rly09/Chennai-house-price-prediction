import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for iOS/Windows/Web
  static String get baseUrl {
    // Replace with your machine's IP address if running on a real device
    return 'https://chennai-house-price-api.onrender.com';
  }

  Future<List<String>> fetchLocations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/locations'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['locations']);
      } else {
        throw Exception('Failed to load locations');
      }
    } catch (e) {
      throw Exception('Error fetching locations: $e');
    }
  }

  Future<double> predictPrice(Map<String, dynamic> inputData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(inputData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['price'].toDouble();
      } else {
        final error = json.decode(response.body)['error'];
        throw Exception(error ?? 'Failed to predict price');
      }
    } catch (e) {
      throw Exception('Error predicting price: $e');
    }
  }
}

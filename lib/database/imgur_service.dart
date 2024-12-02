import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// This class handles the interaction with the Imgur API.
/// It allows uploading images to Imgur and retrieving the image URL.
class ImgurService {
  // Imgur Client ID for authorization
  final String clientId = 'dd97dd9095642cb';

  /// This method uploads an image to Imgur.
  /// It takes an XFile object as input and returns the URL of the uploaded image.
  Future<String?> saveImageToImgur(XFile image) async {
    // Read the image file as bytes
    final bytes = await File(image.path).readAsBytes();
    // Convert the image bytes to a base64 string
    final base64Image = base64Encode(bytes);

    // Set up headers with Imgur Client ID for authorization
    final headers = {
      'Authorization': 'Client-ID $clientId',
    };

    // Send the POST request to Imgur
    final response = await http.post(
      Uri.parse('https://api.imgur.com/3/image'),
      headers: headers,
      body: {
        'image': base64Image, // The base64 encoded image
        'type': 'base64', // Specify the type as base64
      },
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Parse the JSON response
      final jsonResponse = jsonDecode(response.body);
      // Extract the image URL from the response
      final imageUrl = jsonResponse['data']['link'];
      return imageUrl; // Return the image URL
    } else {
      return null; // Return null if the upload failed
    }
  }
}

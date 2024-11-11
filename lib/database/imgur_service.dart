import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImgurService {
  final String clientId = 'dd97dd9095642cb';

  Future<String?> saveImageToImgur(XFile image) async {
    // Encode the image file to base64
    final bytes = await File(image.path).readAsBytes();
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
        'image': base64Image,
        'type': 'base64',
      },
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final imageUrl = jsonResponse['data']['link'];
      print('Imgur Image URL: $imageUrl');
      return imageUrl;
    } else {
      print('Failed to upload image: ${response.statusCode}');
      return null;
    }
  }
}

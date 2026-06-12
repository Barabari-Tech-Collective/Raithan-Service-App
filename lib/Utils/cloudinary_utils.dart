import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/cloudinary_config.dart';

class CloudinaryUtils {
  static Future<Map<String, String>> uploadToCloudinary(
    File file,
    String folder,
    String preset,
  ) async {
    final uri = Uri.parse(CloudinaryConfig.uploadBaseUrl);

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = preset
      ..fields['folder'] = folder
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception(
        'Cloudinary upload failed '
        '(${response.statusCode}): $responseBody',
      );
    }

    final body = jsonDecode(responseBody);

    return {
      'public_id': body['public_id'] as String,
      'secure_url': body['secure_url'] as String,
    };
  }
}
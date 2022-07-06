import 'dart:convert';
import 'dart:typed_data';

dynamic decodeResponseFromUint8List(Uint8List? response) {
  return jsonDecode(utf8.decode(response!));
}

dynamic decodeResponseFromString(String ? response) {
  return jsonDecode(response!);
}

import 'package:flutter_test/flutter_test.dart';
import 'package:onecitizen/config/api_config.dart';
import 'package:onecitizen/models/card_type.dart';

void main() {
  test('API configuration is supplied through the build environment', () {
    const configuredUrl = String.fromEnvironment('API_BASE_URL');

    expect(ApiConfig.baseUrl, configuredUrl);
    expect(ApiConfig.isConfigured, configuredUrl.trim().isNotEmpty);
  });

  test('card form fields are read from the backend card type response', () {
    final cardType = CardType.fromJson({
      'id': 'card-id',
      'code': 'farmer',
      'name': 'Farmer Card',
      'eligibility_criteria': 'Backend criteria',
      'required_documents': ['nid_copy'],
      'application_fields': [
        {
          'key': 'land_acres',
          'label': 'Land area',
          'required': true,
          'input_type': 'number',
          'options': <String>[],
        },
      ],
    });

    expect(cardType.requiredDocuments, ['nid_copy']);
    expect(cardType.applicationFields, hasLength(1));
    expect(cardType.applicationFields.single.key, 'land_acres');
    expect(cardType.applicationFields.single.required, isTrue);
  });
}

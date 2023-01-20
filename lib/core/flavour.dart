enum Flavor { mock, dev, prod, test }

extension FlavorExt on String {
  Flavor get getFlavor => Flavor.values.where((flavor) => flavor.name == this).first;
}

class FlavorConfig {
  static late FlavorConfig _instance;

  static FlavorConfig get instance {
    return _instance;
  }

  factory FlavorConfig({
    required Flavor flavor,
    required String baseUrl,
    int? apiVersion,
  }) {
    _instance = FlavorConfig._internal(baseUrl, apiVersion, flavor);

    return _instance;
  }

  FlavorConfig._internal(
      this.baseUrl,
      this.apiVersion,
      this.flavor,
      );

  final Flavor flavor;
  final String baseUrl;
  final int? apiVersion;

  static bool isProd = _instance.flavor == Flavor.prod;
}

void setupFlavor() {
  const flavor = String.fromEnvironment('flavor', defaultValue: 'dev');
  const httpHost = String.fromEnvironment('http-host', defaultValue: '');

  FlavorConfig(flavor: flavor.getFlavor, baseUrl: httpHost, apiVersion: 5);
}

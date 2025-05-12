enum Flavor {
  cowlar_dev,
  cowlar_stage,
  cowlar_prod,
}

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.cowlar_dev:
        return 'Cowlar Dev';
      case Flavor.cowlar_stage:
        return 'Cowlar Stage';
      case Flavor.cowlar_prod:
        return 'Cowlar Prod';
    }
  }

}

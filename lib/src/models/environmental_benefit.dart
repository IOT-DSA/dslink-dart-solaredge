class EnvironmentalBenefit {
  final num treesPlanted;
  final num lightBulbs;
  final GasEmissions gasEmissions;

  EnvironmentalBenefit(this.treesPlanted, this.lightBulbs, this.gasEmissions);
  factory EnvironmentalBenefit.fromJson(Map data) => new EnvironmentalBenefit(
      data['treesPlanted'],
      data['lightBulbs'],
      new GasEmissions.fromJson(data['gasEmissionSaved']));
}

class GasEmissions {
  final String units;
  final num co2;
  final num so2;
  final num nox;

  GasEmissions(this.units, this.co2, this.so2, this.nox);
  factory GasEmissions.fromJson(Map data) =>
      new GasEmissions(data['units'], data['co2'], data['so2'], data['nox']);
}

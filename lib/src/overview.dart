class Overview {
  String lastUpdate;
  EnergyRevenue lifeTimeData;
  EnergyRevenue lastYearData;
  EnergyRevenue lastMonthData;
  EnergyRevenue lastDayData;
  num currentPower;

  Overview.fromJson(Map map) {
    lastUpdate = map['lastUpdateTime'];
    lifeTimeData = new EnergyRevenue.fromJson(map['lifeTimeData']);
    lastYearData = new EnergyRevenue.fromJson(map['lastYearData']);
    lastMonthData = new EnergyRevenue.fromJson(map['lastMonthData']);
    lastDayData = new EnergyRevenue.fromJson(map['lastDayData']);
    currentPower = map['currentPower']['power'];
  }
}

class EnergyRevenue {
  num energy;
  num revenue;
  EnergyRevenue(this.energy, this.revenue);
  EnergyRevenue.fromJson(Map map) {
    energy = map['energy'];
    revenue = map['revenue'];
  }
}
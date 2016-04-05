class Site {
  static const _id = 'id';
  static const _name = 'name';
  static const _accountId = 'accountId';
  static const _status = 'status';
  static const _peakPower = 'peakPower';
  static const _currency = 'currency';
  static const _installDate = 'installationDate';
  static const _notes = 'notes';
  static const _type = 'type';
  static const _location = 'location';
  static const _alertQuant = 'alertQuantity';
  static const _alertSev = 'alertSeverity';
  static const _uris = 'uris';
  static const _imgUri = 'IMAGE_URI';
  static const _pubSettings = 'publicSettings';
  static const _pubName = 'name';
  static const _pubVis = 'isPublic';

  int get calls => _numCalls;
  int _numCalls = 0;

  int accountId;
  String name;
  String status;
  num peakPower;
  String currency;
  String notes;
  String type;
  DateTime installDate;
  Location location;
  int numAlerts;
  String alertSeverity;
  Map<String, String> uris;
  bool isPublic;
  String publicName;

  final String api;
  final int id;

  Site(this.id, this.api);
  Site.fromJson(Map<String, dynamic> map, this.api) : id = map[_id] {
    accountId = map[_accountId];
    name = map[_name];
    status = map[_status];
    peakPower = map[_peakPower];
    currency = map[_currency];
    installDate = DateTime.parse(map[_installDate]);
    notes = map[_notes];
    type = map[_type];
    location = new Location.fromJson(map[_location]);
    numAlerts = map[_alertQuant];
    alertSeverity = map[_alertSev];
    uris = map[_uris];
    publicName = map[_pubSettings][_pubName];
    isPublic = map[_pubSettings][_pubVis];
  }

  void addCall() { _numCalls++; }
}

class Location {
  static const _country = 'country';
  static const _state = 'state';
  static const _city = 'city';
  static const _address = 'address';
  static const _address2 = 'address2';
  static const _zip = 'zip';
  static const _timeZone = 'timeZone';

  String country;
  String state;
  String city;
  String address;
  String address2;
  String zip;
  String timeZone;

  Location.fromJson(Map<String, String> map) {
    country = map[_country];
    state = map[_state];
    city = map[_city];
    address = map[_address];
    address2 = map[_address2];
    zip = map[_zip];
    timeZone = map[_timeZone];
  }
}
class WhiteListModel {
  WhiteListModel(
      {required this.from,
      required this.to,
      required this.appname,
      required this.check});

  final String from;
  final String to;
  final List<String> appname;
  final List<bool> check;

  factory WhiteListModel.fromJson(Map<String, dynamic> _json) {
    return WhiteListModel(
      from: _json['from'],
      to: _json['to'],
      appname: _json['appname'],
      check: _json['check'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
      'appname': appname,
      'check': check,
    };
  }
}

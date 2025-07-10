class PrintingConfigModel {
  final String? printerName;
  final String? paperSize;
  final bool? isDefaultPrinter;
  final int? copies;
  final String? ip;
  final String? port;

  const PrintingConfigModel({
    this.printerName,
    this.paperSize,
    this.isDefaultPrinter,
    this.copies,
    this.ip,
    this.port,
  });

  factory PrintingConfigModel.fromJson(Map<String, dynamic> json) {
    return PrintingConfigModel(
      printerName: json['printerName'] as String?,
      paperSize: json['paperSize'] as String?,
      isDefaultPrinter: json['isDefaultPrinter'] as bool?,
      copies: json['copies'] as int?,
      ip: json['ip'] as String?,
      port: json['port'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'printerName': printerName,
      'paperSize': paperSize,
      'isDefaultPrinter': isDefaultPrinter,
      'copies': copies,
      'ip': ip,
      'port': port,
    };
  }

  PrintingConfigModel copyWith({
    String? printerName,
    String? paperSize,
    bool? isDefaultPrinter,
    int? copies,
    String? ip,
    String? port,
  }) {
    return PrintingConfigModel(
      printerName: printerName ?? this.printerName,
      paperSize: paperSize ?? this.paperSize,
      isDefaultPrinter: isDefaultPrinter ?? this.isDefaultPrinter,
      copies: copies ?? this.copies,
      ip: ip ?? this.ip,
      port: port ?? this.port,
    );
  }
}

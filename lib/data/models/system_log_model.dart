class PagedLogResponse {
  final List<SystemLogModel> data;
  final LogMetaModel? meta;

  const PagedLogResponse({
    required this.data,
    this.meta,
  });

  factory PagedLogResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'];
    final items = <SystemLogModel>[];
    if (list is List) {
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          items.add(SystemLogModel.fromJson(item));
        }
      }
    }
    return PagedLogResponse(
      data: items,
      meta: json['meta'] is Map<String, dynamic>
          ? LogMetaModel.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'meta': meta?.toJson(),
  };
}

class LogMetaModel {
  final int? totalItems;
  final int? totalPages;
  final int? currentPage;
  final int? pageSize;

  const LogMetaModel({
    this.totalItems,
    this.totalPages,
    this.currentPage,
    this.pageSize,
  });

  factory LogMetaModel.fromJson(Map<String, dynamic> json) {
    return LogMetaModel(
      totalItems: (json['totalItems'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
      currentPage: (json['currentPage'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalItems': totalItems,
    'totalPages': totalPages,
    'currentPage': currentPage,
    'pageSize': pageSize,
  };
}

class SystemLogModel {
  final String? id;
  final String? traceId;
  final DateTime? timestamp;
  final String? level;
  final String? environment;
  final String? clientIp;
  final String? userId;
  final LogRequestModel? request;
  final LogResponseModel? response;
  final LogExceptionModel? exception;

  const SystemLogModel({
    this.id,
    this.traceId,
    this.timestamp,
    this.level,
    this.environment,
    this.clientIp,
    this.userId,
    this.request,
    this.response,
    this.exception,
  });

  factory SystemLogModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedTimestamp;
    final tsRaw = json['timestamp'];
    if (tsRaw is String && tsRaw.isNotEmpty) {
      parsedTimestamp = DateTime.tryParse(tsRaw);
    }

    return SystemLogModel(
      id: json['id'] as String?,
      traceId: json['traceId'] as String?,
      timestamp: parsedTimestamp,
      level: json['level'] as String?,
      environment: json['environment'] as String?,
      clientIp: json['clientIp'] as String?,
      userId: json['userId'] as String?,
      request: json['request'] is Map<String, dynamic>
          ? LogRequestModel.fromJson(json['request'] as Map<String, dynamic>)
          : null,
      response: json['response'] is Map<String, dynamic>
          ? LogResponseModel.fromJson(json['response'] as Map<String, dynamic>)
          : null,
      exception: json['exception'] is Map<String, dynamic>
          ? LogExceptionModel.fromJson(json['exception'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'traceId': traceId,
    'timestamp': timestamp?.toIso8601String(),
    'level': level,
    'environment': environment,
    'clientIp': clientIp,
    'userId': userId,
    'request': request?.toJson(),
    'response': response?.toJson(),
    'exception': exception?.toJson(),
  };

  /// Mensaje legible o resumen para presentar en listas o tarjetas
  String get displayMessage {
    if (exception?.message != null && exception!.message!.isNotEmpty) {
      return exception!.message!;
    }
    final method = request?.method ?? 'REQ';
    final path = request?.path ?? '';
    final code = response?.statusCode;
    final elapsed = response?.elapsedMilliseconds;
    if (path.isNotEmpty) {
      if (code != null) {
        final elapsedText = elapsed != null ? ' (${elapsed}ms)' : '';
        return '$method $path respondió con status $code$elapsedText';
      }
      return '$method $path';
    }
    return 'Evento registrado ($level)';
  }
}

class LogRequestModel {
  final String? method;
  final String? path;
  final String? queryString;
  final String? payload;

  const LogRequestModel({
    this.method,
    this.path,
    this.queryString,
    this.payload,
  });

  factory LogRequestModel.fromJson(Map<String, dynamic> json) {
    return LogRequestModel(
      method: json['method'] as String?,
      path: json['path'] as String?,
      queryString: json['queryString'] as String?,
      payload: json['payload'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'method': method,
    'path': path,
    'queryString': queryString,
    'payload': payload,
  };
}

class LogResponseModel {
  final int? statusCode;
  final int? elapsedMilliseconds;

  const LogResponseModel({
    this.statusCode,
    this.elapsedMilliseconds,
  });

  factory LogResponseModel.fromJson(Map<String, dynamic> json) {
    return LogResponseModel(
      statusCode: (json['statusCode'] as num?)?.toInt(),
      elapsedMilliseconds: (json['elapsedMilliseconds'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'statusCode': statusCode,
    'elapsedMilliseconds': elapsedMilliseconds,
  };
}

class LogExceptionModel {
  final String? message;
  final String? stackTrace;
  final String? source;

  const LogExceptionModel({
    this.message,
    this.stackTrace,
    this.source,
  });

  factory LogExceptionModel.fromJson(Map<String, dynamic> json) {
    return LogExceptionModel(
      message: json['message'] as String?,
      stackTrace: json['stackTrace'] as String?,
      source: json['source'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'stackTrace': stackTrace,
    'source': source,
  };
}

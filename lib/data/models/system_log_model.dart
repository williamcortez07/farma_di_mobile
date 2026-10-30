class PagedLogResponse {
  final List<SystemLogModel> data;
  final LogMetaModel? meta;

  const PagedLogResponse({
    required this.data,
    this.meta,
  });

  factory PagedLogResponse.fromDynamic(dynamic json) {
    if (json is List) {
      final items = <SystemLogModel>[];
      for (final item in json) {
        if (item is Map<String, dynamic>) {
          items.add(SystemLogModel.fromJson(item));
        }
      }
      return PagedLogResponse(data: items);
    }

    if (json is Map<String, dynamic>) {
      return PagedLogResponse.fromJson(json);
    }

    return const PagedLogResponse(data: []);
  }

  factory PagedLogResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] ?? json['Data'] ?? json['items'] ?? json['results'];
    final items = <SystemLogModel>[];
    if (list is List) {
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          items.add(SystemLogModel.fromJson(item));
        }
      }
    }
    final metaData = json['meta'] ?? json['Meta'];
    return PagedLogResponse(
      data: items,
      meta: metaData is Map<String, dynamic>
          ? LogMetaModel.fromJson(metaData)
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
      totalItems: (json['totalItems'] ?? json['TotalItems']) is num
          ? (json['totalItems'] ?? json['TotalItems'] as num).toInt()
          : null,
      totalPages: (json['totalPages'] ?? json['TotalPages']) is num
          ? (json['totalPages'] ?? json['TotalPages'] as num).toInt()
          : null,
      currentPage: (json['currentPage'] ?? json['CurrentPage']) is num
          ? (json['currentPage'] ?? json['CurrentPage'] as num).toInt()
          : null,
      pageSize: (json['pageSize'] ?? json['PageSize']) is num
          ? (json['pageSize'] ?? json['PageSize'] as num).toInt()
          : null,
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
    final tsRaw = json['timestamp'] ?? json['Timestamp'];
    if (tsRaw is String && tsRaw.isNotEmpty) {
      parsedTimestamp = DateTime.tryParse(tsRaw);
    }

    final rawRequest = json['request'] ?? json['Request'];
    final rawResponse = json['response'] ?? json['Response'];
    final rawException = json['exception'] ?? json['Exception'];

    LogExceptionModel? parsedException;
    if (rawException is Map<String, dynamic>) {
      parsedException = LogExceptionModel.fromJson(rawException);
    } else if (rawException is String && rawException.isNotEmpty) {
      parsedException = LogExceptionModel(message: rawException);
    }

    return SystemLogModel(
      id: (json['id'] ?? json['Id']) as String?,
      traceId: (json['traceId'] ?? json['TraceId']) as String?,
      timestamp: parsedTimestamp,
      level: (json['level'] ?? json['Level']) as String?,
      environment: (json['environment'] ?? json['Environment']) as String?,
      clientIp: (json['clientIp'] ?? json['ClientIp']) as String?,
      userId: (json['userId'] ?? json['UserId']) as String?,
      request: rawRequest is Map<String, dynamic>
          ? LogRequestModel.fromJson(rawRequest)
          : null,
      response: rawResponse is Map<String, dynamic>
          ? LogResponseModel.fromJson(rawResponse)
          : null,
      exception: parsedException,
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

  /// Severidad normalizada: 'Information', 'Warning', 'Error'
  String get normalizedLevel {
    final lvl = (level ?? '').trim().toUpperCase();
    if (lvl.contains('ERROR')) return 'Error';
    if (lvl.contains('WARN')) return 'Warning';
    return 'Information';
  }

  /// Mensaje legible o resumen para presentar en listas o tarjetas
  String get displayMessage {
    if (exception?.message != null && exception!.message!.trim().isNotEmpty) {
      return exception!.message!.trim();
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
    return 'Evento registrado ($normalizedLevel)';
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
      method: (json['method'] ?? json['Method']) as String?,
      path: (json['path'] ?? json['Path']) as String?,
      queryString: (json['queryString'] ?? json['QueryString']) as String?,
      payload: (json['payload'] ?? json['Payload']) as String?,
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
    final rawStatusCode = json['statusCode'] ?? json['StatusCode'];
    final rawElapsed = json['elapsedMilliseconds'] ?? json['ElapsedMilliseconds'];

    return LogResponseModel(
      statusCode: (rawStatusCode as num?)?.toInt(),
      elapsedMilliseconds: (rawElapsed as num?)?.toInt(),
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
      message: (json['message'] ?? json['Message']) as String?,
      stackTrace: (json['stackTrace'] ?? json['StackTrace']) as String?,
      source: (json['source'] ?? json['Source']) as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'stackTrace': stackTrace,
    'source': source,
  };
}

class HttpResponseHelpers<T> {
  final T data;
  final HttpError? error;

  HttpResponseHelpers(this.data, this.error);

  static HttpResponseHelpers<T> success<T>(T data) => HttpResponseHelpers(data, null);
  static HttpResponseHelpers<Null> fail<T>({
    required int statusCode,
    required String message,
    required dynamic data,
  }) =>
      HttpResponseHelpers(
        null,
        HttpError(
          statusCode: statusCode,
          message: message,
          data: data,
        ),
      );
}

class HttpError {
  final int statusCode;
  final String message;
  final dynamic data;

  HttpError({
    required this.statusCode,
    required this.message,
    required this.data,
  });
}

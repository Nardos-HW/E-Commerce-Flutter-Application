import 'package:dio/dio.dart';  //using the dio package I installed. it gives me the dio class.
import 'package:flutter/foundation.dart';
import 'failure.dart';
import 'result.dart';
class DioClient {   //a customized dio class. instruction of how to make Dio. 

  final Dio dio; // it says every DioCLient object will have a variable name called dio that holds a Dio object. Dio is the type of the variable

  DioClient() : dio = Dio(//constructor. whenever someone creates a DioClient, run this code.  what it does is create a Dio() object.
    BaseOptions( //default settings. don't need to write them twice.
      baseUrl : 'https://fakestoreapi.com',
      connectTimeout: const Duration(seconds: 10), //wait 10 seconds for the server
      receiveTimeout: const Duration(seconds: 10), //wait 10 seconds for the data
      headers: {
        'Content-Type': 'application/json', //im sending json
        'Accept': 'application/json',   //im accepting json
      }, 
    ),

  )
  {
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
      );
    }
  }

    // Every repository call goes through here instead of calling dio directly.
  // `request` is the actual dio call (dio.get(...), dio.post(...), etc).
  // `parser` turns the raw response data into your model (e.g. Product.fromJson).
  // This way repositories never have to write their own try/catch — they just
  // hand this function the call and how to parse it, and always get a Result back.
  Future<Result<T>> safeCall<T>(
    Future<Response> Function() request,
    T Function(dynamic data) parser,
  ) async {
    try {
      final response = await request();
      return Success<T>(parser(response.data));
    } on DioException catch (e) {
      return FailureResult<T>(_mapDioExceptionToFailure(e));
    } catch (e) {
      // Anything that isn't even a DioException — e.g. a parsing error
      // if the JSON shape doesn't match what `parser` expects.
      return FailureResult<T>(const UnknownFailure());
    }
  }

  Failure _mapDioExceptionToFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();

      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        // The server responded, but with an error status code (4xx/5xx).
        return const ServerFailure();

      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
      case DioExceptionType.transformTimeout:
        return const UnknownFailure();
    }
  }
}





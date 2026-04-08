/**
import 'dart:convert';
import 'dart:io';
import 'package:askfemi/utils/network/network_response_dio.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class NetworkCallerDio {
  final Dio _dio = Dio();


  // Generic function to handle any HTTP request (GET, POST, PUT, DELETE)
  Future<NetworkResponseDio> _request(
      String method,
      String url, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        bool isLogin = false,
      }) async {
    final Map<String, String> requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    try {
      debugPrint('🌐 $method Request to: $url');
      debugPrint('📋 Headers: $requestHeaders');
      if (body != null) {
        debugPrint('📦 Body: $body');
      }

      Response response;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await _dio.post(
            url,
            data: jsonEncode(body),
            options: Options(headers: requestHeaders),
          );
          break;

        case 'GET':
          response = await _dio.get(
            url,
            options: Options(headers: requestHeaders),
          );
          break;

        case 'PUT':
          response = await _dio.put(
            url,
            data: jsonEncode(body),
            options: Options(headers: requestHeaders),
          );
          break;

        case 'DELETE':
          response = await _dio.delete(
            url,
            data: body != null ? jsonEncode(body) : null,
            options: Options(headers: requestHeaders),
          );
          break;

        case 'PATCH':
          response = await _dio.patch(
            url,
            data: jsonEncode(body),
            options: Options(headers: requestHeaders),
          );
          break;

        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.data}');

      // Convert Dio response to string JSON for compatibility
      final fakeHttpResponse = Response(
        requestOptions: response.requestOptions,
        data: response.data,
        statusCode: response.statusCode,
      );

      return _handleResponse(fakeHttpResponse, isLogin);
    } catch (e) {
      debugPrint('❌ Error: $e');
      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Handles response from the HTTP request and returns a NetworkResponse
  NetworkResponseDio _handleResponse(Response response, bool isLogin) {
    try {
      final Map<String, dynamic> jsonResponse =
      response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponseDio(
          isSuccess: true,
          jsonResponse: jsonResponse,
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode == 401 && !isLogin) {
        return NetworkResponseDio(
          isSuccess: false,
          statusCode: response.statusCode,
          jsonResponse: jsonResponse,
          errorMessage: jsonResponse['message'] ?? 'Unauthorized',
        );
      }

      return NetworkResponseDio(
        isSuccess: false,
        statusCode: response.statusCode,
        jsonResponse: jsonResponse,
        errorMessage: jsonResponse['message'] ?? 'Request failed',
      );
    } catch (e) {
      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: 'Error parsing response: ${e.toString()}',
      );
    }
  }

  // GET Request
  Future<NetworkResponseDio> getRequest(
      String url, {
        Map<String, String>? headers,
        bool isLogin = false,
      }) async
  {
    return _request('GET', url, headers: headers, isLogin: isLogin);
  }

  // POST Request
  Future<NetworkResponseDio> postRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async
  {
    return _request(
      'POST',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // PUT Request
  Future<NetworkResponseDio> putRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async
  {
    return _request(
      'PUT',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // DELETE Request
  Future<NetworkResponseDio> deleteRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async
  {
    return _request(
      'DELETE',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // PATCH Request
  Future<NetworkResponseDio> patchRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async
  {
    return _request(
      'PATCH',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }





// PUT Request with Multipart Form Data (for file uploads)
  Future<NetworkResponseDio> putMultipartRequest(
      String url, {
        Map<String, dynamic>? body,
        Map<String, File>? files,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    final Map<String, String> requestHeaders = <String, String>{
      ...?headers,
    };

    try {
      debugPrint('🌐 PUT Multipart Request to: $url');
      debugPrint('📋 Headers: $requestHeaders');
      debugPrint('📦 Body: $body');
      if (files != null) {
        debugPrint('📎 Files: ${files.keys}');
      }

      // Create FormData
      FormData formData = FormData();

      // Add text fields
      body?.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });

      // Add files
      files?.forEach((key, file) {
        formData.files.add(
          MapEntry(
            key,
            MultipartFile.fromFileSync(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      });

      final response = await _dio.put(
        url,
        data: formData,
        options: Options(
          headers: requestHeaders,
          contentType: 'multipart/form-data',
        ),
      );

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.data}');

      final fakeHttpResponse = Response(
        requestOptions: response.requestOptions,
        data: response.data,
        statusCode: response.statusCode,
      );

      return _handleResponse(fakeHttpResponse, isLogin);
    } catch (e) {
      debugPrint('❌ Error: $e');
      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }
}*/







import 'dart:convert';
import 'dart:io';
import 'package:askfemi/utils/network/network_response_dio.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class NetworkCallerDio {
  final Dio _dio = Dio();

  // Generic function to handle any HTTP request (GET, POST, PUT, DELETE)
  Future<NetworkResponseDio> _request(
      String method,
      String url, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        bool isLogin = false,
      }) async {
    final Map<String, String> requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    try {
      debugPrint('🌐 $method Request to: $url');
      debugPrint('📋 Headers: $requestHeaders');
      if (body != null) {
        debugPrint('📦 Body: $body');
      }

      Response response;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await _dio.post(
            url,
            data: jsonEncode(body),
            options: Options(headers: requestHeaders),
          );
          break;

        case 'GET':
          response = await _dio.get(
            url,
            options: Options(headers: requestHeaders),
          );
          break;

        case 'PUT':
          response = await _dio.put(
            url,
            data: jsonEncode(body),
            options: Options(headers: requestHeaders),
          );
          break;

        case 'DELETE':
          response = await _dio.delete(
            url,
            data: body != null ? jsonEncode(body) : null,
            options: Options(headers: requestHeaders),
          );
          break;

        case 'PATCH':
          response = await _dio.patch(
            url,
            data: jsonEncode(body),
            options: Options(headers: requestHeaders),
          );
          break;

        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.data}');

      final fakeHttpResponse = Response(
        requestOptions: response.requestOptions,
        data: response.data,
        statusCode: response.statusCode,
      );

      return _handleResponse(fakeHttpResponse, isLogin);
    } on SocketException catch (e) {
      debugPrint('❌ SocketException: $e');
      return NetworkResponseDio(
        isSuccess: false,
        statusCode: null,
        errorMessage: 'No internet connection. Please check your network settings.',
      );
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.type} - ${e.message}');

      // Handle different types of Dio exceptions
      if (e.type == DioExceptionType.connectionTimeout) {
        return NetworkResponseDio(
          isSuccess: false,
          statusCode: null,
          errorMessage: 'Connection timeout. Please try again.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return NetworkResponseDio(
          isSuccess: false,
          statusCode: null,
          errorMessage: 'Receive timeout. Please try again.',
        );
      } else if (e.type == DioExceptionType.sendTimeout) {
        return NetworkResponseDio(
          isSuccess: false,
          statusCode: null,
          errorMessage: 'Send timeout. Please try again.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        return NetworkResponseDio(
          isSuccess: false,
          statusCode: null,
          errorMessage: 'No internet connection. Please check your network.',
        );
      } else if (e.type == DioExceptionType.cancel) {
        return NetworkResponseDio(
          isSuccess: false,
          statusCode: e.response?.statusCode,
          errorMessage: 'Request cancelled.',
        );
      } else if (e.response?.statusCode == 502) {
        return NetworkResponseDio(
          isSuccess: false,
          statusCode: 502,
          errorMessage: 'Server is temporarily unavailable. Please try again later.',
        );
      } else if (e.response?.statusCode == 503) {
        return NetworkResponseDio(
          isSuccess: false,
          statusCode: 503,
          errorMessage: 'Service unavailable. Please try again later.',
        );
      } else if (e.response?.statusCode == 504) {
        return NetworkResponseDio(
          isSuccess: false,
          statusCode: 504,
          errorMessage: 'Gateway timeout. Please try again later.',
        );
      } else {
        return NetworkResponseDio(
          isSuccess: false,
          statusCode: e.response?.statusCode,
          errorMessage: e.message ?? 'Something went wrong',
        );
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Handles response from the HTTP request and returns a NetworkResponse
  NetworkResponseDio _handleResponse(Response response, bool isLogin) {
    try {
      final Map<String, dynamic> jsonResponse =
      response.data is String ? jsonDecode(response.data) : response.data;

      // Handle successful responses
      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponseDio(
          isSuccess: true,
          jsonResponse: jsonResponse,
          statusCode: response.statusCode,
        );
      }

      // Handle 502 Bad Gateway
      if (response.statusCode == 502) {
        return NetworkResponseDio(
          isSuccess: false,
          statusCode: 502,
          jsonResponse: jsonResponse,
          errorMessage: 'Server is temporarily unavailable. Please try again later.',
        );
      }

      // Handle 503 Service Unavailable
      if (response.statusCode == 503) {
        return NetworkResponseDio(
          isSuccess: false,
          statusCode: 503,
          jsonResponse: jsonResponse,
          errorMessage: 'Service unavailable. Please try again later.',
        );
      }

      // Handle 504 Gateway Timeout
      if (response.statusCode == 504) {
        return NetworkResponseDio(
          isSuccess: false,
          statusCode: 504,
          jsonResponse: jsonResponse,
          errorMessage: 'Gateway timeout. Please try again later.',
        );
      }

      // Handle 500 Internal Server Error
      if (response.statusCode == 500) {
        return NetworkResponseDio(
          isSuccess: false,
          statusCode: 500,
          jsonResponse: jsonResponse,
          errorMessage: 'Server error. Please try again later.',
        );
      }

      // Handle 401 Unauthorized
      if (response.statusCode == 401 && !isLogin) {
        return NetworkResponseDio(
          isSuccess: false,
          statusCode: response.statusCode,
          jsonResponse: jsonResponse,
          errorMessage: jsonResponse['message'] ?? 'Unauthorized',
        );
      }

      // Handle other client/server errors
      return NetworkResponseDio(
        isSuccess: false,
        statusCode: response.statusCode,
        jsonResponse: jsonResponse,
        errorMessage: jsonResponse['message'] ?? 'Request failed',
      );
    } catch (e) {
      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: 'Error parsing response: ${e.toString()}',
      );
    }
  }

  // GET Request
  Future<NetworkResponseDio> getRequest(
      String url, {
        Map<String, String>? headers,
        bool isLogin = false,
      }) async {
    return _request('GET', url, headers: headers, isLogin: isLogin);
  }

  // POST Request
  Future<NetworkResponseDio> postRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request(
      'POST',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // PUT Request
  Future<NetworkResponseDio> putRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request(
      'PUT',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // DELETE Request
  Future<NetworkResponseDio> deleteRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request(
      'DELETE',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // PATCH Request
  Future<NetworkResponseDio> patchRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request(
      'PATCH',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // PUT Request with Multipart Form Data (for file uploads)
  Future<NetworkResponseDio> putMultipartRequest(
      String url, {
        Map<String, dynamic>? body,
        Map<String, File>? files,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    final Map<String, String> requestHeaders = <String, String>{
      ...?headers,
    };

    try {
      debugPrint('🌐 PUT Multipart Request to: $url');
      debugPrint('📋 Headers: $requestHeaders');
      debugPrint('📦 Body: $body');
      if (files != null) {
        debugPrint('📎 Files: ${files.keys}');
      }

      FormData formData = FormData();

      body?.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });

      files?.forEach((key, file) {
        formData.files.add(
          MapEntry(
            key,
            MultipartFile.fromFileSync(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      });

      final response = await _dio.put(
        url,
        data: formData,
        options: Options(
          headers: requestHeaders,
          contentType: 'multipart/form-data',
        ),
      );

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.data}');

      final fakeHttpResponse = Response(
        requestOptions: response.requestOptions,
        data: response.data,
        statusCode: response.statusCode,
      );

      return _handleResponse(fakeHttpResponse, isLogin);
    } on SocketException catch (e) {
      debugPrint('❌ SocketException: $e');
      return NetworkResponseDio(
        isSuccess: false,
        statusCode: null,
        errorMessage: 'No internet connection. Please check your network settings.',
      );
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.type}');

      if (e.response?.statusCode == 502) {
        return NetworkResponseDio(
          isSuccess: false,
          statusCode: 502,
          errorMessage: 'Server is temporarily unavailable. Please try again later.',
        );
      } else if (e.response?.statusCode == 503) {
        return NetworkResponseDio(
          isSuccess: false,
          statusCode: 503,
          errorMessage: 'Service unavailable. Please try again later.',
        );
      } else if (e.response?.statusCode == 504) {
        return NetworkResponseDio(
          isSuccess: false,
          statusCode: 504,
          errorMessage: 'Gateway timeout. Please try again later.',
        );
      } else {
        return NetworkResponseDio(
          isSuccess: false,
          statusCode: e.response?.statusCode,
          errorMessage: 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }
}
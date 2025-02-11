library;

import 'dart:io';
import 'toast.dart';
import 'storage.dart';
import 'package:dio/io.dart';
import 'package:dio/dio.dart';
import 'package:qmnj/entity/response_data.dart';
import 'package:get/get.dart' show Get, GetNavigation;

/// 获取本地存储的信息
CancelToken _cancelToken = CancelToken();

/// DioExceptionType 不同类型对应的错误提示
const _errorMessage = {
  DioExceptionType.unknown: '未知异常！',
  DioExceptionType.cancel: '请求被取消！',
  DioExceptionType.sendTimeout: '数据发送超时！',
  DioExceptionType.badResponse: '网络响应异常！',
  DioExceptionType.receiveTimeout: '数据接收超时！',
  DioExceptionType.connectionError: '网络连接失败！',
  DioExceptionType.connectionTimeout: '网络连接超时！',
};

/// 取消 HTTP 请求
void _abortRequest() {
  _cancelToken.cancel('Http Request Is Canceled');
  _cancelToken = CancelToken();
}

/// 跳转到登录页
void _gotoLogin() {
  String routeName = Get.currentRoute;

  if (routeName != '/login' && routeName != '/register') {
    Get.offAllNamed('/login');
  }
}

/// 根据 HTTP 请求状态码返回对应的错误信息
String _getErrorStatusMessage(int statusCode) {
  switch (statusCode) {
    case 400:
      return "请求语法错误";
    case 403:
      return "禁止访问！";
    case 404:
      return "找不到资源！";
    case 405:
      return "请求方法错误！";
    case 500 || 502 || 503:
      return "服务器异常！";
    case 505:
      return "不支持该协议！";
    default:
      return "未知异常！";
  }
}

/// 自定义拦截器
class _Interceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.cancelToken = _cancelToken;
    options.headers = {'Authorization': 'Bearer ${Storage().getItem('User-Token')}'};
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    ResponseData data = ResponseData.fromJson(response.data);

    if (data.code == 0) {
      handler.resolve(Response<ResponseData>(
        data: data,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        requestOptions: response.requestOptions,
      ));
    } else {
      String message = data.message != '' ? data.message : '未知异常';
      if (data.code == 401) {
        message = '登录失效';

        /// 取消 HTTP 请求
        _abortRequest();
        _gotoLogin();
      }

      handler.reject(DioException(
        message: message,
        response: response,
        requestOptions: response.requestOptions,
      ));

      Toast.show(message);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message = '';

    /// 添加 status code 401 的判断
    if (err.type == DioExceptionType.badResponse) {
      message = _getErrorStatusMessage(err.response!.statusCode!);
      if (err.response!.statusCode! == 401) {
        message = '登录失效';
        _gotoLogin();
      }
    } else {
      message = _errorMessage[err.type]!;
    }
    Toast.show(message);
    handler.reject(err.copyWith(message: message));
  }
}

typedef SendProgress = void Function(int, int);
typedef ReceiveProgress = void Function(int, int);

class HttpRequest {
  static final bool _needsProxyClient = false;
  static final Map<String, HttpRequest> _cache = {};
  static final String _proxyAddress = 'PROXY 192.168.5.130:8899';
  static final BaseOptions _baseOptions = BaseOptions(
    baseUrl: 'http://60.169.69.3:20021',
    sendTimeout: Duration(seconds: 60),
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 60),
  );

  late final Dio _dio;

  factory HttpRequest() {
    return HttpRequest._cache.putIfAbsent('PRIMARY', () => HttpRequest.internal());
  }

  HttpRequest.internal() {
    _dio = Dio(_baseOptions);
    _dio.interceptors.add(_Interceptor());
    _setProxy();
  }

  void _setProxy() {
    if (HttpRequest._needsProxyClient && HttpRequest._proxyAddress.isNotEmpty) {
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          // Config the client.
          client.findProxy = (uri) => HttpRequest._proxyAddress;

          client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
          // You can also create a new HttpClient for Dio instead of returning,
          // but a client must being returned here.
          return client;
        },
      );
    }
  }

  Future<ResponseData> post(
    String url, {
    Options? options,
    Map<String, dynamic>? data,
    SendProgress? onSendProgress,
    ReceiveProgress? onReceiveProgress,
  }) async {
    var response = await _dio.post<ResponseData>(
      url,
      data: data,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return response.data!;
  }

  Future<ResponseData> get(
    String url, {
    Options? options,
    Map<String, dynamic>? data,
    ReceiveProgress? onReceiveProgress,
  }) async {
    var response = await _dio.get<ResponseData>(
      url,
      options: options,
      queryParameters: data,
      onReceiveProgress: onReceiveProgress,
    );

    return response.data!;
  }

  Future<ResponseData> delete(
    String url, {
    Options? options,
    Map<String, dynamic>? data,
    ReceiveProgress? onReceiveProgress,
  }) async {
    var response = await _dio.delete<ResponseData>(url, data: data, options: options);

    return response.data!;
  }
}

HttpRequest httpRequest = HttpRequest();

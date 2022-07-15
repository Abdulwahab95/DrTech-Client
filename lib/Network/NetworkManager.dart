import 'dart:async';
import 'dart:convert';

import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/DatabaseManager.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart' as http_parser;

class NetworkManager {
  static Map<String, int> asyncValidator = {};
  String call(String url, BuildContext context, Function callback, {var body, onError, cachable, isDelete = false}) {
    String storageKey = url;
    int validatorKey = DateTime.now().microsecondsSinceEpoch;
    asyncValidator[url] = validatorKey;

    if (body != null) {
      for (var key in body.keys) {
        storageKey += key + body[key].toString();
      }
    }

    // callback function builder
    Function callbackBody = (responseBody, payloadStorageKey) {
      if (responseBody == null) return;

      try {
        log('try');
        var jsonData = json.decode(responseBody);
        // log('try: $jsonData');
        try {
          // log('try2:');
          // log('try2_jsonData: $jsonData');
          // log('try2_payloadStorageKey: $payloadStorageKey');
          return callback(jsonData, payloadStorageKey);
        } catch (e) {
          // log('catch1: $e');
          return callback(jsonData);
        }
      } catch (e) {
        DatabaseManager.unset(storageKey);
        if (onError != null)
          onError('Error trying parsing server responce . ');
        else
          log('onError: $e');

        if (context != null) {
          Alert.endLoading(context2: context);
          if (json.decode(responseBody)['state'] != null && json.decode(responseBody)['state'] == false) {
            if (json.decode(responseBody)['message_code'] != null && json.decode(responseBody)['message_code'] != -1)
              Alert.show(context, LanguageManager.getText(int.parse(json.decode(responseBody)['message_code'].toString())));
            else
              Alert.show(context, Converter.getRealText(json.decode(responseBody)['message']));
          } else if(json.decode(responseBody)['state'] != null && json.decode(responseBody)['state'] == true){
            Alert.show(context, 'onError: $e');
          }else
            Alert.show(context, responseBody);
        }
      }
    };

    Future serverCall(payloadInfo) async {
      var header = Globals.header();
      var response;

      log("----------START---------");
      log('url: $url');
      log('form-data: $body');
      log('header: $header');
      log("-----------END--------");

      if (body != null)
        response = await http.post(Uri.parse(url), headers: header, body: body).catchError((e) {processError(e, context);});
      else if (isDelete == true)
        response = await http.delete(Uri.parse(url), headers: header).catchError((e) {processError(e, context);});
      else
        response = await http.get(Uri.parse(url), headers: header).catchError((e) {processError(e, context);});

      // log
      try{
        log("----------START---------");
        log('url: $url');
        log('form-data: $body');
        log('header: $header');
        log('response.body: ${response.body}');
        log("-----------END--------");
      }catch(e){
        print('heree: catch: $e');
      }

      if (response == null) {
        if (onError != null) onError("Null Responce");
      }

      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        if (onError != null) onError("Error while fetching data");
        if(context != null) {
          Alert.endLoading(context2: context);
          Alert.show(context, response.body.toString().length == 0? '$url\n--------\nstatusCode: ${response.statusCode}': response.body);
        }
        throw new Exception("Error while fetching data");
      }else if (context != null && response.body != null
          && json.decode(response.body)['state'] != null
          && json.decode(response.body)['state'] == false) {

        // if(json.decode(response.body)['code'] == '401'){
        //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Login()), (Route<dynamic> route) => false);
        // }

        if(context != null)
          Alert.endLoading(context2: context);
        else
          Alert.endLoading();

        var r = json.decode(response.body);
        // r['message_code'] = 10;
        if(notInAllow(r, url)){
          if (r['message_code'] != null && r['message_code'] != -1)
            Alert.show(context, LanguageManager.getText(int.parse(r['message_code'].toString())));
          else if (r['code'] != null && r['code'] is Map && (r['code'] as Map).containsKey('message'))
            Alert.show(context, Converter.getRealText(r['code']['message']));
          else
            Alert.show(context, Converter.getRealText(r['message']));
        }
      }


      if (asyncValidator[payloadInfo['url']] != payloadInfo['validatorKey']) {
        return null;
      }

      try {

        if (cachable == true) {
          DatabaseManager.save(payloadInfo['localStorageKey'], response.body);
        }
        return {
          "data": response.body,
          "storageKey": payloadInfo['localStorageKey']
        };
      } catch (e) {
        if (onError != null) onError("Error in the server responce format");
        throw Exception("Error in the server responce format");
      }
    }

    serverCall({
      "validatorKey": validatorKey,
      "localStorageKey": storageKey,
      "url": url
    }).then((payload) {
      if (payload == null) return;
      //Alert.endLoading(context2: context);
      callbackBody(payload['data'], payload['storageKey']);
    });

    // send The cached Version of the paylaod responce
    // throw the function in thread tp delay , so the cashKey can be returnd before the callback

    if (cachable == true) {
      var cachedData = DatabaseManager.load(storageKey);
      if (cachedData != null && cachedData != "" && cachedData != "null") {
        callbackBody(cachedData, storageKey);
      }
    }

    // callback idenity
    return storageKey;
  }

  void fileUpload(url, List filesData, onProgress, callback, {body}) async {
    log("----------START---------");
    log('url: $url');
    log('form-data: $body');
    log("-----------END--------");

    final request = MultipartRequest(
      'POST',
      Uri.parse(url),
      onProgress: (int bytes, int total) {
        final progress = bytes / total;
        print(progress);
        onProgress(progress);
      },
    );
    var header = Globals.header();
    for (var key in header.keys) {
      request.headers[key] = header[key];
    }
    if (body != null)
      for (var key in body.keys) {
        request.fields[key] = body[key];
      }

    for (var fileData in filesData) {
      request.files.add(http.MultipartFile.fromBytes(
          fileData['name'], fileData['file'],
          contentType: http_parser.MediaType(
              fileData["type_name"], fileData["file_type"]),
          filename: fileData['file_name']));
    }

    StreamedResponse streamedResponse = await request.send();
    final responceBody = await streamedResponse.stream.bytesToString();
    try {
      var jsonResponce = json.decode(responceBody);

      log("----------START---------");
      log('url: $url');
      log('form-data: $body');
      log('header: $header');
      log('response.body: $jsonResponce');
      log("-----------END--------");


      callback(jsonResponce);
    } catch (e) {
      print(responceBody);
    }
  }

  static void httpGet(String url, BuildContext context, Function callback,
      {cashable = false, onError, Map<String, String> body}) {
    if (body != null) {
      List<String> getData = [];
      for (var key in body.keys) {
        getData.add(key + "=" + Uri.decodeComponent(body[key]));
      }
      url = url + (url.contains("?") ? "&" : "?") + getData.join("&");
    }
    NetworkManager().call(url, context, callback, onError: onError, cachable: cashable);
  }

  /// Return Cash Key
  static String httpPost(String url, BuildContext context, Function callback,
      {var body, onError, cachable}) {
    return NetworkManager()
        .call(url, context, callback, body: body, onError: onError, cachable: cachable);
  }

  static String httpDelete(String url, BuildContext context, Function callback,
      {var body, onError}) {
    return NetworkManager()
        .call(url, context, callback, body: body, onError: onError,  isDelete: true);
  }

  static log(e) {
    print(e);
  }

  bool notInAllow(r, String url) {
    if(r['message'].toString() == 'api.failed.unauthenticated' && url.endsWith('api/notifications'))
      return false;
    else
      return true;
  }

  void processError(e, context) {
    Alert.endLoading(context2: context);
    Alert.show(context,
        ((e.toString().contains('errno = 7')
            && LanguageManager.getText(362) != 'NO_LANGUAGE_FOUND'
            && LanguageManager.getText(362) != 'NO_TEXT_FOUND'
        )? LanguageManager.getText(362) : Converter.getRealText(e)));
  }

}

class MultipartRequest extends http.MultipartRequest {
  /// Creates a new [MultipartRequest].
  MultipartRequest(
    String method,
    Uri url, {
    this.onProgress,
  }) : super(method, url);

  final void Function(int bytes, int totalBytes) onProgress;

  /// Freezes all mutable fields and returns a single-subscription [ByteStream]
  /// that will emit the request body.
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    if (onProgress == null) return byteStream;

    final total = this.contentLength;
    int bytes = 0;

    final t = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        onProgress(bytes, total);
        sink.add(data);
      },
    );
    final stream = byteStream.transform(t);
    return http.ByteStream(stream);
  }
}

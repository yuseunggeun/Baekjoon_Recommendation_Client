import 'package:baekjoon_recommendation_client/baekjoon_recommendation_client.dart'
    as baekjoon_recommendation_client;

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future main() async {
  var serverIp = InternetAddress.loopbackIPv4.host;
  var serverPort = 8080;
  var serverPath;

  var httpClient = HttpClient();
  var httpResponseContent;

  HttpClientRequest httpRequest;
  HttpClientResponse httpResponse;

  var content;
  var savedFilter = <dynamic, dynamic>{};
  var jsonContent = <dynamic, dynamic>{};
  var searchFilter = <dynamic, dynamic>{};
  var fileFilter = <dynamic, dynamic>{};
  var command, input, taglist;

  var file;
  var sink;
  String fileText;

  while (true) {
    print("[SetFilter:1, Search:2, ShowBookmark:3, ShowSolved:4, Exit:0]");
    command = stdin.readLineSync().toString();
    if (command == "0") {
      break;
    }

    switch (command) {
      case "1":
        print("SetMinDifficulty(0~30) : ");
        input = int.parse(stdin.readLineSync().toString());
        searchFilter = {"minDifficulty": input};

        print("SetMaxDifficulty(0~30) : ");
        input = int.parse(stdin.readLineSync().toString());
        searchFilter["maxDifficulty"] = input;

        print("SetMinSolveCount(0~) : ");
        input = int.parse(stdin.readLineSync().toString());
        searchFilter["minSolveCount"] = input;

        print("SetMaxSolveCount(0~) : ");
        input = int.parse(stdin.readLineSync().toString());
        searchFilter["maxSolveCount"] = input;

        print("SelectTagOption(and : 0, or : else) : ");
        input = stdin.readLineSync().toString();
        if (input == "0") {
          searchFilter["logical"] = "and";
        } else {
          searchFilter["logical"] = "or";
        }

        print("SetTags(tag1,tag2,...) : ");
        taglist = stdin.readLineSync().toString().split(",");
        searchFilter["tags"] = taglist;

        fileText = jsonEncode(searchFilter);
        file = File("file.txt");
        file.writeAsStringSync(fileText);

        savedFilter = searchFilter;

        break;
      case "2":
        //content = jsonEncode(savedFilter);

        file = File("file.txt");
        content = file.readAsStringSync();

        serverPath = "/problem/search";

        httpRequest = await httpClient.post(serverIp, serverPort, serverPath)
          ..headers.contentType = ContentType.json
          ..headers.contentLength = content.length
          ..write(content);
        httpResponse = await httpRequest.close();
        httpResponseContent = await utf8.decoder.bind(httpResponse).join();
        httpResponseContent = json.decode(httpResponseContent);
        printHttpContentInfo(httpResponse, httpResponseContent);

        print("[ViewDetail:bojTagId, Exit:0]");
        command = stdin.readLineSync().toString();
        if (command == "0") {
          break;
        }

        serverPath = "/problem/" + command;

        httpRequest = await httpClient.get(serverIp, serverPort, serverPath);
        httpResponse = await httpRequest.close();
        httpResponseContent = await utf8.decoder.bind(httpResponse).join();
        httpResponseContent = json.decode(httpResponseContent);
        printHttpContentInfo(httpResponse, httpResponseContent);

        print("[challengeProblem:1, Exit:0]");
        command = stdin.readLineSync().toString();
    }
  }

// Create : POST
  print("북마크 생성");
  jsonContent = {};
  content = jsonEncode(jsonContent);
  serverPath = "/bookmark/1260";
  httpRequest = await httpClient.post(serverIp, serverPort, serverPath)
    ..headers.contentType = ContentType.json
    ..headers.contentLength = content.length
    ..write(content);
  httpResponse = await httpRequest.close();
  httpResponseContent = await utf8.decoder.bind(httpResponse).join();
  httpResponseContent = json.decode(httpResponseContent);
  printHttpContentInfo(httpResponse, httpResponseContent);

  print("북마크 조회");
  jsonContent = {};
  content = jsonEncode(jsonContent);
  serverPath = "/bookmark";
  httpRequest = await httpClient.get(serverIp, serverPort, serverPath);
  httpResponse = await httpRequest.close();
  httpResponseContent = await utf8.decoder.bind(httpResponse).join();
  httpResponseContent = json.decode(httpResponseContent);
  printHttpContentInfo(httpResponse, httpResponseContent);

  print("북마크 삭제");
  jsonContent = {};
  content = jsonEncode(jsonContent);
  serverPath = "/bookmark/3";
  httpRequest = await httpClient.delete(serverIp, serverPort, serverPath)
    ..headers.contentType = ContentType.json
    ..headers.contentLength = content.length
    ..write(content);
  httpResponse = await httpRequest.close();
  httpResponseContent = await utf8.decoder.bind(httpResponse).join();
  httpResponseContent = json.decode(httpResponseContent);
  printHttpContentInfo(httpResponse, httpResponseContent);

  print("북마크 메모 수정");
  jsonContent = {"memo": "memomemomemo"};
  content = jsonEncode(jsonContent);
  serverPath = "/bookmark/4";
  httpRequest = await httpClient.put(serverIp, serverPort, serverPath)
    ..headers.contentType = ContentType.json
    ..headers.contentLength = content.length
    ..write(content);
  httpResponse = await httpRequest.close();
  httpResponseContent = await utf8.decoder.bind(httpResponse).join();
  httpResponseContent = json.decode(httpResponseContent);
  printHttpContentInfo(httpResponse, httpResponseContent);
}

void printHttpContentInfo(var httpResponse, var httpResponseContent) {
  print("|<- status-code    : ${httpResponse.statusCode}");
  print("|<- content-type   : ${httpResponse.headers.contentType}");
  print("|<- content-length : ${httpResponse.headers.contentLength}");
  print("|<- content        : $httpResponseContent");
}

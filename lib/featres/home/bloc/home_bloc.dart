import 'dart:io';

import 'package:another_telephony/telephony.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:photo_manager/photo_manager.dart';
// import 'package:send_sms/constants/app_constants.dart';
import 'package:send_sms/featres/home/bloc/home_event.dart';
import 'package:send_sms/featres/home/bloc/home_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_sms/helper/local_helper.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final gemini = Gemini.instance;
  List<CallLogEntry> callLogs = [];
  Telephony telephony = Telephony.instance;

  HomeBloc() : super(HomeInitialState()) {
    on<HomeInitialEvent>(_initial);
    on<GetCallLogsEvent>(_getCallLogs);
    on<SaveMessageTemplateEvent>(_saveMessageTemplate);
    on<CallStateListenEvent>(_callStateListen);
    on<InsertNewCallLogEvent>(_insertNewCallLog);
  }

  Future<void> _initial(
    HomeInitialEvent event,
    Emitter<HomeState> emitter,
  ) async {
    final result = await _requestPermisions();
    if (result) {
      emitter(GrantedRequestPermissionState());
    }
  }

  Future<bool> _requestPermisions() async {
    final status = await [
      Permission.photos,
      Permission.phone,
      // Permission.notification,
    ].request();
    return status[Permission.photos]!.isGranted &&
        status[Permission.phone]!.isGranted 
        // &&
        // status[Permission.notification]!.isGranted
        ;
  }

  Future<void> _getCallLogs(
    GetCallLogsEvent event,
    Emitter<HomeState> emitter,
  ) async {
    Iterable<CallLogEntry> entries = await CallLog.query(
      type: CallType.outgoing,
      dateTimeFrom: DateTime.now().subtract(Duration(days: 1)),
      dateTimeTo: DateTime.now().add(Duration(days: 1)),
    );
    var callLogs = entries.toList();
    callLogs = callLogs
        .where((test) => test.name == null || test.name == "")
        .toList();
    emitter(GetCallLogsState(callLogs: callLogs));
  }

  void _saveMessageTemplate(
    SaveMessageTemplateEvent event,
    Emitter<HomeState> emitter,
  ) {
    final value = event.template;
    if (value != null) {
      LocalHelper.saveMessageTemplate(value);
    }
  }

  void _callStateListen(
    CallStateListenEvent event,
    Emitter<HomeState> emitter,
  ) {
    Stream<PhoneState> phoneStateStream = PhoneState.stream;
    phoneStateStream.listen((snapshot) async {
      final phoneStatus = snapshot.status;
      if (phoneStatus == PhoneStateStatus.CALL_ENDED) {
        final phoneNumber = snapshot.number;
        if (phoneNumber != null) {
          add(InsertNewCallLogEvent(phoneNumber: phoneNumber));
          final screenshotFile = await _getLastScreenshot();
          if (screenshotFile != null) {
            // final candidates = await gemini.prompt(
            //   parts: [
            //     Part.text(textPrompt),
            //     Part.bytes(screenshotFile.readAsBytesSync()),
            //   ],
            // );
            // if (candidates != null) {
            //   final content = candidates.content;
            //   TextPart? textPart = content?.parts?.first as TextPart?;
            //   final messageTemplate = await LocalHelper.getMessageTemplate();
            //   if (textPart != null && messageTemplate.isNotEmpty) {
            //     telephony.sendSms(
            //       to: phoneNumber,
            //       message: '${textPart.text}\n$messageTemplate',
            //       isMultipart: true,
            //       statusListener: (status) {
            //         debugPrint('SMS status: $status');
            //       },
            //     );
            //   }
            // }
          }
        }
      }
    });
  }

  void _insertNewCallLog(
    InsertNewCallLogEvent event,
    Emitter<HomeState> emitter,
  ) {
    final newCallLog = CallLogEntry(
      number: event.phoneNumber,
      callType: CallType.outgoing,
    );
    emitter(InsertNewCallLogState(callLogEntry: newCallLog));
  }

  Future<File?> _getLastScreenshot() async {
    // 1. Lấy danh sách các album (AssetPathEntity)
    // Thường ảnh chụp màn hình nằm trong album tên là "Screenshots"
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: false,
    );
    // Tìm album Screenshots hoặc lấy album "Recent" (thường là album đầu tiên)
    AssetPathEntity? screenshotAlbum;
    try {
      screenshotAlbum = albums.firstWhere((album) => album.isAll == true);
    } catch (e) {
      // Nếu không tìm thấy album Screenshot cụ thể, lấy album chứa tất cả ảnh
      screenshotAlbum = albums.isNotEmpty ? albums.first : null;
    }
    if (screenshotAlbum == null) return null;
    // 2. Lấy ảnh mới nhất từ album (index 0)
    final assetCount = await screenshotAlbum.assetCountAsync;
    List<AssetEntity> assets = await screenshotAlbum.getAssetListRange(
      start: 0,
      end: assetCount,
    );
    if (assets.isEmpty) return null;
    // 3. Chuyển đổi AssetEntity thành File
    final lastImageFile = await assets.last.file;
    debugPrint('Last screenshot path: ${lastImageFile?.path}');
    return lastImageFile;
  }
}

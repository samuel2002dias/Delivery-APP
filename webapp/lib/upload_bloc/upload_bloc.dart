// ignore_for_file: avoid_web_libraries_in_flutter, unused_import

import 'dart:html' as html;
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:webapp/product/product_repository.dart';



part 'upload_event.dart';
part 'upload_state.dart';

class UploadPictureBloc extends Bloc<UploadPictureEvent, UploadPictureState> {
  ProductClass productRepo;

  UploadPictureBloc(this.productRepo) : super(UploadPictureLoading()) {
    on<UploadPicture>((event, emit) async {
      try {
        String url = await productRepo.sendImage(event.file, event.name);
        emit(UploadPictureSuccess(url));
      } catch (e) {
        emit(UploadPictureFailure());
      }
    });
  }
}

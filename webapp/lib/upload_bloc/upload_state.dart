part of 'upload_bloc.dart';

sealed class UploadPictureState extends Equatable {
  const UploadPictureState();

  @override
  List<Object?> get props => [];
}

final class UploadPictureLoading extends UploadPictureState {}

final class UploadPictureFailure extends UploadPictureState {
  get error => null;

}

final class UploadPictureSuccess extends UploadPictureState {
  final String url;

  const UploadPictureSuccess(this.url);

  @override
  List<Object?> get props => [];
}

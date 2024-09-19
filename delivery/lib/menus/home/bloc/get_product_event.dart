part of 'get_product_bloc.dart';

sealed class GetProductEvent extends Equatable {
  const GetProductEvent();

  @override
  List<Object> get props => [];
}

class GetProduct extends GetProductEvent {}

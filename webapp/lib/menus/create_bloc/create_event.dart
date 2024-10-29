part of 'create_bloc.dart';

sealed class CreateProductEvent extends Equatable {
  const CreateProductEvent();

  @override
  List<Object> get props => [];
}

class CreateProduct extends CreateProductEvent {
  final Product product;

  const CreateProduct(this.product);

  @override
  List<Object> get props => [Product];
}

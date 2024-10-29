import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:webapp/product/product_repository.dart';

part 'create_event.dart';
part 'create_state.dart';

class CreateProductBloc extends Bloc<CreateProductEvent, CreateProductState> {
  ProductClass productRepo;

  CreateProductBloc(this.productRepo) : super(CreateProductInitial()) {
    on<CreateProduct>((event, emit) async {
      emit(CreateProductLoading());
      try {
        await productRepo.createProduct(event.product);
        emit(CreateProductSuccess());
      } catch (e) {
        emit(CreateProductFailure());
      }
    });
  }
}

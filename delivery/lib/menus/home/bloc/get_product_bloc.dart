import 'package:bloc/bloc.dart';
import 'package:delivery/product/src/models/product.dart';
import 'package:delivery/product/src/productClass.dart';
import 'package:equatable/equatable.dart';

part 'get_product_event.dart';
part 'get_product_state.dart';

class GetProductBloc extends Bloc<GetProductEvent, GetProductState> {
  final ProductClass _productRepo;

  GetProductBloc(this._productRepo) : super(GetProductInitial()) {
    on<GetProduct>((event, emit) async {
      emit(GetProductLoading());
      try {
        List<Product> products = await _productRepo.getProduct();
        emit(GetProductSuccess(products));
      } catch (e) {
        emit(GetProductFailure());
      }
    });
  }
}

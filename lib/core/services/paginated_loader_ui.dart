import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/services/paginated_list.dart';
import 'package:get/get.dart';

mixin PaginatedLoaderUi on GetxController {
  LoadingState get paginationContentState;
  PaginatedList<dynamic> get paginatedList;

  bool get showPaginationLoader =>
      paginationContentState == LoadingState.loaded &&
      paginatedList.showLoadMoreLoader;
}

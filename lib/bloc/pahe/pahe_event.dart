part of 'pahe_bloc.dart';
sealed class PaheEvent{

}

class StartPage extends PaheEvent{
  
}
class GetNextPage extends PaheEvent{
  
}

class GetAnimePage extends PaheEvent{
  final Pahe pahe;
  GetAnimePage({required this.pahe});
}

class GetSearch extends PaheEvent{
  final String searchTerm;
  GetSearch({required this.searchTerm});
}
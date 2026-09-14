

// Контракт на преврашение в Json
abstract class ToJsonable {
  Map<String, dynamic> toJson();
}

// Контракт на преврашение из Json
typedef Converter<T> = T Function(dynamic data);




// Response - обертка над запросом содержащий данные и метаданные
class WrResponse<T> {
  final T? data;
  final int statusCode;
  final String? errorMessage;
  final bool isSuccess;


 
  WrResponse({
    this.data,
    required this.statusCode,
    this.errorMessage,
    required this.isSuccess
  });

  // Фабричный конструктор для успешного ответа
  factory WrResponse.success({T? data, required int statusCode}) {
    return WrResponse(
      data: data,
      statusCode: statusCode,
      isSuccess: true,
    );
  }

  // Фабричный конструктор для ошибки
  factory WrResponse.error({required int statusCode, required String message}) {
    return WrResponse(
      statusCode: statusCode,
      errorMessage: message,
      isSuccess: false,
    );
  } 

}




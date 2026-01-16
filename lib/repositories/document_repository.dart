import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_doc/models/document_model.dart';
import 'package:http/http.dart';
import 'package:pretty_logger/pretty_logger.dart';

import '../models/response_model.dart';
import '../urls.dart';

final Provider<DocumentRepository> documentRepositoryProvider =
    Provider<DocumentRepository>((ref) => DocumentRepository(client: Client()));

class DocumentRepository {
  final Client _client;

  DocumentRepository({required Client client}) : _client = client;

  Future<ResponseModel> createDocument(String? token) async {
    ResponseModel responseModel = ResponseModel(errorMessage: null, data: null);
    try {
      final Uri uri = Uri.parse(Urls.createDocumentUrl);
      final Response res = await _client.post(
        uri,
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
          'x-auth-token': token ?? '',
        },
        body: jsonEncode({'createdAt': DateTime.now().microsecondsSinceEpoch}),
      );
      PLog.warning(res.statusCode.toString()) ;
      PLog.warning(res.body) ;
      switch (res.statusCode) {
        case 200:
          final responseBody = jsonDecode(res.body);
          responseModel = ResponseModel(
            errorMessage: null,
            data: DocumentModel.fromMap(responseBody),
          );
          return responseModel;
        default:
          responseModel = ResponseModel(errorMessage: res.body, data: null);
          return responseModel;
      }
    } catch (e) {
      responseModel = ResponseModel(errorMessage: e.toString(), data: null);
      return responseModel;
    }
  }

  Future<ResponseModel> getDocument(String? token) async{
    ResponseModel responseModel =ResponseModel(errorMessage: null, data: null) ;
    try{
      final Uri uri =  Uri.parse(Urls.getDocumentUrl);
      final Response res = await _client.get(uri, headers: {
        'Content-type': 'application/json; charset=UTF-8',
        'x-auth-token': token ?? '',
      });

      switch(res.statusCode){
        case 200:
          final List<DocumentModel> documents = [];
          final responseBody = jsonDecode(res.body);
          for(var item in responseBody['documents']){
            documents.add(DocumentModel.fromMap(item));
          }
          responseModel = ResponseModel(errorMessage: null, data: documents) ;
          return responseModel ;
          default:
            responseModel = ResponseModel(errorMessage: res.body, data: null) ;
            return responseModel ;

      }
    }catch(e){
        responseModel = ResponseModel(errorMessage: e.toString(), data: null);
        return responseModel ;
    }
  }

}

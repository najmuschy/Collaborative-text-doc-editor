import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_doc/models/response_model.dart';
import 'package:google_doc/repositories/auth_repository.dart';
import 'package:pretty_logger/pretty_logger.dart';
import 'package:routemaster/routemaster.dart';

import '../models/document_model.dart';
import '../repositories/document_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  void signOut(WidgetRef ref) {
    ref.read(authRepositoryProvider).signOut();
    ref.read(userProvider.notifier).state = null;
  }

  Future<void> createDocument(BuildContext context, WidgetRef ref) async {
    final navigator = Routemaster.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    String token = ref.read(userProvider)!.token!;
    final ResponseModel responseModel = await ref
        .read(documentRepositoryProvider)
        .createDocument(token);
    print(responseModel.data);
    if (responseModel != null && responseModel.data != null) {
      navigator.push('/doc/${responseModel.data.id}');
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(responseModel.errorMessage ?? 'something went wrong'),
        ),
      );
    }
  }
  void navigateToDocument(BuildContext context ,String id){
    Routemaster.of(context).push('/doc/$id');
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => createDocument(context, ref),
            icon: Icon(Icons.add),
          ),
          IconButton(
            onPressed: () => signOut(ref),
            icon: Icon(Icons.logout, color: Colors.red),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<ResponseModel>(
          future: ref.watch(documentRepositoryProvider).getDocument(ref.watch(userProvider)!.token),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: Center(child: CircularProgressIndicator()));
            }
            return LayoutBuilder(builder: (context, constraints){
              int crossAxisCount ;
              if(constraints.maxWidth>600){
                crossAxisCount = 4;

              }
              else if(constraints.maxWidth>400){
                crossAxisCount = 2;
              }
              else{
                crossAxisCount = 1;
              }
              return  Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: snapshot.data!.data.length,
                  itemBuilder: (context, index){
                    DocumentModel documentModel = snapshot.data!.data[index];
                    return InkWell(
                      onTap: ()=>navigateToDocument(context, documentModel.id),
                      child: Card(
                          child: ListTile(
                            title: Text(documentModel.title),
                          )
                      ),
                    );
                  }, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, mainAxisSpacing: 4, crossAxisSpacing: 5, childAspectRatio:1.5),),
              );
            });
          }),
    );
  }
}

import 'dart:async';

import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_doc/colors.dart';
import 'package:google_doc/models/document_model.dart';
import 'package:google_doc/models/response_model.dart';
import 'package:google_doc/repositories/document_repository.dart';
import 'package:pretty_logger/pretty_logger.dart';

import '../repositories/auth_repository.dart';
import '../repositories/socket_repository.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({super.key, required this.id});

  @override
  ConsumerState createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  SocketRepository socketRepository = SocketRepository();
  Timer? _debounce;
  final TextEditingController _titleController = TextEditingController(
    text: 'Untitled Document',
  );

  quill.QuillController? _textEditingController;

  void _onTitleChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 2000), () {
      updateDocumentTitle(value, ref);
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    socketRepository.joinRoom(widget.id);
    getDocumentData();
    socketRepository.changeListener(
      (data) => {
        _textEditingController?.compose(
          Delta.fromJson(data['delta']),
          _textEditingController?.selection ??
              const TextSelection.collapsed(offset: 0),
          quill.ChangeSource.remote,
        ),
      },
    );
    super.initState();
  }

  void updateDocumentTitle(String value, WidgetRef ref) {
    PLog.red('CALLED');
    ref
        .read(documentRepositoryProvider)
        .updateDocumentTitle(
          token: ref.read(userProvider)!.token!,
          id: widget.id,
          title: value,
        );
  }

  void getDocumentData() async {
    ResponseModel? responseModel = await ref
        .read(documentRepositoryProvider)
        .getDocumentData(token: ref.read(userProvider)!.token!, id: widget.id);
    if (responseModel != null && responseModel.data != null) {
      _titleController.text = (responseModel!.data as DocumentModel).title;
      _textEditingController = quill.QuillController(
        document: responseModel.data.content.isEmpty
            ? quill.Document()
            : quill.Document.fromDelta(
                Delta.fromJson((responseModel.data as DocumentModel).content),
              ),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(responseModel.errorMessage!)));
    }

    setState(() {});

    _textEditingController!.document.changes.listen((event){
      if(event.source == quill.ChangeSource.local){
        Map<String, dynamic> map ={
          'delta' : event.change ,
          'room' : widget.id
        };
      socketRepository.typing(map);
      }
    });



    Timer.periodic(const Duration(seconds: 2), (timer) {
      socketRepository.autoSave({
        'delta': _textEditingController!.document.toDelta(),
        'room': widget.id
      });
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsetsGeometry.all(8),
            child: buildShareButton(),
          ),
        ],
        title: Row(
          spacing: 16,
          children: [
            Image.asset('assets/images/docs-logo.png', height: 40),
            buildDocumentTitleSection(),
          ],
        ),
        bottom: buildAppBarBottom(),
      ),
      body: Center(
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            quill.QuillSimpleToolbar(
              controller: _textEditingController!,
              config: const quill.QuillSimpleToolbarConfig(),
            ),
            Expanded(child: buildQuillEditor()),
          ],
        ),
      ),
    );
  }

  LayoutBuilder buildQuillEditor() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final width = screenWidth > 800
            ? screenWidth * 0.7
            : screenWidth * 0.95;
        final editorPadding = screenWidth > 800 ? 64.0 : 32.0;
        return SizedBox(
          width: width,

          child: TextFieldTapRegion(
            child: Card(
              color: kWhiteColor,
              elevation: 5,
              child: quill.QuillEditor.basic(
                controller: _textEditingController!,
                config: quill.QuillEditorConfig(
                  minHeight: double.infinity,
                  showCursor: true,
                  padding: EdgeInsetsGeometry.all(editorPadding),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  ElevatedButton buildShareButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: 'http://localhost:3000/#/doc/${widget.id}')).then((value){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Link copied to clipboard')));
        });
      },
      label: Text('Share', style: TextStyle(color: Colors.white, fontSize: 13)),
      icon: Icon(Icons.lock, color: Colors.white),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        fixedSize: Size(100, 40),
      ),
    );
  }

  PreferredSize buildAppBarBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(
        height: 1,
        width: double.infinity,
        color: Colors.grey.shade500,
      ),
    );
  }

  SizedBox buildDocumentTitleSection() {
    return SizedBox(
      width: 180,
      child: TextField(
        controller: _titleController,
        decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: _onTitleChanged,
      ),
    );
  }
}

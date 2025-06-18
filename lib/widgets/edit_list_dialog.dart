import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/list_detail_provider.dart';
import '../constants/constants.dart';

class EditListDialog extends StatefulWidget {
  final String listId;
  final String initialName;
  final String? initialTag;
  final String? initialDescription;
  final bool initialVisible;
  const EditListDialog({Key? key, required this.listId, required this.initialName, this.initialTag, this.initialDescription, this.initialVisible = true}) : super(key: key);

  @override
  State<EditListDialog> createState() => _EditListDialogState();
}

class _EditListDialogState extends State<EditListDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  String? _tag;
  String? _description;
  late bool _visible;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _tag = widget.initialTag;
    _description = widget.initialDescription;
    _visible = widget.initialVisible;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(AppConstants.cardGrey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Listeyi Düzenle'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Liste Adı*'),
                onSaved: (v) => _name = v!.trim(),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ad gerekli' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _tag,
                decoration: const InputDecoration(labelText: 'Etiket'),
                onSaved: (v) => _tag = v?.trim(),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Açıklama'),
                maxLines: 2,
                onSaved: (v) => _description = v?.trim(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Herkese Açık'),
                  const Spacer(),
                  Switch(value: _visible, onChanged: (v) => setState(() => _visible = v)),
                ],
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _loading ? null : () => Navigator.pop(context), child: const Text('İptal')),
        ElevatedButton(
          onPressed: _loading
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    setState(() { _loading = true; _error = null; });
                    final success = await context.read<ListDetailProvider>().updateList(
                          widget.listId,
                          name: _name,
                          tag: _tag,
                          description: _description,
                          visible: _visible,
                        );
                    setState(() { _loading = false; });
                    if (success) {
                      if (mounted) Navigator.pop(context, true);
                    } else {
                      setState(() => _error = 'Güncelleme başarısız');
                    }
                  }
                },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(AppConstants.primaryGreen)),
          child: _loading ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2)) : const Text('Kaydet'),
        ),
      ],
    );
  }
} 
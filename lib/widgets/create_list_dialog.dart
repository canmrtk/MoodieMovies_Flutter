import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_lists_provider.dart';
import '../constants/constants.dart';

class CreateListDialog extends StatefulWidget {
  const CreateListDialog({Key? key}) : super(key: key);

  @override
  State<CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<CreateListDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String? _tag;
  String? _description;
  bool _visible = true;
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(AppConstants.cardGrey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Yeni Liste Oluştur'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Liste Adı*'),
                onSaved: (v) => _name = v!.trim(),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ad gerekli' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Etiket'),
                onSaved: (v) => _tag = v?.trim(),
              ),
              const SizedBox(height: 8),
              TextFormField(
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
                    final success = await context.read<UserListsProvider>().createList(
                          name: _name,
                          tag: _tag,
                          description: _description,
                          visible: _visible,
                        );
                    setState(() { _loading = false; });
                    if (success) {
                      if (mounted) Navigator.pop(context, true);
                    } else {
                      setState(() => _error = 'Liste oluşturulamadı');
                    }
                  }
                },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(AppConstants.primaryGreen)),
          child: _loading ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2)) : const Text('Oluştur'),
        ),
      ],
    );
  }
} 
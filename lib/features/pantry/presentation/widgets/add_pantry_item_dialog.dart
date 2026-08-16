import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/app/colors.dart';
import 'package:meal_recommendation_app/features/pantry/data/models/pantry_item_model.dart';
import 'package:meal_recommendation_app/features/pantry/data/pantry_dependencies.dart';

class PantryItemFormResult {
  final String ingredient;
  final double quantity;
  final String unit;

  const PantryItemFormResult({
    required this.ingredient,
    required this.quantity,
    required this.unit,
  });
}

class AddPantryItemDialog extends ConsumerStatefulWidget {
  final PantryItemModel? item;

  const AddPantryItemDialog({super.key, this.item});

  @override
  ConsumerState<AddPantryItemDialog> createState() =>
      _AddPantryItemDialogState();
}

class _AddPantryItemDialogState extends ConsumerState<AddPantryItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ingredientController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final FocusNode _ingredientFocusNode;

  Timer? _debounce;

  bool get isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _ingredientController = TextEditingController(
      text: widget.item?.ingredient ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.item != null ? widget.item!.displayQuantity : '',
    );
    _unitController = TextEditingController(text: widget.item?.unit ?? '');
    _ingredientFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ingredientController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _ingredientFocusNode.dispose();
    super.dispose();
  }

  /// Debounces network calls so we don't hit the backend on every keystroke.
  /// `RawAutocomplete` internally discards results from stale (superseded)
  /// calls, so we don't need extra race-condition handling here.
  Future<List<String>> _fetchSuggestions(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) return Future.value(const []);

    final completer = Completer<List<String>>();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final datasource = ref.read(ingredientSuggestionDatasourceProvider);
        final results = await datasource.search(query);
        if (!completer.isCompleted) completer.complete(results);
      } catch (_) {
        if (!completer.isCompleted) completer.complete(const []);
      }
    });
    return completer.future;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      PantryItemFormResult(
        ingredient: _ingredientController.text.trim(),
        quantity: double.parse(_quantityController.text.trim()),
        unit: _unitController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.burntOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.kitchen_outlined,
              color: AppColors.burntOrange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(isEditing ? 'Edit Item' : 'Add Item'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RawAutocomplete<String>(
              textEditingController: _ingredientController,
              focusNode: _ingredientFocusNode,
              optionsBuilder: (textEditingValue) =>
                  _fetchSuggestions(textEditingValue.text),
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Ingredient',
                    prefixIcon: Icon(Icons.search, color: AppColors.burntOrange),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            leading: const Icon(
                              Icons.circle,
                              size: 6,
                              color: AppColors.burntOrange,
                            ),
                            title: Text(option),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                hintText: 'Quantity',
                prefixIcon: Icon(Icons.numbers_rounded, color: AppColors.burntOrange),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                final parsed = double.tryParse(value.trim());
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid quantity';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _unitController,
              decoration: const InputDecoration(
                hintText: 'Unit (e.g. g, pcs, cups)',
                prefixIcon: Icon(Icons.straighten_rounded, color: AppColors.burntOrange),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
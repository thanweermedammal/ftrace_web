import 'package:flutter/material.dart';

class MultiSelectDropdown<T> extends StatefulWidget {
  final String hint;
  final List<T> items;
  final List<String> selectedIds;
  final String Function(T) labelMapper;
  final String Function(T) idMapper;
  final void Function(List<String> selectedIds, List<T> selectedItems)
  onChanged;

  const MultiSelectDropdown({
    super.key,
    required this.hint,
    required this.items,
    required this.selectedIds,
    required this.labelMapper,
    required this.idMapper,
    required this.onChanged,
  });

  @override
  State<MultiSelectDropdown<T>> createState() => _MultiSelectDropdownState<T>();
}

class _MultiSelectDropdownState<T> extends State<MultiSelectDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Background listener to close on outside tap
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height + 5.0),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: widget.items.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text("No items available"),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: widget.items.length,
                          itemBuilder: (context, index) {
                            final item = widget.items[index];
                            final id = widget.idMapper(item);
                            final label = widget.labelMapper(item);
                            final isSelected = widget.selectedIds.contains(id);

                            return InkWell(
                              onTap: () {
                                final newSelectedIds = List<String>.from(
                                  widget.selectedIds,
                                );
                                if (isSelected) {
                                  newSelectedIds.remove(id);
                                  setState(() {});
                                } else {
                                  newSelectedIds.add(id);
                                  setState(() {});
                                }
                                // Find corresponding items (optional optimization)
                                final newSelectedItems = widget.items
                                    .where(
                                      (i) => newSelectedIds.contains(
                                        widget.idMapper(i),
                                      ),
                                    )
                                    .toList();
                                widget.onChanged(
                                  newSelectedIds,
                                  newSelectedItems,
                                );
                                setState(() {});
                                _overlayEntry?.markNeedsBuild();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight:  FontWeight.normal,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),

                                    // if (isSelected)
                                    //   const Icon(
                                    //       Icons.check, color: Colors.blue,
                                    //       size: 18),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isOpen = false;
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleDropdown,
        child: InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            suffixIcon: Icon(
              _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: Colors.grey.shade600,
            ),
          ),
          child: widget.selectedIds.isEmpty
              ? Text(
                  widget.hint,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: widget.items
                      .where(
                        (item) =>
                            widget.selectedIds.contains(widget.idMapper(item)),
                      )
                      .map((item) {
                        return Chip(
                          label: Text(
                            widget.labelMapper(item),
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.grey.shade200,
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            final newSelectedIds = List<String>.from(
                              widget.selectedIds,
                            );
                            newSelectedIds.remove(widget.idMapper(item));
                            final newSelectedItems = widget.items
                                .where(
                                  (i) => newSelectedIds.contains(
                                    widget.idMapper(i),
                                  ),
                                )
                                .toList();
                            widget.onChanged(newSelectedIds, newSelectedItems);
                            setState(() {});
                            _overlayEntry?.markNeedsBuild();
                          },
                        );
                      })
                      .toList(),
                ),
        ),
      ),
    );
  }
}

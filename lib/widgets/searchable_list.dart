import 'package:flutter/material.dart';

class SearchableList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T) itemBuilder;
  final String hintText; final String Function(T) searchKey;

  const SearchableList({
    super.key, required this.items, required this.itemBuilder, required this.searchKey,
    this.hintText = "Search"
  });

  @override
  State<SearchableList> createState() => _SearchableListState<T>();
}

class _SearchableListState<T> extends State<SearchableList<T>> {

  List<T> filtered = [];
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    filtered = widget.items;
  }


  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: [

      SliverToBoxAdapter(child: SearchBar(
        controller: controller,
        leading: const Icon(Icons.search), hintText: widget.hintText,
        onChanged: (text) => setState(() => filtered = widget.items.where(
          (item) => widget.searchKey(item).contains(text.toLowerCase())
        ).toList()),
        trailing: filtered.length == widget.items.length ? null : [IconButton(
          onPressed: () {
            controller.clear();
            setState(() => filtered = widget.items);
          },
          icon: const Icon(Icons.close)
        )]
      )),

      SliverList.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) => widget.itemBuilder(filtered[index])
      )

    ]);
  }
}

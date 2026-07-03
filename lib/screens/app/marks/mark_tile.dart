import 'package:flutter/material.dart';
import 'package:vstop/lib/db.dart' show Mark;

class MarkTile extends StatefulWidget {
  final Mark mark;
  final String? grade; final void Function()? onTap, onLongTap;
  const MarkTile(this.mark, { super.key, this.grade, this.onTap, this.onLongTap });

  @override
  State<MarkTile> createState() => _MarkTileState();
}

class _MarkTileState extends State<MarkTile> {
  bool weighted = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == .dark;
    final isEst = widget.grade != null && widget.grade!.length == 2;

    return Card(child: ListTile(
      title: Text(widget.mark.title), onTap: widget.onTap ?? () => setState(() => weighted = !weighted),
      onLongPress: widget.onLongTap,
      subtitle: widget.grade == null ? null : Text("Grade${isEst ? ' (est)' : ''}: ${isEst ? widget.grade![1] : widget.grade}"),
      trailing: widget.mark.maxScore == 0 ? null : Stack(
        alignment: .center,
        children: [
          CircularProgressIndicator(
            value: widget.mark.score/widget.mark.maxScore,
            constraints: .tight(Size(50, 50)),
          ),
          SizedBox(
            width: 40,
            child: Column(
              mainAxisSize: .min, crossAxisAlignment: .center, mainAxisAlignment: .center,
              children: [
                Text((weighted ? widget.mark.score : widget.mark.mark).ceil().toString()),
                Divider(color: isDark ? Colors.white54 : Colors.black12),
                Text((weighted ? widget.mark.maxScore : widget.mark.maxMark).ceil().toString())
              ],
            ),
          )
        ],
      ),
    ));
  }
}



import 'package:flutter/material.dart';

class MarkTile extends StatelessWidget {
  final String name; final double score; final double maxScore;
  final String? grade; final void Function()? onTap;
  const MarkTile({
    super.key, required this.name, required this.score, required this.maxScore,
    this.grade, this.onTap
  });

  @override
  Widget build(BuildContext context) {

    final isDark = Theme.of(context).brightness == .dark;
    final isEst = grade != null && grade!.length == 2;

    return Card(child: ListTile(
      title: Text(name), onTap: onTap,
      subtitle: grade == null ? null : Text("Grade${isEst ? ' (est)' : ''}: ${isEst ? grade![1] : grade}"),
      trailing: maxScore == 0 ? null : Stack(
        alignment: .center,
        children: [
          CircularProgressIndicator(
            value: score/maxScore,
            constraints: .tight(Size(50, 50)),
          ),
          SizedBox(
            width: 40,
            child: Column(
              mainAxisSize: .min, crossAxisAlignment: .center, mainAxisAlignment: .center,
              children: [
                Text(score.round().toString()),
                Divider(color: isDark ? Colors.white54 : Colors.black12),
                Text(maxScore.round().toString())
              ],
            ),
          )
        ],
      ),
    ));
  }
}



import 'dart:async';

const List<int> kPreciousResource = <int>[3, 1, 4, 1, 5];

int resourceRequest(int index) => kPreciousResource[index];

Future<void> sleep(int ms) => Future<void>.delayed(Duration(milliseconds: ms));

class Union {
  const Union();
}

const union = Union();

class CopyWith {
  final bool copyWithNull;
  const CopyWith({this.copyWithNull = true});
}

class CopyWithIgnore {
  const CopyWithIgnore();
}

const copyWith = CopyWith();

const copyWithIgnore = CopyWithIgnore();

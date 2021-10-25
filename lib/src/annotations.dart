class Props {
  const Props();
}

class PropsExclude {
  const PropsExclude();
}

const props = Props();

const propsExclude = PropsExclude();

class CopyWith {
  final bool copyWithNull;
  const CopyWith({this.copyWithNull = true});
}

class CopyWithIgnore {
  const CopyWithIgnore();
}

const copyWith = CopyWith();

const copyWithIgnore = CopyWithIgnore();

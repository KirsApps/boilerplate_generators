class Props {
  const Props();
}

class ExcludeFromProps {
  const ExcludeFromProps();
}

const props = Props();

const excludeFromProps = ExcludeFromProps();

class CopyWith {
  final bool copyWithNull;
  const CopyWith({this.copyWithNull = true});
}

class CopyWithIgnore {
  const CopyWithIgnore();
}

const copyWith = CopyWith();

const copyWithIgnore = CopyWithIgnore();

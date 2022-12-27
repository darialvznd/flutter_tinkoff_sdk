enum TinkoffCheckType { no, hold, threeDs, threeDsHold }

extension TinkoffCheckTypeHelper on TinkoffCheckType {
  String get value {
    switch (this) {
      case TinkoffCheckType.no:
        return "NO";
      case TinkoffCheckType.hold:
        return "HOLD";
      case TinkoffCheckType.threeDs:
        return "THREE_DS";
      case TinkoffCheckType.threeDsHold:
        return "THREE_DS_HOLD";
    }
  }
}

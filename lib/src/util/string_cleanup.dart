extension StringCleanup on String {
  /// Cleans this String in one go,
  /// removing \r characters (Widows line breaks)
  /// and replacing multiple whitespaces with single ones.
  String clean() => replaceAllMapped(
        RegExp(r'\r| +'),
        (match) => match.group(0)!.startsWith(' ') ? ' ' : '',
      );
}

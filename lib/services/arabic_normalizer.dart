class ArabicNormalizer {
  ArabicNormalizer._();

  static final RegExp _tashkeel = RegExp(
    r'[\u064B-\u065F\u0670\u06D6-\u06ED\u0640]',
  );
  static final RegExp _spaces = RegExp(r'\s+');

  static String normalize(String input) {
    var text = input.trim();
    if (text.isEmpty) {
      return '';
    }

    text = text.replaceAll(_tashkeel, '');
    text = text.replaceAll('أ', 'ا');
    text = text.replaceAll('إ', 'ا');
    text = text.replaceAll('آ', 'ا');
    text = text.replaceAll('ٱ', 'ا');
    text = text.replaceAll('ى', 'ي');
    text = text.replaceAll('ة', 'ه');
    text = text.replaceAll('ؤ', 'و');
    text = text.replaceAll('ئ', 'ي');
    text = text.replaceAll('ء', '');
    text = text.replaceAll(_spaces, ' ');
    return text;
  }
}

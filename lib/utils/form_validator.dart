String? noEmpty(String? value) {
  return value == null || value.isEmpty ? "此处不能为空" : null;
}

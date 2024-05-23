part of 'account_page.dart';

class _SegmentedItem {
  const _SegmentedItem({required this.name, required this.icon});

  final String name;
  final Widget icon;
}

class _AddAccountDialog extends StatelessWidget {
  _AddAccountDialog({required this.onSubmit});

  final void Function(Account account) onSubmit;

  final _accountTypes = const {
    AccountType.offline:
        _SegmentedItem(name: "离线", icon: Icon(Icons.public_off)),
    // FIXME: 微软图标替换
    AccountType.microsoft:
        _SegmentedItem(name: "微软", icon: Icon(Icons.grid_view)),
    AccountType.custom: _SegmentedItem(name: "自定义", icon: Icon(Icons.tune)),
  };

  final _selectedAccountType = Rx<AccountType>(AccountType.offline);
  final _formKey = GlobalKey<FormState>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<GlobalKey<FormState>>('formKey', _formKey));
  }

  @override
  Widget build(BuildContext context) {
    late Account account;
    late Widget form;
    return DefaultDialog(
      title: const Text("添加用户"),
      content: SizedBox(
        width: 400,
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<AccountType>(
                onSelectionChanged: (set) =>
                    _selectedAccountType.value = set.first,
                segments: List.generate(_accountTypes.length, (index) {
                  final key = _accountTypes.keys.elementAt(index);
                  final item = _accountTypes[key]!;
                  return ButtonSegment(
                    value: key,
                    label: Text(item.name),
                    icon: item.icon,
                  );
                }),
                selected: {_selectedAccountType.value},
              ),
              const SizedBox(height: 15),
              Form(
                key: _formKey,
                child: () {
                  switch (_selectedAccountType.value) {
                    case AccountType.offline:
                      return form = _OfflineLoginForm();
                    case AccountType.microsoft:
                      return form = _MicosoftLoginForm(onSubmit: onSubmit);
                    // TODO: 自定义登录
                    case AccountType.custom:
                      return form = const _CustomLoginForm();
                  }
                }(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        const DialogCancelButton(onPressed: dialogPop, cancelText: Text("取消")),
        Obx(
          () => _selectedAccountType.value == AccountType.microsoft
              ? nil
              : DialogConfirmButton(
                  onPressed: () {
                    switch (_selectedAccountType.value) {
                      case AccountType.offline:
                        if (_formKey.currentState!.validate()) {
                          account = (form as _OfflineLoginForm).submit();
                          onSubmit(account);
                        }
                      case AccountType.microsoft:
                        null;
                      case AccountType.custom:
                        null;
                    }
                  },
                  confirmText: const Text("确定"),
                ),
        )
      ],
    );
  }
}

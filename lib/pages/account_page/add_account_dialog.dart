part of 'account_page.dart';

final _accountTypeProvider =
    StateProvider.autoDispose((ref) => AccountType.offline);

class _SegmentedItem {
  const _SegmentedItem({required this.name, required this.icon});

  final String name;
  final Widget icon;
}

class _AddAccountDialog extends StatefulWidget {
  const _AddAccountDialog({required this.onSubmit});

  final void Function(Account account) onSubmit;

  @override
  State<_AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<_AddAccountDialog> {
  final _accountTypes = const {
    AccountType.offline:
        _SegmentedItem(name: "离线", icon: Icon(Icons.public_off)),
    AccountType.microsoft:
        _SegmentedItem(name: "微软", icon: Icon(Mdi.microsoft)),
    AccountType.custom: _SegmentedItem(name: "自定义", icon: Icon(Icons.tune)),
  };

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
        child: Consumer(builder: (context, ref, child) {
          final accountType = ref.watch(_accountTypeProvider);
          final notifier = ref.watch(_accountTypeProvider.notifier);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<AccountType>(
                onSelectionChanged: (set) => notifier.state = set.first,
                segments: List.generate(_accountTypes.length, (index) {
                  final key = _accountTypes.keys.elementAt(index);
                  final item = _accountTypes[key]!;
                  return ButtonSegment(
                    value: key,
                    label: Text(item.name),
                    icon: item.icon,
                  );
                }),
                selected: {accountType},
              ),
              const SizedBox(height: 15),
              Form(
                key: _formKey,
                child: () {
                  switch (accountType) {
                    case AccountType.offline:
                      return form = _OfflineLoginForm();
                    case AccountType.microsoft:
                      return form =
                          MicosoftLoginForm(onSubmit: widget.onSubmit);
                    // TODO: 自定义登录
                    case AccountType.custom:
                      return form = const _CustomLoginForm();
                  }
                }(),
              ),
            ],
          );
        }),
      ),
      actions: [
        const DialogCancelButton(onPressed: dialogPop, cancelText: Text("取消")),
        Consumer(builder: (context, ref, child) {
          final accountType = ref.watch(_accountTypeProvider);
          return Offstage(
            offstage: accountType == AccountType.microsoft,
            child: DialogConfirmButton(
              onPressed: () {
                switch (accountType) {
                  case AccountType.offline:
                    if (_formKey.currentState!.validate()) {
                      account = (form as _OfflineLoginForm).submit();
                      widget.onSubmit(account);
                      dialogPop();
                    }
                  case AccountType.microsoft:
                    null;
                  case AccountType.custom:
                    null;
                }
              },
              confirmText: const Text("确定"),
            ),
          );
        }),
      ],
    );
  }
}

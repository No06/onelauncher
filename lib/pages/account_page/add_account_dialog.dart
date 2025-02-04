part of 'account_page.dart';

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

  var _accountType = AccountType.offline;
  final _formKey = GlobalKey<FormState>();
  final _offlineLoginFormKey = GlobalKey<_OfflineLoginFormState>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<GlobalKey<FormState>>('formKey', _formKey));
  }

  void _onSelectionChanged(Set<AccountType> set) => setState(() {
        _accountType = set.first;
      });

  @override
  Widget build(BuildContext context) {
    late Account account;
    return DefaultDialog(
      title: const Text("添加用户"),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<AccountType>(
              onSelectionChanged: _onSelectionChanged,
              segments: List.generate(_accountTypes.length, (index) {
                final key = _accountTypes.keys.elementAt(index);
                final item = _accountTypes[key]!;
                return ButtonSegment(
                  value: key,
                  label: Text(item.name),
                  icon: item.icon,
                );
              }),
              selected: {_accountType},
            ),
            const SizedBox(height: 15),
            Form(
              key: _formKey,
              child: switch (_accountType) {
                AccountType.offline =>
                  _OfflineLoginForm(key: _offlineLoginFormKey),
                AccountType.microsoft =>
                  MicosoftLoginForm(onSubmit: widget.onSubmit),
                AccountType.custom => const _CustomLoginForm(),
              },
            ),
          ],
        ),
      ),
      actions: [
        DialogCancelButton(
          onPressed: context.pop,
          cancelText: const Text("取消"),
        ),
        switch (_accountType) {
          AccountType.microsoft => const SizedBox(),
          _ => DialogConfirmButton(
              onPressed: switch (_accountType) {
                AccountType.offline => () {
                    if (_formKey.currentState!.validate()) {
                      account = _offlineLoginFormKey.currentState!.submit();
                      widget.onSubmit(account);
                      context.pop();
                    }
                  },
                AccountType.microsoft => null,
                AccountType.custom => null,
              },
              confirmText: const Text("确定"),
            ),
        },
      ],
    );
  }
}

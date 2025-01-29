part of 'account_page.dart';

final _accountTypeProvider =
    StateProvider.autoDispose((ref) => AccountType.offline);

class _SegmentedItem {
  const _SegmentedItem({required this.name, required this.icon});

  final String name;
  final Widget icon;
}

class _AddAccountDialog extends ConsumerStatefulWidget {
  const _AddAccountDialog({required this.onSubmit});

  final void Function(Account account) onSubmit;

  @override
  ConsumerState<_AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends ConsumerState<_AddAccountDialog> {
  final _accountTypes = const {
    AccountType.offline:
        _SegmentedItem(name: "离线", icon: Icon(Icons.public_off)),
    AccountType.microsoft:
        _SegmentedItem(name: "微软", icon: Icon(Mdi.microsoft)),
    AccountType.custom: _SegmentedItem(name: "自定义", icon: Icon(Icons.tune)),
  };

  final _formKey = GlobalKey<FormState>();
  final _offlineLoginFormKey = GlobalKey<_OfflineLoginFormState>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<GlobalKey<FormState>>('formKey', _formKey));
  }

  @override
  Widget build(BuildContext context) {
    final accountType = ref.watch(_accountTypeProvider);
    final notifier = ref.watch(_accountTypeProvider.notifier);
    late Account account;
    return DefaultDialog(
      title: const Text("添加用户"),
      content: SizedBox(
        width: 400,
        child: Column(
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
              child: switch (accountType) {
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
        const DialogCancelButton(onPressed: dialogPop, cancelText: Text("取消")),
        Consumer(
          builder: (context, ref, child) {
            final accountType = ref.watch(_accountTypeProvider);
            return switch (accountType) {
              AccountType.microsoft => const SizedBox(),
              _ => DialogConfirmButton(
                  onPressed: switch (accountType) {
                    AccountType.offline => () {
                        if (_formKey.currentState!.validate()) {
                          account = _offlineLoginFormKey.currentState!.submit();
                          widget.onSubmit(account);
                          dialogPop();
                        }
                      },
                    AccountType.microsoft => null,
                    AccountType.custom => null,
                  },
                  confirmText: const Text("确定"),
                ),
            };
          },
        ),
      ],
    );
  }
}

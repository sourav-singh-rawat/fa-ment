part of pay_view;

class _RecentTransactionList extends StatelessWidget {
  const _RecentTransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: BlocSelector<PayCubit, PayState, AsyncState<List<Payment>>>(
        selector: (state) => state.transactions,
        builder: (BuildContext context, AsyncState<List<Payment>> transactions) {
          return switch (transactions) {
            AsyncIdle<List<Payment>>() => throw UnimplementedError(),
            // TODO: Handle this case.
            AsyncLoading<List<Payment>>() => CircularProgressIndicator(),
            // TODO: Handle this case.
            AsyncFailure<List<Payment>>() => Text(
              transactions.error ?? 'Error',
            ),
            // TODO: Handle this case.
            AsyncPartial<List<Payment>>() => throw UnimplementedError(),
            // TODO: Handle this case.
            AsyncSuccess<List<Payment>>() => ListView.builder(
              itemCount: (transactions.data ?? []).length,
              itemBuilder: (context, index) {
                final list = transactions.data ?? [];
                return Text(
                  "${list[index].serverId}: ${list[index].amount}: ${list[index].status}",
                );
              },
            ),
          };
        },
      ),
    );
  }
}

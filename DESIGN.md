
# Design notes

## State machine

A payment attempt starts as **pending**. `PayCubit` collects the recipient, amount, note, and gateway mode, then asks `PaymentFlowCoordinator` to create the payment. The coordinator generates a key, saves the attempt locally, listens for gateway updates, and starts a five-second create timeout.

- **Create returns:** The coordinator emits `CreateSucceeded`. `PayCubit` keeps the attempt and moves to confirmation.
- **Create times out or throws:** The coordinator emits `CreateTimedOut`. `PayCubit` shows the error but keeps the attempt, so pressing Pay again checks that attempt rather than creating another payment.
- **Confirmation:** `PaymentConfirmCubit` starts a deadline. The coordinator requests status, polls every two seconds, and listens for push updates. Pending keeps the flow open; success or failure is terminal. The cubit updates the locally saved payment with the received status. On a terminal result, the coordinator stops polling and listening for updates.
- **Deadline reached:** If there is no terminal result, confirmation ends with a pending status—not a claim that the payment failed. Backgrounding stops scheduled work and the update subscription; resuming re-subscribes and checks status against the same deadline.
- **Recent transactions:** `PayCubit` loads locally saved payments and displays only the two most recent. When a pending payment’s status is updated locally, a subsequent load reflects that status in the recent list. `PayCubit` does not itself persist status changes.

The seeded modes cover success (`pending → pending → success`), declined (`pending → failed`), lost create response (timeout; status can later reach success), pending forever (deadline ends confirmation as pending), flip after success (late failed push), and late success (success push after an earlier failed result).

## B3: success, then a failed push

I keep the first terminal status—success—and ignore the later failed push. The coordinator stops listening once it reaches a terminal status, so the push cannot flip the result. Without a version number, sequence number, or other authoritative metadata, I can’t tell whether the push is a real correction or just a delayed, out-of-order message. I apply the same rule in reverse: a success push cannot change an earlier terminal failure. In production, I’d want an explicit reconciliation rule backed by authoritative status metadata.

## Decisions I’m least confident about

1. **Feature-first clean architecture:** I chose it over a simpler MVVM or MVC setup to show how I think about scalability, separation of concerns, and SOLID principles. For a small project, it may be more structure than needed.
2. **Using many interfaces and contracts:** They make boundaries clear and implementations replaceable, but some may add ceremony without much benefit given the scope and timeline.
3. **Local storage:** I’m storing every payment even though the UI shows only the latest two. I considered using a SQLite `TRIGGER` to replace older records, but I couldn’t use that approach with `sqflite` package, need to find better package.
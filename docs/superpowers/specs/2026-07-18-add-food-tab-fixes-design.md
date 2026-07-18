# Add Food tab fixes — design

Date: 2026-07-18
Status: approved

## Scope

Four bounded fixes/small features in the Add Food screen (`lib/ui/add_food/`), reported after manual testing on a real device:

1. Autofocus the name field when the "Add product" dialog opens (Manual tab).
2. Text keyboards should follow the device's normal input rules (sentence auto-capitalization), which currently never engages on any text field.
3. Manual tab's product list needs a delete action with a confirmation dialog.
4. Barcode tab: camera never starts on a real device.

None of these interact with each other; they can ship as one PR but are independent to implement/verify.

## 1. Autofocus name field in "Add product" dialog

`showAddProductDialog` in `lib/ui/add_food/manual_tab.dart` builds the name field as a plain `TextField` with no `autofocus`. Add `autofocus: true` to that field only. No other dialog's name field is affected (existing-food dialogs edit values, not create-from-empty).

## 2. Sentence capitalization on text fields

Root cause: none of the app's `TextField`/`NumberField` widgets set `textCapitalization`, so it defaults to `TextCapitalization.none` and the device keyboard never auto-capitalizes the first letter of a sentence.

Fix: add `textCapitalization: TextCapitalization.sentences` to the four **free-text** fields (numeric fields are unaffected — they use `TextInputType.number` and capitalization is meaningless there):

- `showAddProductDialog` — name field (`manual_tab.dart`)
- `showEditableFoodDialog` — name field (`add_food_screen.dart`)
- `ManualTab` — search field (`manual_tab.dart`)
- `_SearchTab` — search field (`add_food_screen.dart`)

`NumberField` (`lib/ui/widgets/number_field.dart`) is not touched — it's numeric-only.

## 3. Delete product from Manual tab list

Each row in `ManualTab`'s list currently has one trailing icon (favorite star). Add a second trailing icon, a trash/delete icon, positioned to the right of the star, inside a `Row` (`mainAxisSize: MainAxisSize.min`) as the tile's `trailing`.

Tapping delete opens an `AlertDialog` confirmation:

- Text: new localized string with a `{name}` placeholder — ru: `"Продукт {name} будет удален! Подтвердить?"`, en: `"Product {name} will be deleted! Confirm?"`. New ARB key `addFoodDeleteConfirmMessage` in both `app_ru.arb`/`app_en.arb` (placeholder type `String`), following the existing `addFoodKcalPer100g` pattern for parameterized strings.
- Actions: Cancel / Confirm (reuse existing `addFoodCancelButton` label; new `addFoodDeleteConfirmButton` label — ru "Удалить", en "Delete").

On confirm: call `foodRepository.deleteFood(food.existingPrivateFoodId!)` (already implemented in `lib/data/food_repository.dart:65`), then `_refresh()`. No new repository code needed — `PrivateFoods` deletion is already `ON DELETE SET NULL` on the diary FK (`lib/db/database.dart:38`), so past diary entries keep their name/macro snapshot and are unaffected by the delete.

No undo — the confirmation dialog is the only safeguard, matching the wording the user specified.

## 4. Barcode camera not starting on a real device

Root cause: `android/app/src/main/AndroidManifest.xml` has no `<uses-permission android:name="android.permission.CAMERA"/>`. `mobile_scanner` (and the underlying CameraX/ML Kit stack) requires this manifest declaration to request the runtime camera permission; without it, the permission request silently fails and `MobileScanner` never starts a camera session. This reproduces exactly as described (works fine on some emulators that pre-grant permissions, fails on real devices that prompt).

Fix: add to the manifest, before `<application>`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-feature android:name="android.hardware.camera" android:required="false"/>
```

`required="false"` on the `uses-feature` avoids blocking installation on the (hypothetical) camera-less Android device via Play Store filtering — the app has other ways to add food if the camera is unavailable.

No Dart-side changes are needed; `mobile_scanner`'s default `MobileScanner` widget already handles the runtime permission prompt once the manifest grants the capability.

## Testing

- 1, 2, 3: verified via `flutter test` (widget-level, if existing tests cover `ManualTab`/dialogs) plus manual run on the Android emulator (per the `run` skill) — capitalization behavior itself can only be truly confirmed on a real device/emulator keyboard, not a widget test.
- 4: manifest-only change; verify by running on a real device (emulator camera permission behavior differs) and confirming the OS permission prompt appears and the scanner activates.

## Out of scope

- No changes to iOS camera permissions (`Info.plist`) — user only reported the Android real-device repro.
- No batch-delete / undo-delete for item 3.
- No changes to `_RecentTab`'s favorite-only list (no delete action requested there).

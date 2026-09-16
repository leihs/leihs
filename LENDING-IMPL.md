# Legacy: Lending Section (Alternative Pickup Locations)

Source: [WIP Alternative Pickup Locations — Lending Section](https://github.com/leihs/leihs/wiki/WIP-Alternative-Pickup-Locations#lending-section)

**Scope:** implement in `legacy` (Manage) when `inventory_pools.enable_alternative_pickup_locations = true`.  
When the flag is `false`, UI/behavior stays unchanged.

**DB already present (no new migrations expected):**
- `reservations.pickup_location_id`
- `reservations.sent_to_pickup_location_at` / `sent_to_pickup_location_by_user_id` → “handed to courier” (warehouse → alt location)
- `reservations.sent_back_to_main_location_at` / `sent_back_to_main_location_by_user_id` → “handed to courier” (alt location → main warehouse)
- Reminder skip for drop-off at PUL already wired via `Reservation.not_dropped_off_at_pickup_location` in `User` reminders

---

## Gate

All new Manage UI / flows below must be shown or active only if:

```ruby
current_inventory_pool.enable_alternative_pickup_locations
```

---

## 1. Pick up & Hand-over

### 1.1 Show pickup location on order + hand-over lines
- [x] On **order edit** lines, show alternative pickup location name when `pickup_location_id` is set (else main / omit when feature off).
- [x] On **hand-over** lines, show the same pickup location.
- Likely touchpoints:
  - `app/assets/javascripts/manage/views/reservations/order_line.jsr.erb`
  - `app/assets/javascripts/manage/views/reservations/hand_over_line/item_line.jsr.erb`
  - reservation JSON / presenters so `pickup_location` (id, name) is available client-side

### 1.2 “Handed to courier” checkbox (warehouse → alt location)
- [x] On hand-over item lines with an alternative pickup location: show checkbox **“handed to courier”**.
- [x] Checking it sets `sent_to_pickup_location_at` + `sent_to_pickup_location_by_user_id` (current user); unchecking clears them.
- [x] State persists across page refresh (read from reservation attributes).
- [x] Visible to all lending managers so they see items already given to the courier.
- [x] Add API endpoint or extend `Manage::ReservationsController#update` to toggle these fields (feature-flag + only when `pickup_location_id` present).
- [x] **Do not create a contract** when handing to courier — assign/scan item only; contract is created later at the pickup location when handed to the user (see 1.4).

### 1.3 Picking list includes pickup location
- [x] Extend `app/views/documents/picking_list.html.haml` to show pickup location per line / group when feature enabled.
- Controllers already render this view: `Manage::ContractsController#picking_list`, `Manage::ReservationsController` (`picking_list` case).

### 1.4 Hand-over / contract at pickup location
- [x] Warehouse flow: scan + assign item + “handed to courier” → **no** contract / no `signed` status yet.
- [x] Pickup-location staff: complete normal hand-over to user → create contract as today.
- [ ] Clarify/implement how managers at the alt location find and hand over lines already marked sent to courier (filters / visit lists if needed).

---

## 2. Drop off & Return

### 2.1 “Handed to courier” checkbox (alt location → main warehouse)
- [x] On **take-back** lines (when feature on): after scan, show checkbox **“handed to courier”**.
- [x] Checking it sets `sent_back_to_main_location_at` + `sent_back_to_main_location_by_user_id`.
- [x] Effects (spec):
  - Borrow area treats item as **returned** (borrow already keys off `sent_back_to_main_location_at`).
  - **No further reminder emails** to the user — already implemented (`not_dropped_off_at_pickup_location`); verify still correct with UI toggle.
  - Item stays **unavailable** until taken back into the main warehouse (must not free availability on courier checkbox alone).
- [x] Final take-back at main warehouse: existing take-back closes the line/contract as today; ensure availability only returns after that (and after `transfer_buffer_after_drop_off` in availability calc — shared with borrow; verify Manage/timeline consistency).
- Likely touchpoints:
  - `app/assets/javascripts/manage/views/reservations/take_back_line/item_line.jsr.erb`
  - `Manage::ReservationsController#take_back` and/or a dedicated courier toggle action
  - availability / reservation concerns if take-back vs courier-drop-off must differ

### 2.2 Nice to have: bulk “handed to courier”
- [ ] Allow selecting multiple take-back (and optionally hand-over) lines and set “handed to courier” in one action.

---

## 3. Timeline

- [x] When feature on and reservation uses an alternative pickup location, timeline shows:
  - user-chosen **pickup date** (`start_date`)
  - user-chosen **return date** (`end_date`) **plus** `transfer_buffer_after_drop_off` (buffer days after drop-off)
- [x] Main warehouse reservations: timeline unchanged.
- Likely touchpoints:
  - `TimelineAvailability` / `Manage::ModelsController#timeline`
  - client timeline props if buffer end must be rendered explicitly

---

## 4. Tests & i18n

- [x] Feature / Cucumber or RSpec coverage for:
  - hand-over courier checkbox persist + no contract
  - picking list shows pickup location
  - take-back courier checkbox → reminders skipped, borrow “returned”, item not free until main take-back
  - timeline buffer display when alt location
  - feature flag off → no new UI
- [x] Gettext strings for “handed to courier”, pickup location labels; recompile i18n assets if needed.

---

## Already done (do not re-implement)

| Piece | Notes |
| --- | --- |
| Schema for PUL + reservation courier fields | migrations `079`–`085` |
| Skip reminders when dropped at PUL | `User` + `Reservation.not_dropped_off_at_pickup_location` |
| Mail templates show pickup location | `MailTemplate.pickup_location_name_for` |
| Model `transportable` (Inventory Section) | gated by same flag; not part of Lending Section |

---

## Suggested implementation order

1. Expose `pickup_location` (+ courier timestamps) on reservation JSON used by order / hand-over / take-back.
2. Display pickup location on order + hand-over lines + picking list.
3. Hand-over “handed to courier” toggle + contract/sign flow split.
4. Take-back “handed to courier” toggle + availability/reminder verification.
5. Timeline buffer display.
6. (Optional) bulk courier checkbox.

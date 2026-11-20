# Dependency update status (2026/11)

Branch: `mr/pr/dep-upd-leihs`

## Module status

| Module | osv-scan | clj-osv-scan | notes |
|--------|----------|--------------|-------|
| database | clean | n/a | done, squashed |
| deploy | clean | n/a | |
| integration-tests | clean | n/a | |
| admin | clean* | clean | dropped vendor deepmerge |
| borrow | clean* | | dropped vendor deepmerge |
| inventory | clean* | | dropped vendor deepmerge |
| legacy | | | |
| lending | | | |
| mail | | | |
| my | clean* | | dropped vendor deepmerge |
| procure | | | Firefox 153 CRUD waits; Speichern scope fix |

\* `GHSA-gcqx-w48m-w2h4` (deepmerge 4.3.1, CVSS 5.3) ignored in `.osv-scanner-config.toml` — no upstream npm patch; vendoring rejected.

## UI lint / deepmerge (2026-11-20)

Cause: vendored `ui/vendor/deepmerge` was linted by `eslint .` and failed prettier.

Resolution (no eslint/prettier ignore entries):

- delete `vendor/` in admin, borrow, my, inventory
- remove `file:vendor/deepmerge` override from package.json; lockfile back to npm `deepmerge@4.3.1`
- accept GHSA via osv-scanner ignore (same approach as leihs-calendar)

## lending feature spec (2026-11-20)

`Edit order the add form follows the first date range when it changes` failed with
start date off-by-one day (clicked adjacent cell). Selenium warned geckodriver
0.36.0 vs firefox 128.0. Hardened `pick_range` to wait for each click.

## browser tools (2026-11-20)

Aligned modules on `firefox 153.7.0esr` + `geckodriver 0.37.1` in `.tool-versions`:
admin, borrow, inventory, integration-tests, legacy, lending, my, procure.

## admin delegation edit spec (2026-11-20)

`editing a delegation works` failed: after Save the show page still had the
old name. Cause: edit/create modal `open*` re-seeded form state from
`@delegation*` whenever fetch completed (triggered by `?action=edit`), wiping
`fill_in` under faster Firefox 153. Fix: seed form in the Edit/Add button;
`open*` only merges query-params (choose-user return). Spec waits for the name
field before/after choose-user.

## borrow feature specs (2026-11-20)

Profile-switch scenarios (delegations, rentals, templates, search-and-order)
failed under Firefox 153. Cause: `window.location.reload` after GraphQL + 50ms;
waiting only for a stale profile button was too early (re-frame re-render remounts
the button before reload). Spec harden: mark `window` before select and wait until
the marker is gone after full reload; wait_until list cards match after switch.

Follow-up (local green): desktop-only
`.topnav__radix-dropdown-trigger` broke mobile nav (burger twin is
`.for-burger-mode`). Click/assert any *visible* `.ui-user-profile-button`.
Selecting already-active “User A (personal)” does not fire onChange/reload —
skip the marker wait when that option is already selected.

## lending theme spec (2026-11-20)

`toggle between dark and light themes` failed on second `open_theme_menu`
(`Unable to find link or button "Appearance"`). After applying dark theme the
header remounts; a leftover Radix menu made the next username click toggle
closed under Firefox 153. Fix: Escape + wait for closed menus, open via
`data-test-id`s, wait for menu content before/after theme selection.

## lending filters (2026-11-20)

`Orders filters focuses term filter input with Alt+Shift+F` failed under
Firefox 153: one-shot `document.activeElement.name` was `""` after the chord.
Cause: race — chord before TermFilter listener settled, and no wait for focus.
Spec harden: wait for `input[name=term]`, `body.send_keys([:shift,:alt,"f"])`,
then `match_css(":focus")` (same in visits list). Product shortcut unchanged.

## borrow search_results feature (2026-11-20)

`Filter with search term (and caching)` and `Category page (implicit filter…)`
flaked under Firefox 153: `I see N models` used find+all without waiting for
Load more / filter / cache refresh. Hardened steps to wait for `.ui-spinner`
gone and settled counts / "No items found".

## inventory feature specs (2026-11-20)

Firefox 153 flakes across Theme, entitlement/option/model/template CRUD,
Inventory Page filters, and bulk edit. Shared causes in helpers:

1. Leftover Radix menus/listboxes — next Status/select/user-menu click toggled
   closed instead of open. Hardened `dismiss_open_menus`, `select_value`,
   `open_status_menu` / `select_status_filter_submenu`; theme uses Escape +
   `data-test-id`s (same pattern as lending).
2. One-shot `body.text` toast checks raced submit/mount — replaced with
   `expect_toast` (`[data-sonner-toast]`, `visible: :all`, wait).
3. Delete confirm clicked ambiguous "Delete" while dropdown still open —
   `confirm_delete_dialog` / `delete_from_submit_dropdown` scope to alertdialog.
4. `await_debounce` could miss busy under fast FF — short settle sleep + wait.

### remaining three (local reproduce + fix)

Verified green locally (`bin/rspec` + `leihs_test` + FF 153.7 / geckodriver 0.37.1):

- `Create template 01` → `templates/create_spec.rb[1:1]`
- `Inventory Page 03` → `inventory-list/main_spec.rb[1:3]`
- `Search & Edit - bulk edit dynamic fields 01` → `bulk_edit_dynamic_fields_spec.rb[1:1]`

Root causes found by running them:

1. **`dismiss_open_menus` always sent Escape** — closed the bulk-edit Radix
   Dialog mid-flow. Fix: Escape only when a visible `[role=menu|listbox]` is open.
2. **Search & Edit filter race** — selecting Inventory Code remounts the value
   input; typing before settle wiped the term (no results). Fix: shared
   `select_search_filter_field` / `fill_search_filter_text` (await after select).
3. **Status submenu** — Radix `DropdownMenuSub` needs pointer-enter; click-only
   missed `button[name=broken]` on Inventory Page 03. Fix: hover+click in
   `select_status_filter_submenu`; await list settle after filter/`select_value`.
4. **Create template** — missed first-pass toast harden; models search needs
   `await_debounce` before picking from `models-list`.

Committed/pushed on `mr/pr/dep-upd-leihs`.

## procure request CRUD features (2026-11-20)

`admin_crud.feature` / `inspector_crud.feature` failed under Firefox 153.
Verified locally (`bin/rspec`, FF 153.7.0esr): **6 examples, 0 failures** (×2).

Root causes (shared helpers):

1. After Speichern, mutation swaps the form for `<Loading/>` while the
   RequestLine stays open; waiting only for `form` absence returned mid-
   Loading, so the next “expand” click toggled the line closed.
2. Holding a Capybara form node across Loading↔form remounts raised
   `StaleElementReferenceError` under FF 153.
3. Expanding via `li` text could hit a parent wrapper; click the closed
   `.cursor-pointer` row (prefer DB article_name after refetch).
4. Prior debounce flush (StatefulInput 100ms) kept; flush raised to 0.4s.

Committed and pushed to `mr/pr/dep-upd-leihs`.

## procure Speichern wait scope (2026-11-20)

`admin_crud_internal.feature` / `crud.feature` looked stuck/executing
(Timeout::Error). Cause: generic `I click on 'Speichern'` waited for
`form.ui-request-form` / `.text-success` after *every* Speichern — including
AdminKategorien and Budgetperioden saves, which never show a request form.

Fix: snapshot `request_save_context?` before click; only run the request-form
settle wait when a request form (or `@request`) is present; otherwise wait for
loading gone. Image-icon HTTP check also resolves relative `src` and sets
open/read timeouts.

Verified locally (`bin/rspec`, FF 153.7.0esr): **4 examples, 0 failures**
(`crud` + `admin_crud_internal`). Request-edit Speichern smoke still green.
Committed and pushed to `mr/pr/dep-upd-leihs`.

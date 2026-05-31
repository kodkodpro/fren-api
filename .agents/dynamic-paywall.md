# Dynamic Paywall Feature

## Goal

Dynamic paywall lets the backend assign each user a stable paywall variant and serve localized paywall copy from the database. This allows paywall copy, bullets, products, activation, and rollout weights to change without shipping a new app build.

## How It Works

- Paywalls are stored in the `paywalls` table with `name`, typed JSONB `data`, `active`, and integer `weight`.
- Every user has a required `users.paywall_id`.
- When a user is created, `User#assign_paywall` picks one active paywall with `weight > 0` using relative weighted random selection.
- Assignment is stable: `/paywall` returns the user's assigned paywall and does not re-run rollout selection.
- `active` and `weight` affect only future user assignment. Existing users keep their assigned paywall.

## Data Model

`Paywall::Data` is stored via `sorbet-model-attributes` in `paywalls.data`.

Shape:

```ruby
{
  default_locale: "en",
  locales: {
    "en" => {
      title: "...",
      bullets: [
        {
          title: "...",
          description: "...",
          icon: "...",
          icon_color: "..."
        }
      ]
    }
  },
  products: [
    {
      apple_product_id: "..."
    }
  ]
}
```

Products are top-level because App Store handles product localization. Only paywall display content is localized in `locales`.

## Localization

`GET /paywall` reads `X-Device-Language` and resolves content in this order:

1. exact normalized locale, e.g. `pt-BR` -> `pt-br`
2. base language, e.g. `pt-br` -> `pt`
3. `data.default_locale`
4. `en`

Paywall validation requires both `en` and `default_locale` content to exist. Locale keys are normalized for lookup, so stored keys may be mixed case.

## API

Authenticated endpoint:

```http
GET /paywall
X-User-Id: <uuid>
X-Device-Language: pt-BR
```

Response:

```json
{
  "id": "...",
  "name": "...",
  "title": "...",
  "bullets": [
    {
      "title": "...",
      "description": "...",
      "icon": "...",
      "icon_color": "..."
    }
  ],
  "products": [
    {
      "apple_product_id": "..."
    }
  ]
}
```

## Important Files

- `app/models/paywall.rb`: validations, fallback paywall, weighted assignment.
- `app/models/paywall/data.rb`: typed JSONB schema and locale resolution.
- `app/models/user.rb`: required `belongs_to :paywall` and create-time assignment.
- `app/controllers/paywalls_controller.rb`: `/paywall` response.
- `db/migrate/20260530120000_create_paywalls.rb`: creates paywalls, seeds fallback, backfills users, adds `users.paywall_id`.
- `test/models/paywall_test.rb`, `test/models/user_test.rb`, `test/controllers/paywalls_controller_test.rb`: focused coverage.

## Verification Notes

Focused tests:

```sh
mise exec ruby@4 -- bin/rails test test/models/paywall_test.rb test/models/user_test.rb test/controllers/paywalls_controller_test.rb
```

Known unrelated suite issues at time of writing:

- Full test suite has existing proxy subscription-gate failures because `ProxyController` has `before_action :require_active_subscription` commented out.
- `srb tc` has existing unrelated RBI gaps for WebMock helpers and `sorbet_enum`.

# Coinflow Card Form SDK - Swift

A SwiftUI SDK for integrating Coinflow's card tokenization forms into iOS apps.

## Requirements

- iOS 15+
- Swift 5.9+
- Xcode 15+

## Installation

### Swift Package Manager (Xcode)

File → Add Package Dependencies → enter:

```
https://github.com/coinflow-labs-us/coinflow-swift
```

Select version `0.1.0` (or "Up to Next Major"), then add the `CoinflowCardForm` library product to your target.

### Swift Package Manager (Package.swift)

```swift
dependencies: [
    .package(
        url: "https://github.com/coinflow-labs-us/coinflow-swift",
        from: "0.1.0"
    )
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "CoinflowCardForm", package: "coinflow-swift")
        ]
    )
]
```

## Usage

```swift
import SwiftUI
import CoinflowCardForm

struct PaymentView: View {
    @StateObject private var coordinator = CardFormCoordinator()

    var body: some View {
        VStack {
            CoinflowCardFormView(
                variant: .cardForm,
                merchantId: "your-merchant-id",
                env: .sandbox,
                coordinator: coordinator
            )
            .frame(height: 52)

            Button("Tokenize") {
                Task {
                    do {
                        let response = try await coordinator.tokenize()
                        print("Token: \(response.token)")
                    } catch {
                        // surface error to user
                    }
                }
            }
        }
    }
}
```

`coordinator.tokenize()` is `async throws`, returning a `TokenizeResponse` with:

- `token: String` — payment token to send to your backend
- `expMonth: String?`, `expYear: String?` — only populated for variants that collect expiry

## Configuration

### Merchant ID

Issued by Coinflow when you sign up — find it in the merchant dashboard. The same value works for both sandbox and production. Typically read from build config or environment:

```swift
private let merchantId = ProcessInfo.processInfo.environment["COINFLOW_MERCHANT_ID"] ?? ""
```

### Environment

Selects which Coinflow backend the form talks to:

- `.sandbox` — test cards, no real money. Use during integration and QA.
- `.prod` — live cards, real money.

The other cases (`.staging`, `.local`) are Coinflow-internal and not intended for integrators.

Typical pattern:

```swift
#if DEBUG
let env: CoinflowEnv = .sandbox
#else
let env: CoinflowEnv = .prod
#endif
```

## Variants

- `.cardForm` — full card entry (number, expiry, CVV)
- `.cardNumberForm` — card number + expiry only; returns a token used to render `.cvvForm` later
- `.cvvForm` — CVV only; requires the `token:` parameter

## Theming

`MerchantTheme` styles the rendered form to match your app. All fields are optional — pass only what you want to override. Minimal example:

```swift
let theme = MerchantTheme(primary: "#FF6600", style: .rounded)
```

Full example:

```swift
let theme = MerchantTheme(
    primary: "#165DFB",
    background: "#ffffff",
    backgroundAccent: "#F3F4F6",
    backgroundAccent2: "#E4E7EB",
    textColor: "#05092E",
    textColorAccent: "#030712",
    textColorAction: "#ffffff",
    ctaColor: "#165DFB",
    font: "Red Hat Display",
    style: .rounded
)
```

Pass into `CoinflowCardFormView(theme: theme, ...)`.

### Theme fields

| Field | Purpose |
| --- | --- |
| `primary`, `ctaColor` | Accent / action colors (hex strings) |
| `background`, `backgroundAccent`, `backgroundAccent2` | Form background tones |
| `textColor`, `textColorAccent`, `textColorAction` | Input and label text colors |
| `font`, `fontSize`, `fontWeight` | Typography. `font` must be available on the device. |
| `style` | Input shape: `.rounded`, `.sharp`, `.pill` |
| `cardNumberPlaceholder`, `cvvPlaceholder`, `expirationPlaceholder` | Override input placeholder text |
| `showCardIcon` | Toggle the card brand icon (Visa/Mastercard/Amex) |

## License

Apache 2.0 — see [LICENSE](./LICENSE).

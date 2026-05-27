# Changelog

## 0.2.0

- Add `@Published var contentHeight: CGFloat?` to `CardFormCoordinator`. The hosted form now reports its rendered content height (CSS pixels, 1:1 with `CGFloat` points) whenever it reflows — e.g. when narrow widths cause inputs to wrap to multiple rows. SwiftUI hosts can bind `.frame(height: coordinator.contentHeight ?? defaultHeight)` to keep the container fitted.
- Append `useHeightChange=true` to the form URL so the embedded iframe emits height-change postMessages.

## 0.1.0

- Initial release of `CoinflowCardForm`.
- WebView-backed card tokenization with `.cardForm`, `.cardNumberForm`, and `.cvvForm` variants.
- `MerchantTheme` support for styling the rendered form.
- `CardFormCoordinator.tokenize()` is `async throws` and returns a `TokenizeResponse` with token and optional expiry.

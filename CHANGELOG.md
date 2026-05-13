# Changelog

## 0.1.0

- Initial release of `CoinflowCardForm`.
- WebView-backed card tokenization with `.cardForm`, `.cardNumberForm`, and `.cvvForm` variants.
- `MerchantTheme` support for styling the rendered form.
- `CardFormCoordinator.tokenize()` is `async throws` and returns a `TokenizeResponse` with token and optional expiry.

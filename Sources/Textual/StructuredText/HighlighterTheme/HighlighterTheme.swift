import SwiftUI

extension StructuredText {
  /// A theme used to style syntax-highlighted code blocks.
  ///
  /// A `HighlighterTheme` defines the base foreground and background colors for code blocks and
  /// an optional set of token-specific text properties.
  ///
  /// You can set a highlighter theme using the ``TextualNamespace/highlighterTheme(_:)`` modifier.
  public struct HighlighterTheme: Hashable, Sendable {
    public var foregroundColor: DynamicColor
    public var backgroundColor: DynamicColor
    public var tokenProperties: [TokenType: AnyTextProperty]

    /// Creates a highlighter theme.
    ///
    /// - Parameters:
    ///   - foregroundColor: The default text color for code blocks.
    ///   - backgroundColor: The background color for code blocks.
    ///   - tokenProperties: Token-specific text properties. Token types are identified by a
    ///     string, for example `"keyword"` or `"comment"`.
    public init(
      foregroundColor: DynamicColor,
      backgroundColor: DynamicColor,
      tokenProperties: [TokenType: AnyTextProperty] = [:]
    ) {
      self.foregroundColor = foregroundColor
      self.backgroundColor = backgroundColor
      self.tokenProperties = tokenProperties
    }
  }
}

extension EnvironmentValues {
  @usableFromInline
  @Entry var highlighterTheme: StructuredText.HighlighterTheme = .default
}

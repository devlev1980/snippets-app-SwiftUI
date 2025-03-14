# SnippetsApp

SnippetsApp is an iOS application for managing code snippets.

# CodeView Theme Usage

The `CodeView` component in the SnippetsApp now supports manually specifying either light or dark theme using the `forceTheme` parameter:

## Examples

### Auto-theme (follows system)
```swift
CodeView(
    code: $snippetCode,
    language: selectedLanguage,
    isDisabled: false,
    showLineNumbers: false,
    fontSize: 14,
    theme: selectedTheme
)
```

### Force Dark Theme
```swift
CodeView(
    code: $snippetCode,
    language: selectedLanguage,
    isDisabled: false,
    showLineNumbers: false,
    fontSize: in14,
    theme: selectedTheme,
    forceTheme: .dark
)
```

### Force Light Theme
```swift
CodeView(
    code: $snippetCode,
    language: selectedLanguage,
    isDisabled: false,
    showLineNumbers: false,
    fontSize: 14,
    theme: selectedTheme,
    forceTheme: .light
)
```

## Implementation Details

The `forceTheme` parameter accepts a `ColorScheme` value (`.dark` or `.light`) that overrides the system's color scheme. This applies to the CodeView background, syntax highlighting theme, and UI elements.

When `forceTheme` is nil (the default), the component will follow the system's appearance setting. 
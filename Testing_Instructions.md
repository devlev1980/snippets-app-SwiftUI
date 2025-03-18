# SnippetsApp Testing Instructions

## Overview
This document outlines what testers should check in the current build of SnippetsApp, an iOS application for managing code snippets.

## Test Environment
- Test on multiple iOS devices (iPhone and iPad if possible)
- Test in both light and dark mode
- Test with different iOS versions (latest and one version prior recommended)

## Authentication Testing
1. **Sign Up Process**
   - Create a new account with valid credentials
   - Verify error handling for invalid email formats
   - Verify error handling for weak passwords
   - Verify error handling for already existing accounts

2. **Sign In Process**
   - Sign in with valid credentials
   - Verify error handling for incorrect credentials
   - Test the "Forgot Password" functionality

3. **Account Management**
   - Verify user profile information is displayed correctly
   - Test account settings modification

## Core Functionality Testing

### Snippet Management
1. **Creation**
   - Create a new snippet with a name, description, and code
   - Verify snippet is saved correctly
   - Test with various programming languages
   - Test with both short and long code blocks

2. **Viewing**
   - Verify snippets list displays all user snippets
   - Verify snippet details view shows all information correctly
   - Test code syntax highlighting for different languages
   - Verify code formatting is preserved

3. **Editing**
   - Edit an existing snippet's name, description, and code
   - Verify changes are saved and displayed correctly

4. **Deletion**
   - Delete a snippet and verify it's removed from the list
   - Check if confirmation dialog appears before deletion

5. **Favorites**
   - Mark snippets as favorites
   - Verify they appear in the Favorites tab
   - Remove snippets from favorites

### Tag Management
1. **Creation and Assignment**
   - Create new tags with different colors
   - Assign tags to snippets
   - Verify tag colors are displayed correctly

2. **Filtering**
   - Filter snippets by tags
   - Verify filtered results are accurate

3. **Tag Editing and Deletion**
   - Edit tag names and colors
   - Delete tags and verify they're removed from associated snippets

### Theme and Appearance
1. **Theme Support**
   - Test the app in light, dark, and system modes
   - Verify CodeView theme switching works correctly
   - Check all UI elements for proper theming

2. **CodeView Display**
   - Test code highlighting with various languages
   - Verify line numbers display correctly when enabled
   - Test different font sizes

## Cross-Functional Testing

1. **Performance**
   - Check app responsiveness with many snippets
   - Verify loading times for snippet lists and details
   - Test search functionality with a large dataset

2. **Offline Mode**
   - Test app behavior when offline
   - Verify data persistence and synchronization when connection is restored

3. **Data Migration**
   - If applicable, test data migration from previous app versions

## Bug Reporting
When reporting bugs, please include:
- Device model and iOS version
- Steps to reproduce the issue
- Expected vs. actual behavior
- Screenshots or screen recordings when possible
- Any error messages displayed

## Specific Areas of Focus for This Build
- Theme switching functionality, particularly the new `forceTheme` feature
- Tag management and color assignment
- Snippet filtering by tags
- Authentication flow improvements
- CodeView syntax highlighting for all supported languages

Thank you for your testing efforts! Your feedback is essential for improving the quality of SnippetsApp. 
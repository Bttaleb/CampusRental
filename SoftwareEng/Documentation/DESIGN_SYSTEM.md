# Wayne State University Design System

## Overview

This design system provides a comprehensive set of colors, spacing, typography, and components for the Campus Booking System iOS app, branded with Wayne State University's official green and yellow color palette.

---

## Brand Colors

### Primary Colors

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| **WSU Green** | `#006633` | Primary actions, navigation bars, main branding |
| **WSU Gold** | `#FFCB05` | Accent elements, highlights, secondary CTAs |

### Supporting Colors

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| **Light Green** | `#00833E` | Lighter backgrounds, completed status |
| **Dark Green** | `#004D26` | Text emphasis, darker variants |
| **Cream** | `#FFF8DC` | Subtle background tints |

### Neutral Colors (Light Theme)

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| **Background** | `#F8F9FA` | App background |
| **Card Background** | `#FFFFFF` | Card/surface backgrounds |
| **Text Primary** | `#1A1A1A` | Primary text |
| **Text Secondary** | `#6C757D` | Secondary/helper text |
| **Border** | `#E5E7EB` | Borders and dividers |

### Semantic Colors

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| **Success** | WSU Green (`#006633`) | Success messages, confirmed bookings |
| **Warning** | WSU Gold (`#FFCB05`) | Warnings, pending status |
| **Error** | `#DC3545` | Error messages, cancelled bookings |
| **Info** | `#0066CC` | Informational messages |

---

## Color Usage in Code

### SwiftUI Colors

```swift
// Brand colors
ColorTheme.wsuGreen
ColorTheme.wsuGold
ColorTheme.wsuLightGreen
ColorTheme.wsuDarkGreen

// Semantic colors
ColorTheme.primary      // WSU Green
ColorTheme.accent       // WSU Gold
ColorTheme.success      // WSU Green
ColorTheme.warning      // WSU Gold
ColorTheme.error        // Red

// Backgrounds
ColorTheme.background         // Off-white
ColorTheme.cardBackground     // White
ColorTheme.secondaryBackground // Light gray

// Text colors
ColorTheme.textPrimary      // Near black
ColorTheme.textSecondary    // Gray
ColorTheme.textOnPrimary    // White (for green backgrounds)
ColorTheme.textOnAccent     // Black (for gold backgrounds)

// Borders
ColorTheme.border
ColorTheme.divider

// Status colors
ColorTheme.statusPending     // Gold
ColorTheme.statusConfirmed   // Green
ColorTheme.statusCancelled   // Red
ColorTheme.statusCompleted   // Light Green
ColorTheme.statusNoShow      // Gray
```

### UIKit Colors (for Navigation Bar, etc.)

```swift
UIColor.wsuGreen
UIColor.wsuGold
```

---

## Spacing System

Consistent spacing values for layouts:

| Name | Value | Usage |
|------|-------|-------|
| `Spacing.xxs` | 4pt | Extra tight spacing |
| `Spacing.xs` | 8pt | Tight spacing |
| `Spacing.sm` | 12pt | Small spacing |
| `Spacing.md` | 16pt | Medium spacing (default) |
| `Spacing.lg` | 20pt | Large spacing |
| `Spacing.xl` | 24pt | Extra large spacing |
| `Spacing.xxl` | 32pt | Extra extra large |
| `Spacing.xxxl` | 40pt | Triple extra large |

### Specific Use Cases

```swift
Spacing.cardPadding           // 16pt
Spacing.cardCornerRadius      // 12pt
Spacing.buttonCornerRadius    // 10pt
Spacing.textFieldCornerRadius // 8pt
Spacing.screenHorizontal      // 16pt
Spacing.screenVertical        // 20pt
Spacing.sectionSpacing        // 24pt
```

### Example Usage

```swift
VStack(spacing: Spacing.lg) {
    // Content
}
.padding(Spacing.md)
```

---

## Typography

### Text Styles

```swift
Text("Title")
    .wsuTitle()          // Large title, bold, primary text color

Text("Heading")
    .wsuHeading()        // Section heading, semibold

Text("Subheading")
    .wsuSubheading()     // Subsection heading, medium

Text("Body")
    .wsuBody()           // Body text, regular

Text("Caption")
    .wsuCaption()        // Secondary/helper text, small

Text("Small Caption")
    .wsuSmallCaption()   // Very small text

Text("Section Header")
    .wsuSectionHeader()  // Section title in WSU green
```

### Font Specifications

| Style | Size | Weight | Color |
|-------|------|--------|-------|
| **Title** | 34pt | Bold | Primary |
| **Heading** | 22pt | Semibold | Primary |
| **Subheading** | 18pt | Medium | Primary |
| **Body** | 16pt | Regular | Primary |
| **Caption** | 14pt | Regular | Secondary |
| **Small Caption** | 12pt | Regular | Secondary |
| **Section Header** | 18pt | Semibold | WSU Green |

---

## View Modifiers

### Cards

```swift
VStack {
    // Content
}
.wsuCard()
```

**Effect:** White background, 12pt corner radius, subtle shadow

### Buttons

#### Primary Button (Green)

```swift
Button("Sign In") {
    // Action
}
.wsuPrimaryButton()
.disabled(isDisabled)
```

#### Secondary Button (Outlined)

```swift
Button("Cancel") {
    // Action
}
.wsuSecondaryButton()
```

#### Accent Button (Gold)

```swift
Button("Highlight Action") {
    // Action
}
.wsuAccentButton()
```

#### Text Button

```swift
Button("Forgot Password?") {
    // Action
}
.wsuTextButton()
```

### Text Fields

```swift
TextField("University Email", text: $email)
    .wsuTextField()
```

**Effect:** Padding, white background, rounded corners, border

---

## Components

### WSUHeader

Branded header with optional gradient background:

```swift
WSUHeader(
    title: "Campus Booking",
    subtitle: "Wayne State University",
    showGradient: true
)
```

**Props:**
- `title: String` - Main title
- `subtitle: String?` - Optional subtitle
- `showGradient: Bool` - Show gradient (green to light green) or solid green

### WSUBadge

Status badge for bookings:

```swift
WSUBadge(text: "Confirmed", style: .confirmed)
```

**Badge Styles:**
- `.pending` - Gold background
- `.confirmed` - Green background
- `.cancelled` - Red background
- `.completed` - Light green background
- `.noShow` - Gray background
- `.custom(backgroundColor: Color, textColor: Color)` - Custom colors

### WSUEmptyState

Empty state view for when no data is available:

```swift
WSUEmptyState(
    icon: "calendar.badge.exclamationmark",
    title: "No Bookings Yet",
    message: "You haven't made any bookings. Start by exploring available rooms and tutors.",
    actionTitle: "Browse Rooms",
    action: { /* Navigate */ }
)
```

**Props:**
- `icon: String` - SF Symbol name
- `title: String` - Main title
- `message: String` - Description text
- `actionTitle: String?` - Optional button text
- `action: (() -> Void)?` - Optional button action

---

## Design Principles

### 1. Light & Clean
- Use white/off-white backgrounds with generous spacing
- Avoid heavy borders; prefer subtle shadows for depth
- Maintain visual hierarchy through spacing and typography

### 2. WSU Brand First
- **Green as Primary:** Use WSU Green for main actions, navigation, and branding
- **Gold as Accent:** Use WSU Gold for highlights, secondary actions, and important stats
- Never dilute brand colors with excessive variations

### 3. High Contrast
- Ensure text meets WCAG AA standards for readability
- WSU Green (#006633) on white: ✅ Passes
- White text on WSU Green: ✅ Passes
- Use WSU Gold carefully for text (prefer for icons/accents)

### 4. Consistent Spacing
- Always use `Spacing` constants
- Avoid magic numbers (e.g., `.padding(12)`)
- Use semantic spacing names (`Spacing.cardPadding` instead of `Spacing.md`)

### 5. Accessible
- Meet WCAG AA standards for color contrast
- Provide sufficient touch targets (minimum 44x44pt)
- Use semantic colors for status (don't rely on color alone)

### 6. Professional
- University setting requires polished, trustworthy design
- Avoid overly casual or playful elements
- Maintain consistency across all screens

---

## Booking Status Colors

| Status | Color | Badge Style |
|--------|-------|-------------|
| Pending | WSU Gold | `.pending` |
| Confirmed | WSU Green | `.confirmed` |
| Cancelled | Error Red | `.cancelled` |
| Completed | Light Green | `.completed` |
| No Show | Gray | `.noShow` |

### Usage

```swift
// In Booking model
booking.status.color        // Returns Color
booking.status.badgeStyle   // Returns BadgeStyle

// Display badge
WSUBadge(text: booking.status.displayName, style: booking.status.badgeStyle)
```

---

## Examples

### Login Screen

```swift
ZStack {
    ColorTheme.background
        .ignoresSafeArea()

    VStack(spacing: Spacing.xl) {
        // Logo
        Image(systemName: "building.2.crop.circle.fill")
            .resizable()
            .frame(width: 100, height: 100)
            .foregroundColor(ColorTheme.wsuGreen)

        // Title
        Text("Campus Booking")
            .wsuTitle()

        Text("Wayne State University")
            .foregroundColor(ColorTheme.wsuGold)

        // Form
        VStack(spacing: Spacing.md) {
            TextField("Email", text: $email)
                .wsuTextField()

            SecureField("Password", text: $password)
                .wsuTextField()

            Button("Sign In") { }
                .wsuPrimaryButton()
        }
        .padding(.horizontal, Spacing.xl)
    }
}
```

### Dashboard Stat Card

```swift
VStack(spacing: Spacing.xs) {
    Image(systemName: "calendar")
        .font(.title2)
        .foregroundColor(ColorTheme.wsuGreen)

    Text("12")
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(ColorTheme.textPrimary)

    Text("Upcoming")
        .font(.caption)
        .foregroundColor(ColorTheme.textSecondary)
}
.frame(maxWidth: .infinity)
.padding(Spacing.md)
.wsuCard()
```

### Tutor Card

```swift
HStack(spacing: Spacing.sm) {
    Circle()
        .fill(ColorTheme.wsuGreen.opacity(0.2))
        .frame(width: 50, height: 50)
        .overlay {
            Text("J")
                .foregroundColor(ColorTheme.wsuGreen)
        }

    VStack(alignment: .leading, spacing: Spacing.xxs) {
        Text("John Doe")
            .wsuSubheading()

        Label("4.8", systemImage: "star.fill")
            .foregroundColor(ColorTheme.wsuGold)
    }

    Spacer()

    Image(systemName: "chevron.right")
        .foregroundColor(ColorTheme.textSecondary)
}
.padding(Spacing.md)
.wsuCard()
```

---

## Asset Catalog

Color assets configured in `/Resources/Assets.xcassets/`:

- **PrimaryColor.colorset** → WSU Green (#006633)
- **AccentGold.colorset** → WSU Gold (#FFCB05)
- **AccentColor.colorset** → WSU Green (for system accent)

These can be referenced as:
```swift
Color("PrimaryColor")
Color("AccentGold")
```

However, prefer using `ColorTheme` for consistency:
```swift
ColorTheme.wsuGreen
ColorTheme.wsuGold
```

---

## Navigation Bar Styling

Navigation bars are configured in `SoftwareEngApp.swift` to use WSU Green:

```swift
let appearance = UINavigationBarAppearance()
appearance.configureWithOpaqueBackground()
appearance.backgroundColor = .wsuGreen
appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

UINavigationBar.appearance().standardAppearance = appearance
UINavigationBar.appearance().tintColor = .white
```

---

## Tab Bar Styling

Tab bars use WSU Green as the accent color in `ContentView.swift`:

```swift
TabView {
    // Tabs
}
.accentColor(ColorTheme.wsuGreen)
```

---

## Quick Reference

### Common Patterns

**Screen Layout:**
```swift
ScrollView {
    VStack(alignment: .leading, spacing: Spacing.lg) {
        // Content sections
    }
    .padding(Spacing.md)
}
.background(ColorTheme.background)
```

**Section Header:**
```swift
Text("Section Title")
    .wsuSectionHeader()
```

**Grid of Cards:**
```swift
LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
    // Cards
}
```

**Button with Loading State:**
```swift
Button {
    // Action
} label: {
    if isLoading {
        ProgressView()
            .tint(.white)
    } else {
        Text("Sign In")
    }
}
.wsuPrimaryButton(isDisabled: isLoading)
.disabled(isLoading)
```

---

## Team Guidelines

1. **Always use theme constants** - Never hardcode colors or spacing
2. **Follow naming conventions** - Use descriptive variable names
3. **Maintain consistency** - Apply the same patterns across features
4. **Test accessibility** - Verify color contrast and touch targets
5. **Document custom components** - Add comments for team understanding
6. **Reuse before creating** - Check if a component already exists

---

## Resources

- **Color Theme:** `Utils/Theme/ColorTheme.swift`
- **Spacing:** `Utils/Theme/Spacing.swift`
- **Typography:** `Utils/Theme/Typography.swift`
- **View Modifiers:** `Utils/Theme/ViewModifiers.swift`
- **Components:** `Views/Components/`

---

## Support

For questions or suggestions about the design system, reach out to the development team or create an issue in the project repository.

**Version:** 1.0
**Last Updated:** February 2026

---
name: Pro-Vendor Management
colors:
  surface: '#f9f9ff'
  surface-dim: '#d3daea'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eefe'
  surface-container-high: '#e2e8f8'
  surface-container-highest: '#dce2f3'
  on-surface: '#151c27'
  on-surface-variant: '#434654'
  inverse-surface: '#2a313d'
  inverse-on-surface: '#ebf1ff'
  outline: '#737686'
  outline-variant: '#c3c5d7'
  surface-tint: '#1353d8'
  primary: '#003fb1'
  on-primary: '#ffffff'
  primary-container: '#1a56db'
  on-primary-container: '#d4dcff'
  inverse-primary: '#b5c4ff'
  secondary: '#7127e5'
  on-secondary: '#ffffff'
  secondary-container: '#8b4aff'
  on-secondary-container: '#fffbff'
  tertiary: '#852b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#ad3b00'
  on-tertiary-container: '#ffd4c5'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b5c4ff'
  on-primary-fixed: '#00174d'
  on-primary-fixed-variant: '#003dab'
  secondary-fixed: '#eaddff'
  secondary-fixed-dim: '#d2bbff'
  on-secondary-fixed: '#25005a'
  on-secondary-fixed-variant: '#5a00c6'
  tertiary-fixed: '#ffdbcf'
  tertiary-fixed-dim: '#ffb59a'
  on-tertiary-fixed: '#380d00'
  on-tertiary-fixed-variant: '#802a00'
  background: '#f9f9ff'
  on-background: '#151c27'
  surface-variant: '#dce2f3'
typography:
  headline-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  caption:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 24px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-margin: 1rem
  stack-gap: 1rem
  element-gap: 0.5rem
  grid-gutter: 0.75rem
  section-padding: 1.25rem
---

## Brand & Style

The design system is engineered for the modern e-commerce vendor, prioritizing operational efficiency, clarity, and professional trust. It adopts a **Corporate / Modern** aesthetic that balances high-density data management with approachable, soft-edged UI elements. 

The personality is reliable and precise, ensuring that vendors can manage inventory, customer inquiries, and analytics with minimal cognitive load. The emotional response should be one of "controlled productivity"—feeling empowered by data rather than overwhelmed. Visuals use a structured card-based architecture to containerize information, while subtle gradients and a vibrant primary blue provide the necessary energy to drive action.

## Colors

The palette is anchored by a deep **Action Blue**, used for primary touchpoints, progress indicators, and interactive states. 

- **Primary Action:** Used for CTAs, active navigation states, and highlight icons.
- **Surface Strategy:** In light mode, surfaces use pure white over a light-gray background to create distinct layering. In dark mode, surfaces shift to a deep charcoal to maintain contrast without harshness.
- **Semantic Logic:**
    - **Success (Completed):** Emerald green for order fulfillment.
    - **Warning (Low Stock/Pending):** Warm amber/orange for urgent inventory alerts.
    - **Neutral/Secondary:** Slate grays for secondary labels and metadata.

## Typography

This design system utilizes **Plus Jakarta Sans** for its friendly yet professional geometry. The hierarchy is optimized for dashboards:

- **Large Headlines:** Used for "Good morning" greetings and primary page titles.
- **Data Weights:** Numerical data in charts and stat cards should use `Bold` or `ExtraBold` weights to stand out.
- **Status Labels:** Use the `label-md` role with uppercase or semi-bold styling for chips and badges.
- **Readability:** Body text is set with a generous line height (1.5x) to ensure inquiry messages and product descriptions remain legible during high-speed scanning.

## Layout & Spacing

The layout follows a **Fluid Grid** model with high density.

- **Mobile Philosophy:** Uses a single-column stack with 16px (`1rem`) side margins. Horizontal scrolling is reserved for category chips and filtered lists.
- **Card Spacing:** Internal padding for cards is consistently 20px (`1.25rem`) to allow content to breathe.
- **Rhythm:** An 8px base unit is used for all spacing. Standard gaps between related elements (like a product title and its price) are 4px or 8px, while gaps between distinct dashboard widgets are 16px.
- **Breakpoints:**
    - Mobile: < 600px (Single column)
    - Tablet: 600px - 1024px (2-column cards)
    - Desktop: > 1024px (Multi-column sidebar layout)

## Elevation & Depth

Visual hierarchy is established through **Tonal Layers** and soft shadows.

- **Base Layer:** The background uses a slight tint (`#F9FAFB`) to differentiate from white cards.
- **Interactive Level:** Cards and buttons use a very soft, diffused ambient shadow (Blur: 10px, Y: 4, Opacity: 4%) to appear slightly lifted.
- **Floating Level:** Action buttons (like the "+" floating button) and modals use a higher elevation with a more pronounced shadow to indicate they are at the top of the stack.
- **Dark Mode:** Shadows are replaced by subtle 1px inner borders or "rim lighting" to define surface edges without relying on shadow contrast.

## Shapes

The shape language is defined by **Rounded** corners that soften the data-heavy environment.

- **Cards & Containers:** Use a 16px (`1rem`) radius for a modern, friendly feel.
- **Buttons & Inputs:** Use a 12px (`0.75rem`) radius to maintain consistency with the cards.
- **Status Chips:** Utilize a "Pill" shape (full radius) to distinguish them from interactive buttons.
- **Image Containers:** Product thumbnails should always inherit the card's roundedness (typically 8px-12px) to prevent visual jarring.

## Components

### Buttons & Chips
- **Primary Button:** Solid Blue background with white text. High-contrast, 48px height for mobile tap targets.
- **Status Chips:** Lightly tinted backgrounds (10% opacity of the semantic color) with high-saturation text for readability (e.g., Light Red background with Dark Red text for "Low Stock").

### Cards
- **Stat Cards:** Feature a large bold number, a small icon in the top right, and a trend indicator (percentage) at the bottom.
- **Product Cards:** Vertical layout on mobile with an image aspect ratio of 1:1. Includes a discrete "Edit" or "Delete" icon row.

### Form Inputs
- **Search Bar:** Subtle gray background with a magnifying glass icon. Rounded corners to match the overall shape language.
- **Toggle Switches:** Used for system settings (like Dark Mode), utilizing the primary blue for the "on" state.

### Messaging
- **Inquiry List:** Uses a "read/unread" dot indicator in Action Blue. Profiles are shown as 40px circular avatars.
- **Chat Bubbles:** User messages in Primary Blue (white text), recipient messages in Light Gray (dark text).
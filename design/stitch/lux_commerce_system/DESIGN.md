---
name: Lux-Commerce System
colors:
  surface: '#f9f9f9'
  surface-dim: '#dadada'
  surface-bright: '#f9f9f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f3'
  surface-container: '#eeeeee'
  surface-container-high: '#e8e8e8'
  surface-container-highest: '#e2e2e2'
  on-surface: '#1b1b1b'
  on-surface-variant: '#4c4546'
  inverse-surface: '#303030'
  inverse-on-surface: '#f1f1f1'
  outline: '#7e7576'
  outline-variant: '#cfc4c5'
  surface-tint: '#5e5e5e'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#1b1b1b'
  on-primary-container: '#848484'
  inverse-primary: '#c6c6c6'
  secondary: '#5d5f5f'
  on-secondary: '#ffffff'
  secondary-container: '#dfe0e0'
  on-secondary-container: '#616363'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#1a1c1d'
  on-tertiary-container: '#838486'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e2e2e2'
  primary-fixed-dim: '#c6c6c6'
  on-primary-fixed: '#1b1b1b'
  on-primary-fixed-variant: '#474747'
  secondary-fixed: '#e2e2e2'
  secondary-fixed-dim: '#c6c6c7'
  on-secondary-fixed: '#1a1c1c'
  on-secondary-fixed-variant: '#454747'
  tertiary-fixed: '#e2e2e4'
  tertiary-fixed-dim: '#c6c6c8'
  on-tertiary-fixed: '#1a1c1d'
  on-tertiary-fixed-variant: '#454749'
  background: '#f9f9f9'
  on-background: '#1b1b1b'
  surface-variant: '#e2e2e2'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-padding: 24px
  gutter-md: 16px
  stack-lg: 32px
  stack-xl: 48px
---

## Brand & Style

This design system is built on a foundation of **High-Fashion Minimalism**, blending the technical precision of modern technology brands with the editorial elegance of luxury retail. The target audience is a discerning consumer who values clarity, premium aesthetics, and effortless navigation.

The visual narrative is driven by an "Apple-meets-high-fashion" ethos:
- **Minimalism:** Use of extreme whitespace to allow product photography to serve as the primary visual driver.
- **Modernity:** A focus on high-contrast interactions (Black/White) paired with sophisticated, subtle depth.
- **Luxury:** Refinement through generous breathing room, precise typography, and a "less is more" approach to UI decoration.

## Colors

The palette is strictly curated to ensure a premium feel while maintaining high accessibility and clear visual hierarchy.

- **Primary Black (#000000):** Reserved for high-emphasis elements, including primary CTA buttons, major headlines, and navigation icons. It represents authority and timelessness.
- **Crisp White (#FFFFFF):** The canvas for the application. It provides the negative space required for a luxury feel.
- **Sophisticated Neutral Gray (#F5F5F7):** Used for background layering and card surfaces. It prevents the interface from feeling "flat" by providing a subtle distinction from the white canvas.
- **Elegant Gold Accent (#B89B72):** A refined, muted gold used sparingly for active states, notifications, and "Limited Edition" or "Premium" badges.
- **Soft Muted Gray (#E0E0E0):** Used exclusively for structural elements like dividers and input borders to provide definition without visual clutter.

## Typography

The design system utilizes **Inter** for its systematic clarity and modern grotesque characteristics. 

- **Hierarchy:** Dramatic contrast between large, bold headlines and clean, functional body text is essential.
- **Tracking:** Headings use slight negative letter-spacing for a "tight," editorial look, while uppercase labels use increased tracking for improved legibility and a luxury "tag" aesthetic.
- **Color Application:** Headings must always be Primary Black. Body text should be Primary Black at 85% opacity or 100% depending on the surface.

## Layout & Spacing

The layout philosophy centers on **Generous Breathing Room**. To avoid the "basic" e-commerce look, the design system utilizes a "Comfortable" density model.

- **Grid:** A 4-column fluid grid for mobile and a 12-column grid for tablet/desktop. 
- **Margins:** Standard side margins are 24px to provide a modern, airy feel.
- **Vertical Rhythm:** Elements are spaced using an 8px base unit. Section headers should have at least 48px of top margin to clearly separate categories and product groupings.
- **Reflow:** On mobile, product grids should utilize a 2-column layout to allow product imagery to be large enough to appreciate detail.

## Elevation & Depth

This design system uses **Tonal Layering** and **Soft Ambient Shadows** to create a sense of tactile luxury without the heaviness of traditional skeuomorphism.

- **Surface Levels:** 
  - Level 0: Pure White (#FFFFFF) - Main background.
  - Level 1: Sophisticated Neutral (#F5F5F7) - Card surfaces and secondary sections.
- **Shadows:** Use extremely diffused shadows. For a floating card, use `offset: (0, 8), blur: 24, spread: 0, color: RGBA(0, 0, 0, 0.04)`. 
- **Interactions:** When a user interacts with a card, elevation should subtly increase by deepening the shadow blur, rather than changing the border color.

## Shapes

The shape language is defined by "Large Soft Geometry." 

- **Standard Radius:** 16px for most containers and cards.
- **Large Radius (rounded-xl):** 24px for prominent feature cards and bottom sheets.
- **Buttons:** Buttons should maintain a 12px or 16px radius to feel substantial and high-end. 
- **Inputs:** 12px radius to balance the softness with the precision of typography.

## Components

### Buttons
- **Primary:** Solid Primary Black background, White text. High contrast, 16px rounded corners. No border.
- **Secondary:** Transparent background, Primary Black 1.5px border.
- **Text Button:** Primary Black text, uppercase label-lg style, with the Gold Accent used for the arrow/icon.

### Cards
- **Product Card:** Sophisticated Neutral Gray (#F5F5F7) background with a 16px radius. No border. Image should have a slight zoom effect on hover/tap.
- **Cart Card:** White surface with a Soft Muted Gray (#E0E0E0) 1px border.

### Input Fields
- **Default State:** Soft Muted Gray (#E0E0E0) 1px border, White background.
- **Active/Focus:** Primary Black 1.5px border.
- **Corner Radius:** 12px.

### Chips & Badges
- **Status Badges:** Small, pill-shaped, using Gold Accent background at 10% opacity with solid Gold Accent text.

### Navigation
- **Bottom Bar:** Pure White background with a 1px Soft Muted Gray top border. Icons in Primary Black (Active) and 40% Black (Inactive). No text labels for a cleaner, high-fashion look if icons are universally recognizable.
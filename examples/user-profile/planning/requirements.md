# Requirements: User Profile

## Questions & Answers

1. **What fields should the profile include?**
   Avatar image, display name, bio (max 500 chars), location, website URL

2. **Should avatar upload support cropping?**
   Yes, client-side crop to square before upload. Max file size 5MB. Accept PNG, JPG, WebP.

3. **Who can view profiles?**
   Any authenticated user can view any profile. Only the profile owner can edit.

4. **Are there any existing user models to extend?**
   Yes, extend the existing `User` model with a new `UserProfile` relation.

5. **What responsive breakpoints matter most?**
   Mobile-first. Profile card stacks vertically on mobile, side-by-side on desktop.

6. **Should profile changes be immediately visible or require save?**
   Explicit save button. Show unsaved changes indicator.

## Visual Assets
No mockups provided — follow existing design system patterns.

## Reusable Components
- Existing `ImageUpload` component can be extended for avatar
- Existing `FormField` component for text inputs
- Existing `Button` component for save action

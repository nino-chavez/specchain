# Specification: User Profile Page

## Goal
Enable users to create and edit a personal profile with avatar, bio, and contact details, accessible to all authenticated users.

## User Stories
- As a user, I want to upload a profile avatar so that other users can identify me
- As a user, I want to edit my bio and personal details so that I can share information about myself
- As a user, I want to view other users' profiles so that I can learn about my collaborators

## Core Requirements
### Functional Requirements
- Profile page at `/profile/:userId` displaying avatar, name, bio, location, website
- Edit profile form accessible only to the profile owner
- Avatar upload with client-side cropping (square, max 5MB, PNG/JPG/WebP)
- Bio text field with 500 character limit and live character count
- Explicit save with unsaved changes indicator

### Non-Functional Requirements
- Profile page loads in < 2 seconds
- Avatar images optimized and served via CDN
- WCAG 2.1 AA compliant (contrast, keyboard nav, screen reader)

## Visual Design
- No mockups provided — follow existing design system
- Mobile: stacked layout (avatar above bio)
- Desktop: side-by-side layout (avatar left, details right)

## Reusable Components
### Existing Code to Leverage
- Components: `ImageUpload`, `FormField`, `Button`
- Services: Existing auth middleware for ownership checks
- Patterns: Follow existing `/settings` page layout

### New Components Required
- `ProfileCard` — displays user profile summary
- `AvatarCropper` — wraps ImageUpload with crop functionality

## Technical Approach
- Database: New `UserProfile` model with one-to-one `User` relation
- API: REST endpoints for GET/PUT profile, POST avatar upload
- Frontend: Profile view page + edit form with optimistic UI
- Testing: Model validation, API auth, component rendering, upload flow

## Out of Scope
- Profile privacy settings (public/private)
- Profile cover images
- Social media links
- Activity feed on profile

## Success Criteria
- Users can upload avatar and edit bio
- Profile accessible at `/profile/:id`
- Mobile and desktop layouts render correctly
- All tests pass with 0 failures

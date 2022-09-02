# Roadmap

These are the proposed and/or historically implemented major/distinct features and changes that may be implemented in this application. 

Items may be added, updated, or removed from the Roadmap, but it should more or less cover the main points implemented/to be implemented.

`- [ ]` indicates a feature/change that may be implemented
`-` indicates potential implementation notes about a feature/change that may be implemented

## Features

- [X] Account Management
  - [X] Users
    - [X] Authentication
    - [ ] Authorization
      - [X] Simple, linear role hierarchy
      - [ ] More robust role system
- [X] Resource Management
    - [X] Slugs
    - [X] Core Schemas and Nested Forms
      - [X] Recipes
      - [X] Steps 
      - [X] StepIngredients
      - [X] Ingredients
    - [ ] Pagination and Query Limiting
- [ ] Attachments
  - [X] Basic Image Attachments
  - [ ] Full, multi-attachment solution
    - [ ] Recipe single and gallery images
    - [ ] Step gallery images
    - [ ] Ingredient single and gallery images
  - [ ] Recipe Downloads
    - [ ] Individual
    - [ ] Bulk
- [X] Publicly Viewable Pages
- [X] Custom Error Pages
- [ ] Assets
  - [X] Sass Setup
  - [ ] TypeScript Setup
- [ ] Citations
- [ ] Notes
  - [ ] Recipes
  - [ ] Steps
  - [ ] Ingredients
- [ ] Blog-style Post Content
  - Tips
  - Tools
  - Product Referral Links(?)
  - Long-form Recipe Content
- [ ] User Interaction
  - [ ] Comments
    - [ ] Recipes
    - [ ] Posts
- [ ] Recipe Maintenance Mode
  - Publicly accessible recipes, return a 503 when many changes are being made and not ready for viewer/bot consumption
- [ ] CookLang Support
- [ ] Recipe/User Ingredients vs. Canonical Ingredients
  - May need to re-implement core features of Ruby/Rails `ancestry` gem
  - Migration Notes: When the time comes to implement this feature, all existing ingredients would become Recipe/User Ingredients that may be linked to canonical ingredients as needed
- [ ] Resource Limits
- [X] Alerting and Monitoring Tools
- [ ] Full LiveView-enabled Site
- [ ] Search
  - SQL-based 
- [ ] Better Tests

## Workflows
- [ ] GitHub Actions
  - [X] CI
  - [ ] CD
- [X] Initial Deployment Setup
- [X] Transactional Emails
- [X] Custom Domain
  - [X] SSL Certificate Setup
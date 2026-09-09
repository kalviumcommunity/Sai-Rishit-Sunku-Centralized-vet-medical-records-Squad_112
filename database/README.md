# Database Schemas & Security Rules

This directory is dedicated to the Cloud Firestore database configuration, security rules, indexes, and seed/migration scripts for VetCare.

> **Note:** Firestore schema definitions, collection structures, and security rules are being developed by the backend/database teammate. Paste incoming rules and schema documentation into this folder as they become available.

## Files
- `firestore.rules`: Security rules governing document read/write permissions across owners, vets, and clinic branches.
- `firestore.indexes.json`: Composite indexes for multi-field queries (e.g., querying treatments by branch and pet ID).

# Library Booking System Backend

This directory contains the backend implementation of our Library Booking System. The code is organized in a way that promotes readability, maintainability, and scalability.

## Directory Structure

```
backend/
├── models/          # Data models representing our core entities
│   ├── room.dart    # Room model with capacity and availability info
│   └── booking.dart # Booking model with time slots and status
├── services/        # Services handling business logic and Firebase interactions
│   ├── auth_service.dart    # Authentication service for admin access
│   └── database_service.dart # Database operations for rooms and bookings
└── README.md        # This file
```

## Code Organization

### Models

Our models are designed to be intuitive and self-documenting:

- **Room Model**: Represents a library room with properties like capacity and name
- **Booking Model**: Handles room reservations with time slots and status tracking

### Services

The services layer contains business logic and Firebase interactions:

- **Auth Service**: Manages admin authentication using Firebase custom tokens
- **Database Service**: Handles all Firestore operations for rooms and bookings

## Key Features

1. **Real-time Updates**: Using Firebase streams for live data
2. **Secure Admin Access**: Custom token-based authentication
3. **Booking Management**: Complete booking lifecycle handling
4. **Statistics Tracking**: Real-time analytics for room usage

## Development Notes

- All code is thoroughly commented for better understanding
- Error handling is implemented throughout the services
- Firebase best practices are followed for data structure
- Models include data validation and type safety

## Dependencies

Make sure these dependencies are in your `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.15.0
  firebase_auth: ^4.10.0
  cloud_firestore: ^4.8.0
  firebase_functions: ^1.6.0
```

## Firebase Setup

1. Create a Firebase project
2. Enable Authentication and Firestore
3. Deploy the admin login Cloud Function
4. Add your Firebase configuration to the app

## Best Practices

- Always use the provided models for data consistency
- Handle errors appropriately in service calls
- Keep the Firebase structure flat for better performance
- Use transactions for critical operations

This backend implementation is organized for clarity and maintainability, making it suitable for both presentations and future development. 
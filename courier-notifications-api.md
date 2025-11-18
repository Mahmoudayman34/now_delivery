# Courier Notifications API Documentation

## Overview
This document describes the notification-related API endpoints for couriers.

---

## Endpoints

### 1. Update FCM Token

**Endpoint:** `POST /api/v1/courier/update-fcm-token`

**Description:** Updates the Firebase Cloud Messaging (FCM) token for the authenticated courier. This token is used to send push notifications to the courier's device.

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "fcmToken": "string"
}
```

**Body Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| fcmToken | string | Yes | The FCM token obtained from the mobile device |

**Success Response (200):**
```json
{
  "success": true,
  "message": "FCM token updated successfully"
}
```

**Error Responses:**

**400 Bad Request** - Missing FCM token:
```json
{
  "success": false,
  "message": "FCM token is required"
}
```

**400 Bad Request** - Authentication error:
```json
{
  "success": false,
  "message": "Cannot identify courier from authentication token"
}
```

**404 Not Found** - Courier not found:
```json
{
  "success": false,
  "message": "Courier not found"
}
```

**500 Internal Server Error:**
```json
{
  "success": false,
  "message": "Failed to update FCM token",
  "error": "Error message details"
}
```

---

### 2. Get Courier Notifications

**Endpoint:** `GET /api/v1/courier/notifications`

**Description:** Retrieves all notifications for the authenticated courier, sorted by creation date (newest first).

**Authentication:** Required (Bearer Token)

**Request Body:** None

**Query Parameters:** None

**Success Response (200):**
```json
{
  "success": true,
  "notifications": [
    {
      "_id": "notification_id",
      "recipient": "courier_id",
      "title": "Notification Title",
      "body": "Notification body text",
      "type": "notification_type",
      "status": "delivered",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "deliveredAt": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

**Error Response (500):**
```json
{
  "success": false,
  "message": "Failed to get notifications",
  "error": "Error message details"
}
```

---

## Notes

- Both endpoints require authentication via the `verifyToken` middleware
- The courier ID is automatically extracted from the authentication token
- Notifications are sorted in descending order by creation date (newest first)
- FCM tokens should be updated whenever the app is launched or the token changes


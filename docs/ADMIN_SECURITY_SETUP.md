# Admin Security Setup Guide

## Overview
This guide explains how to configure and use the admin security features implemented in the app.

## Security Features

### 1. Secret Gesture Access (Hidden Entry Point)
- **What**: Admin panel is hidden from regular users
- **How to Access**: Tap the "Settings" title 7 times within 3 seconds
- **Result**: Opens admin login page

### 2. Biometric Authentication
- **What**: Fingerprint or Face ID required before admin login
- **Platforms**: iOS (Face ID/Touch ID), Android (Fingerprint)
- **Fallback**: If biometrics unavailable, password-only login is used

### 3. Session Management
- **Timeout**: 15 minutes of inactivity
- **Auto-Logout**: Automatically logs out admin after timeout
- **Activity Tracking**: Session resets on any admin interaction

### 4. Backend Security (Supabase RLS)
- **Row-Level Security**: Enforces admin-only modifications
- **Audit Logging**: Tracks all admin actions
- **Public Read**: Everyone can read content, only admins can modify

## Platform Configuration

### iOS Setup

Add to `ios/Runner/Info.plist`:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Authenticate to access admin panel</string>
```

### Android Setup

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
```

## Supabase Backend Setup

### Step 1: Run SQL Migration

1. Open your Supabase project dashboard
2. Go to SQL Editor
3. Copy and paste the contents of `supabase/migrations/admin_security_policies.sql`
4. Click "Run"

### Step 2: Set Admin Role

Run this SQL to grant admin role to your user:

```sql
UPDATE auth.users
SET raw_user_meta_data = raw_user_meta_data || '{"role": "admin"}'::jsonb
WHERE email = 'your-admin-email@example.com';
```

Replace `your-admin-email@example.com` with your actual admin email.

### Step 3: Verify Security

Test that RLS policies are working:

1. **As Non-Admin**: Try to insert/update/delete content (should fail)
2. **As Admin**: Try to insert/update/delete content (should succeed)
3. **Check Audit Log**: Query `admin_audit_log` table to see logged actions

```sql
SELECT * FROM admin_audit_log ORDER BY created_at DESC LIMIT 10;
```

## Usage Instructions

### Accessing Admin Panel

1. Open the app
2. Navigate to Settings
3. Tap "Settings" title 7 times quickly (within 3 seconds)
4. Admin login page appears
5. If biometrics available, authenticate with fingerprint/face
6. Enter email and password
7. Access granted for 15 minutes

### Session Management

- Session automatically expires after 15 minutes of inactivity
- Any interaction in admin panel resets the timer
- On expiry, you'll be automatically logged out
- Must re-authenticate to access admin again

## Security Best Practices

### For Production Builds

1. **Remove Admin Code from Public Builds**:
   - Use Flutter build flavors
   - Create separate "admin" and "production" builds
   - Admin features only in "admin" build

2. **Strengthen Authentication**:
   - Use strong passwords
   - Enable 2FA in Supabase
   - Regularly rotate admin credentials

3. **Monitor Access**:
   - Regularly check `admin_audit_log`
   - Set up alerts for suspicious activity
   - Review admin actions weekly

4. **Network Security**:
   - Use HTTPS only
   - Enable Supabase IP restrictions
   - Use VPN for admin access if possible

## Troubleshooting

### Biometrics Not Working

**Problem**: Biometric prompt doesn't appear

**Solutions**:
- Ensure device has biometrics enrolled
- Check platform permissions are configured
- Verify `local_auth` package is installed
- Fallback to password-only login works automatically

### Session Expires Too Quickly

**Problem**: Getting logged out frequently

**Solution**: Adjust timeout in `admin_session_manager.dart`:

```dart
static const Duration _sessionTimeout = Duration(minutes: 30); // Change from 15 to 30
```

### Can't Access Admin Panel

**Problem**: Secret gesture not working

**Solutions**:
- Ensure you're tapping "Settings" title (not back button)
- Tap 7 times within 3 seconds
- Try tapping slightly slower/faster
- Check console for gesture detection logs

### RLS Policies Blocking Admin

**Problem**: Admin can't modify content

**Solutions**:
- Verify admin role is set in Supabase:
  ```sql
  SELECT raw_user_meta_data->>'role' FROM auth.users WHERE email = 'your-email';
  ```
- Check RLS policies are enabled
- Verify `is_admin()` function exists
- Check Supabase logs for policy errors

## Files Modified

### New Files Created
- `lib/core/services/biometric_auth_service.dart` - Biometric authentication
- `lib/core/services/admin_session_manager.dart` - Session management
- `lib/core/widgets/secret_admin_access_widget.dart` - Secret gesture detection
- `supabase/migrations/admin_security_policies.sql` - Database security

### Modified Files
- `pubspec.yaml` - Added `local_auth` dependency
- `lib/features/settings/presentation/pages/settings_page.dart` - Secret gesture integration
- `lib/features/admin/presentation/pages/admin_login_page.dart` - Biometric auth
- `lib/features/admin/presentation/providers/admin_provider.dart` - Session management

## Next Steps

1. **Test on Real Devices**: Test biometrics on actual iOS/Android devices
2. **Deploy SQL Migration**: Run the SQL script in your Supabase project
3. **Set Admin Role**: Grant admin role to your user account
4. **Test Security**: Verify all security layers are working
5. **Create Production Build**: Set up build flavors to remove admin from public builds

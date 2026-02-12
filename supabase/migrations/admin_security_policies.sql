-- =====================================================
-- Admin Security Policies for Supabase
-- =====================================================
-- This script creates Row-Level Security (RLS) policies
-- to protect admin-only operations and add audit logging
-- =====================================================

-- =====================================================
-- 1. Enable Row-Level Security on all admin tables
-- =====================================================

ALTER TABLE IF EXISTS virtues ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS prayer_formulas ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS "prayerFormulaSounds" ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS evidence ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS hadith ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS media ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS sounds ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 2. Create Admin Role Check Function
-- =====================================================

CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    SELECT EXISTS (
      SELECT 1
      FROM public.admins
      WHERE id = auth.uid()
      AND "isAdmin" = true
    )
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 3. Create Audit Log Table
-- =====================================================

CREATE TABLE IF NOT EXISTS admin_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id UUID REFERENCES auth.users(id),
  action TEXT NOT NULL,
  table_name TEXT NOT NULL,
  record_id TEXT,
  old_data JSONB,
  new_data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on audit log
ALTER TABLE admin_audit_log ENABLE ROW LEVEL SECURITY;

-- Only admins can view audit logs
CREATE POLICY "Admins can view audit logs"
ON admin_audit_log
FOR SELECT
USING (is_admin());

-- =====================================================
-- 4. Public Read Access (Everyone can read)
-- =====================================================

CREATE POLICY "Public read access" ON virtues
FOR SELECT USING (true);

CREATE POLICY "Public read access" ON prayer_formulas
FOR SELECT USING (true);

CREATE POLICY "Public read access" ON "prayerFormulaSounds"
FOR SELECT USING (true);

CREATE POLICY "Public read access" ON evidence
FOR SELECT USING (true);

CREATE POLICY "Public read access" ON hadith
FOR SELECT USING (true);

CREATE POLICY "Public read access" ON media
FOR SELECT USING (true);

CREATE POLICY "Public read access" ON sounds
FOR SELECT USING (true);

-- =====================================================
-- 5. Admin-Only Modifications
-- =====================================================

-- Virtues
CREATE POLICY "Admin only insert" ON virtues
FOR INSERT WITH CHECK (is_admin());

CREATE POLICY "Admin only update" ON virtues
FOR UPDATE USING (is_admin());

CREATE POLICY "Admin only delete" ON virtues
FOR DELETE USING (is_admin());

-- Prayer Formulas
CREATE POLICY "Admin only insert" ON prayer_formulas
FOR INSERT WITH CHECK (is_admin());

CREATE POLICY "Admin only update" ON prayer_formulas
FOR UPDATE USING (is_admin());

CREATE POLICY "Admin only delete" ON prayer_formulas
FOR DELETE USING (is_admin());

-- Prayer Formula Sounds
CREATE POLICY "Admin only insert" ON "prayerFormulaSounds"
FOR INSERT WITH CHECK (is_admin());

CREATE POLICY "Admin only update" ON "prayerFormulaSounds"
FOR UPDATE USING (is_admin());

CREATE POLICY "Admin only delete" ON "prayerFormulaSounds"
FOR DELETE USING (is_admin());

-- Evidence
CREATE POLICY "Admin only insert" ON evidence
FOR INSERT WITH CHECK (is_admin());

CREATE POLICY "Admin only update" ON evidence
FOR UPDATE USING (is_admin());

CREATE POLICY "Admin only delete" ON evidence
FOR DELETE USING (is_admin());

-- Hadith
CREATE POLICY "Admin only insert" ON hadith
FOR INSERT WITH CHECK (is_admin());

CREATE POLICY "Admin only update" ON hadith
FOR UPDATE USING (is_admin());

CREATE POLICY "Admin only delete" ON hadith
FOR DELETE USING (is_admin());

-- Media
CREATE POLICY "Admin only insert" ON media
FOR INSERT WITH CHECK (is_admin());

CREATE POLICY "Admin only update" ON media
FOR UPDATE USING (is_admin());

CREATE POLICY "Admin only delete" ON media
FOR DELETE USING (is_admin());

-- Sounds
CREATE POLICY "Admin only insert" ON sounds
FOR INSERT WITH CHECK (is_admin());

CREATE POLICY "Admin only update" ON sounds
FOR UPDATE USING (is_admin());

CREATE POLICY "Admin only delete" ON sounds
FOR DELETE USING (is_admin());

-- =====================================================
-- 6. Audit Logging Triggers
-- =====================================================

CREATE OR REPLACE FUNCTION log_admin_action()
RETURNS TRIGGER AS $$
BEGIN
  IF is_admin() THEN
    INSERT INTO admin_audit_log (
      admin_id,
      action,
      table_name,
      record_id,
      old_data,
      new_data
    ) VALUES (
      auth.uid(),
      TG_OP,
      TG_TABLE_NAME,
      COALESCE(NEW.id::TEXT, OLD.id::TEXT),
      CASE WHEN TG_OP = 'DELETE' OR TG_OP = 'UPDATE' THEN row_to_json(OLD) ELSE NULL END,
      CASE WHEN TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN row_to_json(NEW) ELSE NULL END
    );
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create triggers for each table
CREATE TRIGGER virtues_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON virtues
FOR EACH ROW EXECUTE FUNCTION log_admin_action();

CREATE TRIGGER prayer_formulas_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON prayer_formulas
FOR EACH ROW EXECUTE FUNCTION log_admin_action();

CREATE TRIGGER prayer_formula_sounds_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON "prayerFormulaSounds"
FOR EACH ROW EXECUTE FUNCTION log_admin_action();

CREATE TRIGGER evidence_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON evidence
FOR EACH ROW EXECUTE FUNCTION log_admin_action();

CREATE TRIGGER hadith_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON hadith
FOR EACH ROW EXECUTE FUNCTION log_admin_action();

CREATE TRIGGER media_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON media
FOR EACH ROW EXECUTE FUNCTION log_admin_action();

CREATE TRIGGER sounds_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON sounds
FOR EACH ROW EXECUTE FUNCTION log_admin_action();

-- =====================================================
-- 7. Grant Permissions
-- =====================================================

-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO anon;

-- Grant select to everyone (public read)
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;

-- =====================================================
-- SETUP INSTRUCTIONS
-- =====================================================
-- 
-- 1. Run this script in your Supabase SQL Editor
-- 
-- 2. Set admin role for your user:
--    UPDATE auth.users
--    SET raw_user_meta_data = raw_user_meta_data || '{"role": "admin"}'::jsonb
--    WHERE email = 'your-admin-email@example.com';
-- 
-- 3. Verify policies are working:
--    - Try to insert/update/delete as non-admin (should fail)
--    - Try to insert/update/delete as admin (should succeed)
--    - Check admin_audit_log for logged actions
-- 
-- =====================================================

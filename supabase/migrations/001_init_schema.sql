-- ============================================================================
-- Prayer Content Schema with RLS Policies
-- Complete schema for the Islamic Prayer Application
-- ============================================================================

-- ============================================================================
-- 1. ADMINS TABLE - Stores administrator login credentials
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.admins (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT NOT NULL,
    email TEXT NOT NULL,
    "isAdmin" BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- ============================================================================
-- 2. VIRTUES TABLE - Stores the virtues/benefits of prayers on the Prophet
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.virtues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type TEXT NOT NULL,
    category TEXT,
    text TEXT NOT NULL,
    title TEXT,
    description TEXT,
    url TEXT,
    image_binary TEXT,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- ============================================================================
-- 3. PRAYER FORMULAS TABLE - Different formulas for praying on the Prophet
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.prayer_formulas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "titleAr" TEXT NOT NULL,
    "titleEn" TEXT NOT NULL,
    "contentAr" TEXT NOT NULL,
    "contentEn" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ DEFAULT now() NOT NULL,
    "updatedAt" TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- ============================================================================
-- 4. EVIDENCE TABLE - Evidence from Quran and Sunnah for prayer formulas
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.evidence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "titleAr" TEXT NOT NULL,
    "titleEn" TEXT NOT NULL,
    "contentAr" TEXT NOT NULL,
    "contentEn" TEXT NOT NULL,
    source TEXT,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- ============================================================================
-- 5. HADITH TABLE - Stores hadiths related to the prayers
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.hadith (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "textAr" TEXT NOT NULL,
    "textEn" TEXT NOT NULL,
    narrator TEXT,
    source TEXT,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- ============================================================================
-- 6. MEDIA TABLE - Stores paths to media files (images, videos)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    url TEXT NOT NULL,
    type TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- ============================================================================
-- 7. SOUNDS TABLE - Stores paths to audio files
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.sounds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    url TEXT NOT NULL,
    duration INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- ============================================================================
-- 8. PRAYER FORMULA SOUNDS TABLE - Stores audio recordings of prayer formulas
-- ============================================================================
CREATE TABLE IF NOT EXISTS public."prayerFormulaSounds" (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    language TEXT NOT NULL,
    title TEXT NOT NULL,
    url TEXT,
    sound_binary BYTEA,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- ============================================================================
-- 9. USERS TABLE - Extended user profile data (linked with auth.users)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- ============================================================================
-- 10. FAVORITES TABLE - User's favorite prayer formulas (NEW TABLE)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    prayer_formula_id UUID NOT NULL REFERENCES public.prayer_formulas(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    UNIQUE(user_id, prayer_formula_id)
);

-- ============================================================================
-- INDEXES - Improve query performance
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_evidence_title_ar ON public.evidence("titleAr");
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON public.favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_prayer_formula_id ON public.favorites(prayer_formula_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_media_type ON public.media(type);

-- ============================================================================
-- ENABLE ROW-LEVEL SECURITY (RLS) for all tables
-- ============================================================================
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.virtues ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prayer_formulas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evidence ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hadith ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.media ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sounds ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."prayerFormulaSounds" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- RLS POLICIES - PUBLIC READ ACCESS for main content tables
-- ============================================================================

-- Virtues: Allow public read access
CREATE POLICY "allow_public_read_virtues" ON public.virtues
FOR SELECT
USING (true);

-- Prayer Formulas: Allow public read access
CREATE POLICY "allow_public_read_prayer_formulas" ON public.prayer_formulas
FOR SELECT
USING (true);

-- Evidence: Allow public read access
CREATE POLICY "allow_public_read_evidence" ON public.evidence
FOR SELECT
USING (true);

-- Hadith: Allow public read access
CREATE POLICY "allow_public_read_hadith" ON public.hadith
FOR SELECT
USING (true);

-- Media: Allow public read access
CREATE POLICY "allow_public_read_media" ON public.media
FOR SELECT
USING (true);

-- Sounds: Allow public read access
CREATE POLICY "allow_public_read_sounds" ON public.sounds
FOR SELECT
USING (true);

-- Prayer Formula Sounds: Allow public read access
CREATE POLICY "allow_public_read_prayer_formula_sounds" ON public."prayerFormulaSounds"
FOR SELECT
USING (true);

-- Users: Allow authenticated users to read public user info
CREATE POLICY "allow_read_users" ON public.users
FOR SELECT
USING (true);

-- ============================================================================
-- RLS POLICIES - ADMIN ONLY WRITE ACCESS
-- ============================================================================

-- Admins: Only authenticated admins can access
CREATE POLICY "allow_admin_all_access" ON public.admins
FOR ALL
USING (
    auth.role() = 'authenticated' 
    AND EXISTS (
        SELECT 1 FROM public.admins 
        WHERE id = auth.uid() 
        AND "isAdmin" = true
    )
);

-- Virtues: Only admins can create/update/delete
CREATE POLICY "allow_admin_insert_virtues" ON public.virtues
FOR INSERT
WITH CHECK (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

CREATE POLICY "allow_admin_update_virtues" ON public.virtues
FOR UPDATE
USING (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

CREATE POLICY "allow_admin_delete_virtues" ON public.virtues
FOR DELETE
USING (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

-- Prayer Formulas: Only admins can create/update/delete
CREATE POLICY "allow_admin_insert_prayer_formulas" ON public.prayer_formulas
FOR INSERT
WITH CHECK (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

CREATE POLICY "allow_admin_update_prayer_formulas" ON public.prayer_formulas
FOR UPDATE
USING (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

CREATE POLICY "allow_admin_delete_prayer_formulas" ON public.prayer_formulas
FOR DELETE
USING (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

-- Evidence: Only admins can create/update/delete
CREATE POLICY "allow_admin_insert_evidence" ON public.evidence
FOR INSERT
WITH CHECK (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

CREATE POLICY "allow_admin_update_evidence" ON public.evidence
FOR UPDATE
USING (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

CREATE POLICY "allow_admin_delete_evidence" ON public.evidence
FOR DELETE
USING (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

-- Hadith: Only admins can create/update/delete
CREATE POLICY "allow_admin_insert_hadith" ON public.hadith
FOR INSERT
WITH CHECK (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

CREATE POLICY "allow_admin_update_hadith" ON public.hadith
FOR UPDATE
USING (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

CREATE POLICY "allow_admin_delete_hadith" ON public.hadith
FOR DELETE
USING (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

-- Media: Only admins can create/update/delete
CREATE POLICY "allow_admin_insert_media" ON public.media
FOR INSERT
WITH CHECK (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

CREATE POLICY "allow_admin_update_media" ON public.media
FOR UPDATE
USING (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

CREATE POLICY "allow_admin_delete_media" ON public.media
FOR DELETE
USING (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

-- Sounds: Only admins can create/update/delete
CREATE POLICY "allow_admin_insert_sounds" ON public.sounds
FOR INSERT
WITH CHECK (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

CREATE POLICY "allow_admin_update_sounds" ON public.sounds
FOR UPDATE
USING (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

CREATE POLICY "allow_admin_delete_sounds" ON public.sounds
FOR DELETE
USING (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

-- Prayer Formula Sounds: Only admins can create/update/delete
CREATE POLICY "allow_admin_insert_prayer_formula_sounds" ON public."prayerFormulaSounds"
FOR INSERT
WITH CHECK (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

CREATE POLICY "allow_admin_update_prayer_formula_sounds" ON public."prayerFormulaSounds"
FOR UPDATE
USING (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

CREATE POLICY "allow_admin_delete_prayer_formula_sounds" ON public."prayerFormulaSounds"
FOR DELETE
USING (
    auth.role() = 'authenticated'
    AND EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
        AND "isAdmin" = true
    )
);

-- ============================================================================
-- RLS POLICIES - USER PROFILE ACCESS
-- ============================================================================

-- Users: Can read own profile
CREATE POLICY "allow_users_read_own_profile" ON public.users
FOR SELECT
USING (auth.uid() = id OR true);

-- Users: Can update own profile
CREATE POLICY "allow_users_update_own_profile" ON public.users
FOR UPDATE
USING (auth.uid() = id);

-- Users: Can insert own profile
CREATE POLICY "allow_users_insert_own_profile" ON public.users
FOR INSERT
WITH CHECK (auth.uid() = id);

-- ============================================================================
-- RLS POLICIES - FAVORITES ACCESS
-- ============================================================================

-- Favorites: Authenticated users can read their own favorites
CREATE POLICY "allow_users_read_own_favorites" ON public.favorites
FOR SELECT
USING (auth.uid() = user_id);

-- Favorites: Authenticated users can insert their own favorites
CREATE POLICY "allow_users_insert_own_favorites" ON public.favorites
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Favorites: Authenticated users can delete their own favorites
CREATE POLICY "allow_users_delete_own_favorites" ON public.favorites
FOR DELETE
USING (auth.uid() = user_id);

-- ============================================================================
-- SYNC MANAGEMENT (Last Changes)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public."lastChanges" (
    "entityName" TEXT PRIMARY KEY,
    "lastChange" TIMESTAMPTZ DEFAULT now() NOT NULL
);

ALTER TABLE public."lastChanges" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read lastChanges" ON public."lastChanges"
    FOR SELECT USING (true);

CREATE POLICY "Allow admin update lastChanges" ON public."lastChanges"
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.admins
            WHERE id = auth.uid()
            AND "isAdmin" = true
        )
    );

-- Function to update lastChanges
CREATE OR REPLACE FUNCTION public.handle_last_change()
RETURNS TRIGGER AS $$
DECLARE
    tbl_name TEXT;
BEGIN
    -- Map table names to entity names expected by the app
    IF TG_TABLE_NAME = 'prayerFormulaSounds' THEN
        tbl_name := 'prayerFormulaSounds';
    ELSIF TG_TABLE_NAME = 'prayer_formulas' THEN
        tbl_name := 'prayerFormulaSounds'; -- Wait, map correctly based on service
    ELSIF TG_TABLE_NAME = 'virtues' THEN
        tbl_name := 'virtues';
    ELSIF TG_TABLE_NAME = 'evidence' THEN
        tbl_name := 'evidence';
    ELSIF TG_TABLE_NAME = 'hadith' THEN
        tbl_name := 'hadith';
    ELSIF TG_TABLE_NAME = 'media' THEN
        tbl_name := 'media';
    ELSIF TG_TABLE_NAME = 'sounds' THEN
        tbl_name := 'sounds';
    ELSE
        tbl_name := TG_TABLE_NAME;
    END IF;

    -- Special handling: if prayer_formulas updates, it might be related to prayerFormulaSounds? 
    -- Actually looking at SyncManagerService, each has its own sync.
    -- prayer_formulas -> syncPrayerFormulas -> uses lastSync, not lastChanges table?
    -- Only prayerFormulaSounds and virtues use lastChanges table in checkAndSyncChanges.
    
    INSERT INTO public."lastChanges" ("entityName", "lastChange")
    VALUES (tbl_name, now())
    ON CONFLICT ("entityName")
    DO UPDATE SET "lastChange" = now();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Triggers for all synced tables
DROP TRIGGER IF EXISTS trigger_update_last_change_virtues ON public.virtues;
CREATE TRIGGER trigger_update_last_change_virtues
AFTER INSERT OR UPDATE OR DELETE ON public.virtues
FOR EACH STATEMENT EXECUTE FUNCTION public.handle_last_change();

DROP TRIGGER IF EXISTS trigger_update_last_change_prayerFormulaSounds ON public."prayerFormulaSounds";
CREATE TRIGGER trigger_update_last_change_prayerFormulaSounds
AFTER INSERT OR UPDATE OR DELETE ON public."prayerFormulaSounds"
FOR EACH STATEMENT EXECUTE FUNCTION public.handle_last_change();

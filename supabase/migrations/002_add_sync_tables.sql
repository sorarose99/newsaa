
-- ============================================================================
-- SYNC MANAGEMENT (Last Changes)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public."lastChanges" (
    "entityName" TEXT PRIMARY KEY,
    "lastChange" TIMESTAMPTZ DEFAULT now() NOT NULL
);

ALTER TABLE public."lastChanges" ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read lastChanges" ON public."lastChanges";
CREATE POLICY "Allow public read lastChanges" ON public."lastChanges"
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow admin update lastChanges" ON public."lastChanges";
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
        tbl_name := 'prayer_formulas';
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

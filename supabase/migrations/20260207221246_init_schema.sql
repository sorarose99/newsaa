-- Create Tables for Prophet Mohammed App

-- Users table
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  email TEXT UNIQUE,
  username TEXT,
  "lastActive" TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Admins table
CREATE TABLE IF NOT EXISTS public.admins (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  "isAdmin" BOOLEAN DEFAULT FALSE
);

-- Virtues table
CREATE TABLE IF NOT EXISTS public.virtues (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL,
  category TEXT,
  text TEXT NOT NULL,
  title TEXT,
  description TEXT,
  url TEXT,
  file_path TEXT,
  image_binary TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Prayer Formulas table
CREATE TABLE IF NOT EXISTS public.prayer_formulas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  virtue_id UUID REFERENCES public.virtues(id) ON DELETE SET NULL,
  category TEXT,
  title_ar TEXT NOT NULL,
  title_en TEXT NOT NULL,
  content_ar TEXT NOT NULL,
  content_en TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Evidence table
CREATE TABLE IF NOT EXISTS public.evidence (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prayer_formula_id UUID REFERENCES public.prayer_formulas(id) ON DELETE CASCADE,
  title_ar TEXT NOT NULL,
  title_en TEXT NOT NULL,
  content_ar TEXT NOT NULL,
  content_en TEXT NOT NULL,
  source TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Hadith table
CREATE TABLE IF NOT EXISTS public.hadith (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text_ar TEXT NOT NULL,
  text_en TEXT NOT NULL,
  narrator TEXT NOT NULL,
  source TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Media table
CREATE TABLE IF NOT EXISTS public.media (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  url TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sounds table
CREATE TABLE IF NOT EXISTS public.sounds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  url TEXT NOT NULL,
  duration INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Prayer Formula Sounds table
CREATE TABLE IF NOT EXISTS public."prayerFormulaSounds" (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  language TEXT NOT NULL,
  title TEXT NOT NULL,
  url TEXT,
  sound_binary TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Favorites table
CREATE TABLE IF NOT EXISTS public.favorites (
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  prayer_formula_id UUID REFERENCES public.prayer_formulas(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, prayer_formula_id)
);

-- RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.virtues ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prayer_formulas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evidence ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hadith ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.media ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sounds ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."prayerFormulaSounds" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Allow public read virtues" ON public.virtues FOR SELECT USING (true);
CREATE POLICY "Allow public read prayer_formulas" ON public.prayer_formulas FOR SELECT USING (true);
CREATE POLICY "Allow public read evidence" ON public.evidence FOR SELECT USING (true);
CREATE POLICY "Allow public read hadith" ON public.hadith FOR SELECT USING (true);
CREATE POLICY "Allow public read media" ON public.media FOR SELECT USING (true);
CREATE POLICY "Allow public read sounds" ON public.sounds FOR SELECT USING (true);
CREATE POLICY "Allow public read prayerFormulaSounds" ON public."prayerFormulaSounds" FOR SELECT USING (true);

-- Storage Buckets Creation
INSERT INTO storage.buckets (id, name, public) 
VALUES ('virtues', 'virtues', true), 
       ('sounds', 'sounds', true), 
       ('files', 'files', true)
ON CONFLICT (id) DO NOTHING;

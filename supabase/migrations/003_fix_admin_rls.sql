
-- Fix recursive RLS on admins table

-- 1. Drop the problematic recursive policy
DROP POLICY IF EXISTS "allow_admin_all_access" ON public.admins;

-- 2. Allow users to read THEIR OWN admin record (Non-recursive base case)
CREATE POLICY "allow_read_own_admin" ON public.admins
FOR SELECT
USING (auth.uid() = id);

-- 3. Allow admins to insert/update/delete records (Recursive check, but terminates because of policy #2)
-- Note: When the subquery runs, it performs a SELECT. 
-- That SELECT will be authorized by "allow_read_own_admin" because we are looking up our own ID.
-- Thus, no infinite loop.

CREATE POLICY "allow_admin_insert_admin" ON public.admins
FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.admins 
        WHERE id = auth.uid() 
        AND "isAdmin" = true
    )
);

CREATE POLICY "allow_admin_update_admin" ON public.admins
FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM public.admins 
        WHERE id = auth.uid() 
        AND "isAdmin" = true
    )
);

CREATE POLICY "allow_admin_delete_admin" ON public.admins
FOR DELETE
USING (
    EXISTS (
        SELECT 1 FROM public.admins 
        WHERE id = auth.uid() 
        AND "isAdmin" = true
    )
);

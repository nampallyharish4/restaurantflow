-- Location: supabase/migrations/20250804182310_restaurant_management_complete.sql
-- Schema Analysis: FRESH_PROJECT (No existing tables or schema found)
-- Integration Type: NEW_COMPLETE_SCHEMA_REQUIRED
-- Dependencies: None (fresh database)

-- ========================================================================
-- RESTAURANT MANAGEMENT SYSTEM - COMPLETE DATABASE SCHEMA
-- ========================================================================

-- 1. EXTENSIONS & TYPES
-- Extensions are pre-installed in Supabase, no need to create

-- Core enums for restaurant operations
CREATE TYPE public.user_role AS ENUM ('admin', 'waiter', 'counter', 'kitchen', 'manager');
CREATE TYPE public.order_status AS ENUM ('pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled');
CREATE TYPE public.payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');
CREATE TYPE public.table_status AS ENUM ('available', 'occupied', 'reserved', 'maintenance');
CREATE TYPE public.menu_category AS ENUM ('starters', 'main_course', 'desserts', 'drinks', 'specials');

-- 2. CORE TABLES (NO FOREIGN KEYS)

-- User profiles table (intermediary between auth.users and business logic)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'waiter'::public.user_role,
    phone TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Restaurant tables management
CREATE TABLE public.tables (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_number INTEGER NOT NULL UNIQUE,
    capacity INTEGER NOT NULL DEFAULT 4,
    status public.table_status DEFAULT 'available'::public.table_status,
    location TEXT, -- e.g., 'Ground Floor', 'Terrace', 'VIP Section'
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Menu categories
CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    category_type public.menu_category NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Menu items
CREATE TABLE public.menu_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    image_url TEXT,
    is_available BOOLEAN DEFAULT true,
    is_vegetarian BOOLEAN DEFAULT false,
    is_vegan BOOLEAN DEFAULT false,
    is_spicy BOOLEAN DEFAULT false,
    preparation_time INTEGER DEFAULT 15, -- in minutes
    allergens TEXT[], -- array of allergen strings
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. DEPENDENT TABLES (WITH FOREIGN KEYS)

-- Orders table
CREATE TABLE public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number TEXT NOT NULL UNIQUE,
    table_id UUID REFERENCES public.tables(id) ON DELETE SET NULL,
    waiter_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    customer_name TEXT,
    customer_phone TEXT,
    status public.order_status DEFAULT 'pending'::public.order_status,
    payment_status public.payment_status DEFAULT 'pending'::public.payment_status,
    subtotal DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) DEFAULT 0,
    special_requests TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ
);

-- Order items (junction table for orders and menu items)
CREATE TABLE public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
    menu_item_id UUID REFERENCES public.menu_items(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    special_instructions TEXT,
    status public.order_status DEFAULT 'pending'::public.order_status,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Order status history for tracking changes
CREATE TABLE public.order_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
    previous_status public.order_status,
    new_status public.order_status NOT NULL,
    changed_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Daily analytics data
CREATE TABLE public.daily_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date DATE NOT NULL UNIQUE,
    total_orders INTEGER DEFAULT 0,
    total_revenue DECIMAL(12,2) DEFAULT 0,
    average_order_value DECIMAL(10,2) DEFAULT 0,
    peak_hour INTEGER, -- hour of day (0-23)
    most_ordered_item_id UUID REFERENCES public.menu_items(id) ON DELETE SET NULL,
    total_customers INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. INDEXES FOR PERFORMANCE
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_user_profiles_active ON public.user_profiles(is_active);
CREATE INDEX idx_tables_status ON public.tables(status);
CREATE INDEX idx_tables_number ON public.tables(table_number);
CREATE INDEX idx_categories_type ON public.categories(category_type);
CREATE INDEX idx_categories_active ON public.categories(is_active);
CREATE INDEX idx_menu_items_category ON public.menu_items(category_id);
CREATE INDEX idx_menu_items_available ON public.menu_items(is_available);
CREATE INDEX idx_orders_status ON public.orders(status);
CREATE INDEX idx_orders_table ON public.orders(table_id);
CREATE INDEX idx_orders_waiter ON public.orders(waiter_id);
CREATE INDEX idx_orders_date ON public.orders(created_at);
CREATE INDEX idx_orders_number ON public.orders(order_number);
CREATE INDEX idx_order_items_order ON public.order_items(order_id);
CREATE INDEX idx_order_items_menu ON public.order_items(menu_item_id);
CREATE INDEX idx_order_status_history_order ON public.order_status_history(order_id);
CREATE INDEX idx_daily_analytics_date ON public.daily_analytics(date);

-- 5. FUNCTIONS (MUST BE BEFORE RLS POLICIES)

-- Function to generate order numbers
CREATE OR REPLACE FUNCTION public.generate_order_number()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    order_count INTEGER;
    today_date TEXT;
BEGIN
    today_date := to_char(CURRENT_DATE, 'YYYYMMDD');
    
    SELECT COUNT(*) INTO order_count
    FROM public.orders
    WHERE DATE(created_at) = CURRENT_DATE;
    
    RETURN 'ORD-' || today_date || '-' || LPAD((order_count + 1)::TEXT, 4, '0');
END;
$$;

-- Function to update order totals
CREATE OR REPLACE FUNCTION public.update_order_totals()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    order_subtotal DECIMAL(10,2);
    tax_rate DECIMAL(5,4) := 0.18; -- 18% tax
BEGIN
    -- Calculate subtotal from order items
    SELECT COALESCE(SUM(total_price), 0)
    INTO order_subtotal
    FROM public.order_items
    WHERE order_id = COALESCE(NEW.order_id, OLD.order_id);
    
    -- Update order totals
    UPDATE public.orders
    SET 
        subtotal = order_subtotal,
        tax_amount = ROUND(order_subtotal * tax_rate, 2),
        total_amount = ROUND(order_subtotal * (1 + tax_rate), 2),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = COALESCE(NEW.order_id, OLD.order_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$;

-- Function for role validation (for non-user tables)
CREATE OR REPLACE FUNCTION public.has_role(required_role TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role::TEXT = required_role AND up.is_active = true
)
$$;

-- Function for admin access
CREATE OR REPLACE FUNCTION public.is_admin_or_manager()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() 
    AND up.role IN ('admin', 'manager') 
    AND up.is_active = true
)
$$;

-- 6. ENABLE ROW LEVEL SECURITY
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_analytics ENABLE ROW LEVEL SECURITY;

-- 7. RLS POLICIES (FOLLOWING PATTERN GUIDELINES)

-- Pattern 1: Core user table - Simple policies only
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 4: Public read, authenticated write for tables
CREATE POLICY "authenticated_read_tables"
ON public.tables
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "admin_manage_tables"
ON public.tables
FOR ALL
TO authenticated
USING (public.is_admin_or_manager())
WITH CHECK (public.is_admin_or_manager());

-- Pattern 4: Public read for categories and menu items
CREATE POLICY "authenticated_read_categories"
ON public.categories
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "admin_manage_categories"
ON public.categories
FOR ALL
TO authenticated
USING (public.is_admin_or_manager())
WITH CHECK (public.is_admin_or_manager());

CREATE POLICY "authenticated_read_menu_items"
ON public.menu_items
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "admin_manage_menu_items"
ON public.menu_items
FOR ALL
TO authenticated
USING (public.is_admin_or_manager())
WITH CHECK (public.is_admin_or_manager());

-- Pattern 2: Simple ownership for orders (waiters can manage their orders)
CREATE POLICY "waiter_manage_own_orders"
ON public.orders
FOR ALL
TO authenticated
USING (waiter_id = auth.uid() OR public.is_admin_or_manager())
WITH CHECK (waiter_id = auth.uid() OR public.is_admin_or_manager());

-- Staff can view all orders
CREATE POLICY "staff_view_orders"
ON public.orders
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() 
        AND up.role IN ('counter', 'kitchen', 'manager', 'admin')
        AND up.is_active = true
    )
);

-- Pattern 7: Order items access through order relationship
CREATE POLICY "staff_manage_order_items"
ON public.order_items
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.orders o
        JOIN public.user_profiles up ON up.id = auth.uid()
        WHERE o.id = order_id
        AND (o.waiter_id = auth.uid() OR up.role IN ('counter', 'kitchen', 'manager', 'admin'))
        AND up.is_active = true
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.orders o
        JOIN public.user_profiles up ON up.id = auth.uid()
        WHERE o.id = order_id
        AND (o.waiter_id = auth.uid() OR up.role IN ('counter', 'kitchen', 'manager', 'admin'))
        AND up.is_active = true
    )
);

-- Order status history - staff can view, system can insert
CREATE POLICY "staff_view_order_history"
ON public.order_status_history
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.is_active = true
    )
);

CREATE POLICY "staff_insert_order_history"
ON public.order_status_history
FOR INSERT
TO authenticated
WITH CHECK (changed_by = auth.uid());

-- Analytics - admin/manager only
CREATE POLICY "admin_manage_analytics"
ON public.daily_analytics
FOR ALL
TO authenticated
USING (public.is_admin_or_manager())
WITH CHECK (public.is_admin_or_manager());

-- 8. TRIGGERS
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_order_totals_trigger
    AFTER INSERT OR UPDATE OR DELETE ON public.order_items
    FOR EACH ROW
    EXECUTE FUNCTION public.update_order_totals();

-- Function for new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, role)
    VALUES (
        NEW.id, 
        NEW.email, 
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'role', 'waiter')::public.user_role
    );
    RETURN NEW;
END;
$$;

-- 9. MOCK DATA FOR RESTAURANT MANAGEMENT
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    waiter1_uuid UUID := gen_random_uuid();
    waiter2_uuid UUID := gen_random_uuid();
    counter_uuid UUID := gen_random_uuid();
    kitchen_uuid UUID := gen_random_uuid();
    
    starters_cat_id UUID := gen_random_uuid();
    mains_cat_id UUID := gen_random_uuid();
    desserts_cat_id UUID := gen_random_uuid();
    drinks_cat_id UUID := gen_random_uuid();
    
    table1_id UUID := gen_random_uuid();
    table2_id UUID := gen_random_uuid();
    table3_id UUID := gen_random_uuid();
    
    item1_id UUID := gen_random_uuid();
    item2_id UUID := gen_random_uuid();
    item3_id UUID := gen_random_uuid();
    item4_id UUID := gen_random_uuid();
    item5_id UUID := gen_random_uuid();
    
    order1_id UUID := gen_random_uuid();
    order2_id UUID := gen_random_uuid();
BEGIN
    -- Create auth users with complete field structure
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@restaurantflow.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Restaurant Admin", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (waiter1_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'waiter1@restaurantflow.com', crypt('waiter123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Sarah Johnson", "role": "waiter"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, '+1234567890', '', '', null),
        (waiter2_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'waiter2@restaurantflow.com', crypt('waiter123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Mike Chen", "role": "waiter"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, '+1234567891', '', '', null),
        (counter_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'counter@restaurantflow.com', crypt('counter123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Emma Davis", "role": "counter"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, '+1234567892', '', '', null),
        (kitchen_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'kitchen@restaurantflow.com', crypt('kitchen123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Carlos Rodriguez", "role": "kitchen"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, '+1234567893', '', '', null);

    -- Create restaurant tables
    INSERT INTO public.tables (id, table_number, capacity, status, location) VALUES
        (table1_id, 1, 4, 'available', 'Ground Floor - Window Side'),
        (table2_id, 2, 2, 'occupied', 'Ground Floor - Center'),
        (table3_id, 3, 6, 'available', 'Ground Floor - Corner'),
        (gen_random_uuid(), 4, 4, 'reserved', 'First Floor - Balcony'),
        (gen_random_uuid(), 5, 8, 'available', 'First Floor - Private');

    -- Create menu categories
    INSERT INTO public.categories (id, name, display_name, category_type, description, sort_order) VALUES
        (starters_cat_id, 'appetizers', 'Appetizers & Starters', 'starters', 'Delicious appetizers to start your meal', 1),
        (mains_cat_id, 'main_dishes', 'Main Course', 'main_course', 'Hearty main dishes and entrees', 2),
        (desserts_cat_id, 'sweet_treats', 'Desserts', 'desserts', 'Sweet endings to your perfect meal', 3),
        (drinks_cat_id, 'beverages', 'Beverages', 'drinks', 'Refreshing drinks and beverages', 4);

    -- Create menu items
    INSERT INTO public.menu_items (id, name, description, price, category_id, image_url, is_vegetarian, is_spicy, preparation_time) VALUES
        (item1_id, 'Crispy Calamari Rings', 'Fresh squid rings served with spicy marinara sauce', 12.99, starters_cat_id, 'https://images.unsplash.com/photo-1559847844-d721426d6edc?w=300', false, true, 10),
        (item2_id, 'Grilled Chicken Breast', 'Herb-marinated chicken breast with roasted vegetables', 18.99, mains_cat_id, 'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=300', false, false, 25),
        (item3_id, 'Margherita Pizza', 'Classic pizza with fresh mozzarella, tomatoes and basil', 16.99, mains_cat_id, 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=300', true, false, 20),
        (item4_id, 'Chocolate Lava Cake', 'Warm chocolate cake with molten center and vanilla ice cream', 8.99, desserts_cat_id, 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=300', true, false, 12),
        (item5_id, 'Fresh Orange Juice', 'Freshly squeezed orange juice', 4.99, drinks_cat_id, 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=300', true, false, 5);

    -- Create sample orders
    INSERT INTO public.orders (id, order_number, table_id, waiter_id, customer_name, customer_phone, status, subtotal, tax_amount, total_amount, special_requests) VALUES
        (order1_id, 'ORD-20250804-0001', table2_id, waiter1_uuid, 'John Smith', '+1555123456', 'preparing', 31.98, 5.76, 37.74, 'No onions in salad'),
        (order2_id, 'ORD-20250804-0002', table1_id, waiter2_uuid, 'Maria Garcia', '+1555654321', 'confirmed', 25.98, 4.68, 30.66, 'Extra spicy sauce');

    -- Create order items
    INSERT INTO public.order_items (order_id, menu_item_id, quantity, unit_price, total_price, special_instructions) VALUES
        (order1_id, item1_id, 1, 12.99, 12.99, 'Medium spice level'),
        (order1_id, item2_id, 1, 18.99, 18.99, 'Well done'),
        (order2_id, item3_id, 1, 16.99, 16.99, 'Extra cheese'),
        (order2_id, item5_id, 2, 4.99, 9.98, 'No ice');

    -- Create order status history
    INSERT INTO public.order_status_history (order_id, previous_status, new_status, changed_by, notes) VALUES
        (order1_id, 'pending', 'confirmed', counter_uuid, 'Order confirmed by counter staff'),
        (order1_id, 'confirmed', 'preparing', kitchen_uuid, 'Order started in kitchen'),
        (order2_id, 'pending', 'confirmed', counter_uuid, 'Order approved');

    -- Create daily analytics
    INSERT INTO public.daily_analytics (date, total_orders, total_revenue, average_order_value, peak_hour, most_ordered_item_id, total_customers) VALUES
        (CURRENT_DATE, 2, 68.40, 34.20, 13, item2_id, 3),
        (CURRENT_DATE - INTERVAL '1 day', 15, 420.75, 28.05, 19, item3_id, 28),
        (CURRENT_DATE - INTERVAL '2 days', 18, 495.20, 27.51, 20, item1_id, 32);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;
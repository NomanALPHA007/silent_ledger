-- Smart Data Capture Layer Migration
-- IMPLEMENTING MODULE: Smart Data Capture Layer

-- 1. Extensions and Types
CREATE TYPE public.transaction_status AS ENUM ('pending', 'verified', 'flagged', 'confirmed');
CREATE TYPE public.confidence_level AS ENUM ('low', 'medium', 'high');
CREATE TYPE public.trust_tier AS ENUM ('bronze', 'silver', 'gold', 'platinum');
CREATE TYPE public.merchant_status AS ENUM ('active', 'inactive', 'verified', 'pending');

-- 2. Core Tables

-- User profiles table (intermediary for auth relationships)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    trust_tier public.trust_tier DEFAULT 'bronze'::public.trust_tier,
    trust_score DECIMAL(5,2) DEFAULT 0.00,
    passive_logging_enabled BOOLEAN DEFAULT false,
    total_verified_volume DECIMAL(12,2) DEFAULT 0.00,
    confirmation_percentage DECIMAL(5,2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Merchant profiles table
CREATE TABLE public.merchant_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    qr_code TEXT UNIQUE NOT NULL,
    location TEXT,
    category TEXT,
    status public.merchant_status DEFAULT 'pending'::public.merchant_status,
    owner_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    trust_score DECIMAL(5,2) DEFAULT 0.00,
    total_transactions INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Enhanced transactions table with smart capture features
CREATE TABLE public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    merchant_id UUID REFERENCES public.merchant_profiles(id) ON DELETE SET NULL,
    amount DECIMAL(12,2) NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL,
    account TEXT NOT NULL,
    transaction_date TIMESTAMPTZ NOT NULL,
    status public.transaction_status DEFAULT 'pending'::public.transaction_status,
    confidence_level public.confidence_level DEFAULT 'medium'::public.confidence_level,
    is_recurring BOOLEAN DEFAULT false,
    auto_logged BOOLEAN DEFAULT false,
    receipt_image_url TEXT,
    notes TEXT,
    tags TEXT[],
    geolocation POINT,
    verification_count INTEGER DEFAULT 0,
    anomaly_flags TEXT[],
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Trust scores tracking table
CREATE TABLE public.trust_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    score DECIMAL(5,2) NOT NULL,
    tier public.trust_tier NOT NULL,
    verified_transactions INTEGER DEFAULT 0,
    total_volume DECIMAL(12,2) DEFAULT 0.00,
    calculation_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Anomalies tracking table
CREATE TABLE public.anomalies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id UUID REFERENCES public.transactions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    anomaly_type TEXT NOT NULL,
    description TEXT NOT NULL,
    severity TEXT DEFAULT 'medium',
    reviewed BOOLEAN DEFAULT false,
    reviewer_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Wallets table for Silent Coin
CREATE TABLE public.wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    silent_coins DECIMAL(10,2) DEFAULT 0.00,
    royalty_balance DECIMAL(10,2) DEFAULT 0.00,
    total_earned DECIMAL(10,2) DEFAULT 0.00,
    last_payout_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Ledger shards preparation table
CREATE TABLE public.ledger_shards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shard_name TEXT NOT NULL,
    region TEXT NOT NULL,
    transaction_id UUID REFERENCES public.transactions(id) ON DELETE CASCADE,
    synced_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Training samples for AI layer
CREATE TABLE public.training_samples (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    transaction_id UUID REFERENCES public.transactions(id) ON DELETE CASCADE,
    sample_data JSONB NOT NULL,
    sample_type TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_trust_tier ON public.user_profiles(trust_tier);
CREATE INDEX idx_merchant_profiles_qr_code ON public.merchant_profiles(qr_code);
CREATE INDEX idx_merchant_profiles_owner_id ON public.merchant_profiles(owner_id);
CREATE INDEX idx_transactions_user_id ON public.transactions(user_id);
CREATE INDEX idx_transactions_merchant_id ON public.transactions(merchant_id);
CREATE INDEX idx_transactions_date ON public.transactions(transaction_date);
CREATE INDEX idx_transactions_status ON public.transactions(status);
CREATE INDEX idx_trust_scores_user_id ON public.trust_scores(user_id);
CREATE INDEX idx_anomalies_transaction_id ON public.anomalies(transaction_id);
CREATE INDEX idx_wallets_user_id ON public.wallets(user_id);

-- 4. Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.merchant_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trust_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.anomalies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ledger_shards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.training_samples ENABLE ROW LEVEL SECURITY;

-- 5. Helper Functions
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.trust_tier = 'platinum'::public.trust_tier
)
$$;

CREATE OR REPLACE FUNCTION public.owns_transaction(transaction_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.transactions t
    WHERE t.id = transaction_uuid AND t.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.owns_merchant(merchant_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.merchant_profiles mp
    WHERE mp.id = merchant_uuid AND mp.owner_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.can_verify_transaction(transaction_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.transactions t
    JOIN public.merchant_profiles mp ON t.merchant_id = mp.id
    WHERE t.id = transaction_uuid AND mp.owner_id = auth.uid()
)
$$;

-- 6. RLS Policies
CREATE POLICY "users_own_profile"
ON public.user_profiles
FOR ALL
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

CREATE POLICY "public_read_merchants"
ON public.merchant_profiles
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "owners_manage_merchants"
ON public.merchant_profiles
FOR ALL
TO authenticated
USING (public.owns_merchant(id))
WITH CHECK (public.owns_merchant(id));

CREATE POLICY "users_own_transactions"
ON public.transactions
FOR ALL
TO authenticated
USING (public.owns_transaction(id))
WITH CHECK (public.owns_transaction(id));

CREATE POLICY "users_own_trust_scores"
ON public.trust_scores
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_view_anomalies"
ON public.anomalies
FOR SELECT
TO authenticated
USING (auth.uid() = user_id OR public.is_admin());

CREATE POLICY "users_own_wallets"
ON public.wallets
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "admin_manage_ledger_shards"
ON public.ledger_shards
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

CREATE POLICY "users_own_training_samples"
ON public.training_samples
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 7. Functions for Smart Features

-- Function for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
  );
  
  INSERT INTO public.wallets (user_id)
  VALUES (NEW.id);
  
  RETURN NEW;
END;
$$;

-- Trust score calculation function
CREATE OR REPLACE FUNCTION public.calculate_trust_score(user_uuid UUID)
RETURNS DECIMAL(5,2)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    verified_count INTEGER;
    total_volume DECIMAL(12,2);
    confirmation_rate DECIMAL(5,2);
    base_score DECIMAL(5,2);
    tier_bonus DECIMAL(5,2);
    final_score DECIMAL(5,2);
BEGIN
    -- Get user statistics
    SELECT 
        COUNT(*) FILTER (WHERE status = 'verified'::public.transaction_status),
        COALESCE(SUM(ABS(amount)) FILTER (WHERE status = 'verified'::public.transaction_status), 0),
        CASE 
            WHEN COUNT(*) > 0 THEN 
                (COUNT(*) FILTER (WHERE status = 'verified'::public.transaction_status) * 100.0 / COUNT(*))
            ELSE 0
        END
    INTO verified_count, total_volume, confirmation_rate
    FROM public.transactions t
    WHERE t.user_id = user_uuid;
    
    -- Calculate base score
    base_score := LEAST(
        (verified_count * 5.0) + 
        (LEAST(total_volume / 100, 50.0)) + 
        (confirmation_rate * 0.3),
        100.0
    );
    
    -- Add tier bonus
    tier_bonus := CASE 
        WHEN base_score >= 80 THEN 10.0
        WHEN base_score >= 60 THEN 5.0
        WHEN base_score >= 40 THEN 2.0
        ELSE 0.0
    END;
    
    final_score := LEAST(base_score + tier_bonus, 100.0);
    
    -- Update user profile
    UPDATE public.user_profiles
    SET 
        trust_score = final_score,
        trust_tier = CASE 
            WHEN final_score >= 80 THEN 'platinum'::public.trust_tier
            WHEN final_score >= 60 THEN 'gold'::public.trust_tier
            WHEN final_score >= 40 THEN 'silver'::public.trust_tier
            ELSE 'bronze'::public.trust_tier
        END,
        total_verified_volume = total_volume,
        confirmation_percentage = confirmation_rate,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = user_uuid;
    
    -- Record in trust_scores history
    INSERT INTO public.trust_scores (user_id, score, tier, verified_transactions, total_volume)
    VALUES (
        user_uuid, 
        final_score,
        CASE 
            WHEN final_score >= 80 THEN 'platinum'::public.trust_tier
            WHEN final_score >= 60 THEN 'gold'::public.trust_tier
            WHEN final_score >= 40 THEN 'silver'::public.trust_tier
            ELSE 'bronze'::public.trust_tier
        END,
        verified_count,
        total_volume
    );
    
    RETURN final_score;
END;
$$;

-- Anomaly detection function
CREATE OR REPLACE FUNCTION public.flag_anomaly(transaction_uuid UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    t_record RECORD;
    avg_amount DECIMAL(12,2);
    anomaly_reason TEXT;
BEGIN
    -- Get transaction details
    SELECT * INTO t_record FROM public.transactions WHERE id = transaction_uuid;
    
    -- Calculate average amount for this user and category
    SELECT AVG(ABS(amount)) INTO avg_amount
    FROM public.transactions
    WHERE user_id = t_record.user_id 
    AND category = t_record.category
    AND created_at >= CURRENT_TIMESTAMP - INTERVAL '30 days';
    
    -- Check for anomalies
    IF ABS(t_record.amount) > (avg_amount * 2) THEN
        anomaly_reason := 'Amount significantly higher than average for category';
        
        -- Update transaction with anomaly flag
        UPDATE public.transactions
        SET anomaly_flags = array_append(anomaly_flags, 'high_amount')
        WHERE id = transaction_uuid;
        
        -- Log anomaly
        INSERT INTO public.anomalies (transaction_id, user_id, anomaly_type, description)
        VALUES (transaction_uuid, t_record.user_id, 'amount_anomaly', anomaly_reason);
    END IF;
END;
$$;

-- Royalty calculation function
CREATE OR REPLACE FUNCTION public.update_royalty(transaction_uuid UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    t_record RECORD;
    royalty_amount DECIMAL(10,2);
BEGIN
    -- Get transaction details
    SELECT * INTO t_record FROM public.transactions WHERE id = transaction_uuid;
    
    -- Calculate royalty (0.5% of transaction amount)
    royalty_amount := ABS(t_record.amount) * 0.005;
    
    -- Update wallet
    UPDATE public.wallets
    SET 
        royalty_balance = royalty_balance + royalty_amount,
        total_earned = total_earned + royalty_amount,
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = t_record.user_id;
END;
$$;

-- Trigger for new user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Trigger for anomaly detection
CREATE OR REPLACE FUNCTION public.trigger_anomaly_check()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check for anomalies on new transactions
    PERFORM public.flag_anomaly(NEW.id);
    RETURN NEW;
END;
$$;

CREATE TRIGGER check_transaction_anomalies
    AFTER INSERT ON public.transactions
    FOR EACH ROW EXECUTE FUNCTION public.trigger_anomaly_check();

-- Trigger for trust score updates
CREATE OR REPLACE FUNCTION public.trigger_trust_score_update()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Recalculate trust score when transaction status changes to verified
    IF NEW.status = 'verified'::public.transaction_status AND 
       OLD.status != 'verified'::public.transaction_status THEN
        PERFORM public.calculate_trust_score(NEW.user_id);
        PERFORM public.update_royalty(NEW.id);
    END IF;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER update_trust_score_on_verification
    AFTER UPDATE ON public.transactions
    FOR EACH ROW EXECUTE FUNCTION public.trigger_trust_score_update();

-- 8. Mock Data
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    user_uuid UUID := gen_random_uuid();
    merchant_uuid UUID := gen_random_uuid();
    transaction_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users
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
         'admin@silentledger.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'john@example.com', crypt('user123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Doe"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create sample merchant
    INSERT INTO public.merchant_profiles (id, name, qr_code, location, category, owner_id, status)
    VALUES 
        (merchant_uuid, 'Cafe Central', 'QR_CAFE_CENTRAL_001', 'Downtown Plaza', 'Food & Dining', user_uuid, 'verified'::public.merchant_status);

    -- Create sample transactions
    INSERT INTO public.transactions (id, user_id, merchant_id, amount, description, category, account, transaction_date, status, confidence_level)
    VALUES 
        (transaction_uuid, user_uuid, merchant_uuid, -25.50, 'Coffee and pastry', 'Food & Dining', 'Main Checking', now() - interval '1 hour', 'verified'::public.transaction_status, 'high'::public.confidence_level),
        (gen_random_uuid(), user_uuid, null, -45.20, 'Gas station', 'Transportation', 'Credit Card', now() - interval '2 hours', 'pending'::public.transaction_status, 'medium'::public.confidence_level),
        (gen_random_uuid(), user_uuid, null, 2500.00, 'Salary deposit', 'Income', 'Main Checking', now() - interval '1 day', 'verified'::public.transaction_status, 'high'::public.confidence_level);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 9. Cleanup function
CREATE OR REPLACE FUNCTION public.cleanup_test_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    auth_user_ids_to_delete UUID[];
BEGIN
    -- Get auth user IDs first
    SELECT ARRAY_AGG(id) INTO auth_user_ids_to_delete
    FROM auth.users
    WHERE email LIKE '%@example.com' OR email LIKE '%@silentledger.com';
    
    -- Delete in dependency order (children first, then auth.users last)
    DELETE FROM public.training_samples WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.ledger_shards WHERE transaction_id IN (SELECT id FROM public.transactions WHERE user_id = ANY(auth_user_ids_to_delete));
    DELETE FROM public.anomalies WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.trust_scores WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.transactions WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.merchant_profiles WHERE owner_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.wallets WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.user_profiles WHERE id = ANY(auth_user_ids_to_delete);

    -- Delete auth.users last (after all references are removed)
    DELETE FROM auth.users WHERE id = ANY(auth_user_ids_to_delete);
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;
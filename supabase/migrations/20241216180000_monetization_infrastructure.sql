-- Monetization Infrastructure Migration
-- IMPLEMENTING MODULE: Monetization Center

-- 1. Types for Monetization
CREATE TYPE public.subscription_tier AS ENUM ('free', 'pro', 'elite');
CREATE TYPE public.api_tier AS ENUM ('basic', 'premium', 'enterprise');
CREATE TYPE public.redeem_status AS ENUM ('pending', 'processing', 'completed', 'failed');
CREATE TYPE public.revenue_source AS ENUM ('subscription', 'api_usage', 'coin_store', 'loan_referral', 'data_export');

-- 2. Subscription Plans Table
CREATE TABLE public.subscription_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    merchant_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    tier public.subscription_tier DEFAULT 'free'::public.subscription_tier,
    monthly_price DECIMAL(10,2) DEFAULT 0.00,
    transaction_limit INTEGER DEFAULT 100,
    api_calls_limit INTEGER DEFAULT 1000,
    analytics_enabled BOOLEAN DEFAULT false,
    priority_support BOOLEAN DEFAULT false,
    custom_branding BOOLEAN DEFAULT false,
    start_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMPTZ,
    auto_renew BOOLEAN DEFAULT true,
    stripe_subscription_id TEXT,
    status TEXT DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. API Access Table
CREATE TABLE public.api_access (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    api_key TEXT UNIQUE NOT NULL,
    tier public.api_tier DEFAULT 'basic'::public.api_tier,
    calls_per_month INTEGER DEFAULT 10000,
    calls_used INTEGER DEFAULT 0,
    monthly_fee DECIMAL(10,2) DEFAULT 0.00,
    trust_score_access BOOLEAN DEFAULT true,
    credit_profile_access BOOLEAN DEFAULT false,
    anonymized_data_access BOOLEAN DEFAULT false,
    real_time_webhooks BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    last_call_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. API Usage Logs
CREATE TABLE public.api_usage_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    api_key TEXT REFERENCES public.api_access(api_key) ON DELETE CASCADE,
    endpoint TEXT NOT NULL,
    method TEXT NOT NULL,
    status_code INTEGER NOT NULL,
    response_time_ms INTEGER,
    request_size_bytes INTEGER,
    response_size_bytes INTEGER,
    ip_address INET,
    user_agent TEXT,
    called_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Coin Redemptions Table
CREATE TABLE public.coin_redemptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    coins_redeemed DECIMAL(10,2) NOT NULL,
    redemption_type TEXT NOT NULL, -- 'cash', 'gift_card', 'loan_interest_reduction'
    redemption_value DECIMAL(10,2) NOT NULL,
    status public.redeem_status DEFAULT 'pending'::public.redeem_status,
    payment_method TEXT,
    transaction_reference TEXT,
    notes TEXT,
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 6. Loan Referrals Table
CREATE TABLE public.loan_referrals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    trust_score_at_referral DECIMAL(5,2) NOT NULL,
    loan_amount_requested DECIMAL(12,2) NOT NULL,
    fintech_partner TEXT NOT NULL,
    referral_fee DECIMAL(10,2) DEFAULT 0.00,
    commission_rate DECIMAL(5,4) DEFAULT 0.0500, -- 5% default
    loan_approved BOOLEAN DEFAULT false,
    approval_date TIMESTAMPTZ,
    loan_disbursed BOOLEAN DEFAULT false,
    disbursement_date TIMESTAMPTZ,
    referral_earnings DECIMAL(10,2) DEFAULT 0.00,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 7. Revenue Tracking Table
CREATE TABLE public.revenue_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source public.revenue_source NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency TEXT DEFAULT 'MYR',
    client_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    subscription_id UUID REFERENCES public.subscription_plans(id) ON DELETE SET NULL,
    api_access_id UUID REFERENCES public.api_access(id) ON DELETE SET NULL,
    redemption_id UUID REFERENCES public.coin_redemptions(id) ON DELETE SET NULL,
    referral_id UUID REFERENCES public.loan_referrals(id) ON DELETE SET NULL,
    description TEXT,
    period_month INTEGER DEFAULT EXTRACT(MONTH FROM CURRENT_TIMESTAMP),
    period_year INTEGER DEFAULT EXTRACT(YEAR FROM CURRENT_TIMESTAMP),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 8. Data Marketplace Exports
CREATE TABLE public.data_exports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    export_type TEXT NOT NULL, -- 'city_trends', 'category_insights', 'merchant_analytics'
    region_filter TEXT,
    date_range_start TIMESTAMPTZ NOT NULL,
    date_range_end TIMESTAMPTZ NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    file_url TEXT,
    download_count INTEGER DEFAULT 0,
    max_downloads INTEGER DEFAULT 5,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 9. CSR Fund Distribution
CREATE TABLE public.csr_funds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sponsor_name TEXT NOT NULL,
    region TEXT NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    allocated_amount DECIMAL(12,2) DEFAULT 0.00,
    remaining_amount DECIMAL(12,2),
    purpose TEXT NOT NULL,
    criteria JSONB,
    is_active BOOLEAN DEFAULT true,
    start_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 10. Community Voting
CREATE TABLE public.community_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    region TEXT NOT NULL,
    proposal TEXT NOT NULL,
    description TEXT,
    total_votes INTEGER DEFAULT 0,
    votes_for INTEGER DEFAULT 0,
    votes_against INTEGER DEFAULT 0,
    voting_ends_at TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.user_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    vote_id UUID REFERENCES public.community_votes(id) ON DELETE CASCADE,
    vote_choice BOOLEAN NOT NULL, -- true for 'for', false for 'against'
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, vote_id)
);

-- 11. Referral Program
CREATE TABLE public.referral_program (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referrer_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    referral_code TEXT UNIQUE NOT NULL,
    total_referrals INTEGER DEFAULT 0,
    successful_referrals INTEGER DEFAULT 0,
    total_coins_earned DECIMAL(10,2) DEFAULT 0.00,
    referral_bonus_per_signup DECIMAL(10,2) DEFAULT 10.00,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.referral_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referrer_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    referred_user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    referral_code TEXT NOT NULL,
    coins_awarded DECIMAL(10,2) DEFAULT 10.00,
    signup_completed BOOLEAN DEFAULT false,
    first_transaction_completed BOOLEAN DEFAULT false,
    bonus_paid BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 12. Essential Indexes
CREATE INDEX idx_subscription_plans_merchant_id ON public.subscription_plans(merchant_id);
CREATE INDEX idx_subscription_plans_tier ON public.subscription_plans(tier);
CREATE INDEX idx_api_access_client_id ON public.api_access(client_id);
CREATE INDEX idx_api_access_api_key ON public.api_access(api_key);
CREATE INDEX idx_api_usage_logs_client_id ON public.api_usage_logs(client_id);
CREATE INDEX idx_api_usage_logs_called_at ON public.api_usage_logs(called_at);
CREATE INDEX idx_coin_redemptions_user_id ON public.coin_redemptions(user_id);
CREATE INDEX idx_loan_referrals_user_id ON public.loan_referrals(user_id);
CREATE INDEX idx_revenue_tracking_source ON public.revenue_tracking(source);
CREATE INDEX idx_revenue_tracking_period ON public.revenue_tracking(period_year, period_month);
CREATE INDEX idx_data_exports_buyer_id ON public.data_exports(buyer_id);
CREATE INDEX idx_referral_program_referrer_id ON public.referral_program(referrer_id);
CREATE INDEX idx_referral_history_referrer_id ON public.referral_history(referrer_id);

-- 13. Enable RLS
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.api_access ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.api_usage_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coin_redemptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loan_referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.revenue_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.data_exports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.csr_funds ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referral_program ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referral_history ENABLE ROW LEVEL SECURITY;

-- 14. Helper Functions for Monetization
CREATE OR REPLACE FUNCTION public.owns_subscription(subscription_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.subscription_plans sp
    WHERE sp.id = subscription_uuid AND sp.merchant_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.owns_api_access(api_access_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.api_access aa
    WHERE aa.id = api_access_uuid AND aa.client_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.can_access_revenue()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.trust_tier IN ('gold'::public.trust_tier, 'platinum'::public.trust_tier)
)
$$;

-- 15. RLS Policies for Monetization
CREATE POLICY "users_own_subscriptions"
ON public.subscription_plans
FOR ALL
TO authenticated
USING (public.owns_subscription(id))
WITH CHECK (public.owns_subscription(id));

CREATE POLICY "users_own_api_access"
ON public.api_access
FOR ALL
TO authenticated
USING (public.owns_api_access(id))
WITH CHECK (public.owns_api_access(id));

CREATE POLICY "users_view_own_api_logs"
ON public.api_usage_logs
FOR SELECT
TO authenticated
USING (auth.uid() = client_id);

CREATE POLICY "users_own_redemptions"
ON public.coin_redemptions
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_own_loan_referrals"
ON public.loan_referrals
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "admin_access_revenue"
ON public.revenue_tracking
FOR ALL
TO authenticated
USING (public.is_admin() OR public.can_access_revenue())
WITH CHECK (public.is_admin());

CREATE POLICY "users_purchase_data_exports"
ON public.data_exports
FOR ALL
TO authenticated
USING (auth.uid() = buyer_id OR public.is_admin())
WITH CHECK (auth.uid() = buyer_id OR public.is_admin());

CREATE POLICY "public_view_csr_funds"
ON public.csr_funds
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "public_view_community_votes"
ON public.community_votes
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "users_own_votes"
ON public.user_votes
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_own_referral_program"
ON public.referral_program
FOR ALL
TO authenticated
USING (auth.uid() = referrer_id)
WITH CHECK (auth.uid() = referrer_id);

CREATE POLICY "users_view_referral_history"
ON public.referral_history
FOR SELECT
TO authenticated
USING (auth.uid() = referrer_id OR auth.uid() = referred_user_id);

-- 16. Monetization Functions

-- Generate API Key
CREATE OR REPLACE FUNCTION public.generate_api_key(client_uuid UUID, tier_level public.api_tier)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    api_key_value TEXT;
    key_prefix TEXT;
BEGIN
    -- Generate key prefix based on tier
    key_prefix := CASE tier_level
        WHEN 'basic'::public.api_tier THEN 'slb_'
        WHEN 'premium'::public.api_tier THEN 'slp_'
        WHEN 'enterprise'::public.api_tier THEN 'sle_'
        ELSE 'sl_'
    END;
    
    -- Generate random key
    api_key_value := key_prefix || encode(gen_random_bytes(32), 'hex');
    
    -- Insert into api_access table
    INSERT INTO public.api_access (client_id, api_key, tier)
    VALUES (client_uuid, api_key_value, tier_level);
    
    RETURN api_key_value;
END;
$$;

-- Redeem Silent Coins
CREATE OR REPLACE FUNCTION public.redeem_silent_coins(
    user_uuid UUID,
    coins_amount DECIMAL(10,2),
    redemption_type_param TEXT,
    redemption_value_param DECIMAL(10,2)
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    redemption_id UUID;
    current_balance DECIMAL(10,2);
BEGIN
    -- Check current balance
    SELECT silent_coins INTO current_balance
    FROM public.wallets
    WHERE user_id = user_uuid;
    
    IF current_balance < coins_amount THEN
        RAISE EXCEPTION 'Insufficient Silent Coins balance';
    END IF;
    
    -- Create redemption record
    INSERT INTO public.coin_redemptions (user_id, coins_redeemed, redemption_type, redemption_value)
    VALUES (user_uuid, coins_amount, redemption_type_param, redemption_value_param)
    RETURNING id INTO redemption_id;
    
    -- Deduct coins from wallet
    UPDATE public.wallets
    SET 
        silent_coins = silent_coins - coins_amount,
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = user_uuid;
    
    RETURN redemption_id;
END;
$$;

-- Calculate Monthly Revenue
CREATE OR REPLACE FUNCTION public.calculate_monthly_revenue(month_param INTEGER, year_param INTEGER)
RETURNS TABLE(
    source_type public.revenue_source,
    total_amount DECIMAL(12,2),
    transaction_count INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rt.source,
        SUM(rt.amount),
        COUNT(*)::INTEGER
    FROM public.revenue_tracking rt
    WHERE rt.period_month = month_param 
    AND rt.period_year = year_param
    GROUP BY rt.source
    ORDER BY SUM(rt.amount) DESC;
END;
$$;

-- Create Loan Referral
CREATE OR REPLACE FUNCTION public.create_loan_referral(
    user_uuid UUID,
    loan_amount DECIMAL(12,2),
    partner_name TEXT
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    referral_id UUID;
    user_trust_score DECIMAL(5,2);
    commission_amount DECIMAL(10,2);
BEGIN
    -- Get user's current trust score
    SELECT trust_score INTO user_trust_score
    FROM public.user_profiles
    WHERE id = user_uuid;
    
    -- Calculate commission (5% of loan amount)
    commission_amount := loan_amount * 0.05;
    
    -- Create referral record
    INSERT INTO public.loan_referrals (
        user_id, 
        trust_score_at_referral, 
        loan_amount_requested, 
        fintech_partner,
        referral_fee
    )
    VALUES (
        user_uuid, 
        user_trust_score, 
        loan_amount, 
        partner_name,
        commission_amount
    )
    RETURNING id INTO referral_id;
    
    RETURN referral_id;
END;
$$;

-- Update Subscription Tier
CREATE OR REPLACE FUNCTION public.update_subscription_tier(
    merchant_uuid UUID,
    new_tier public.subscription_tier,
    stripe_sub_id TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    monthly_price DECIMAL(10,2);
    transaction_limit INTEGER;
    api_limit INTEGER;
BEGIN
    -- Set pricing based on tier
    CASE new_tier
        WHEN 'free'::public.subscription_tier THEN
            monthly_price := 0.00;
            transaction_limit := 100;
            api_limit := 1000;
        WHEN 'pro'::public.subscription_tier THEN
            monthly_price := 29.99;
            transaction_limit := 1000;
            api_limit := 10000;
        WHEN 'elite'::public.subscription_tier THEN
            monthly_price := 99.99;
            transaction_limit := -1; -- unlimited
            api_limit := 100000;
    END CASE;
    
    -- Insert or update subscription
    INSERT INTO public.subscription_plans (
        merchant_id, 
        tier, 
        monthly_price, 
        transaction_limit, 
        api_calls_limit,
        analytics_enabled,
        priority_support,
        custom_branding,
        stripe_subscription_id
    )
    VALUES (
        merchant_uuid, 
        new_tier, 
        monthly_price, 
        transaction_limit, 
        api_limit,
        new_tier != 'free'::public.subscription_tier,
        new_tier = 'elite'::public.subscription_tier,
        new_tier = 'elite'::public.subscription_tier,
        stripe_sub_id
    )
    ON CONFLICT (merchant_id) 
    DO UPDATE SET
        tier = EXCLUDED.tier,
        monthly_price = EXCLUDED.monthly_price,
        transaction_limit = EXCLUDED.transaction_limit,
        api_calls_limit = EXCLUDED.api_calls_limit,
        analytics_enabled = EXCLUDED.analytics_enabled,
        priority_support = EXCLUDED.priority_support,
        custom_branding = EXCLUDED.custom_branding,
        stripe_subscription_id = EXCLUDED.stripe_subscription_id,
        updated_at = CURRENT_TIMESTAMP;
        
    -- Track revenue
    IF monthly_price > 0 THEN
        INSERT INTO public.revenue_tracking (source, amount, client_id, description)
        VALUES (
            'subscription'::public.revenue_source, 
            monthly_price, 
            merchant_uuid, 
            'Monthly subscription: ' || new_tier::TEXT
        );
    END IF;
END;
$$;

-- Track API Usage
CREATE OR REPLACE FUNCTION public.track_api_usage(
    api_key_param TEXT,
    endpoint_param TEXT,
    method_param TEXT,
    status_code_param INTEGER,
    response_time_param INTEGER
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    client_uuid UUID;
    current_usage INTEGER;
    usage_limit INTEGER;
BEGIN
    -- Get client info
    SELECT client_id, calls_used, calls_per_month 
    INTO client_uuid, current_usage, usage_limit
    FROM public.api_access
    WHERE api_key = api_key_param AND is_active = true;
    
    IF client_uuid IS NULL THEN
        RAISE EXCEPTION 'Invalid API key';
    END IF;
    
    -- Check usage limit
    IF current_usage >= usage_limit THEN
        RAISE EXCEPTION 'API usage limit exceeded';
    END IF;
    
    -- Log the API call
    INSERT INTO public.api_usage_logs (
        client_id, 
        api_key, 
        endpoint, 
        method, 
        status_code, 
        response_time_ms
    )
    VALUES (
        client_uuid, 
        api_key_param, 
        endpoint_param, 
        method_param, 
        status_code_param, 
        response_time_param
    );
    
    -- Update usage count
    UPDATE public.api_access
    SET 
        calls_used = calls_used + 1,
        last_call_at = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    WHERE api_key = api_key_param;
END;
$$;

-- 17. Mock Data for Monetization
DO $$
DECLARE
    test_user_id UUID;
    merchant_user_id UUID;
    api_client_id UUID;
    subscription_id UUID;
    api_access_id UUID;
    referral_id UUID;
BEGIN
    -- Get existing user IDs
    SELECT id INTO test_user_id FROM public.user_profiles WHERE email = 'john@example.com' LIMIT 1;
    SELECT id INTO merchant_user_id FROM public.user_profiles WHERE email = 'admin@silentledger.com' LIMIT 1;
    
    IF test_user_id IS NOT NULL THEN
        -- Create subscription plans
        INSERT INTO public.subscription_plans (merchant_id, tier, monthly_price, transaction_limit, api_calls_limit, analytics_enabled)
        VALUES 
            (merchant_user_id, 'pro'::public.subscription_tier, 29.99, 1000, 10000, true),
            (test_user_id, 'free'::public.subscription_tier, 0.00, 100, 1000, false);
        
        -- Create API access
        INSERT INTO public.api_access (client_id, api_key, tier, calls_per_month, monthly_fee)
        VALUES 
            (merchant_user_id, 'slp_' || encode(gen_random_bytes(16), 'hex'), 'premium'::public.api_tier, 50000, 99.99),
            (test_user_id, 'slb_' || encode(gen_random_bytes(16), 'hex'), 'basic'::public.api_tier, 10000, 19.99);
        
        -- Create sample coin redemptions
        INSERT INTO public.coin_redemptions (user_id, coins_redeemed, redemption_type, redemption_value, status)
        VALUES 
            (test_user_id, 100.00, 'cash', 10.00, 'completed'::public.redeem_status),
            (test_user_id, 50.00, 'gift_card', 5.00, 'pending'::public.redeem_status);
        
        -- Create loan referrals
        INSERT INTO public.loan_referrals (user_id, trust_score_at_referral, loan_amount_requested, fintech_partner, referral_fee)
        VALUES 
            (test_user_id, 75.50, 5000.00, 'FinTech Partner Malaysia', 250.00),
            (merchant_user_id, 85.20, 15000.00, 'Islamic Bank Solutions', 750.00);
        
        -- Create revenue tracking records
        INSERT INTO public.revenue_tracking (source, amount, client_id, description)
        VALUES 
            ('subscription'::public.revenue_source, 29.99, merchant_user_id, 'Pro subscription'),
            ('api_usage'::public.revenue_source, 99.99, merchant_user_id, 'Premium API access'),
            ('coin_store'::public.revenue_source, 10.00, test_user_id, 'Coin redemption fee'),
            ('loan_referral'::public.revenue_source, 250.00, test_user_id, 'Loan referral commission');
        
        -- Create referral program
        INSERT INTO public.referral_program (referrer_id, referral_code, total_referrals, successful_referrals, total_coins_earned)
        VALUES 
            (test_user_id, 'JOHN2024', 5, 3, 30.00),
            (merchant_user_id, 'MERCHANT2024', 12, 8, 80.00);
        
        -- Create sample community vote
        INSERT INTO public.community_votes (region, proposal, description, total_votes, votes_for, votes_against, voting_ends_at)
        VALUES 
            ('Kuala Lumpur', 'Allocate RM 10,000 for Small Business Support', 'Community funding for micro-businesses affected by economic changes', 45, 32, 13, CURRENT_TIMESTAMP + INTERVAL '30 days');
        
        -- Create CSR fund
        INSERT INTO public.csr_funds (sponsor_name, region, total_amount, allocated_amount, remaining_amount, purpose)
        VALUES 
            ('Corporate Social Foundation', 'Selangor', 50000.00, 15000.00, 35000.00, 'Support for informal economy workers');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creating monetization mock data: %', SQLERRM;
END $$;
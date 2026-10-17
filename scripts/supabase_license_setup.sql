-- =====================================================================
-- HỆ THỐNG QUẢN LÝ BẢN QUYỀN VÀ KIỂM SOÁT LƯỢT DÙNG - TRƯƠNG NGỌC HOÀ
-- Hướng dẫn: Mở Supabase -> Vào mục "SQL Editor" -> Dán toàn bộ mã này -> Bấm "RUN"
-- =====================================================================

-- 1. TẠO BẢNG QUẢN LÝ BẢN QUYỀN (LICENSES)
create table if not exists public.licenses (
    license_key text primary key,
    hwid text default null,                   -- Tự động lưu mã máy khi kích hoạt lần đầu
    customer_name text default '',            -- Tên khách hàng / Ghi chú
    plan_type text default 'monthly',         -- Loại gói: 'monthly', 'credits', 'lifetime', 'trial'
    expires_at timestamptz default null,      -- Hạn sử dụng (null = không giới hạn ngày)
    credits_remaining integer default null,   -- Số lượt còn lại (null = không giới hạn lượt)
    is_active boolean default true,           -- Trạng thái: true = hoạt động, false = khóa
    created_at timestamptz default now(),     -- Ngày tạo key
    updated_at timestamptz default now()
);

-- Bật bảo mật hàng (Row Level Security)
alter table public.licenses enable row level security;

-- Không cho phép khách hàng tự đọc/ghi trực tiếp vào bảng (chỉ tương tác qua hàm an toàn)
drop policy if exists "Deny direct public access" on public.licenses;
create policy "Deny direct public access" on public.licenses for all using (false);

-- =====================================================================
-- 2. HÀM KIỂM TRA VÀ KÍCH HOẠT KEY (check_license)
-- =====================================================================
create or replace function public.check_license(p_key text, p_hwid text)
returns json
language plpgsql
security definer -- Chạy với quyền quản trị nội bộ
as $$
declare
    v_rec record;
    v_clean_key text;
    v_clean_hwid text;
begin
    v_clean_key := trim(p_key);
    v_clean_hwid := trim(p_hwid);

    if v_clean_key = '' then
        return json_build_object('valid', false, 'message', 'Vui lòng cung cấp mã bản quyền.');
    end if;

    select * into v_rec from public.licenses where license_key = v_clean_key;

    if not found then
        return json_build_object('valid', false, 'message', 'Mã bản quyền không tồn tại.');
    end if;

    if not v_rec.is_active then
        return json_build_object('valid', false, 'message', 'Bản quyền này đã bị khóa hoặc thu hồi.');
    end if;

    -- Kiểm tra gán phần cứng (HWID Lock)
    if v_rec.hwid is null or v_rec.hwid = '' then
        -- Lần đầu kích hoạt: Gán chặt máy tính này vào Key
        update public.licenses 
        set hwid = v_clean_hwid, updated_at = now() 
        where license_key = v_clean_key;
    elsif v_rec.hwid <> v_clean_hwid then
        return json_build_object(
            'valid', false, 
            'message', 'Mã bản quyền này đã được kích hoạt trên thiết bị khác.'
        );
    end if;

    -- Kiểm tra thời hạn ngày/tháng
    if v_rec.expires_at is not null and v_rec.expires_at < now() then
        return json_build_object(
            'valid', false, 
            'message', 'Bản quyền đã hết hạn vào ngày ' || to_char(v_rec.expires_at, 'DD/MM/YYYY HH24:MI')
        );
    end if;

    -- Kiểm tra số lượt sử dụng
    if v_rec.credits_remaining is not null and v_rec.credits_remaining <= 0 then
        return json_build_object(
            'valid', false, 
            'message', 'Bạn đã sử dụng hết số lượt được cấp. Vui lòng nạp thêm lượt.'
        );
    end if;

    return json_build_object(
        'valid', true,
        'message', 'Bản quyền hợp lệ.',
        'customer_name', v_rec.customer_name,
        'plan_type', v_rec.plan_type,
        'expires_at', v_rec.expires_at,
        'credits_remaining', v_rec.credits_remaining
    );
end;
$$;

-- Cấp quyền gọi hàm cho người dùng thông thường / app client
grant execute on function public.check_license(text, text) to anon, authenticated, service_role;

-- =====================================================================
-- 3. HÀM TRỪ LƯỢT KHI XỬ LÝ / XUẤT VIDEO (consume_credit)
-- =====================================================================
create or replace function public.consume_credit(p_key text, p_hwid text)
returns json
language plpgsql
security definer
as $$
declare
    v_rec record;
    v_clean_key text;
    v_clean_hwid text;
    v_left integer;
begin
    v_clean_key := trim(p_key);
    v_clean_hwid := trim(p_hwid);

    select * into v_rec 
    from public.licenses 
    where license_key = v_clean_key and hwid = v_clean_hwid and is_active = true 
    for update;

    if not found then
        return json_build_object('success', false, 'message', 'Key không hợp lệ hoặc sai thiết bị.');
    end if;

    -- Kiểm tra ngày
    if v_rec.expires_at is not null and v_rec.expires_at < now() then
        return json_build_object('success', false, 'message', 'Bản quyền đã hết hạn sử dụng.');
    end if;

    -- Nếu là gói giới hạn theo lượt thì trừ đi 1
    if v_rec.credits_remaining is not null then
        if v_rec.credits_remaining <= 0 then
            return json_build_object('success', false, 'message', 'Hết số lượt xử lý.');
        end if;

        v_left := v_rec.credits_remaining - 1;
        update public.licenses 
        set credits_remaining = v_left, updated_at = now() 
        where license_key = v_clean_key;

        return json_build_object('success', true, 'credits_left', v_left);
    end if;

    -- Nếu là gói không giới hạn lượt (theo tháng/vĩnh viễn)
    return json_build_object('success', true, 'credits_left', null);
end;
$$;

-- Cấp quyền gọi hàm cho người dùng thông thường / app client
grant execute on function public.consume_credit(text, text) to anon, authenticated, service_role;

-- =====================================================================
-- 4. TẠO MẪU MỘT SỐ KEY THỬ NGHIỆM
-- =====================================================================
insert into public.licenses (license_key, customer_name, plan_type, expires_at, credits_remaining, is_active)
values 
    -- Key dùng thử 7 ngày (không giới hạn lượt)
    ('TNH-TRIAL-7DAYS', 'Khách Dùng Thử', 'trial', now() + interval '7 days', null, true),

    -- Key theo tháng (30 ngày, không giới hạn lượt)
    ('TNH-THANG-VIP01', 'Anh Nam Gói Tháng', 'monthly', now() + interval '30 days', null, true),

    -- Key theo lượt (50 lượt xuất video, không giới hạn ngày)
    ('TNH-LUOT-50VIDEO', 'Chị Mai Gói 50 Video', 'credits', null, 50, true),

    -- Key vĩnh viễn
    ('TNH-LIFETIME-VIP', 'Khách VIP Trọn Đời', 'lifetime', null, null, true)
on conflict (license_key) do nothing;

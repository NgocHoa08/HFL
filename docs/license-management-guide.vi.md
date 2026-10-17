# Hướng dẫn Quản lý Bản quyền Phần mềm Trương Ngọc Hoà (Supabase API)

Hệ thống quản lý bản quyền được thiết kế sẵn theo **Phương án 1 (API Serverless Supabase Miễn phí 100%)**, giúp bạn kiểm soát hoàn toàn việc phát hành phần mềm:
- **Khóa theo thiết bị phần cứng (HWID Lock)**: Mỗi Key chỉ dùng được trên đúng máy tính của người mua (lấy mã phần cứng Windows `MachineGuid`).
- **Kiểm soát theo hạn ngày / tháng**: Hết ngày tự động khóa phần mềm.
- **Kiểm soát theo số lượt (Credits)**: Mỗi lần xử lý hoặc xuất video sẽ tự động trừ 1 lượt. Hết lượt sẽ không cho xuất tiếp.
- **Bản quyền trọn đời (Lifetime)**: Không giới hạn ngày và lượt.
- **Khóa từ xa / Thu hồi key**: Bạn có thể bật/tắt bất kỳ key nào trực tiếp từ trang web quản trị của Supabase trên điện thoại hoặc máy tính.

---

## Bước 1: Tạo dự án Supabase miễn phí (2 phút)

1. Truy cập [https://supabase.com](https://supabase.com) và bấm **Sign In** (có thể đăng nhập nhanh bằng tài khoản GitHub hoặc Google).
2. Bấm **New project** (Tạo dự án mới).
3. Đặt tên dự án (ví dụ: `truongngochoa-license`), đặt mật khẩu cơ sở dữ liệu và chọn khu vực (Region: Singapore để tốc độ tại Việt Nam nhanh nhất).
4. Bấm **Create new project** và đợi khoảng 1 phút để Supabase khởi tạo.

---

## Bước 2: Thiết lập cơ sở dữ liệu bản quyền

1. Ở menu bên trái của trang Supabase, bấm vào biểu tượng **SQL Editor** (hoặc hình trang giấy có ký hiệu `SQL`).
2. Mở file [scripts/supabase_license_setup.sql](file:///w:/GITNEW/TruongNgocHoa/scripts/supabase_license_setup.sql) trong thư mục dự án này, copy toàn bộ nội dung và dán vào ô SQL Editor của Supabase.
3. Bấm nút xanh **Run** (Chạy).
4. Hệ thống sẽ tự động tạo:
   - Bảng `licenses` chứa danh sách mã bản quyền.
   - Cơ chế bảo mật Row Level Security (khách hàng không thể hack hoặc xem trộm key của người khác).
   - Hàm `check_license` để kiểm tra và khóa máy.
   - Hàm `consume_credit` để tự động trừ lượt khi làm video.
   - 4 mã key mẫu thử nghiệm: `TNH-TRIAL-7DAYS`, `TNH-THANG-VIP01`, `TNH-LUOT-50VIDEO`, `TNH-LIFETIME-VIP`.

---

## Bước 3: Lấy thông tin kết nối Supabase URL & Anon Key

1. Trên Supabase, vào **Project Settings** (biểu tượng bánh răng ở góc dưới bên trái) -> Chọn mục **API**.
2. Tìm và sao chép 2 giá trị:
   - **Project URL** (dạng `https://xyzabcdefg.supabase.co`)
   - **Project API keys** -> copy mục **anon public** (dạng chuỗi ký tự dài bắt đầu bằng `eyJhbGci...`)

---

## Bước 4: Nhập cấu hình vào phần mềm

Bạn có 2 cách cực kỳ đơn giản để nhập thông tin này vào app:

### Cách 1: Nhập trực tiếp trên giao diện phần mềm (Tiện nhất)
1. Mở phần mềm **Trương Ngọc Hoà**.
2. Bấm vào nút **Kích hoạt bản quyền** ở thanh menu trên cùng (hoặc vào menu **Trợ giúp / Thông tin** -> **Quản lý bản quyền**).
3. Bấm mở mục **▼ Cấu hình máy chủ Supabase (Dành cho người phân phối)**.
4. Dán **Supabase Project URL** và **Anon Key** đã lấy ở Bước 3.
5. Bấm **Lưu cấu hình máy chủ**.

### Cách 2: Lưu vào file cấu hình
Mở file `runtime/data/license-server.json` và điền:
```json
{
  "supabase_url": "https://xyzabcdefg.supabase.co",
  "supabase_key": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

## Bước 5: Cách cấp mã bản quyền cho khách hàng

Khi có khách hàng mua bản quyền của bạn:

1. **Khách hàng lấy mã máy (HWID)**:
   - Khách mở phần mềm, vào phần **Quản lý bản quyền**, bấm nút **Sao chép mã máy** và gửi cho bạn (ví dụ: `1F734EF880068E3997C5`).
2. **Bạn tạo Key trên Supabase**:
   - Vào Supabase -> Chọn **Table Editor** -> Chọn bảng `licenses`.
   - Bấm **Insert row** (Thêm dòng mới) và điền:
     - `license_key`: Đặt mã cho khách (ví dụ: `TNH-KH01-NAM`).
     - `customer_name`: Tên khách (ví dụ: `Anh Nam - 0912345678`).
     - `hwid`: Dán mã máy của khách (hoặc **để trống** để khi khách kích hoạt lần đầu, hệ thống sẽ tự động bắt chặt và lưu mã máy của khách).
     - `plan_type`: Chọn loại gói (`monthly`, `credits`, `trial`, hoặc `lifetime`).
     - `expires_at`: Nếu là gói theo ngày/tháng, chọn ngày hết hạn (ví dụ: `2026-11-17 00:00:00`). Nếu không giới hạn ngày thì để `null`.
     - `credits_remaining`: Nếu là gói theo lượt, nhập số lượt (ví dụ: `100`). Nếu không giới hạn lượt thì để `null`.
     - `is_active`: Đặt là `true` (khi muốn thu hồi key chỉ cần sửa thành `false`).
   - Bấm **Save**.
3. **Khách kích hoạt**:
   - Gửi mã `license_key` cho khách. Khách nhập vào ô và bấm **Kích hoạt ngay**.
   - Phần mềm sẽ lập tức hiển thị màu xanh lá cây: **ĐÃ KÍCH HOẠT**, hiển thị đúng tên gói, hạn sử dụng và số lượt còn lại!

---

## Cơ chế bảo vệ khi xuất video
- Mỗi khi người dùng bấm **Bắt đầu**, **Tiếp tục**, **Xuất video**, hoặc **Chạy hàng loạt**:
  - Hệ thống tự động kiểm tra key online với Supabase.
  - Nếu là gói lượt: Tự động trừ 1 lượt. Khi về 0 lượt, hệ thống lập tức thông báo yêu cầu gia hạn và mở cửa sổ bản quyền.
  - Nếu là gói tháng: Kiểm tra xem đã qua ngày `expires_at` chưa.
  - Nếu key bị bạn thu hồi (`is_active = false`) hoặc bị mang sang máy tính khác chạy (khác `hwid`), hệ thống sẽ từ chối xử lý ngay lập tức.

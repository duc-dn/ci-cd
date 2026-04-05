# Cách GitHub Actions Hoạt Động (Internal Workflow)

Tài liệu này giải thích chi tiết quy trình từ lúc bạn Push code cho đến khi GitHub Actions hoàn tất việc kiểm thử (CI).

---

## 1. Tổng quan các thành phần chính
- **Workflow:** Toàn bộ quy trình tự động (file `.yml`).
- **Job:** Một nhóm các bước thực thi trên **cùng một Runner**.
- **Step:** Các lệnh hoặc Action cụ thể (chạy tuần tự).
- **Runner:** Máy chủ (máy ảo) thực hiện các Job.

---

## 2. Vòng đời của một lần chạy (Workflow Lifecycle)

### Bước 1: Sự kiện kích hoạt (The Trigger)
Khi bạn thực hiện một hành động (ví dụ: `git push`), GitHub nhận tín hiệu và kiểm tra thư mục `.github/workflows/`. Nếu file `.yml` có điều kiện khớp với sự kiện, Workflow sẽ được đưa vào hàng đợi.

### Bước 2: Cấp phát máy ảo (Provisioning Runner)
GitHub sẽ tìm một máy ảo (Runner) đang rảnh. 
- Mỗi Job sẽ được cấp một **máy ảo hoàn toàn mới**.
- Môi trường này sạch 100%, không có code hay dữ liệu cũ của bạn.

### Bước 3: Lấy mã nguồn (Checkout)
Vì máy ảo mới tinh, bước đầu tiên thường là:
```yaml
- uses: actions/checkout@v4
```
Lúc này, Runner sẽ thực hiện `git clone` để kéo code từ repository của bạn vào thư mục làm việc trên máy ảo.

### Bước 4: Thực thi và Caching
Đây là bước chạy các lệnh như `npm install` hoặc `pip install`. 
- **Cơ chế Cache:** Dù máy ảo là mới, GitHub có một **Local Cache Service** tách biệt. 
- Khi dùng `cache: 'pip'`, Runner sẽ tải lại các thư viện đã lưu từ Server Cache về máy ảo mới trước khi cài đặt, giúp giảm thời gian tải từ Internet.

### Bước 5: Dọn dẹp (Post-job Cleanup)
Sau khi tất cả các bước hoàn tất (thành công hoặc thất bại):
1. Các bản log được lưu lại.
2. Các file cache mới (nếu có) sẽ được upload ngược lên Server Cache.
3. **Máy ảo sẽ bị hủy hoàn toàn.** Toàn bộ dữ liệu trên đó biến mất để đảm bảo bảo mật.

---

## 3. Tại sao Cache vẫn tồn tại khi Runner bị hủy?

Vấn đề này thường gây nhầm lẫn. Hãy tưởng tượng:
- **Runner** giống như một **căn phòng thuê theo giờ**. Bạn nhận phòng trống, làm việc xong rồi trả phòng là người ta dọn sạch.
- **Cache Service** giống như một **cái tủ gửi đồ ở sảnh**. 

1. Bạn nhận phòng (Runner mới).
2. Bạn xuống sảnh lấy đồ từ tủ (Restore Cache) mang vào phòng dùng.
3. Làm xong, bạn gói những đồ mới mua bỏ lại vào tủ sảnh (Save Cache).
4. Bạn trả phòng và người ta xóa sạch phòng đó. Người thuê sau (lần chạy sau) lại ra sảnh lấy đồ từ tủ của họ.

---

## 4. Bảo mật với Secrets
Bất kỳ thông tin nhạy cảm nào (Token, Mật khẩu) sẽ không được ghi trực tiếp vào code mà được lưu trong **Settings > Secrets**. GitHub Actions sẽ "tiêm" các giá trị này vào biến môi trường của Runner chỉ khi nó đang chạy.

---

> [!NOTE]
> Để xem hướng dẫn chi tiết về cú pháp viết file YAML, hãy xem file [github_actions_guide.md](./github_actions_guide.md).

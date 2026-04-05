# Sử dụng image Python chuẩn và nhẹ nhàng
FROM python:3.12-slim

# Thiết lập thư mục làm việc trong container
WORKDIR /app

# Copy tệp yêu cầu thư viện vào trước để tận dụng cache của Docker
COPY requirements.txt .

# Cài đặt các thư viện cần thiết
RUN pip install --no-cache-dir -r requirements.txt

# Copy toàn bộ mã nguồn vào thư mục làm việc
COPY . .

# Thiết lập biến môi trường thư mục gốc để app mô đun hoạt động
ENV PYTHONPATH=/app

# Định nghĩa lệnh khởi chạy mặc định khi container chạy
# (Cấu hình này giả định việc chạy ứng dụng bằng app/main.py)
CMD ["python", "app/main.py"]

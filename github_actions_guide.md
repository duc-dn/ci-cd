# Hướng dẫn Cơ bản về GitHub Actions (CI)

GitHub Actions là một nền tảng Continuous Integration (CI) và Continuous Deployment (CD) cho phép bạn tự động hóa quy trình xây dựng, kiểm thử và triển khai mã nguồn trực tiếp từ GitHub.

---

## 1. Cấu trúc Thư mục
Tất cả các file cấu hình GitHub Actions (được gọi là workflows) phải được đặt trong thư mục:
`[root]/.github/workflows/`

Các file này sử dụng định dạng **YAML** (đuôi `.yml` hoặc `.yaml`). Ví dụ: `.github/workflows/ci.yml`.

---

## 2. Cấu trúc cơ bản của file YAML

Một file workflow chuẩn thường bao gồm các thành phần sau:

```yaml
name: CI Workflow  # Tên của workflow (hiển thị trên giao diện GitHub)

on: [push, pull_request]  # Sự kiện kích hoạt (khi push hoặc tạo PR)

jobs:  # Danh sách các công việc cần thực hiện
  build-and-test:  # ID của job
    runs-on: ubuntu-latest  # Hệ điều hành máy ảo (runner)

    steps:  # Các bước thực hiện trong job này
      - name: Checkout code
        uses: actions/checkout@v4  # Sử dụng Action có sẵn để lấy code từ repo

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt

      - name: Run tests
        run: pytest
```

### Giải thích các thành phần chính:
- **`name`**: Tên hiển thị của workflow trên tab Actions của GitHub.
- **`on`**: Các sự kiện kích hoạt workflow (ví dụ: `push`, `pull_request`, `schedule`, `workflow_dispatch` - kích hoạt thủ công).
- **`jobs`**: Một workflow có thể gồm nhiều jobs chạy song song hoặc tuần tự.
- **`runs-on`**: Loại máy chủ mà job sẽ chạy trên đó (thường là `ubuntu-latest`).
- **`steps`**: Danh sách các hành động. Mỗi step có thể chạy một lệnh terminal (`run`) hoặc một Action có sẵn (`uses`).

---

## 3. Cách truyền Biến và Secrets

Trong GitHub Actions, có 3 loại biến chính:

### a. Environment Variables (Biến môi trường - `env`)
Dùng cho các thông tin không nhạy cảm (như tên môi trường, port...).

```yaml
env:
  NODE_ENV: production  # Biến toàn cục cho cả workflow

jobs:
  build:
    runs-on: ubuntu-latest
    env:
      DB_NAME: my_app_test  # Biến chỉ có tác dụng trong job này
    steps:
      - name: Show Variables
        run: echo "Environment is $NODE_ENV and DB is $DB_NAME"
```

### b. Secrets (Dùng cho thông tin nhạy cảm)
Dùng để lưu API Key, Password, Token... Bạn phải thiết lập các giá trị này trong GitHub Repo: **Settings > Secrets and variables > Actions**.

Khi sử dụng, bạn gọi qua cú pháp `${{ secrets.TEN_SECRET }}`.

```yaml
steps:
  - name: Deploy to Server
    env:
      API_KEY: ${{ secrets.FIREBASE_API_KEY }}  # Tuyệt đối không viết trực tiếp key vào file
    run: ./deploy.sh --key $API_KEY
```

### c. Inputs (Cho workflow kích hoạt thủ công)
Khi bạn muốn người dùng nhập thông tin khi chạy workflow (dùng sự kiện `workflow_dispatch`).

```yaml
on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to deploy'
        required: true
        default: 'v1.0.0'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        run: echo "Deploying version ${{ github.event.inputs.version }}"
```

---

## 4. Ví dụ thực tế hoàn chỉnh (`ci.yml`)

Dưới đây là một file mẫu cho dự án Python:

```yaml
name: Python CI

on:
  push:
    branches: [ "main" ]  # Chạy khi push lên nhánh main
  pull_request:
    branches: [ "main" ]  # Chạy khi tạo PR vào nhánh main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Set up Python 3.12
      uses: actions/setup-python@v5
      with:
        python-version: '3.12'
        cache: 'pip' # Caching pip giúp chạy nhanh hơn

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        # pip install flake8 pytest # Nếu chưa có trong requirements.txt

    - name: Lint with flake8
      run: |
        # stop the build if there are Python syntax errors or undefined names
        flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
        # exit-zero treats all errors as warnings. The GitHub editor is 127 chars wide
        flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

    - name: Test with pytest
      run: pytest
      env:
        DATABASE_URL: ${{ secrets.DB_URL }}
```

---

> [!TIP]
> Bạn nên sử dụng `cache: 'pip'` trong `setup-python` để tiết kiệm thời gian cài đặt thư viện ở những lần chạy sau.

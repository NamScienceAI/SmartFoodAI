# CHG-UI-003 · SmartFood AI main UI

## Phạm vi đã triển khai
- Thay trang kiểm tra kết nối tại `/` bằng ứng dụng SmartFood AI; chuyển trang kiểm tra kết nối cũ sang `/health`.
- Giữ nguyên trang quản lý hộ gia đình hiện tại tại `/household` và không chỉnh sửa backend.
- Bổ sung màn hình đăng ký/đăng nhập, tạo hộ/tham gia hộ, dashboard, điều hướng module.
- Dashboard đọc dữ liệu thật từ API inventory và monitoring.
- Trang kho hiển thị lô thực phẩm; trang thông báo lọc cảnh báo và đánh dấu đã đọc qua API.
- Các mục OCR, gợi ý món, kế hoạch bữa ăn, mua sắm, báo cáo và hộ gia đình đã có khung điều hướng/mô tả API, chờ các change request giao diện chi tiết tiếp theo.
- Responsive cho desktop/tablet/mobile.

## Chạy
Theo README gốc: cài `requirements.txt`, chạy Uvicorn ở `127.0.0.1:8000`, mở `http://127.0.0.1:8000/`.

## Kiểm thử trong môi trường build
- `node --check web/assets/app.js`: pass.
- `python -m compileall -q backend`: pass.
- `python -m unittest discover -s tests -p 'test_*.py' -v`: 22 tests, 21 passed, 1 skipped (OCR Windows local adapter).
- Smoke test TestClient: root, static assets, `/household`, `/health`, register/login, create household, inventory API, alerts API: pass.

## Giới hạn
- Chưa thêm API hoặc thay đổi schema/database.
- Số lượng tồn kho hiển thị theo `ticks`/đơn vị cơ sở mà backend trả về, chưa định dạng đổi sang đơn vị nhập.
- Những trang module chưa thuộc CHG-UI-003 mới có khung điều hướng, không giả lập rằng nghiệp vụ đã được tích hợp vào UI.

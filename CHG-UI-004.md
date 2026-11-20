# CHG-UI-004 · Next.js Premium SaaS Dashboard

## Mục tiêu
Chuyển giao diện Web sang Next.js + TypeScript, giữ nguyên FastAPI và nghiệp vụ hiện tại. Ưu tiên Dashboard SmartFood AI theo phong cách Premium SaaS xanh lá - trắng.

## Phạm vi
- Bổ sung ứng dụng Next.js App Router trong `frontend/`.
- Bổ sung đăng ký, đăng nhập, thiết lập hộ gia đình.
- Dashboard đọc inventory batches và alerts trực tiếp từ API FastAPI hiện hữu.
- Hiển thị chỉ số tồn kho, cảnh báo, hạn 7 ngày, thông báo chưa đọc, phân bố trạng thái, danh sách lô gần đây và thao tác nhanh.
- Bổ sung trang kho và trang thông báo sử dụng API hiện có.
- Các module chưa được phát triển UI chi tiết hiển thị trạng thái lộ trình, không giả lập nghiệp vụ.
- Proxy `/api/*` qua Next.js rewrites để giữ luồng cookie cùng origin trong local development.

## Bảo toàn hệ thống
- Không sửa `backend/`, migration, schema SQLite hoặc API contract.
- Không thay đổi `web/` hiện tại; FastAPI tiếp tục phục vụ giao diện cũ tại `/` và trang hộ gia đình tại `/household`.
- Giữ header xác nhận ghi `X-SmartFood: 1` và header actor cho request ghi sau đăng nhập.
- Không đưa session cookie hoặc API key vào JavaScript public.

## Kiểm thử cần thực hiện khi chạy local
1. Đăng ký tài khoản mới và đăng nhập.
2. Tạo hộ gia đình hoặc tham gia bằng mã mời.
3. Dashboard tải thành công inventory batches và alerts.
4. Refresh tải lại dữ liệu.
5. Trang kho tìm kiếm và lọc theo trạng thái.
6. Đánh dấu cảnh báo đã đọc và xác nhận trạng thái được cập nhật.
7. Đăng xuất và xác nhận phiên kết thúc.
8. Chạy lại bộ test backend gốc để bảo đảm không hồi quy.

# CHG-UI-005 · Inventory Operations

## Mục tiêu
Hoàn thiện luồng quản lý kho thực phẩm trên Next.js bằng cách kết nối các thao tác nhập hàng, ghi nhận biến động tồn kho và rà soát thông tin lô với API FastAPI hiện hữu.

## Chức năng đã triển khai
- Tìm thực phẩm từ danh mục backend qua `GET /api/catalog/products?q=...`; người dùng phải chọn sản phẩm thuộc danh mục, không tự tạo product ngoài catalog.
- Nhập lô thực phẩm qua `POST /api/households/{hid}/inventory/batches` với số lượng, đơn vị, ngày nhận, hạn sử dụng, nguồn hạn và request key duy nhất.
- Hỗ trợ đơn vị phù hợp với đơn vị chuẩn của sản phẩm: `g`/`kg`, `ml`/`l`, `quả`.
- Ghi nhận đã sử dụng, bỏ đi/hư hỏng hoặc đối soát số lượng qua `POST /api/households/{hid}/inventory/batches/{bid}/movements`.
- Đối soát gửi `expected_version` để backend kiểm tra xung đột cập nhật.
- Rà soát hạn sử dụng, nguồn hạn và cờ cần kiểm tra qua `PUT /api/households/{hid}/inventory/batches/{bid}/review`.
- Tải lại dashboard, tồn kho và cảnh báo sau mỗi thao tác ghi thành công.
- Giao diện modal responsive, trạng thái đang lưu, phản hồi lỗi API và thông báo thành công.

## Quy tắc nghiệp vụ được giữ nguyên
- Không tự quy đổi số lượng ở frontend; backend catalog chịu trách nhiệm chuyển đổi đơn vị và kiểm tra độ chính xác.
- Hạn `estimate` vẫn được thể hiện là cần xác minh; `unknown` gửi `expiry: null`.
- Không cho phép thao tác vượt tồn, sử dụng lô chưa đủ điều kiện hoặc ghi đè phiên bản khi kiểm kê.
- Không thêm chức năng xóa lô vì API hiện tại không cung cấp endpoint xóa; lịch sử biến động/audit được giữ theo nghiệp vụ backend.

## Tệp thay đổi
- `frontend/src/components/smartfood-app.tsx`
- `frontend/src/lib/api.ts`
- `frontend/src/app/globals.css`

## Bảo toàn hệ thống
Không thay đổi `backend/`, migrations, schema SQLite, API contract hoặc giao diện `web/` cũ.

## Kiểm thử
- `python -m compileall -q backend`: đạt.
- `python -m unittest discover -s tests -p 'test_*.py' -v`: 22 tests, 21 passed, 1 skipped (OCR adapter chỉ chạy trên Windows).
- TypeScript transpile syntax check: 2 tệp được kiểm tra, không có lỗi cú pháp.
- Chưa chạy `next build` vì các package frontend chưa được cài trong môi trường tạo bản ZIP; cần chạy `npm install` và `npm run build` trên máy phát triển.

# SmartFood AI — CHG-UI-009: Smart Grocery Purchase & Inventory Sync

## Mục tiêu

Hoàn thiện vòng đời mua sắm bằng cách cho phép xác nhận mặt hàng đã mua và tạo lô tồn kho tương ứng, thay vì chỉ lưu checkbox trạng thái mua.

## Luồng người dùng

1. Người dùng mở **Danh sách mua sắm** và đánh dấu mặt hàng đã mua.
2. Chọn **Nhập kho** ở mặt hàng đó.
3. Nhập số lượng thực nhận, đơn vị, ngày nhận, hạn sử dụng và nguồn hạn (nhãn, người dùng xác nhận, ước tính hoặc chưa xác định).
4. Xác nhận. Backend tạo lô hàng và movement `receive`, cập nhật trạng thái mua và liên kết dòng mua với lô vừa tạo trong cùng transaction.
5. Frontend tải lại danh sách mua, tồn kho, cảnh báo và Dashboard. Dòng mua hiển thị mã lô đã tạo.

## API và dữ liệu

- `POST /api/households/{hid}/grocery-lists/{lid}/items/{pid}/receive` — nhận payload tương thích schema `inventory.Receive`; xác thực `product_id` khớp với `{pid}`.
- `GET /api/households/{hid}/grocery-lists` — mỗi item bổ sung `received_batch_id` (null nếu chưa nhập).
- `PUT /api/households/{hid}/grocery-lists/{lid}/items/{pid}` — vẫn dùng để đánh dấu đã mua/chưa mua; không cho bỏ trạng thái đã mua sau khi item đã nhập kho.
- Migration `005_grocery_receiving.sql` tạo bảng `grocery_item_receipts`, khóa chính `(list_id, product_id)` và `batch_id` duy nhất.

## Bảo đảm nghiệp vụ

- Tạo batch, movement, liên kết mua hàng và cập nhật purchased nằm trong cùng transaction; lỗi giữa chừng sẽ rollback toàn bộ.
- Dùng `once(...)` với `request_key`: gửi lại cùng payload và key trả lại kết quả cũ, không tạo batch thứ hai.
- Một dòng trong một danh sách chỉ liên kết tối đa một batch; request key khác cho dòng đã nhập trả HTTP 409.
- Hạn sử dụng và ngày nhận được kiểm tra bằng schema inventory hiện có. Hạn ước tính không được coi là hạn xác nhận để tính tồn kho có thể sử dụng.
- Dữ liệu tồn kho và Dashboard vẫn lấy từ API/backend, frontend không tự cộng tồn.

## Files changed

- `backend/meal_grocery/__init__.py` — endpoint nhận hàng, truy vấn batch đã liên kết và bảo vệ trạng thái mua.
- `backend/audit_config/database.py` — đăng ký migration 005.
- `migrations/005_grocery_receiving.sql` — bảng liên kết dòng mua với batch.
- `frontend/src/components/meal-planner-page.tsx` — modal xác nhận nhập kho và trạng thái đã nhập.
- `frontend/src/app/globals.css` — style cho trạng thái nhập kho responsive.
- `tests/test_backend.py`, `tests/test_foundation.py` — kiểm thử nhận hàng, idempotency, chống nhập trùng và schema version.

## Giới hạn hiện tại

- Mỗi dòng sản phẩm trong một danh sách mua chỉ được nhập thành một lô. Nếu người dùng mua cùng sản phẩm nhiều lần hoặc cần chia nhiều lô/hạn khác nhau, cần tạo nhiều dòng mua hoặc phát triển luồng nhận nhiều lô ở phiên bản sau.
- Chưa lưu giá mua, cửa hàng, ảnh hóa đơn hay phí vận chuyển vào giao dịch nhập kho.
- Khi nhập số lượng thực nhận khác số lượng dự kiến, tồn kho dùng số lượng thực nhận; danh sách mua vẫn giữ số lượng thiếu ban đầu để làm lịch sử nhu cầu.
- Người dùng cần chọn đúng đơn vị tương thích với nhóm đơn vị của sản phẩm; quy đổi vẫn do backend kiểm tra.

## Run and validation

Backend và frontend khởi chạy như hướng dẫn trong `README.md` và `frontend/README.md`. Database cũ tự nâng cấp từ schema 4 lên schema 5 khi FastAPI khởi động.

- `python -m compileall -q backend`: passed.
- `python -m unittest discover -s tests -p 'test_*.py' -v`: 22 tests, 21 passed, 1 skipped (Windows-only OCR integration test).
- TypeScript/TSX transpile syntax check: passed.
- Full `next build`, lint và browser E2E chưa chạy trong môi trường build này vì dependencies npm chưa được cài.

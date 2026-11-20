# SmartFood AI · Next.js Frontend

Frontend mới được bổ sung theo hướng Premium SaaS, sử dụng Next.js App Router, React, TypeScript và CSS responsive. Backend FastAPI hiện tại được giữ nguyên.

## Yêu cầu

- Node.js 20.9 trở lên (khuyến nghị LTS)
- npm
- Backend SmartFood AI chạy tại `http://127.0.0.1:8000`

## Chạy local

Terminal 1 — tại thư mục gốc `AI_Food-1`:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe -m uvicorn backend.main:app --host 127.0.0.1 --port 8000 --no-proxy-headers
```

Terminal 2 — tại `AI_Food-1/frontend`:

```powershell
npm install
npm run dev
```

Mở `http://localhost:3000` để dùng giao diện Next.js. FastAPI tiếp tục chạy tại `http://127.0.0.1:8000`; trang frontend proxy `/api/*` đến FastAPI thông qua Next.js rewrites. Trang cũ và trang hộ gia đình vẫn còn tại backend (`/` và `/household`) để đối chiếu hoặc quay lui.

## Cấu hình API

Mặc định `SMARTFOOD_API_ORIGIN=http://127.0.0.1:8000`. Nếu backend chạy ở địa chỉ khác, tạo file `.env.local` từ `.env.example` và sửa giá trị tương ứng, sau đó khởi động lại Next.js.

Khi triển khai production, nên đặt Next.js và FastAPI sau cùng một reverse proxy/domain để cookie phiên HttpOnly, SameSite=Strict và các API cùng origin hoạt động ổn định. Không đưa thông tin bí mật hoặc API key AI vào biến môi trường `NEXT_PUBLIC_*`.

## Phạm vi UI trong phiên bản này

- Đăng nhập / đăng ký qua API hiện có.
- Tạo hộ gia đình / tham gia bằng mã mời.
- Dashboard đọc dữ liệu thật từ inventory batches và alerts.
- Thẻ tổng quan, cảnh báo, phân bố trạng thái tồn kho, tồn kho gần đây và thao tác nhanh.
- Trang kho và thông báo dùng API hiện có.
- OCR, gợi ý món ăn, kế hoạch bữa ăn và danh sách mua sắm đã được tích hợp với API hiện có. Báo cáo và quản lý hộ gia đình vẫn là các mục định hướng trong giao diện Next.js.

## Kiến trúc và bảo toàn nghiệp vụ

- Các phiên bản giao diện trước CHG-UI-009 giữ nguyên schema SQLite và endpoint nghiệp vụ. CHG-UI-009 bổ sung migration 005 và một endpoint nhận hàng từ danh sách mua sắm; các endpoint cũ được giữ tương thích.
- Logic tính tồn kho, quy đổi đơn vị, tạo batch và ghi sổ vẫn do FastAPI đảm nhiệm.
- API ghi dữ liệu vẫn gửi `X-SmartFood: 1`; các thao tác sau đăng nhập gửi thêm `X-SmartFood-Actor` theo cơ chế frontend cũ.
- Cookie phiên được quản lý bởi FastAPI; frontend không đọc token phiên.

## Quản lý kho (CHG-UI-005)

Trang **Kho thực phẩm** hiện hỗ trợ:
- **Nhập thực phẩm:** tìm và chọn từ danh mục backend, nhập số lượng/đơn vị/ngày nhận/hạn sử dụng.
- **Biến động tồn:** ghi nhận đã sử dụng, bỏ đi/hư hỏng hoặc đối soát số lượng thực tế.
- **Rà soát lô:** cập nhật nguồn hạn, ngày hạn và cờ cần kiểm tra.

Các thao tác được gửi đến API FastAPI hiện có. Frontend không tự tạo danh mục thực phẩm và không xóa lô vì backend chưa cung cấp endpoint xóa.

## Quét hóa đơn OCR (CHG-UI-006)

Trang **Quét hóa đơn** đã được kết nối với API receipt hiện có:
- Tải ảnh PNG/JPEG tối đa 5 MiB lên API.
- Hiển thị các dòng OCR gốc, gợi ý danh mục và cảnh báo ảnh trùng.
- Người dùng phải chọn sản phẩm, kiểm tra số lượng/đơn vị/ngày nhận/hạn sử dụng.
- Lưu bản nháp, sau đó xác nhận nhập kho; dữ liệu chỉ được ghi vào kho sau khi xác nhận.
- Có luồng nhập thủ công khi OCR không đọc được hoặc không khả dụng.

**Lưu ý môi trường OCR:** backend hiện dùng Windows Runtime `Windows.Media.Ocr` qua PowerShell, nên nhận diện ảnh chỉ hoạt động trên Windows có gói ngôn ngữ OCR phù hợp. Trên Linux/macOS API sẽ trả về HTTP 503; có thể dùng lựa chọn nhập thủ công. OCR hiện là nhận diện văn bản cục bộ, không phải mô hình AI hiểu ngữ nghĩa hóa đơn; cần kiểm tra kỹ kết quả và tự quy đổi các đơn vị đóng gói như hộp/gói/bó trước khi xác nhận.


## CHG-UI-007 · AI Recipe Recommendation

Trang **Gợi ý món ăn** đọc danh mục công thức và hồ sơ ăn uống từ FastAPI, cho phép lưu dị ứng/chế độ ăn/nguyên liệu yêu thích, gọi endpoint xếp hạng theo tồn kho, xem nguyên liệu thiếu và thêm món vào kế hoạch bữa ăn. Chi tiết API, giới hạn dữ liệu công thức và cách kiểm thử được ghi tại `../CHG-UI-007.md`.


## CHG-UI-008 · Meal Planning & Smart Grocery Management

Hai trang **Kế hoạch bữa ăn** và **Danh sách mua sắm** dùng các API meal/grocery hiện có. Hỗ trợ tạo/sửa/xóa bữa ăn, chọn khoảng ngày, xem nhu cầu thiếu hụt do backend tính toán, lưu danh sách mua và đánh dấu trạng thái đã mua. Xem `../CHG-UI-008.md` để biết chi tiết về dữ liệu, giới hạn và API. Việc đánh dấu đã mua hiện chỉ cập nhật trạng thái dòng mua sắm; chưa tự động tạo lô tồn kho.


## CHG-UI-009 · Purchase to inventory

Trong danh sách mua sắm, sau khi đánh dấu mặt hàng đã mua, chọn **Nhập kho** để nhập số lượng thực nhận, ngày nhận, hạn sử dụng và nguồn hạn. Xác nhận sẽ gọi endpoint nhận hàng từ danh sách mua; backend tạo batch và movement, liên kết batch với dòng mua và ngăn nhập trùng. Giao diện tải lại danh sách mua, tồn kho, cảnh báo và Dashboard sau khi thành công. Dòng đã nhập hiển thị mã lô và không thể bỏ trạng thái đã mua.

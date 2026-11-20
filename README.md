# SmartFood AI

## Backend để review

[Cấu trúc 11 phần, cách chạy và các luồng kiểm tra](backend/README.md). Bản local sử dụng schema 5; migration mới bổ sung liên kết nhập kho từ danh sách mua sắm.

## Giao diện SmartFood AI

Sau khi khởi chạy server, mở [trang tổng quan SmartFood AI](http://127.0.0.1:8000/). Giao diện chính hỗ trợ đăng ký/đăng nhập, tạo hoặc tham gia hộ, dashboard, xem kho thực phẩm và cảnh báo hạn sử dụng. Trang quản lý hộ gia đình W1 vẫn được giữ tại `/household`; trang kiểm tra kết nối API cũ được chuyển đến `/health`.

## W1 · Tài khoản và hộ gia đình

Khởi chạy theo các lệnh Windows bên dưới, rồi mở [trang hộ gia đình](http://127.0.0.1:8000/household). Bạn có thể đăng ký, đăng nhập, tạo hộ, chia sẻ mã mời, quản lý thành viên, chuyển chủ hộ và rời hộ. [Demo hai hộ](docs/demo.md) · [Test G1](docs/evaluation.md) · [Mô hình dữ liệu](docs/data.md).

Ứng dụng tự tạo SQLite tại `var/smartfood.sqlite3`. Có thể đặt biến môi trường `SMARTFOOD_DB` trỏ tới đường dẫn DB cục bộ riêng trước khi khởi động. Khởi động lại sẽ giữ dữ liệu. Thử nghiệm tự động dùng DB tạm. Dùng môi trường loopback cho demo. Trang cần được mở qua HTTP.

Mã mời có hiệu lực 24 giờ, dùng một lần. Phiên đăng nhập có hiệu lực 7 ngày. Cookie là HttpOnly, SameSite=Strict và có Secure khi dùng HTTPS. API sửa dữ liệu yêu cầu header `X-SmartFood: 1`, được trang Web gửi cùng origin. Danh mục endpoint và schema có tại [OpenAPI](http://127.0.0.1:8000/docs). Chế độ thử yêu cầu trên Swagger cần gửi thêm header này.

## W1-01 · Kiểm tra kết nối Web–API

FastAPI phục vụ trang Web và API từ cùng một tiến trình. Trang tiếng Việt gửi yêu cầu đến `/api/health` khi mở và khi bấm **Thử lại**.

### Chạy trên Windows

Mở PowerShell tại thư mục chứa tệp này. Dùng Python 3.14 trên Windows x64 (phiên bản kiểm thử 3.14.5).

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe -m uvicorn backend.main:app --host 127.0.0.1 --port 8000 --no-proxy-headers
```

Nếu lệnh `python` mở Microsoft Store, dùng `py -3.14 -m venv .venv` hoặc gọi trực tiếp đường dẫn đến Python 3.14 đã cài ở bước đầu.

### Kiểm tra

1. Mở [trang kiểm tra](http://127.0.0.1:8000/health). Trang hiển thị **Đã kết nối API** sau khi nhận phản hồi hợp lệ.
2. Từ cửa sổ PowerShell khác, chạy `Invoke-RestMethod http://127.0.0.1:8000/api/health`. Trường `status` phải bằng `ok`; phản hồi HTTP có mã 200 và kiểu JSON.
3. Giữ trang đang mở. Nhấn Ctrl+C trong cửa sổ chạy Uvicorn. Trên trang, bấm **Thử lại** để thấy **Chưa kết nối được API**.
4. Chạy lại lệnh Uvicorn, rồi bấm **Thử lại** trên cùng trang. Trạng thái phải trở về **Đã kết nối API**.

Mỗi lần kiểm tra bỏ qua cache và chờ tối đa 5 giây. Endpoint kiểm tra khả năng phản hồi của tiến trình ứng dụng. Dữ liệu tài khoản, hộ gia đình và kho thuộc các phần việc tiếp theo.

## Frontend Next.js mới · CHG-UI-004

Bản giao diện Premium SaaS mới nằm trong `frontend/`. Backend FastAPI, SQLite, migration và các API nghiệp vụ được giữ nguyên. Xem hướng dẫn chạy tại [frontend/README.md](frontend/README.md).

Chạy FastAPI ở cổng `8000`, sau đó chạy Next.js trong `frontend/` bằng `npm install` và `npm run dev`; mở `http://localhost:3000`. Trang frontend mới sử dụng API thật qua proxy Next.js. Giao diện cũ vẫn được giữ ở FastAPI để tương thích và đối chiếu.

## CHG-UI-006 · Quét hóa đơn OCR

Frontend Next.js đã có luồng tải ảnh hóa đơn, xem OCR, ghép dòng hàng với danh mục, chỉnh sửa và xác nhận nhập kho. Xem [tài liệu CHG-UI-006](CHG-UI-006.md) và [hướng dẫn frontend](frontend/README.md). Bộ OCR hiện tại sử dụng Windows Runtime, vì vậy cần Windows có gói ngôn ngữ OCR phù hợp; luồng nhập thủ công vẫn khả dụng khi OCR không chạy.


## CHG-UI-007 · Gợi ý món ăn thông minh

Frontend Next.js đã tích hợp hồ sơ ăn uống, xếp hạng món theo tồn kho và nguyên liệu gần hạn, xem mức đáp ứng nguyên liệu và thêm món vào kế hoạch bữa ăn. Xem [tài liệu CHG-UI-007](CHG-UI-007.md). Gợi ý sử dụng thuật toán xếp hạng hiện có trong Backend; danh mục ban đầu là dữ liệu công thức demo đã được duyệt và hiện chưa có hướng dẫn chế biến chi tiết.


## CHG-UI-008 · Kế hoạch bữa ăn và mua sắm thông minh

Hai mục **Kế hoạch bữa ăn** và **Danh sách mua sắm** đã được kết nối với API FastAPI. Người dùng có thể thêm/sửa/xóa bữa ăn, xem lịch theo ngày, xem nhu cầu nguyên liệu còn thiếu theo tồn kho, lưu danh sách mua sắm và đánh dấu các mặt hàng đã mua. Xem [tài liệu CHG-UI-008](CHG-UI-008.md) để biết API, giới hạn và kết quả kiểm thử.


## CHG-UI-009 · Xác nhận mua hàng và đồng bộ tồn kho

Danh sách mua sắm hiện hỗ trợ luồng khép kín sau khi mua hàng: đánh dấu đã mua, nhập số lượng thực nhận, ngày nhận và nguồn hạn sử dụng, sau đó xác nhận tạo lô hàng mới trong kho. Backend ghi lô và sổ biến động trong cùng giao dịch, tự đánh dấu mặt hàng đã mua và liên kết lô vừa tạo với dòng mua sắm. Một dòng mua chỉ được nhập kho một lần; retry cùng request key trả lại kết quả cũ, còn request key mới cho mặt hàng đã nhập bị từ chối. Dashboard và kho được tải lại sau khi xác nhận. Xem [CHG-UI-009](CHG-UI-009.md).

## Triển khai công khai trên Vercel và Render

1. Tạo Blueprint trên Render từ `render.yaml` và triển khai backend. Render sẽ tạo ổ đĩa `smartfood-data` để SQLite không bị mất khi máy chủ khởi động lại.
2. Sao URL HTTPS của backend Render, ví dụ `https://smartfood-ai-api.onrender.com`.
3. Triển khai thư mục `frontend/` trên Vercel. Trong **Environment Variables**, đặt `SMARTFOOD_API_ORIGIN` bằng URL HTTPS của backend.
4. Triển khai lại frontend sau khi đặt biến môi trường. Vercel sẽ tạo đường link công khai dạng `https://ten-du-an.vercel.app`.
5. Chia đường link Vercel cho người trong gia đình. Dữ liệu tài khoản và kho được lưu chung qua backend; mỗi người nên đăng ký tài khoản riêng.

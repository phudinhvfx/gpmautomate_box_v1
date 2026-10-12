# Kết nối của Box_v1

Tài liệu này mô tả ranh giới kết nối của Box_v1. Chỉ chứa địa chỉ nội bộ, đường dẫn chương trình và kiểm tra chỉ-đọc; không lưu mật khẩu, token, cookie hoặc chuỗi proxy. Trạng thái device, Appium, MikroTik Tool và ADB là trạng thái động — phải đọc lại trước mỗi canary.

## 1. API MikroTik — mạng và proxy

| Mục | Giá trị |
| --- | --- |
| Swagger | `http://127.0.0.1:8000/docs` |
| OpenAPI schema | `http://127.0.0.1:8000/openapi.json` |
| Health check chỉ-đọc | `GET http://127.0.0.1:8000/api/app/health` |
| Kết quả lịch sử | Swagger, schema và health từng trả HTTP 200; không thay thế kiểm tra live hiện tại |

Khởi đầu bằng Swagger để đọc đúng request body và phương thức cho từng endpoint. Các nhóm endpoint có sẵn gồm thiết bị, proxy client, PPPoE, route, WireGuard và OpenVPN.

Kiểm tra an toàn bằng PowerShell:

```powershell
Invoke-WebRequest 'http://127.0.0.1:8000/api/app/health' -UseBasicParsing
```

`/api/app/health` chỉ chứng minh API cục bộ đang sống. Nó **không** tự chứng minh đã đăng nhập hay điều khiển được RouterOS/MikroTik. Chỉ gọi `POST`, đăng nhập, thay proxy, PPPoE, route, VPN hoặc endpoint có hậu tố `start`/`apply`/`assign`/`clear` sau khi có mục tiêu và ủy quyền rõ ràng.

## 2. GPM Automate Phone và GPM UI Automator

| Mục | Giá trị |
| --- | --- |
| Project Phone | `D:\gpm\Box_v1` |
| Metadata project | `D:\gpm\Box_v1\info.gpmsln` |
| Workflow source | `D:\gpm\Box_v1\src.gscript` |
| GPM Automate Editor | `C:\Users\phudinh\AppData\Local\Programs\GPMAutomate\Editor\GPMAutomateEditor.exe` |
| GPM Automate Runtime | `C:\Users\phudinh\AppData\Local\Programs\GPMAutomate\Runtime\GPMAutomateRuntime.exe` |

Project hiện là `PhoneEditor` hợp lệ và đã có Main, `flow_0` và `flow_1`. `flow_0` là sandbox action; `flow_1` là canary Facebook Lite; Main gọi workflow bằng `Call workflow`. Xem `README.md` và `PHONE_ACTION_RUNBOOK.md` để biết phạm vi từng flow.

GPM UI Automator hữu ích để người dùng tự chụp màn hình và dò XPath, nhưng không cung cấp API để Codex điều khiển. Khi Codex cần đọc/test UI Android, ưu tiên Appium UiAutomator2 của BoxPhone V3. XPath native đọc accessibility/UI hierarchy chứ không đọc HTML DOM; khi app không expose semantic accessibility thì chuyển sang Image Search hoặc screenshot/OCR.

## 3. BoxPhone qua ADB

| Mục | Giá trị |
| --- | --- |
| Fleet UI | `http://127.0.0.1:8080/` |
| Runtime status | `GET http://127.0.0.1:8080/api/runtime` |
| Thiết bị đang thấy | `GET http://127.0.0.1:8080/api/devices` |
| UI driver ưu tiên | Appium UiAutomator2 tại `127.0.0.1:4723`, chỉ dùng khi `/api/runtime` báo `ready` |
| ADB khả dụng | `C:\Users\phudinh\AppData\Local\Programs\xiaowei_android\tools\adb.exe` |
| ADB server ports | `5037` và `5038` |
| Trạng thái đã xác minh | Fleet API trả 20 thiết bị `online`; luôn đọc lại trước mỗi thao tác |

Liệt kê thiết bị trên cả hai ADB server:

```powershell
$adbPath = 'C:\Users\phudinh\AppData\Local\Programs\xiaowei_android\tools\adb.exe'
& $adbPath -P 5037 devices -l
& $adbPath -P 5038 devices -l
```

Kiểm tra không thay đổi trạng thái cho một thiết bị lấy từ `/api/devices`:

```powershell
$adbPath = 'C:\Users\phudinh\AppData\Local\Programs\xiaowei_android\tools\adb.exe'
$serial = '<serial-tu-api-devices>'
& $adbPath -P <5037-hoac-5038> -s $serial get-state
& $adbPath -P <5037-hoac-5038> -s $serial exec-out uiautomator dump /dev/tty
```

`/api/devices` là nguồn sự thật hiện tại cho mapping BoxPhone, serial và cổng ADB. Không cố định serial/port từ một lần kiểm tra cũ; không khởi động lại hoặc dừng ADB server 5037/5038, không gửi shell tùy ý, không mở app, đổi proxy hay thay dữ liệu thiết bị nếu chưa có ủy quyền riêng. Khi Appium chưa `ready`, dừng và yêu cầu người dùng bật Appium UiAutomator2; không fallback âm thầm sang GPM UI Automator.

## Trình tự dùng lại

1. Gọi health MikroTik API và đọc Swagger/OpenAPI.
2. Gọi `/api/runtime` và `/api/devices` của BoxPhone Fleet.
3. Xác nhận Appium UiAutomator2 là `ready` nếu cần Codex đọc/test UI.
4. Chọn một canary `online`; dùng Appium để quan sát UI và chỉ chạy thao tác có ủy quyền.
5. Trong GPM UI Automator, người dùng có thể chọn cùng canary để tự dò selector/ảnh tham chiếu.
6. Chỉ sau khi các kiểm tra trên đạt và có ủy quyền mới chạy workflow Phone hoặc thay đổi mạng/proxy.

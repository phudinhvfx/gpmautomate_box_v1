# Box_v1 — Facebook Lite Phone Workflow

Box_v1 là project **GPM Automate Phone** để nghiên cứu và chạy thử automation Facebook Lite trên Android. Project được xây theo hướng an toàn: dùng GPM Automate để tác giả hoá và kiểm chứng node; mọi runtime BoxPhone V3 trong tương lai chỉ tái hiện những bước đã được xác nhận, không chạy trực tiếp GPM Runtime trên cùng một điện thoại.

## Thành phần project

| File | Vai trò |
| --- | --- |
| `info.gpmsln` | Metadata project GPM Phone. |
| `src.gscript` | Main workflow. Main hiện gọi `flow_1`. |
| `flow_0.gscript` | Sandbox để học và test độc lập các node Image Search, Wait element, Touch, Scroll, Press key, Clipboard và Type text. Không phải flow production. |
| `flow_1.gscript` | Canary Facebook Lite: mở app, chờ feed, cuộn 5 lần, tìm icon Like/Comment, trả `$likePos`/`$commentPos`, và có các block touch/đóng panel để test thủ công. |
| `img_*.img64` | Ảnh mẫu đã dán từ Editor cho Image Search. |
| `PHONE_ACTION_RUNBOOK.md` | Runbook tham số, canary và giới hạn của các Phone action. |
| `CONNECTIONS.md` | Ranh giới kết nối giữa GPM Phone, Appium và BoxPhone V3. |

## Trạng thái đã xác nhận

- GPM Automate Editor v3.0.8-stable đã lưu được các Phone action trong project này.
- `flow_1` đã chạy canary trên Device 01: sau năm lượt cuộn, Image Search trả vị trí Like và Comment động.
- Image Search tìm icon theo pixel; nó không đọc HTML DOM, cũng không biết kích thước bubble comment.
- Appium UiAutomator2 là công cụ ưu tiên để Codex quan sát/test UI Android. GPM UI Automator chỉ dùng tương tác thủ công trong Editor, vì không cung cấp API điều khiển cho Codex.

## Cách chạy và test

1. Trong GPM Automate Editor, mở folder `D:\gpm\Box_v1`.
2. Xác nhận Appium UiAutomator2 của BoxPhone V3 đang ở trạng thái **ready** trước khi cần kiểm tra selector/UI bằng Codex.
3. Dùng **Test** để canary một node. Dùng **Run** để chạy Main workflow; Main phải gọi flow đích qua `Call workflow`.
4. Với flow_1, kiểm tra `$likePos` và `$commentPos` sau Image Search. Nếu biến rỗng thì không touch theo tọa độ đó.
5. Khi mở Comment panel, ưu tiên `Press key: Back` để đóng. Các thao tác touch/scroll theo tọa độ chỉ là fallback đã test trên Device 01 cùng độ phân giải.

## Safety boundary

- Không chạy đồng thời GPM Automate Runtime và runtime BoxPhone V3 trên cùng một phone.
- Không coi selector XPath native hoặc Image Search là bằng chứng semantic kiểu Chrome DOM/CDP.
- Không hard-code tọa độ feed/Comment cho production; phải visual rediscover theo màn hình hiện tại.
- Nếu không chắc chắn Like/Comment đã xảy ra, dừng và ghi nhận trạng thái thay vì lặp thao tác.
- Tài liệu có thể ghi nhận canary lịch sử; trước thao tác thiết bị thật luôn kiểm tra lại mapping device, Appium và màn hình hiện tại.

## Hướng BoxPhone V3 sau này

BoxPhone V3 có thể tái hiện các bước Phone đã xác nhận bằng JavaScript allowlist thông qua scheduler chung. Với bubble comment có chiều cao biến đổi, cần pipeline vision riêng: xác định avatar/tên làm visual anchor, phân đoạn nền bubble xám gần anchor, rồi trả `x,y,width,height`. Chi tiết thiết kế nằm trong `PHONE_ACTION_RUNBOOK.md`.

## Trước khi commit/push

```powershell
ConvertFrom-Json (Get-Content -Raw .\src.gscript) | Out-Null
ConvertFrom-Json (Get-Content -Raw .\flow_0.gscript) | Out-Null
ConvertFrom-Json (Get-Content -Raw .\flow_1.gscript) | Out-Null
git status --short
```

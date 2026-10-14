# Box_v1 — Facebook Lite Phone Workflow

`Box_v1` là project GPM Automate Phone cho Facebook Lite trên Android. Project dùng GPM Automate để xây và kiểm thử workflow; không chạy đồng thời GPM Runtime với BoxPhone V3 trên cùng điện thoại.

## Workflow đang được Main sử dụng

`src.gscript` mở Facebook Lite bằng `flow_0_v2`, đặt pool comment Telex chung, rút quota ngẫu nhiên `1..3` cho từng hoạt động, rồi chọn flow theo quota còn lại. Mỗi flow được gọi đúng quota đã rút.

| Workflow | Vai trò | Kết quả/chính sách chính |
| --- | --- | --- |
| `flow_0_v2` | Mở Facebook Lite và chờ feed. | Mở `com.facebook.lite`, chờ `root_layout`, rồi chờ 1.5–2.5 giây. |
| `flow_1_v2` | Cuộn feed và Like. | Tìm Like theo ảnh, chỉ touch khi có `$likePos`; đợi 5 giây và kiểm tra ảnh Liked. |
| `flow_2` | Comment độc lập. | Random `1..9`; chỉ comment khi bằng `1`. Đọc ngẫu nhiên một dòng Telex, gửi và kiểm tra ảnh post-comment. |
| `flow_3` | Đọc comment. | Tìm Comment, mở panel, cuộn nhỏ hai lần và swipe xuống để đóng. Nếu verify panel thất bại sau khi đã mở, vẫn gửi swipe đóng fallback. |
| `flow_0_v3` | Đưa Facebook về Home. | Tìm ảnh Home và chỉ touch khi `$homePos` có tọa độ. |
| `flow_0_v4` | Recovery độc lập. | Đóng panel nếu ảnh panel có mặt, gọi `flow_0_v3`; nếu không thấy Home, bấm Android Home rồi gọi `flow_0_v2`. |

`flow_0.gscript` và `flow_1.gscript` là sandbox/canary lịch sử. Main không gọi hai file này.

## Ảnh tham chiếu

| Asset | Nguồn | Được dùng bởi |
| --- | --- | --- |
| `img_3.img64` | `symbol_like.png` | Tìm Like. |
| `img_4.img64` | `symbol_liked.png` | Verify Like. |
| `img_5.img64` | Biểu tượng Comment | Mở panel comment. |
| `img_6.img64` | `verify_panelcomment.png` | Verify panel comment và focus input. |
| `img_7.img64` | `symbol_send.png` | Tìm nút Send. |
| `img_8.img64` | `verify_postcomment.png` | Verify comment đã gửi. |
| `img_9.img64` | `symbol_home.png` | Tìm Home Facebook Lite. |

Giữ các file `img_*.img64` cùng thư mục project. Image Search trả về chuỗi `x,y`; không trả bounding box. Không touch khi biến vị trí rỗng.

## Comment Telex

Main đặt `$commentsPath` thành:

```text
D:\docs\comments_warmup.telex.txt
```

`flow_2` dùng `FileReadRandomLine` để lấy một dòng bất kỳ. File phải là Telex ASCII vì `PhoneTypeText` không gửi Unicode tiếng Việt ổn định với Gboard Telex.

Tạo pool Telex từ pool tiếng Việt bằng script:

```cmd
powershell -NoProfile -File "D:\gpm\Box_v1\tools\Convert-CommentsToTelex.ps1" -InputPath "D:\docs\comments_warmup.txt"
```

Nếu máy chặn chạy PowerShell script theo Execution Policy, xử lý chính sách đó theo quy định máy trước khi chạy; không đổi workflow sang Clipboard vì `PhonePasteClipboard` đã không dán ổn định vào ô comment trong Runtime hiện tại.

## Trạng thái và recovery

Mỗi flow con ghi `$flowRunStatus = OK` ở cuối để hỗ trợ đọc log. Phone Runtime chưa chứng minh biến này được trả về Main sau `Call workflow`: log đã cho thấy flow con ghi `OK` nhưng Main vẫn đi vào recovery. Vì vậy Main **không tự gọi** `flow_0_v4` theo biến này.

Khi cần recovery, chạy `flow_0_v4` độc lập. Không chạy `flow_0_v3` khi panel comment còn che màn hình; `flow_0_v4` xử lý điều kiện đó trước.

## Xác nhận hiện có

| Hạng mục | Bằng chứng |
| --- | --- |
| Gửi comment Telex | Đã được người vận hành test thành công. |
| Verify comment sau gửi bằng `img_8` | Đã được người vận hành test thành công. |
| Đóng panel bình thường của `flow_3` | Đã có luồng swipe và verify ảnh sau đóng. |
| Fallback đóng panel khi `img_6` trả `false` | Đã kiểm tra cấu trúc source; cần canary Runtime riêng nếu cần bằng chứng thiết bị. |
| Android `Home` trong `flow_0_v4` | Log Runtime đã ghi node thành công. |
| Home bằng `img_9` | Đã kiểm tra JSON/asset; cần canary Runtime sau lần đổi từ XPath sang ảnh. |

## Kiểm tra trước khi chạy

1. Mở lại project trong Editor sau khi sửa `.gscript`, để tránh state cache.
2. Đảm bảo Facebook Lite đang ở trạng thái phù hợp và ảnh tham chiếu còn khớp giao diện hiện tại.
3. Dùng Test cho node/flow cần canary; đọc giá trị biến trong log.
4. Khi `Image Search` trả rỗng, workflow phải log và bỏ qua touch tương ứng.
5. Dùng Run cho Main sau khi các canary cần thiết đã đạt.

## Tài liệu liên quan

- [PHONE_ACTION_RUNBOOK.md](PHONE_ACTION_RUNBOOK.md): trình tự, biến trạng thái, lỗi thường gặp và checklist kiểm thử.
- [CONNECTIONS.md](CONNECTIONS.md): ranh giới GPM Phone, GPM Runtime và BoxPhone V3.

## Kiểm tra source trước commit

```powershell
Get-ChildItem -LiteralPath 'D:\gpm\Box_v1' -Filter '*.gscript' |
  ForEach-Object { Get-Content -Raw $_.FullName | ConvertFrom-Json | Out-Null }
git -C D:\gpm\Box_v1 diff --check
git -C D:\gpm\Box_v1 status --short
```
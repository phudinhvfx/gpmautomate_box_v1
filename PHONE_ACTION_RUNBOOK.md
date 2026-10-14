# Box_v1 — Phone action runbook

Tài liệu này là sổ tay học action Phone của GPM Automate. Mỗi mục chỉ được
đánh dấu **đã xác nhận** sau khi:

1. Đọc node thật mà Editor đã lưu trong `src.gscript`.
2. Chạy canary trên Device 01 qua GPM Automate.
3. Có hậu kiểm độc lập bằng Appium UiAutomator2 khi khả thi.

Không suy luận type hay `raw_input` từ tên action. GPM UI Automator là công cụ
khảo sát thủ công của người vận hành; tác nhân dùng Appium UiAutomator2 để đọc
và hậu kiểm device.

## Inventory Main workflow

| Thứ tự | Action | type | Trạng thái |
| --- | --- | ---: | --- |
| 1 | Wait element | 120 | Đã có mẫu source; Runtime đã xác nhận lịch sử |
| 2 | Has element | 113 | Đã có mẫu source; Runtime chưa kiểm |
| 3 | Get element data | 112 | Đã có mẫu source; Runtime chưa kiểm |
| 4 | Type text | 111 | Chưa bắt đầu |
| 5 | Press key | 110 | Chưa bắt đầu |
| 6 | Scroll | 108 | Chưa bắt đầu |
| 7 | Start app | 91 | Đã xác nhận cơ bản |
| 8 | Delay | 7 | Đã xác nhận cơ bản |
| 9 | Touch | 107 | Đang tìm hiểu |
| 10 | Stop app | 92 | Đã xác nhận cơ bản |

## 1. Wait element (`type: 120`)

### Schema hiện quan sát

- `type`: `120`
- `display_text`: `Wait element`
- `element_xpath`: `//*[@resource-id='com.facebook.lite:id/root_layout']`
- `raw_input`: `[{"Key":"TIME_OUT","Value":"20"}]`
- `TIME_OUT`: `20` giây
- `output_variable_name`: `null`
- `delay`: `300,600` ms sau khi action hoàn tất
- `continue_on_error`: `false`
- `comment`: `action type 120`

Mẫu mới lưu trong Main workflow ngày 2026-10-14 dùng cùng schema với XPath
Home và timeout 10 giây:

```json
{
  "type": 120,
  "display_text": "Wait element",
  "element_xpath": "/hierarchy/node[1]/node[1]/node[1]/node[1]/node[1]/node[1]/node[3]/node[5]/node[1]",
  "output_variable_name": null,
  "raw_input": "[{\"Key\":\"TIME_OUT\",\"Value\":\"10\"}]"
}
```

### Mục tiêu học

Đã xác minh XPath nằm ở `element_xpath`, còn timeout là `TIME_OUT` trong
`raw_input`. Cần tiếp tục xác minh ý nghĩa log thành công/thất bại và hành vi
khi hết timeout trên Device 01.

### Canary đề xuất

1. Mở Facebook Lite trên Device 01.
2. Điền một selector native có tính ổn định vào action trong Editor.
3. Chạy khi selector đang có mặt, rồi chạy lần hai với selector không tồn tại.
4. Đọc log GPM và hậu kiểm UI bằng Appium.

### Bằng chứng Appium hiện có

Sau khi mở Facebook Lite trên Device 01, UiAutomator2 nhìn thấy các resource id
`com.facebook.lite:id/root_layout` và `com.facebook.lite:id/main_layout`.
Tree hiện không lộ node semantic cho Like/post, nên chúng không được dùng làm
selector của canary này.

### Trạng thái

**Đã xác nhận Runtime Phone (log do người vận hành cung cấp).**

Log lúc `10:45:33` bắt đầu test, action `PhoneWaitElement` hoàn tất lúc
`10:45:36`, sau đó test hoàn thành. Selector đã được tìm thấy thành công trong
khoảng ba giây, sớm hơn giới hạn `TIME_OUT = 20` giây. Điều này xác nhận action
trả về khi element xuất hiện, không chờ cố định đủ 20 giây.

Log không nêu target device, nên không gắn kết quả này với một serial cụ thể.

## 1a. Has element (`type: 113`)

### Mẫu source lưu từ Phone Editor (2026-10-14)

Node mẫu trong Main workflow có cấu trúc:

```json
{
  "type": 113,
  "display_text": "Has element",
  "element_xpath": "/hierarchy/node[1]/node[1]/node[1]/node[1]/node[1]/node[1]/node[3]/node[5]/node[1]",
  "output_variable_name": "output variable name",
  "raw_input": null
}
```

Khi dùng, điền tên biến không có ký tự `$`, ví dụ `homeExists`. Dùng biến này ở node điều kiện tiếp theo, ví dụ `$homeExists = "true"`.

`output variable name` trong node mẫu chỉ là nội dung minh họa của Editor; không phải tên biến bắt buộc. Schema source đã được xác nhận. Giá trị Runtime trả về và nhánh không tìm thấy vẫn cần một lần chạy canary để xác nhận.

## 1b. Get element data (`type: 112`)

### Mẫu source lưu từ Phone Editor (2026-10-14)

Node mẫu trong Main workflow có cấu trúc:

```json
{
  "type": 112,
  "display_text": "Get element data",
  "element_xpath": "/hierarchy/node[1]/node[1]/node[1]/node[1]/node[1]/node[1]/node[3]/node[5]/node[1]",
  "output_variable_name": "output variiable name",
  "raw_input": "[{\"Key\":\"ATTR_NAME\",\"Value\":\"atrribute name\"}]"
}
```

Điền tên thuộc tính Android cần đọc vào `ATTR_NAME` và tên biến nhận dữ liệu vào `output_variable_name`. Hai chuỗi `output variiable name` và `atrribute name` giữ nguyên theo mẫu Editor, chỉ là placeholder có lỗi chính tả; khi viết flow cần thay bằng giá trị thật. Schema source đã được xác nhận, còn thuộc tính hỗ trợ và giá trị Runtime trả về chưa được kiểm chứng trên thiết bị.

## 2. Touch (`type: 107`)

### Property đã quan sát trong Editor

- **Touch type** có hai kiểu target:
  - `Touch by XPath`: nhập selector ở ô **XPath**.
  - `Touch by coordinates`: nhập một cặp **Coordinates (x,y)**.
- **Touch mode** có ba kiểu thao tác: `Normal` (một chạm), `Double` (chạm đôi), và
  `Hold` (nhấn giữ 1 giây).

Source đã lưu sau khi thử chọn `Touch by coordinates` và `Double` ghi:

```json
[{"Key":"TOUCH_TYPE","Value":"TOUCH_POS"},{"Key":"XPATH","Value":""},{"Key":"POS","Value":""},{"Key":"MODE","Value":"Double"}]
```

Điều này xác nhận tên key của dạng tọa độ, nhưng `POS` đang trống nên đây chưa phải node
đủ cấu hình để chạy. `element_xpath` cũ vẫn còn trong object nguồn, vì vậy chỉ giá trị của
kiểu Touch đang chọn mới được coi là target thực tế; không được để node lai giữa XPath cũ và
tọa độ mới rồi suy ra Runtime sẽ chọn cái nào.

### Cấu trúc node XPath đã dùng trong `flow_0`

- `element_xpath`: selector cần chạm.
- `raw_input`: `null`.
- `output_variable_name`: `null`.
- `delay`: `"0,0"`.
- `continue_on_error`: `false`.

### Trạng thái

**Đã xác nhận Runtime Phone cho selector 1 (bằng hậu kiểm trực quan do người vận hành cung cấp).**

Lúc `12:21:23`, `PhoneTouch` với `touch selector 1` bắt đầu; action thành công lúc
`12:21:26`. Người vận hành xác nhận hậu kiểm: node đã thực sự Like bài viết.
Kết quả này xác nhận `Touch` (type `107`) thực thi thao tác chạm trên element XPath
đang khớp, không chỉ báo thành công giả.

Selector 1 là XPath tuyệt đối theo vị trí node. Nó chỉ phù hợp làm canary khi giữ nguyên
màn hình/bài viết hiện tại; cần đánh giá riêng selector 2 và 3 trước khi dùng lâu dài.

### Trạng thái cần xác nhận tiếp

Canary trước chỉ xác nhận `Touch by XPath` với thao tác Normal. Chưa có bằng chứng Runtime
cho `Touch by coordinates`, truyền biến tọa độ `$imagesearch`, Double, hoặc Hold. Thứ tự test
an toàn: tọa độ cố định trên vị trí vô hại → cùng node với `$imagesearch` → sau cùng mới thử
Double/Hold trên một vị trí không làm thay đổi trạng thái ngoài ý muốn.

## 2a. Scroll (`type: 108`)

### Property đã quan sát trong Editor

- `By direction`: chọn một trong bốn hướng `Up`, `Down`, `Left`, `Right`.
- `By points`: nhập `Start position (x,y)`, `End position (x,y)`, và `Duration (ms)`.

Source đã lưu xác nhận schema chung gồm các key:

```json
SCROLL_TYPE, DIRECTION, START_POS, END_POS, DURATION_MS, POS, ACTION_TYPE
```

Khi chọn `By direction`, source dùng `SCROLL_TYPE: "DIRECTION"` và `DIRECTION: "Up"`.
Khi chọn `By points`, source dùng `SCROLL_TYPE: "POINTS"`; ba giá trị `START_POS`,
`END_POS`, `DURATION_MS` đang chờ điền và test Runtime. Các key không áp dụng vẫn được
Editor giữ lại dưới dạng rỗng, nên chỉ đọc các key thuộc Scroll type đang chọn.

### Quy ước khi dùng By points

Điểm đầu/cuối mô tả đường đi của ngón tay, không phải hướng nội dung. Ví dụ, ngón tay vuốt
từ vùng thấp lên vùng cao sẽ làm feed đi xuống để lộ bài mới. Đây là loại nên ưu tiên cho
Facebook Lite vì ta có thể giữ ngón tay ở vùng an toàn của feed, tránh thanh điều hướng hoặc
nút thao tác, và kiểm soát được quãng vuốt bằng vị trí và thời lượng.

## 3. Kết quả selector Like đang thử

| Selector | Bằng chứng Runtime | Kết luận hiện tại |
| --- | --- | --- |
| 1. XPath tuyệt đối `/hierarchy/.../node[2]` | Wait thành công trong khoảng 3 giây; Touch thành công và người vận hành hậu kiểm Like thật. | Hoạt động ở đúng màn hình/bài viết thử nghiệm, nhưng **chưa ổn định** vì phụ thuộc toàn bộ vị trí node. |
| 2. `//node[@class="android.view\\.ViewGroup"]` | Wait hết 20 giây lúc `12:22:47`: element không tìm thấy. | **Không dùng được** trong Runtime hiện tại. Cần thử riêng cú pháp class không escape nếu muốn điều tra tiếp. |
| 3. `main_layout` + class | Wait hết 20 giây lúc `12:32:14`: element không tìm thấy. | **Không dùng được** trong Runtime hiện tại. |

Kết quả selector 1 chỉ chứng minh thao tác chạm ở vị trí đó dẫn đến Like trong canary;
XPath không mang thuộc tính semantic khẳng định node là nút Like.

Hai selector thất bại cùng dùng điều kiện `@class="android.view\\.ViewGroup"`; đây là
nguyên nhân chung đáng nghi nhất. Cần canary chỉ-đọc riêng với class không escape trước
khi rút kết luận về `main_layout`.

## 4. Ranh giới khả năng đọc UI Android

Phone XPath/Appium UiAutomator2 đọc **Android accessibility/UI hierarchy**, không đọc
HTML DOM. Nếu app lộ `text`, `content-desc` hoặc `resource-id`, selector có thể mang ý
nghĩa. Nếu app render nội dung trong custom view mà không expose accessibility semantics,
tree chỉ còn lớp/khung và selector vị trí; không có XPath native nào tự suy ra đây là Like.

Selector 1 của Facebook Lite là **đường dẫn chỉ số node tuyệt đối**. Nó không dùng
`resource-id`, `content-desc`, text, cũng không ở WebView. Nó chạy trong `NATIVE_APP`;
hai resource id quan sát được (`root_layout`, `main_layout`) chỉ là container và không có
trong selector 1.

Chỉ khi Appium liệt kê thêm một context `WEBVIEW_*` mới có thể chuyển sang web context
và đọc DOM/CDP kiểu Chrome. Trong lần quan sát Facebook Lite hiện tại chỉ có `NATIVE_APP`.
TikTok và Threads phải kiểm tra theo từng phiên bản app, màn hình và device; không thể
suy ra từ Facebook Lite rằng chúng chắc chắn cũng nghèo semantic, hoặc chắc chắn có DOM.

Không thể có dữ liệu tương đương DOM/CDP nếu app chỉ lộ `NATIVE_APP`: DOM đơn giản là
không phải giao diện mà driver đang điều khiển. Chỉ một `WEBVIEW_*` debuggable mới mở
được đường chuyển context sang ChromeDriver/CDP. Các phương án còn lại là accessibility
tree tốt hơn do app expose, hoặc screenshot/OCR; OCR đọc pixel, không biến node thành DOM.

## 5. Nhóm Image search — Property schema quan sát từ Editor

| Type | Action | Field hiển thị | Mục đích đã xác nhận |
| --- | --- | --- | --- |
| 31 | Wait to image | Image, Timeout (s), Threshold, True color | Chờ ảnh mẫu xuất hiện; timeout sẽ fail nếu không có ảnh. |
| 32 | Image exists | Image, Threshold, True color, Output Variable Name | Kiểm tra ảnh mẫu tại thời điểm hiện tại và ghi boolean `true`/`false` vào biến. |
| 33 | Image search | Image, Threshold, True color, Output Variable Name | Tìm ảnh mẫu và ghi tọa độ `x,y` vào biến; không thấy thì biến rỗng. |
| 83 | Image to Base64 | Image file, Output Variable Name | Mã hóa file ảnh thành chuỗi Base64; không tìm ảnh trên màn hình. |

`Image` cho phép dán ảnh từ clipboard hoặc chọn file; `Threshold` mặc định `0.7`;
`True color` mặc định `No`. Tên biến output nhập không kèm dấu `$`; khi tham chiếu ở
node sau mới dùng `$tenBien`. Ý nghĩa chính xác của `True color` và định dạng kết quả
search phải xác nhận bằng test Runtime, không suy đoán từ nhãn property.

`Image to Base64` là action khác nhóm với ba action còn lại: trường **Image file** nhận
đường dẫn của một file ảnh đã tồn tại trên máy, nên Editor không hiện nút chọn/dán ảnh từ
clipboard. Node `type: 83` đang để trống có `raw_input: null`, vì vậy tên key lưu trong
source chỉ nên chốt sau khi nhập một đường dẫn và lưu. Nó không cần thiết cho chuỗi tìm/click
icon trên điện thoại; chỉ dùng khi một node khác cần nội dung ảnh ở dạng chuỗi Base64.

### Wait to image (`type: 31`) — schema và canary đã xác nhận

Sau khi dán crop icon Like, source lưu chính xác:

```json
[{"Key":"IMG","Value":"img_3.img64"},{"Key":"TIME_OUT","Value":"5"},{"Key":"THRESH_HOLD","Value":"0.8"},{"Key":"TRUE_COLOR","Value":"No"}]
```

Log Runtime lúc `15:23:31` chạy `ImageWait` với `img_3.img64`, trả `True` lúc
`15:23:32` và hoàn tất thành công. Điều này xác nhận ảnh mẫu được nhận và tìm thấy trong
bối cảnh test hiện tại, sớm hơn timeout 5 giây. Node không có ô Output Variable Name;
`$True` trong log là kết quả Runtime quan sát được, chưa phải bằng chứng về biến có thể
dùng ở node tiếp theo.

### Image exists (`type: 32`) — schema và canary đã xác nhận

Source sau khi test `symbol_liked`:

```json
{
  "output_variable_name": "symbol_liked",
  "raw_input": "[{\"Key\":\"IMG\",\"Value\":\"img_4.img64\"},{\"Key\":\"THRESH_HOLD\",\"Value\":\"0.8\"},{\"Key\":\"TRUE_COLOR\",\"Value\":\"No\"}]"
}
```

Log lúc `15:29:27` ghi `$symbol_liked = true` khi icon Liked hiện diện. Canary âm lúc
`15:31:54` ghi `$symbol_liked = false` khi icon này không có. Như vậy action kiểm tra tức
thời và ghi boolean `true`/`false` vào biến output; không có timeout. Đây là đủ bằng chứng
Runtime cho gate chống Like lặp; cú pháp điều kiện GPM cụ thể vẫn nên được test khi kéo node
If vào workflow.

### Image search (`type: 33`) — canary tọa độ đã xác nhận

Với icon Like đang hiện diện, Runtime trả:

```text
$imagesearch = 207,1442
```

Với `img_4.img64` không hiện diện, Runtime vẫn hoàn tất thành công nhưng trả:

```text
$imagesearch =
```

Do đó `Image search` không phải action click: nó chỉ tìm trên ảnh màn hình và xuất ra vị trí
theo định dạng `x,y`. Khi không thấy, kết quả là chuỗi rỗng, không phải `false` và cũng không
phải lỗi. Tọa độ này là dữ liệu đủ để truyền sang một action touch có hỗ trợ tọa độ, nhưng cần
test riêng cách action touch nhận biến `$imagesearch` trước khi đưa vào Main workflow.

### Crop ảnh tham chiếu cho Facebook Lite

- Không crop cả pill button vì số lượt Like/Comment thay đổi theo bài viết.
- Crop icon bất biến cùng khoảng 4–6 px nền pill xung quanh, không lấy chữ số phía bên phải.
- Trên mẫu 367×43 hiện có: Like khoảng `x=31..55, y=7..31`; Comment khoảng
  `x=157..181, y=7..31`. Đây chỉ là vùng minh họa cho ảnh mẫu cùng kích thước, không
  phải tọa độ click để tái sử dụng trên feed.
- Lấy crop từ screenshot gốc của Device 01, không resize hoặc nén qua ứng dụng khác.
- Like có ít nhất hai trạng thái hình ảnh (chưa Like / đã Like), nên cần file crop riêng
  cho mỗi trạng thái nếu workflow phải nhận ra cả hai. Comment thường dùng một mẫu.

## 6. Mẫu `flow_1` — cuộn rồi trả vị trí Like/Comment

`flow_1.gscript` hiện có một mẫu: mở Facebook Lite, chờ `root_layout`, đợi feed, rồi For từ
`0` đến `5`. Mỗi lượt tạo ngẫu nhiên điểm vuốt trong
vùng trung tâm an toàn của màn hình 1440×2960: đầu `x=520..920, y=2350..2550`; cuối
`x=520..920, y=1150..1350`; thời lượng `450..700` ms. Sau mỗi lượt chờ `1200..1800` ms.

Hai node Image search cuối flow trả:

- `$likePos` dùng `img_3.img64`;
- `$commentPos` dùng `img_5.img64`.

Đã đối chiếu nội dung ảnh: `img_3.img64` chính là `D:\capture\symbol_like.png`, còn
`img_5.img64` chính là `D:\capture\symbol_comment.png`. Nếu không thấy ảnh, biến tương
ứng sẽ rỗng.

Canary Runtime lúc `16:11:37` dừng ở node thứ hai, `PhoneWaitElement` (`type: 120`): sau
20 giây selector `//*[@resource-id='com.facebook.lite:id/root_layout']` không được tìm thấy.
Vì vậy Delay, For/Scroll và hai Image search **chưa hề chạy**. Log không đủ để kết luận Start
app không chạy; cần quan sát màn hình thực tế sau Start app trước khi thay selector hoặc đổi
chiến lược chờ.

### Phân biệt Run và Test — đã xác nhận từ source

`Run` khởi chạy **Main workflow** trong `src.gscript`, không tự chạy file con `flow_1.gscript`.
Main hiện bắt đầu bằng `Wait element root_layout`; node Start app của Main đứng tận vị trí thứ
tám nên không bao giờ tới được khi Wait đầu tiên fail. `flow_1` có Start app ở node đầu tiên,
vì vậy **Test** riêng node đó mở Facebook Lite thành công lúc `16:17:54`, nhưng điều này không
chứng minh Run đã đi qua flow_1. Muốn chạy cả flow_1 bằng Run phải đặt node `Call workflow`
từ Main tới flow_1, hoặc chuyển/mở đầu Main bằng flow mong muốn.

Sau khi Main gọi flow_1, Runtime lúc `16:23:12` đã đi hết flow: Start app, Wait element,
năm lượt `PhoneScroll`, rồi Image search trả `$likePos = 192,1312` và
`$commentPos = 716,1311`. Hai node cuối flow sau đó được thêm để test thủ công:

- `Touch by coordinates`, `POS: $likePos`, `MODE: Normal`;
- `Touch by coordinates`, `POS: $commentPos`, `MODE: Normal`.

Các node Touch dùng biến động theo lần Image search mới nhất, không hard-code hai tọa độ
trong log. Chúng chưa có bằng chứng Runtime/hậu kiểm riêng.

## 7. Phone - Action: Press key và Type text

Thông tin dưới đây được đọc trực tiếp từ Property của GPM Automate Editor v3.0.8-stable
trên Box_v1 ngày 2026-10-12.

### Press key (`type: 110`)

Property chỉ có một tham số nghiệp vụ:

- `Key`: tên phím Android cần gửi, ví dụ `Back` để đóng comment panel.

Ngoài ra là các thuộc tính chung của node: `Delay after completion (ms)` và
`Continue on error`. Không có XPath, tọa độ, hay thời gian giữ phím.

`Back` đã được xác minh bằng Appium UiAutomator2 trên Device 01: khi panel Comment đang
mở, nó đóng panel và ô `Write a comment...` biến mất. Cần test riêng trong GPM Runtime sau
khi điền `Back` để xác nhận cách Runtime serialize/tên phím trên phiên bản Editor này.

### Type text (`type: 111`)

Property có năm tham số:

- `XPath`: ô nhập native cần nhận văn bản;
- `Text`: nội dung hoặc biến văn bản cần nhập;
- `Min delay (ms)`: độ trễ tối thiểu giữa các ký tự;
- `Max delay (ms)`: độ trễ tối đa giữa các ký tự;
- `Delay after completion (ms)`: độ trễ sau khi nhập xong.

Node cũng có `Continue on error` và `Note`. `Min delay`/`Max delay` là thời gian gõ từng
ký tự, khác với `Delay after completion` là thời gian chờ sau toàn bộ thao tác. Với Facebook
Lite, chỉ điền XPath sau khi UI dump cho thấy một ô nhập có nghĩa; không dùng XPath cố định
từ feed vì app có nhiều custom UI không expose semantic selector.

## 8. Đóng panel Comment Facebook Lite — ba phương án đã test trên Device 01

Trong màn hình 1440×2960 đã test bằng Appium UiAutomator2, panel Comment lộ ô
`Write a comment...` (native class `android.widget.MultiAutoCompleteTextView`). Cả ba thao
tác dưới đây đều làm ô này biến mất, tức panel đã đóng:

1. `Press key` với `Key: Back` — ưu tiên dùng trong workflow vì không phụ thuộc tọa độ;
2. `Touch by coordinates` tại `360,300` — chạm nền bị làm tối phía trên panel;
3. `Scroll by points` từ `720,450` đến `720,1750`, duration `650` ms — vuốt xuống từ tay
   nắm ở đầu panel.

Tọa độ 2 và 3 chỉ là fallback cho màn hình Device 01 cùng độ phân giải và trạng thái panel
đã mở. Chúng không thay thế Image Search để tìm nút Comment, vì vị trí nút này đổi theo feed.

`flow_1.gscript` có ba Normal block cuối để test nối tiếp: block Back chờ panel đang mở rồi
đóng; hai block sau tự touch lại `$commentPos`, chờ `600..800` ms, rồi lần lượt chạm nền và
vuốt xuống. Khi chọn hành vi sản xuất, giữ **một** phương án (khuyến nghị Back), không cần
để cả ba block cùng chạy.

## 9. Hướng Box V3: phân đoạn bubble Comment bằng ảnh

### Ranh giới năng lực

GPM Automate Phone hiện có Screenshot, Image Search và Touch. Image Search trả vị trí một
ảnh mẫu theo dạng `x,y`; nó **không** trả `width,height`, không đọc chữ OCR và không tự tách
bubble comment có kích thước biến đổi. Vì vậy không thể dùng riêng GPM Phone để lấy chính xác
vùng comment chỉ từ avatar/tên khi nội dung có thể ngắn, dài, xuống dòng, emoji hoặc ảnh.

Box V3 runtime có thể bổ sung một bước xử lý ảnh riêng sau khi đã lấy screenshot. Mục tiêu là
trả bounding box của bubble comment:

```text
x, y, width, height
```

### Pipeline đề xuất

1. Tìm avatar hoặc tên đã biết bằng visual anchor, lấy điểm neo.
2. Trong vùng lân cận bên phải/dưới neo, phân đoạn các vùng nền bubble màu xám.
3. Chọn bubble gần nhất, cùng hàng hoặc nằm ngay dưới neo; trả bounding box.
4. Dùng box để crop screenshot làm bằng chứng hoặc làm vùng đầu vào cho bước kiểm tra tiếp
   theo.

Không suy kích thước từ độ dài text. Bubble phải được nhận diện từ ảnh hiện tại vì text có thể
wrap dòng và Facebook Lite thay đổi layout theo nội dung.

### Safety / fallback

- Chỉ chấp nhận box khi phù hợp với avatar/tên neo và độ tin cậy đủ cao.
- Khi không xác định được chắc chắn, lưu screenshot hoặc trạng thái `UNCONFIRMED`, rồi bỏ qua;
  không touch vào bubble hoặc nút lân cận.
- Tọa độ/threshold phải gắn với độ phân giải, theme và phiên bản app đã test; luôn visual
  rediscover sau khi đổi thiết bị hoặc giao diện.
- Đây là hướng thiết kế Box V3 tương lai, **chưa phải** tính năng đã triển khai hay đã kiểm
  chứng Runtime.

## 10. Traceability: source, canary và tài liệu

| Hạng mục | Nguồn chính | Trạng thái |
| --- | --- | --- |
| Main workflow | `src.gscript` | Gọi `flow_1` qua `Call workflow`; không tự chạy file flow rời. |
| Sandbox node | `flow_0.gscript` | Dùng để test từng action/selector; không dùng làm production flow. |
| Facebook Lite canary | `flow_1.gscript` | Đã có canary mở app, cuộn, tìm `$likePos`/`$commentPos` và test touch/đóng comment. |
| Ảnh tham chiếu | `img_*.img64` | Là asset source của Image Search; phải giữ cùng project khi clone/mở lại. |
| Tổng quan dự án | `README.md` | Mô tả cấu trúc, quy tắc chạy và safety boundary. |
| Kết nối/runtime | `CONNECTIONS.md` | Mô tả GPM UI Automator, Appium UiAutomator2 và BoxPhone V3; luôn kiểm tra live trước canary. |

Khi chỉnh trực tiếp source, đóng/mở lại Editor trước khi test để tránh dùng state đang cache. Trước commit, parse toàn bộ `.gscript` như JSON và không commit `.gpmconfig`, `.gpmlaunch`, screenshot tạm hoặc dữ liệu nhạy cảm.

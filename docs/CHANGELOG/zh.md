# 更新日志

## 1.17.2+95

**🌐 本地化**

- 更新阿拉伯语翻译，感谢 abdelbasset jabrane 在 Weblate 的贡献。
- 更新乌克兰语翻译，感谢 Максим Горпиніч 在 Weblate 的贡献。

**🧹 其他**

- Flutter 版本升级到 v3.29.3 (#315)
- 升级依赖包 (#316)
  - 升级 `share_plus` 到 11.1.0（主版本更新）
  - 升级 `data_saver` 到 0.4.0（主版本更新）
  - 升级 `fl_chart` 到 1.0.0（主版本更新）
  - 升级 `copy_with_extension_gen` 到 v6（主版本更新）

**📝 文档**

- 添加 [Github Wiki](https://github.com/FriesI23/mhabit/wiki) (#312, #313)

## 1.16.22+91

**✨ 新功能**

- 删除习惯时显示 UI 反馈（#303）

**🌐 本地化**

- 更新阿拉伯语翻译，感谢 abdelbasset jabrane 在 Weblate 上的贡献。
- 更新俄语翻译，感谢 Yurt Page 在 Weblate 上的贡献。
- 更新乌克兰语翻译，感谢 PavloPogonets 在 GitHub 上的贡献。

**🧹 其他**

- 增加 Flatpak 支持（#304）
- 更新依赖项（#306）
- 为提交到 Flathub 做准备（#307）

**📝 文档**

- 加强了 Linux 的构建说明

## 1.16.20+89

**🌐 本地化**

- 修复英文本地化中的拼写错误，感谢 PavloPogonets 在 GitHub 上的贡献。
- 更新阿拉伯语翻译，感谢 abdelbasset jabrane 在 Weblate 上的贡献。
- 更新乌克兰语翻译，感谢 Максим Горпиніч 在 Weblate 上的贡献。
- 再次更新乌克兰语翻译，感谢 PavloPogonets 在 GitHub 上的贡献。

**🧹 其他**

- 处理部分 WebDAV 服务器缺失 `getetag` 属性导致的问题（#298）
- 修复飞行模式下的同步问题（#295）
- 确保 ARB 文件以换行符结尾

**📝 文档**

- 增加 WebDAV 同步的配置示例（#292）
- 更新 `README.md`

## 1.16.17+86

**✨ 新功能**

- 添加网络同步通知（#287）
  - 为 Android / iOS / macOS / Windows / Linux 添加网络同步通知
  - 为非 Android 平台添加应用内通知配置

**🌐 本地化**

- 更新俄语翻译，感谢 Yurt Page 在 Weblate 上的贡献。
- 更新土耳其语翻译，感谢 Bora Atıcı 和 Soykan Aydın 在 Weblate 上的贡献。
- 更新乌克兰语翻译，感谢 PavloPogonets 在 Github 上的贡献。

## 1.16.14+83

**✨ 新功能**

- 增强 WebDAV 同步功能：当启用自动同步时，在某些场景下触发同步（#278）：
  - 减少启动后自动同步的延迟时间；
  - 添加异步防抖工具代码；
  - 应用切换到后台一段时间后再次切回前台时重新同步；
  - 习惯状态变化后重新同步；
  - 习惯记录变更后重新同步；
- 在应用中添加隐私声明。
- **[iOS]** 在 App Store 构建中隐藏“捐赠”选项。

**🌐 本地化**

- 更新阿拉伯语翻译，感谢 abdelbasset jabrane 在 Weblate 上的贡献。
- 更新俄语翻译，感谢 Bora Yurt Page 在 Weblate 上的贡献。
- 更新西班牙语翻译，感谢 Óscar Fernández Díaz 在 Weblate 上的贡献。
- 更新乌克兰语翻译，感谢 Максим Горпиніч 在 Weblate 上的贡献。
- 更新乌克兰语翻译，感谢 Preck757 在 GitHub 上的贡献。（#281）
- 更新贡献者文件。
- 添加希伯来语支持（待翻译），来自 elid 在 Weblate 上的请求。

**🧹 其他**

- 从 `flutter_markdown` 迁移到 `markdown_widget`，从 [#162966](https://github.com/flutter/flutter/issues/162966) 获取更多信息。（#272）
- 重构通知相关代码（#275）：
  - 为 Android 通知 Channel 添加本地化支持。
  - 升级 `flutter_local_notifications` 到 v19。
  - 添加对 Windows 通知的支持（功能受限）。
- **[Android]** 设置 `AppDebugger` 通知为持续显示（ongoing）。
- **[iOS]** 在应用中添加中国地区 IPC（仅限 zh-cn 本地化）。

**📝 文档**

- 更新 README 文件。

## 1.16.10+78

**🍎 iOS**

- 支持 iOS 应用语言偏好。

**📝 文档**

- 添加隐私政策文件。

## 1.16.9+77

**🐛 BUG 修复**

- 在 iOS 上加载应用后显示通知栏
- 在重新计算习惯记录 UUID 时处理重复的 UUID（#269）

**🌐 本地化**

- 更新西班牙语翻译，感谢 Patricio Carrau 在 Weblate 上的贡献。

**🧹 其他**

- chore：升级依赖项（#267）

## 1.16.7+74

**✨ 新功能**

- 添加 iOS 和 Android 启动屏幕图片。
- 默认启用应用同步功能（#264）。

**🐛 Bug 修复**

- 选择备份文件后导入未开始的问题（#257）。
- 西里尔字母和表情符号编码错误的问题（#254）。

**🍎 iOS**

- **添加构建 Flavor：**
  - `f_dev`：用于 iOS 开发构建。
  - `f_generic`：用于 iOS 发布构建。
  - `f_store`：用于 iOS App Store 发布构建。
- **生成 Logo 变体：**
  - 深色版
  - 淡色版
  - [更多信息](https://developer.apple.com/design/human-interface-guidelines/app-icons#iOS-iPadOS)
- **CI：**
  - 添加 iOS 发布 CI（生成未签名 IPA 文件）。

**🍏 macOS**

- **添加构建 Flavor：**
  - `f_dev`：用于 macOS 开发构建。
  - `f_generic`：用于 macOS 发布构建。

**🪟 Windows**

- 修复 Windows MSIX 打包问题（#261）。

**🌐 本地化**

- 更新西班牙语本地化翻译，感谢 Patricio Carrau 在 Weblate 上的贡献。

**📝 文档**

- 更新 **README.md** 中 iOS / macOS 的构建说明。
- 更新 **README.md** 中 iOS Testflight 的说明。
- 更新 **add_new_locale_support.md**。

## 1.16.3+70

**✨ 新功能**

- 添加 WebDav 网络同步功能（实验性）。
- 添加自动同步功能。
- 添加实验性功能开关。

> **警告**：WebDav 网络同步会修改数据库字段。
> 请务必先使用 **“导出”** 功能备份当前习惯数据。
>
> **警告**：此功能为实验性，可能包含恶性 BUG。
> 使用时请谨慎操作。

1. 前往 `设置 -> 实验性功能` 并启用 `"习惯云同步"` 以显示该功能入口。
2. 前往 `设置 -> 同步选项` 启用并配置新的服务器。
3. 点击 `立即同步` 或在主页下拉以与服务器同步，同步进度将在设置中显示。

如遇 BUG，请描述当前网络环境，并导出对应的（或全部）同步失败日志。

**🐛 BUG 修复**

- 删除习惯后显示正确的底部提示信息。（#247）
- 修复开始日期早于今天的习惯时，分数计算错误的问题。（#248）
- **“全选”** 仅选择当前可见的习惯。（#249）
- （Android）明确声明网络权限。
- （Android）移除不必要的 `READ_EXTERNAL_STORAGE` 权限。

**🌐 本地化**

- 更新俄语翻译，感谢 Bora Yurt Page 在 Weblate 上的贡献。
- 更新乌克兰语翻译，感谢 Максим Горпиніч 在 Weblate 上的贡献。

## 1.15.8+66

- 更新繁体中文翻译，感谢 Peter Dave Hello 在 GitHub 上的贡献。
- 更新土耳其语翻译，感谢 Bora Atıcı 在 Weblate 上的贡献。
- 更新波兰语翻译，感谢 Bartek Skrzypek 在 Weblate 上的贡献。
- 为 `Proxy` 设计模式相关类添加代码生成器/注解（#228）。
- 确保 `firstday` 配置应用到日历选择（#222，#228）。
- 导出时也导出跳过原因（#227）。
- 修复数据库操作中的若干问题：
  - 自定义 SQL 中的变量名拼写错误。
  - 使用正确的字段类型：`Record.reason`。
  - 在插入多条记录时使用 "update" 而不是 "replace"。
  - 插入多条记录时使用事务。
- 修复批量习惯更改页面中无法修改今天状态的问题。
- 修复页面初始化时 `loadData` 被执行多次的问题（#230）。

## 1.15.4+62

- 本地化：添加捷克语翻译，感谢 Jirka Čapek 在 Weblate 上的贡献。
- CI：标准化翻译 ARB 文件。
- CI：添加代码检查的 GitHub Action。

## 1.15.3+61

- 升级 `flutter` 版本到 3.24.5。
- 升级依赖版本。
- 将 `file_picker` 迁移到 `file_selector`。
- 统一跨平台的 `saveFile` 和 `shareXFiles` 功能实现：
  - Windows / MacOS / Linux 平台使用 `saveFile`。
  - Android / iOS（含 iPadOS）平台使用 `shareXFiles`。
- 优化页面返回逻辑实现。
- 修复 `Frequency` 和 `Target Days` 选项中 `TextField` 文本下沉的问题。
- 修复 iPadOS 中显示页面的习惯导出功能。
- 修复 Linux 上多个与导出相关的功能。

## 1.14.4+57

- 从安卓去除 `DependenciesInfo` 块, 解决 [#205](https://github.com/FriesI23/mhabit/issues/205).

完整的更新内容详见：[release.md](https://github.com/FriesI23/mhabit/blob/v1.14.4%2B57/docs/release.md)

## 1.14.3+56

- 添加 Windows MSIX 安装程序。
- 在应用启动期间崩溃时添加单独的错误页面。
- 修复部分 `Completer` 使用不当的问题。
- 将调试日志路径更改为 `Cache` 目录。
- 将数据库路径 （非安卓平台）更改为 `Support` 目录。
- 更新乌克兰语翻译，感谢 Максим Горпиніч 在 Weblate 上的贡献。

**警告**：由于更改数据库路径将涉及文件迁移，强烈建议在升级前备份（导出）习惯数据。

完整的更新内容详见：[release.md](https://github.com/FriesI23/mhabit/blob/v1.14.3%2B56/docs/release.md)

## 1.14.1+54

- 添加土耳其语翻译，感谢 S. Aydın 在 Weblate 上的贡献。
- 更新了 Android 端对应依赖版本。
- 保留 `@mipmap/ic_notification`，以防被 `shrinkResources` 移除，
  详见 [https://stackoverflow.com/a/50703322](https://stackoverflow.com/a/50703322)。

完整的更新内容详见：[release.md](https://github.com/FriesI23/mhabit/blob/v1.14.1%2B54/docs/release.md)

## 1.13.6+52

- 添加波兰语翻译（需要翻译）。
- 添加繁体中文翻译，感谢 PeterDaveHello 在 GitHub 上的贡献。
- 添加乌克兰语翻译，感谢 Fqwe1 在 Weblate 上的贡献。
- 更新西班牙语翻译，感谢 gallegonovato 在 Weblate 上的贡献。
- 更新意大利语翻译，感谢 glemco 在 Weblate 上的贡献。
- 更新波斯语翻译，感谢 ulracte 在 Weblate 上的贡献。
- 更新依赖项版本, 更多信息请参见[此处](https://github.com/FriesI23/mhabit/commit/204922af8eaf0c025739623aad85a12f14cefce5)。

## 1.13.3+49

- 更新西班牙语翻译，感谢 Andres Blasco Arnáiz 和 gallegonovato 在 Weblate 上的贡献。
- 修复从主屏幕返回时黑屏的问题。

完整的更新内容详见：[release.md](https://github.com/FriesI23/mhabit/blob/v1.13.3%2B49/docs/release.md)

## 1.13.1+47

- 升级 Flutter 到 3.19.6 版本。
- 添加西班牙语翻译，感谢 Andres Blasco Arnáiz 在 weblate 上的贡献。

完整的更新内容详见：[release.md](https://github.com/FriesI23/mhabit/blob/v1.13.1%2B47/docs/release.md)

## 1.12.8+45

- 更新翻译文件。（越南语）
- 增加对 Linux 平台的支持。（#174）
- 修复 Github Action 测试报告程序的 HTTP 错误。（#181）
- 升级依赖项的版本。

## 1.12.5+42

- 添加应用内语言切换功能。
- 添加调试日志收集功能。
- 修复：原生 Android 平台上不显示通知图标。
- 修复：本地化批量签到的 `snackbar` 文本。
- 升级依赖项的版本。

## 1.12.2+39

- 添加俄语翻译。 (#169, 感谢 @yurtpage 的贡献)
- 添加意大利语翻译。 (来自 Weblate，感谢 @spar34vi 的翻译)
- 添加对 Windows 支持。 (#164)
- 添加对 macOS 上 dmg 支持。 (#168, 感谢 @rxzheng 的贡献)
- 添加 `pre-release` 版本构建流程。 (#171)
- 修复了通过 `OpenContainer` 导航时, 如果启用 `Tooltips` 会引发异常的问题。 (#166)
- 更新 iOS 依赖版本。
- 优化代码质量。

## 1.12.0+37

- 新增批量打卡功能

长按选择多个习惯后，可以通过点击屏幕右下角的 `FAB` 来访问 `批量打卡` 功能。

## 1.11.1+36

- 添加贡献者页面
- 修复在编辑模式下按返回按钮会退出应用的问题
- 重构与 `db` / `profile` / `provider` / `view` 等相关代码
- `analysis_options.yaml` 中添加相关代码检查选项

**警告**: 强烈建议在更新此版本之前备份。

## 1.11.0+35

- 更新 Dart SDK 依赖 >=3.0.0
- 重构日志模块
- 明确页面中的 `Provider` 依赖
- 移除摘要和详细页面间的依赖关系
- 重写 `context.maybeRead` 方法
- 修复习惯的撤销操作

## 1.10.6+34

- 修复安卓上不提醒的问题（#144）

## 1.10.5+33

- 如果习惯已归档，则冻结分数（#138）
- 修复安卓上不提醒的问题（#140）
- 修复项目中的拼写错误问题（#137）

## 1.10.4+32

- 修复错误的默认语言 (#133)

## 1.10.3+31

- 增加法语翻译 (#130)
- 增加阿拉伯语翻译 (#132)

## 1.10.2+30

- 添加越南语翻译 (#121)
- 更新德语翻译 (#123)
- 修复习惯 Filter (#125)

## 1.10.1+29

- 添加德语翻译
- 增加习惯记录自定义点击操作

## 1.10.0+28

- 升级 Flutter 版本至 3.13.9
- 升级依赖包
- 修改应用发布操作，使用项目中的子模块
- 修复了一些 bug

查看完整变更内容，请参见 [#115](https://github.com/FriesI23/mhabit/pull/115).

## 1.9.2+27

- 优化 捐赠 Dialog (#113)
- 修正 Heatmap 月份名称对齐 (#114)

## 1.9.1+26

- 增加加密货币捐赠按钮（#102）
- 修复筛选正确隐藏已完成习惯（#104）

## 1.9.0+25

- 更换新的应用程序图标 (#92)
- 修复了图表柱可能重叠的问题 (#94)

## 1.8.5+24

- 添加主题图标 (#89)
- 存储上次填写的目标天数 (#88)
- 即使已归档，仍显示已完成习惯 (#87)

## 1.8.4+23

- 修复使用用户输入的值而不是每日目标值计算自动完成数值 (#85)
- 修复在最受欢迎的习惯部分中包含已归档习惯的问题 (#83)
- 修复暗模式下备忘录字符串使用错误的 Markdown 颜色 (#79)
- 修复暗模式下 '?' 和 '×' 按钮颜色不清楚的问题 (#75)

## 1.8.3+22

- 增加“习惯模板”功能
- 重构 `Appbar` 部分代码

## 1.8.2+21

- 增加对波斯语的支持，感谢 @chromer030 的翻译贡献 🎉
- 修复在 RTL 布局下 UI 的显示问题
- 在 `readme` 中添加翻译统计图
- 在发布新版本时按 ABI 拆分 APK，目前仅支持 `GitHub/Releases`
- 优化 CI 脚本的文件组织结构

## 1.8.1+20

- 在习惯详情页面显示备忘录
- 支持在习惯备忘录中使用 Markdown 格式
- 修复编辑页面中正向习惯目标设为 0 的问题
- 修复编辑已存在习惯时不能切换 habitType 的问题

## 1.8.0+19

- 添加负面习惯
- 重构部分代码
- 增加 CI

**重要**：在更新此版本之前，请进行全量备份。

## 1.7.1+18

- 修复总览中显示负数的问题
- 添加新的目标天数选项

## 1.7.0+17

- 在习惯页面上添加紧凑型用户界面
- 添加滑块来调整习惯勾选区域的占比

## 1.6.0+16

- 添加自定义日期时间格式选择弹窗
- 修复创建日期图标的错误使用的问题

## 1.5.1+15

- 修复 FAB 按钮与习惯重叠的问题

## 1.5.0+14

- 添加两个更快改变每日目标数值的按钮

## 1.4.2+13

- 修复主题更改按钮中的拼写错误

## 1.4.1+12

- 修复筛选器错误, [#38](https://github.com/FriesI23/mhabit/issues/38)

## 1.4.0+11

- 添加无记录导出习惯的功能
- 更新`Readme`文档

## 1.3.2+10

- 修复 Fastlane/zh-CN 应用程序标题名称
- 修复一些拼写错误

## 1.3.1+9

- 移除应用程序互联网权限
- 修改 `launchUrl` 模式为外部应用程序
- 升级 `flutter_donation_buttons` 至 0.2.7
- 修改导出习惯使其根据手动排序导出
- 添加自动生成变更日志的 Python 脚本

## 1.3.0+8

- 修复执行 `flutter pub get` 导致 `pubspec.lock` 被修改的问题

## 1.2.5+7

- 将 flutter 引入为 submodule

## 1.2.4+6

- 添加 distributionSha256Sum，详见[此处](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/13058#note_1404993220)

## 1.2.3+5

- 修复 appbundle 构件路径
- 修复应用程序构建签名

## 1.2.2+4

- 修复 Fastlane 的本地化文件夹大小写问题

## 1.2.1+3

- 添加 Fastlane 文件结构
- 添加 Android 应用程序签名

## 1.2.0+2

- 新功能：
  - 在`Heatmap`上添加跳过原因的`Dialog`。
  - 在目标更改`Dialog`中添加“每日最大目标”选项。
  - 在跳过原因和目标更改`Dialog`中添加自定义颜色。
- 修复：
  - 补充部分文本翻译。
  - 整数如`1`不应显示小数点。
- 其他：
  - 更改应用图表样式。

## 1.1.0+1

- 将 `package` 域名更改为 `github.io`

## 1.0.0

- 发布新版本

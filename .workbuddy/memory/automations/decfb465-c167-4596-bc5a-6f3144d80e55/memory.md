# 夜间值守自动化执行记录

## 2026-10-09 01:55 run（第X轮检查）
- run 37815503403 查询结果：completed / **failure**。
- 失败 Job: "Build and upload SideStore (macos-14, 16.1)"；失败 Step: "Build Rust libs without LSE (A10-safe)"。
- 根因：em_proxy 头文件回退下载 URL 为空（`pin-matched em_proxy release not found, falling back to latest` 后 URL 变量未赋值，wget 报 `http://: Invalid host name`，exit 1）。
- 前段 Rust 库编译成功（libem_proxy-ios.a ≈19.7MB），minimuxer 头文件下载解压成功；仅 em_proxy 头文件获取失败。
- 已写 F:/IOS3APP/ios_ctrl/_ss_re/R10_FAIL.md；原始日志 r10_fail_log.txt（630 行）保留。
- 自动化 "SideStore A10 无LSE构建·夜间值守"（id decfb465-c167-4596-bc5a-6f3144d80e55）已按预案 status=PAUSED 自停。未改仓库代码、未动 iPad。
- 待人工：修 workflow 中 em_proxy 头文件 latest 回退 URL 为空的逻辑（比对 minimuxer 分支为何正常），修好后重新触发并恢复值守。

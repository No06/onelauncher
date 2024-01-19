# OneLauncher

试图做一个 All (shit) in one的 Minecraft 启动器

## 自己编译

1. 本项目使用 Flutter + Dart 开发，需安装以下开发环境，或可查阅 [Flutter Get started](https://docs.flutter.dev/get-started) 安装相关工具
   - 所有系统: `flutter`, `git`
   - Windows: `Visual Studio 2022` 及其 `使用 C++ 的桌面开发` 组件
   - MacOS: `Xcode 15`, `CocoaPods`
   - Linux: 建议使用 Ubuntu 22.04, 执行命令安装所需环境
     ```
     sudo apt-get install clang cmake git ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
     ```
3. 打开命令提示符
4. 使用 Git 克隆项目
   ```
   git clone https://github.com/No06/onelauncher.git
   ```
5. 进入项目目录
   ```
   cd onelauncher
   ```
   执行 build_runner 编译
   ```
   dart run build_runner build
   ```
   编译
     - Windows:
       ```
       flutter build windows
       ```
     - Linux:
       ```
       flutter build linux
       ```
     - MacOS: 参阅 [为 macOS 应用构建和发布](https://flutter.cn/docs/deployment/macos)

# Rust

## 安装Rust

### rustup

rustup是什么？ --Rust安装器和版本管理工具

```shell
# 类unix系统
curl https://sh.rustup.rs -sSf | sh
# arch
yaourt -S rustup
rustup install stable
rustup default stable
```

### cargo

cargo是什么？ --Rust 的构建工具和包管理器

您在安装 Rustup 时，也会安装  Cargo。Cargo 可以做很多事情：

- cargo new 开始一个新的项目

- `cargo build` 可以构建项目
- `cargo run` 可以运行项目
- `cargo test` 可以测试项目
- `cargo doc` 可以为项目构建文档
- `cargo publish` 可以将库发布到 [crates.io](https://crates.io)。

### Editor

Rust 支持多种编辑器：

​     [VS Code](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust)        [Sublime Text 3](https://github.com/rust-lang/rust-enhanced)        [Atom](https://github.com/rust-lang/atom-ide-rust)        [IntelliJ IDEA](https://plugins.jetbrains.com/plugin/8182-rust)        [Eclipse](https://www.eclipse.org/downloads/packages/release/2018-12/r/eclipse-ide-rust-developers-includes-incubating-components)        [Vim](https://github.com/rust-lang/rust.vim)        [Emacs](https://github.com/rust-lang/rust-mode)   

您可以用 `rustup component add rustfmt` 安装代码格式化工具 Rustfmt，用 `rustup component add clippy` 安装 lint 工具 Clippy。

## Hello World

安装国际惯例，先来一个Hello World!

### 创建项目

终端执行**`cargo new hello-rust`**生成一个名为hello-rust的HelloWorld项目。其中包含以下文件：

```
hello-rust
|- Cargo.toml
|- src
```

`Cargo.toml` 为 Rust 的清单文件。其中包含了项目的元数据和依赖库。

`src/main.rs` 为编写应用代码的地方。

### 运行项目

```shell
cd hello-rust
cargo run
# 或cargo构建运行
cargo build
./target/debug/hello-rust
# 或rustc编译运行源文件
rustc src/main.rs
./main
```

## 工具

### IntelliJ rust/toml

### Rustfmt - 自动格式化 Rust 代码

```shell
rustup component add rustfmt
cargo fmt
```

### Clippy - 捕获常见错误和并改进你的代码

cargo install clippy

### Cargo Doc
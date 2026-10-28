# skyward-lmi

Redmi K30 Pro（lmi）用的 skyward recovery。

源码在 [kafuzhi/skyward](https://github.com/kafuzhi/skyward) 的 `lmi` 分支（fork 自 kirklin/skyward）。
这个仓库放设备配置和打包脚本。

## 需要的东西

- Rust 工具链和 NDK，`cargo-ndk`
- 底包的 `recovery.img`：取里面的 dtbo、dtb 和 cmdline
- 内核：底包 `boot.img`，或者 anykernel 包里的 `kernels/miui/Image`

内核要用和 ROM 配套的那颗。vendor 分区里的 `.ko` 是按它编译的，vermagic 对不上就加载不了。

ramdisk 用底包 `recovery.img` 自带的（这台机器的 TWRP），刷机脚本要的 busybox、unzip、awk 都在里面。

## 打包

```
git clone -b lmi https://github.com/kafuzhi/skyward
cd skyward
./build.sh <recovery.img> <boot.img 或 Image>
```

输出 `skyward-lmi.img`。用 `fastboot boot` 试，或者 `fastboot flash recovery` 装进去。

## 设备配置

`devices/lmi.toml`：

- 单槽位，分区名没有 `_a/_b` 后缀
- 屏幕 1080x2400，密度 440
- 振动走 aw8697 的 sysfs：index 1、mode 0、40ms
- 起三个 TEE 服务：qseecomd、keymaster@4.0、gatekeeper@1.0
- 触控设备名黑名单：hbtp_vm

## 现在能做什么

刷 zip、刷分区、MTP、截图、导出日志、振动。

可刷的分区：super、system、vendor、product、odm、system_ext、boot、recovery、dtbo、vbmeta、vbmeta_system、modem、cust、logo。

## 现在还不行

WLAN：vendor 里 `qca_cld3_qca6390.ko` 的 vermagic 和手上几颗内核都对不上，而且还需要 `cnss-daemon` 参与固件下载。`lmi.toml` 里留了 `[wlan]` 的样例，目前整段注释着。

真加密设备的解密：lmi 是 keymaster 4.0/4.1 HIDL，上游 skyward 只实现了 KeyMint AIDL。现在只有 `keymaster_hidl.rs` 的骨架（查服务、读 getHardwareInfo），密钥链没写。所以 `/data` 必须是解密包留下的明文 f2fs。

## 关于 vbmeta

不要用空的 vbmeta 去“禁用校验”。这张 bootloader 会直接把系统判为不可启动。
要关校验就用 ROM 作者提供的 `firmware-update/vbmeta.img`，那是带完整 descriptor、只关校验标志的版本。

## 版本

v59 是最新的。v58 里带过一个自己写的「禁用 AVB」功能，已经删掉，别用那个版本。

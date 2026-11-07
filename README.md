# skyward-lmi

umi 家族（SM8250）五个机型的 skyward recovery：lmi（红米 K30 Pro）、umi（小米 10）、cmi（小米 10 Pro）、cas（小米 10 Ultra）、apollo（红米 K30S Ultra）。

源码在 [kafuzhi/skyward](https://github.com/kafuzhi/skyward) 的 `lmi` 分支（fork 自 kirklin/skyward），这里放设备配置、打包说明和发布。

## 镜像怎么做的

每台机型都用自己的底座：

- **ramdisk、dtbo、dtb、cmdline**：该机型 skkk 的 TWRP 镜像（`--stock` + `--custom-ramdisk`）
- **内核**：该机型自己的 FZKernel（`--kernel-blob kernels/miui/Image`）

打包命令：

```
skyward-pack recovery \
  --stock <该机型的 TWRP 镜像> \
  --custom-ramdisk \
  --kernel-blob <该机型内核 Image> \
  --binary target/aarch64-linux-android/release/skyward \
  --config devices/<codename>.toml \
  --font resources/fonts/MiSansVF.ttf \
  --mono resources/fonts/KirkMono-Regular.ttf \
  --mono-license resources/fonts/KirkMono-OFL.txt \
  --out skyward-<codename>.img
```

## 能用 / 不能用

能用：刷 zip、刷分区（super、system、vendor、product、odm、system_ext、boot、recovery、dtbo、vbmeta、vbmeta_system、modem、cust、logo）、MTP（functionfs）、截图、导出日志、振动（aw8697）。

不能用：加密 data 的解密、WLAN、系统更新。

## 关于 MTP

TWRP 把 MTP 绑到内核自带的 `mtp.gs0`，skyward 只走 functionfs，所以打包时会把 TWRP 的 `init.recovery.usb.rc` 里 `functions/mtp.gs0` 全部换成 `functions/ffs.mtp`；运行期若 `/dev/usb-ffs/mtp/ep0` 不在，还会自己挂一次 functionfs。

## 关于 vbmeta

不要用空的 vbmeta 去“禁用校验”，这张 bootloader 会直接把系统判为不可启动。要关校验就用系统作者提供的 `vbmeta.img` / `vbmeta_system.img`，按分区刷进去。

## 版本

- `skyward-v89`：五机型，内核/底座各自对齐
- 更早的单机型版本留在历史 release 里

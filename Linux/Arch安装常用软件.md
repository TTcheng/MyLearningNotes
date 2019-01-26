# archlinux 安装常用windows软件

```shell
# 先添加archlinuxcn源
sudo pacman -Syu # 更新软件包列表
sudo pacman -S netease-cloud-music 	#网易云音乐
sudo pacman -S deepin-wine-foxmail 	#Foxmail邮件客户端
sudo pacman -S deepin-wine-tim		# TIM 
sudo yaourt -S deepin-wechat		# 微信
sudo pacman -S deepin-baidu-pan  	# 百度网盘
sudo pacman -S wps-office  			# WPS
# 如果64位安装失败，在/etc/pacman.conf中启用 Multilib
sudo nano /etc/pacman.conf 
# 去掉Multilib以及其下Server前面的 # 
```


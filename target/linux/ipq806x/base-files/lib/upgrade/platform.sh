PART_NAME=firmware
REQUIRE_IMAGE_METADATA=1

RAMFS_COPY_BIN='fw_printenv fw_setenv'
RAMFS_COPY_DATA='/etc/fw_env.config /var/lock/fw_printenv.lock'

platform_check_image() {
	return 0;
}

platform_do_upgrade() {
	case "$(board_name)" in
	asus,rt-ac58u|\
	asus,rt-acrh17)
		CI_UBIPART="UBI_DEV"
		CI_KERNPART="linux"

		local ubidev=$(nand_find_ubi $CI_UBIPART)
		local jffs2=$(nand_find_volume $ubidev jffs2)
		local linux2=$(nand_find_volume $ubidev linux2)
		[ -n "$jffs2" ] && ubirmvol /dev/$ubidev --name=jffs2
		[ -n "$linux2" ] && ubirmvol /dev/$ubidev --name=linux2
		nand_do_upgrade "$1"
		;;
	linksys,ea8500)
		platform_do_upgrade_linksys "$ARGV"
		;;
	netgear,d7800 |\
	netgear,r7500 |\
	netgear,r7500v2 |\
	netgear,r7800 |\
	qcom,ap-dk04.1-c1 |\
	qcom,ipq8064-ap148 |\
	zyxel,nbg6817)
		nand_do_upgrade "$ARGV"
		;;
	openmesh,a42)
		PART_NAME="inactive"
		platform_do_upgrade_openmesh "$ARGV"
		;;
	tplink,c2600)
		PART_NAME="os-image:rootfs"
		MTD_CONFIG_ARGS="-s 0x200000"
		default_do_upgrade "$ARGV"
		;;
	tplink,vr2600v)
		PART_NAME="kernel:rootfs"
		MTD_CONFIG_ARGS="-s 0x200000"
		default_do_upgrade "$ARGV"
		;;
	*)
		default_do_upgrade "$ARGV"
		;;
	esac
}

platform_nand_pre_upgrade() {
	case "$(board_name)" in
	asus,rt-ac58u)
		CI_UBIPART="UBI_DEV"
		CI_KERNPART="linux"
		;;
	zyxel,nbg6817)
		zyxel_do_upgrade "$1"
		;;
	esac
}

blink_led() {
	. /etc/diag.sh; set_state upgrade
}

append sysupgrade_pre_upgrade blink_led

bin_commondir =		$(bindir)/common
bin_common_DATA =	common/bin/*

bin_common_hwdir =	$(bindir)/common-hw
bin_common_hw_DATA =	common-hw/bin/*

bin_common_vmdir =	$(bindir)/common-vm
bin_common_vm_DATA =	common-vm/bin/*

bin_dell_s6000_hwdir =		$(bindir)/dell-s6000-hw
bin_dell_s6000_hw_DATA =	dell-s6000-hw/bin/*

systemddir =	/lib/systemd

systemd_common_servicedir =	$(systemddir)/system/common
systemd_common_service_DATA =	common/lib/systemd/system/*

systemd_shutdown_dell_s6000dir =	$(systemddir)/system-shutdown/dell-s6000-hw
systemd_shutdown_dell_s6000_DATA =	dell-s6000-hw/lib/systemd/system-shutdown/*

conf_common_modulesdir =	$(sysconfdir)/modules-load.d/common
conf_common_modules_DATA =	common/etc/modules-load.d/*

conf_common_opxdir =	$(sysconfdir)/common/opx
conf_common_opx_DATA =	common/etc/opx/*

conf_dell_s6000_modulesdir =	$(sysconfdir)/modules-load.d/dell-s6000-hw
conf_dell_s6000_modules_DATA =	dell-s6000-hw/etc/modules-load.d/*

conf_dell_s6000_env_tmpctldir =		$(sysconfdir)/opx/dell-s6000/env-tmpctl
conf_dell_s6000_env_tmpctl_DATA =	dell-s6000/etc/opx/env-tmpctl/*

conf_dell_s6000_nasdir =	$(sysconfdir)/opx/dell-s6000/nas
conf_dell_s6000_nas_DATA =	dell-s6000/etc/opx/nas/*

conf_dell_s6000_pasdir =	$(sysconfdir)/opx/dell-s6000/pas
conf_dell_s6000_pas_DATA =	dell-s6000/etc/opx/pas/*

conf_dell_s6000_hw_saidir =	$(sysconfdir)/opx/dell-s6000-hw/sai
conf_dell_s6000_hw_sai_DATA =	dell-s6000-hw/etc/opx/sai/*

conf_dell_s6000_hw_sdidir =	$(sysconfdir)/opx/dell-s6000-hw/sdi
conf_dell_s6000_hw_sdi_DATA =	dell-s6000-hw/etc/opx/sdi/*

conf_dell_s6000_vm_saidir =	$(sysconfdir)/opx/dell-s6000-vm/sai
conf_dell_s6000_vm_sai_DATA =	dell-s6000-hw/etc/opx/sai/*

conf_dell_s6000_vm_sdidir =	$(sysconfdir)/opx/dell-s6000-vm/sdi
conf_dell_s6000_vm_sdi_DATA =	dell-s6000-hw/etc/opx/sdi/*


lib_LTLIBRARIES =	libopx_nas_platform_vm.la libopx_nas_platform_dell_s6000.la

libopx_nas_platform_la_ldflags =	-shared -version-info 1:1:0

libopx_nas_platform_la_cppflags =	-D_FILE_OFFSET_BITS=64 -I$(top_srcdir)/inc/opx -I$(includedir)/opx

libopx_nas_platform_la_cxxflags =	-std=c++11

libopx_nas_platform_vm_la_SOURCES =	dell-s6000-vm/src/hal_npu_platform_init.c

libopx_nas_platform_vm_la_LDFLAGS =	$(libopx_nas_platform_la_ldflags)

libopx_nas_platform_vm_la_CPPFLAGS =	$(libopx_nas_platform_la_cppflags)

libopx_nas_platform_vm_la_CXXFLAGS =	$(libopx_nas_platform_la_cxxflags)

libopx_nas_platform_dell_s6000_la_SOURCES =	dell-s6000-hw/src/nas_ndi_plat_stat.c

libopx_nas_platform_dell_s6000_la_LDFLAGS =	$(libopx_nas_platform_la_ldflags)

libopx_nas_platform_dell_s6000_la_CPPFLAGS =	$(libopx_nas_platform_la_cppflags)

libopx_nas_platform_dell_s6000_la_CXXFLAGS =	$(libopx_nas_platform_la_cxxflags)

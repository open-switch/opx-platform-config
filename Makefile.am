systemddir =	/lib/systemd

# common - Common to all platforms

conf_common_modulesdir =	$(sysconfdir)/modules-load.d/common
conf_common_modules_DATA =	common/etc/modules-load.d/*

conf_common_opxdir =	$(sysconfdir)/common/opx
conf_common_opx_DATA =	common/etc/opx/*

# common-hw - Common to all hardware platforms

bin_common_hwdir =	$(bindir)/common-hw
bin_common_hw_DATA =	common-hw/bin/*

# dell-s6000 - Common to both Dell S6000-ON hardware and VM platforms

conf_dell_s6000_env_tmpctldir =		$(sysconfdir)/opx/dell-s6000/env-tmpctl
conf_dell_s6000_env_tmpctl_DATA =	dell-s6000/etc/opx/env-tmpctl/*

conf_dell_s6000_nasdir =	$(sysconfdir)/opx/dell-s6000/nas
conf_dell_s6000_nas_DATA =	dell-s6000/etc/opx/nas/*

conf_dell_s6000_pasdir =	$(sysconfdir)/opx/dell-s6000/pas
conf_dell_s6000_pas_DATA =	dell-s6000/etc/opx/pas/*

# dell-s6000-hw - Specific to Dell S6000-ON hardware platform

bin_dell_s6000_hwdir =		$(bindir)/dell-s6000-hw
bin_dell_s6000_hw_DATA =	dell-s6000-hw/bin/*

conf_dell_s6000_hw_modulesdir =	$(sysconfdir)/modules-load.d/dell-s6000-hw
conf_dell_s6000_hw_modules_DATA =	dell-s6000-hw/etc/modules-load.d/*

conf_dell_s6000_hw_saidir =	$(sysconfdir)/opx/dell-s6000-hw/sai
conf_dell_s6000_hw_sai_DATA =	dell-s6000-hw/etc/opx/sai/*

conf_dell_s6000_hw_sdidir =	$(sysconfdir)/opx/dell-s6000-hw/sdi
conf_dell_s6000_hw_sdi_DATA =	dell-s6000-hw/etc/opx/sdi/*

systemd_dell_s6000_hw_initdir =	$(systemddir)/system/dell-s6000-hw
systemd_dell_s6000_hw_init_DATA =	dell-s6000-hw/lib/systemd/system/*

systemd_dell_s6000_hw_shutdowndir =	$(systemddir)/system-shutdown/dell-s6000-hw
systemd_dell_s6000_hw_shutdown_DATA =	dell-s6000-hw/lib/systemd/system-shutdown/*

# dell-s6000-vm - Specific to Dell S6000-ON VM platform

conf_dell_s6000_vm_saidir =	$(sysconfdir)/opx/dell-s6000-vm/sai
conf_dell_s6000_vm_sai_DATA =	dell-s6000-hw/etc/opx/sai/*

conf_dell_s6000_vm_sdidir =	$(sysconfdir)/opx/dell-s6000-vm/sdi
conf_dell_s6000_vm_sdi_DATA =	dell-s6000-hw/etc/opx/sdi/*

# NAS plugins (shared libs) for various platforms

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

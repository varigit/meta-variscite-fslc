FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

do_install_append() {
	# This is the set of machine features that the script has markers for
	FEATURES="acpi apm"
	SCRIPT="${S}/sedder"
	rm -f $SCRIPT
	touch $SCRIPT
	for FEAT in $FEATURES; do
		if echo ${MACHINE_FEATURES} | awk "/$FEAT/ {exit 1}"; then
			echo "/feature-$FEAT/d" >> $SCRIPT
		fi
	done

	sed -i -f "$SCRIPT" ${D}/${sysconfdir}/matchbox/session
}

# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
ETYPE="sources"

K_SECURITY_UNSUPPORTED="1"

inherit kernel-2 unpacker

BOARD="rockchip64"
BRANCH="current"
ARMBIAN_VER="22.11.1"
EXTRAVERSION="-armbian-${BOARD}"

BASE_URL="mirror://armbian-packages/pool/main/l"

DESCRIPTION="Armbian kernel sources (${BOARD},${BRANCH})"
HOMEPAGE="https://github.com/armbian/build"
SRC_URI="
	${BASE_URL}/linux-source-${PV}-${BRANCH}-${BOARD}/linux-source-${BRANCH}-${BOARD}_${ARMBIAN_VER}_all.deb -> ${P}.deb
"

SLOT="${PV}"
KEYWORDS="~arm64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

SOURCES_DIR="linux-${PV}-armbian-${BOARD}"
S="${WORKDIR}/${SOURCES_DIR}"

src_unpack() {
	default
	unpacker ${A}

	mkdir "${S}"
	pushd "${S}"
	unpack "${WORKDIR}/usr/src/linux-source-${PV}-${BOARD}.tar.xz"
	popd

	unpack_set_extraversion
}

src_prepare() {
	kernel-2_src_prepare

	# Mainly for testing on amd64
	if use amd64; then
		local ARCH="x86"
	fi

	# Run make mrproper to remove prebuilt binaries
	make mrproper || die "make failed"
}

src_install() {
	kernel-2_src_install

	dodoc "default_linux-${BOARD}-${BRANCH}.config"
}

pkg_postinst() {
	einfo
	einfo "This sources package is designed for single board computers"
	einfo "which use RockChip SOCs (such as the RockPro64)."
	einfo
	einfo "A default kernel config (generated by Armbian) is provided in"
	einfo "${EROOT}/usr/src/${SOURCES_DIR}/default_linux-${BOARD}-${BRANCH}.config"
	einfo "and ${EROOT}/usr/share/doc/${P}/default_linux-${BOARD}-${BRANCH}.config.bz2"
	einfo
	einfo "To use this config simply copy it to ${EROOT}/usr/src/${SOURCES_DIR}/.config"
	einfo
}

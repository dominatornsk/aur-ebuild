# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/xmms/xmms-1.2.10-r16.ebuild,v 1.4 2006/07/05 06:14:10 vapier Exp $

inherit flag-o-matic eutils libtool

PATCH_VER="2.3.1"
M4_VER="1.1"

DESCRIPTION="X MultiMedia System"
HOMEPAGE="http://www.xmms.org/"
SRC_URI="http://legacy.xmms2.org/xmms-1.2.11.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86"
IUSE="nls mmx vorbis mikmod directfb flac"

DEPEND="=x11-libs/gtk+-1.2*"

RDEPEND="${DEPEND}
	directfb? ( dev-libs/DirectFB )
	app-arch/unzip"

#We want these things in DEPEND only
DEPEND="${DEPEND}
	>=sys-devel/automake-1.9
	>=sys-devel/autoconf-2.5
	media-libs/alsa-lib
	sys-devel/libtool
	nls? ( dev-util/intltool
	       dev-lang/perl
	       sys-devel/gettext )
	!nls? ( !<sys-devel/gettext-0.14.1 )"

# USE flags pull in xmms plugins
PDEPEND="flac? ( media-libs/flac )
	mikmod? ( media-libs/libmikmod )
	vorbis? ( media-libs/libvorbis )"

src_unpack() {
	unpack ${A}
	cd ${S}

	EPATCH_SOURCE="${FILESDIR}" EPATCH_SUFFIX="patch" \
		EPATCH_FORCE="yes" epatch

	export WANT_AUTOMAKE=1.9
	export WANT_AUTOCONF=2.5

	sed -i 's:Output Input Effect General Visualization::' Makefile.am

	if use nls; then
		cd ${S}/po
		cp ${FILESDIR}/po-update.pl update.pl
		perl update.pl --pot
	fi
}

src_compile() {
	export EGREP="grep -E"
	filter-flags -fforce-addr -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE

	local myconf=""

	if use !amd64 && { use 3dnow || use mmx; }; then
		myconf="${myconf} --enable-simd"
	else
		myconf="${myconf} --disable-simd"
	fi

	# Please see Bug 58092 for details
	use ppc64 && replace-flags "-O[2-9]" "-O1"

	econf `use_enable nls` ${myconf} || die

	# For some reason, gmake doesn't export this for libtool's consumption
	emake -j1 || die
}

src_install() {
	export EGREP="grep -E"
	make DESTDIR="${D}" install || die

	dodoc AUTHORS ChangeLog FAQ NEWS README TODO
	newdoc ${PATCHDIR}/README README.patches
	newdoc ${PATCHDIR}/ChangeLog ChangeLog.patches

	keepdir /usr/share/xmms/Skins
	insinto /usr/share/pixmaps/
	newins ${DISTDIR}/gnomexmms.xpm xmms.xpm
	doins xmms/xmms_logo.xpm
	insinto /usr/share/pixmaps/mini
	doins xmms/xmms_mini.xpm

	insinto /etc/X11/wmconfig
	newins xmms/xmms.wmconfig xmms

	insinto /usr/share/applications
	doins ${FILESDIR}/xmms.desktop

	# Add the sexy Gentoo Ice skin
	insinto /usr/share/xmms/Skins/gentoo_ice
	doins ${WORKDIR}/gentoo_ice/*
	docinto gentoo_ice
	dodoc ${WORKDIR}/README

	insinto /usr/include/xmms/libxmms
	doins ${S}/libxmms/*.h

	insinto /usr/include/xmms
	doins ${S}/xmms/i18n.h
}

pkg_postinst() {
	einfo "media-sound/xmms now just provides the xmms binary and libxmms."
	einfo "All plugins that were packaged with xmms are now provided by other"
	einfo "packages in media-plugins.  Some of these are automatically pulled in"
	einfo "based on USE flags.  Others you will need to emerge manually.  The"
	einfo "following is a list of packages which were previously provided by"
	einfo "media-sound/xmms that are not automatically emerged:"
	einfo "media-plugins/xmms-blur-scope"
	einfo "media-plugins/xmms-cdaudio"
	einfo "media-plugins/xmms-disk-writer"
	einfo "media-plugins/xmms-echo"
	einfo "media-plugins/xmms-ir"
	einfo "media-plugins/xmms-joystick"
	einfo "media-plugins/xmms-opengl-spectrum"
	einfo "media-plugins/xmms-sanalyzer"
	einfo "media-plugins/xmms-song-change"
	einfo "media-plugins/xmms-stereo"
	einfo "media-plugins/xmms-tonegen"
	einfo "media-plugins/xmms-voice"
	einfo "media-plugins/xmms-wav"
}

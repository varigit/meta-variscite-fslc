MIRRORS += "\
    git://anonscm.debian.org/.*   git://anonscm.debian.org/git/PATH;protocol=https \n \
    git://git.gnome.org/.*        git://git.gnome.org/browse/PATH;protocol=https \n \
    git://git.savannah.gnu.org/.* git://git.savannah.gnu.org/git/PATH;protocol=https \n \
    git://git.yoctoproject.org/.* git://git.yoctoproject.org/git/PATH;protocol=https \n \
    git://.*/.*                   git://HOST/PATH;protocol=https \n \
    git://source.codeaurora.org/external/imx/ git://github.com/nxp-imx/ \n \
    git://git.videolan.org/x264.git git://github.com/mirror/x264 \n \
    https://source.codeaurora.org/external/imx/ https://github.com/nxp-imx/ \n \
    http://source.codeaurora.org/external/imx/ http://github.com/nxp-imx/ \n \
    gitsm://source.codeaurora.org/external/imx/ gitsm://github.com/nxp-imx/ \n \
    ftp://nano-editor.org/pub/nano/ https://nano-editor.org/dist/ \n \
    http://sourceforge.net/projects/linuxptp/files/v1.6/ https://software-dl.ti.com/processor-sdk-mirror/sources \n \
    http://sourceforge.net/projects/linuxptp/files/v1.6/ https://variscite-public.nyc3.cdn.digitaloceanspaces.com/mirror/sources/ \n \
    http://share.basyskom.com/demos/ https://artifacts.toradex.com/artifactory/tdxref-oe-prod-frankfurt/dunfell-5.x.y/release/4/sources/ \n \
    http://threadingbuildingblocks.org/sites/default/files/software_releases/source/ https://petalinux.xilinx.com/sswreleases/rel-v2017.3/sources/aarch64-xilinx-linux/tbb-4.1-r20130314/ \n \
    ${DEBIAN_MIRROR} https://snapshot.debian.org/archive/debian/20150212T040413Z/pool \n \
"

# Force nobranch to fix renamed default branch
INHERIT += "srcuri-force-nobranch"

SRCURI_FORCE_NOBRANCH_LIST ??= " \
    puzzles git://git.tartarus.org/simon/puzzles.git \n \
    ostree git://github.com/ostreedev/ostree.git \n \
    systemd git://github.com/systemd/systemd.git \n \
"

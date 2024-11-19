## This class provides a way to add the 'nobranch' parameter in the SRC_URI
## for specific recipes. While this can be also done by creating a bbappend
## file for each recipe or adding a recipe override, this class allows to
## define a list of recipes and its URI to be patched.
##
## To use it, inherit the class in a global configuration and add the
## SRCURI_FORCE_NOBRANCH_LIST with the list of recipe as shown below:
##
## INHERIT += "srcuri-force-nobranch"
## SRCURI_FORCE_NOBRANCH_LIST ??= " \
##    ostree git://github.com/ostreedev/ostree.git \n \
## "
##
## The syntax for an entry is:
## <recipe-name> <uri>
##
## Where:
## <recipe-name> base package name of the recipe to be patched.
## <uri>         URI where the 'nobranch' parameter should be applied to.
##
## Note:
## This is a workaround and should be used for projects where updating the
## affected meta layer is not an option. It's recommended to keep your Yocto
## project up-to-date whenever possible.

def srcuri_add_nobranch(d, url):
    src_uri = d.getVar('SRC_URI', True)
    if not src_uri:
        return

    if url not in src_uri:
        bb.warn("URL %s not found in SRC_URI: %s" % (url, src_uri))
        return

    src_uris = src_uri.split()
    for i, uri in enumerate(src_uris):
        if url in uri:
            src_uris[i] = uri + ";nobranch=1"
            break

    d.setVar('SRC_URI', ' '.join(src_uris))

python srcuri_force_nobranch() {
    # Acquire base package name
    bpn = d.getVar('BPN', True)

    force_nobranch_list = d.getVar('SRCURI_FORCE_NOBRANCH_LIST', True) or ""
    if not force_nobranch_list:
        bb.warn("SRCURI_FORCE_NOBRANCH_LIST is not defined or empty.")
        return

    for ln, entry in enumerate(force_nobranch_list.split("\\n"), start=1):
        # Skip empty lines
        if not entry.strip():
            continue
        try:
            pn, url = entry.split()
            if pn == bpn:
                srcuri_add_nobranch(d, url)
        except ValueError as e:
            bb.fatal("Malformed line in SRCURI_FORCE_NOBRANCH_LIST at line %s: %s. Error: %s" % (ln, entry.strip(), e))
}

srcuri_force_nobranch[eventmask] = "bb.event.RecipePreFinalise"
addhandler srcuri_force_nobranch

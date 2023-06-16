pkg_name=certbot
pkg_origin=pkg_origin
pkg_maintainer="Mozilla Mixed Reality <mixreality@mozilla.com>"
pkg_license=('Apache-2.0')
pkg_upstream_url='https://certbot.eff.org'
pkg_description='The Certbot LetsEncrypt client.'
pkg_deps=(
  'core/bash/5.1/20220311102415'
  'core/iptables/1.8.7/20220312041053'
  'core/findutils/4.9.0/20220311104411'
  'core/python/3.10.0/20220817121853'
)
#pkg_plugins=(
  #'dns-route53'
#)
pkg_bin_dirs=(bin)
pkg_svc_user="root"

pkg_version() {
  pip --disable-pip-version-check search "$pkg_name" \
    | grep "^$pkg_name " \
    | cut -d'(' -f2 \
    | cut -d')' -f1
}

do_before() {
  update_pkg_version
}

do_prepare() {
  python -m venv "$pkg_prefix"
  source "$pkg_prefix/bin/activate"
}

do_build() {
  return 0
}

do_install() {
  pip install certbot-dns-route53
  #local account_path="$svc_data_path/accounts"
  #mkdir -p $account_path

  #cp -R \
    #accounts \
    #$account_path

  
}

do_strip() {
  return 0
}
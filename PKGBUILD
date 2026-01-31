pkgname=sedscripts
pkgver=0.1.1
pkgrel=1
pkgdesc="Key-value helpers built around sed"
arch=('any')
url="https://github.com/rdbhvr-001/sedscripts"
license=('MIT')
depends=('bash' 'sed' 'awk' 'grep')
source=("sedscripts-$pkgver.tar.gz::$url/archive/v$pkgver.tar.gz")
sha256sums=('SKIP')

package() {
  cd "$srcdir/sedscripts-$pkgver"

  install -Dm755 sedscripts "$pkgdir/usr/bin/sedscripts"

  install -d "$pkgdir/usr/share/sedscripts"

  for f in set_kv.sh get_kv.sh has_k.sh has_kv.sh ; do
    install -Dm755 "$f" "$pkgdir/usr/share/sedscripts/$f"
  done

  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}

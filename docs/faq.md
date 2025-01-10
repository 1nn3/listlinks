# Häufig gestellte Fragen (FAQ)

Was tun beim Fehler *E: Fail to load URL: https://www.example.net*?
Mit gesetztem Schalter `--debug=true` erhält man Details zum Fehler:

	phantomjs --debug=true listlinks.js https://www.example.net

Was tun beim Fehler *QStandardPaths: XDG_RUNTIME_DIR not set, defaulting to '/tmp/runtime-user*?
Verzeichnis erstellen und die Umgebungsvariable setzen:

	# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
	export USER="${USER:-$LOGNAME}"
	export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-$USER}"
	mkdir -m "0700" -p "$XDG_RUNTIME_DIR"

Firefox running in Linux Sandbox (e.g. Snap package) and geckodriver fails with
a *"Profile not found"* error:

This issue can be worked around by setting the TMPDIR environment
variable to a location that both Firefox and geckodriver have
read/write access to e.g.:

	mkdir $HOME/tmp
	TMPDIR=$HOME/tmp geckodriver

Headless Mode für Firefox:

	env MOZ_HEADLESS=1 listlinks https://example.net


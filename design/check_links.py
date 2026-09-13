"""Check local references and preserved source hashes in the design package."""
from pathlib import Path
import hashlib
import json
import re
from urllib.parse import unquote, urlsplit

BASE = Path(__file__).resolve().parent
ROOT = BASE.parent


def main():
    files = [ROOT / 'README.md', ROOT / 'DESIGN.md', ROOT / 'AGENTS.md']
    files += list((BASE / 'screens').glob('*.md'))
    files += list(BASE.glob('*.md'))
    files += list((BASE / 'preview').glob('*.html'))
    checked, errors = 0, []
    for file in files:
        content = file.read_text(encoding='utf-8-sig')
        pattern = r'(?:href|src)="([^"]+)"' if file.suffix == '.html' else r'\]\(([^)]+)\)'
        for ref in re.findall(pattern, content):
            ref = ref.strip('<>')
            parts = urlsplit(ref)
            if parts.scheme or not parts.path:
                continue
            target = (file.parent / unquote(parts.path)).resolve()
            checked += 1
            if not target.exists():
                errors.append(str(file.relative_to(ROOT)) + ': ' + ref)
    manifest = json.loads((BASE / 'manifest.json').read_text(encoding='utf-8'))
    for name, expected in manifest['sourceSha256'].items():
        actual = hashlib.sha256((BASE / 'source' / name).read_bytes()).hexdigest()
        if actual != expected:
            errors.append('Source hash mismatch: ' + name)
    for screen in manifest['screens']:
        for key in ['preview', 'spec', 'desktop', 'mobile', 'source']:
            checked += 1
            if not (BASE / screen[key]).is_file():
                errors.append('Manifest missing: ' + screen[key])
    if errors:
        raise SystemExit('\n'.join(errors))
    print(f'PASS: {checked} local references and {len(manifest["sourceSha256"])} source hashes.')


if __name__ == '__main__':
    main()

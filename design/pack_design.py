"""Create the portable design archive and verify every archived file."""
from pathlib import Path
import json
import re
import zipfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parent
CONTRACTS = [
    'README.md', 'AGENTS.md', 'DESIGN.md',
    'PRD-Aplikasi-Produktivitas-Mahasiswa.md', 'schema.md', 'API-SPEC.md',
    'openapi.yaml', 'ERD.md', 'OPERATIONS.md',
]


def main():
    version = json.loads((BASE / 'manifest.json').read_text(encoding='utf-8'))['version']
    if not re.fullmatch(r'\d+\.\d+', version):
        raise SystemExit('Invalid design package version.')
    files = [ROOT / name for name in CONTRACTS]
    files += sorted(file for file in BASE.rglob('*') if file.is_file()
                    and '__pycache__' not in file.parts)
    contents = {file.relative_to(ROOT).as_posix(): file.read_bytes() for file in files}
    archive = ROOT / f'Dailys-design-v{version}.zip'
    with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_DEFLATED) as bundle:
        for name, content in contents.items():
            bundle.writestr(name, content)
    with zipfile.ZipFile(archive) as bundle:
        assert bundle.testzip() is None, 'ZIP CRC mismatch'
        assert set(bundle.namelist()) == set(contents), 'ZIP file list mismatch'
        for name, content in contents.items():
            assert bundle.read(name) == content, f'ZIP bytes mismatch: {name}'
    print(f'PASS: {len(contents)} files; CRC and bytes verified; {archive.name} '
          f'({archive.stat().st_size:,} bytes).')


if __name__ == '__main__':
    main()

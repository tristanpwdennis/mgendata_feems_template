"""Register the mgendata-feems Jupyter kernel."""
import json, pathlib, subprocess, tempfile

root     = pathlib.Path(__file__).parent.parent
launcher = root / 'launch_kernel.sh'
launcher.chmod(0o755)

spec = {
    "argv": [str(launcher), "-f", "{connection_file}"],
    "display_name": "FEEMS (mgendata)",
    "language": "python",
    "metadata": {"debugger": True},
}

with tempfile.TemporaryDirectory() as tmp:
    (pathlib.Path(tmp) / 'kernel.json').write_text(json.dumps(spec, indent=1))
    subprocess.run(
        ['jupyter', 'kernelspec', 'install', '--user', '--name', 'mgendata-feems', tmp],
        check=True,
    )

print("Kernel 'FEEMS (mgendata)' registered.")
print(f"Launcher: {launcher}")

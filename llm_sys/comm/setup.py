from setuptools import setup
from distutils.command.install import install
import glob
import shutil


def _built(name):
    # e.g. build/llm_worker.cpython-310-x86_64-linux-gnu.so (the suffix depends on Python / arch)
    found = sorted(glob.glob(f'./build/{name}*.so'))
    assert found, f'./build/{name}*.so not found: run cmake / make first (build.sh)'
    return found[0]


class CustomInstall(install):
    def run(self):
        install.run(self)
        shutil.copyfile(_built('llm_worker'), self.install_lib + '/llm_worker.so')
        shutil.copyfile(_built('llm_host'), self.install_lib + '/llm_host.so')


setup(
    name='LLM system',
    version='1.0',
    cmdclass={'install': CustomInstall},
)

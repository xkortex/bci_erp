from setuptools import setup, find_packages

# https://python-packaging.readthedocs.org/en/latest/dependencies.html
# https://gehrcke.de/2014/02/distributing-a-python-command-line-application/
# python setup.py install develop

setup(name='bci_erp',
      version='0.1.0',
      description='Scripts for data processing in conjunction with OpenBCI for P300',
      url='https://github.com/prefrontalvortex',
      author='Michael McDermott',
      author_email='rberanek@gaittronics.com',
      license='Private',
      packages=find_packages(exclude=["*.testing", "testing.*", "testing", "*.tests", "*.tests.*", "tests.*", "tests"]),
      install_requires=[
          'numpy==1.11.3',
          'pandas==0.19.2',
          'scipy==0.18.1',
          'matplotlib==1.5.3',
      ],
      zip_safe=False)

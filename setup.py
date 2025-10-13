"""
CQC - Crypto Quant Contracts
Protocol Buffer definitions and generated code for the Crypto Quant trading platform.
"""

from setuptools import setup, find_packages

setup(
    name="cqc",
    version="0.1.0",
    description="Protocol Buffer definitions for Crypto Quant trading platform",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    author="Combine Capital",
    url="https://github.com/Combine-Capital/cqc",
    packages=find_packages(where="gen/python"),
    package_dir={"": "gen/python"},
    install_requires=[
        "protobuf>=4.21.0,<5.0.0",
        "grpcio>=1.50.0,<2.0.0",
        "grpcio-tools>=1.50.0,<2.0.0",
    ],
    python_requires=">=3.8",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
    ],
    zip_safe=False,
)

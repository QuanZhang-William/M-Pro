# This project is no longer maintained

# Mythril Pro
Mythril Pro is developed based on original Mythril-Classic symbolic engine, utilizing storage dependency analysis to prioritize path executions and prune unnecessary search spaces. Mythril Pro is significantly more efficient and scalable, while producing exactly the same result as Mythril-Classic.

## Installation and setup

### Prerequisite

See the [Wiki](https://github.com/ConsenSys/mythril/wiki/Installation-and-Setup) to install required dependencies. 

You can use [solc-select](https://github.com/crytic/solc-select)  to quickly switch between Solidity compiler versions

Note: do not run 'pip3 install mythril' in this step, as this command installs the original Mythril-Classic.

```bash
$ pip3 install mythril 
```

Mythril Pro also requires a slightly modified version of Slither to analyze state variable dependencies. 

### Using Git

To install the modified version of Slither:

```bash
$ git clone https://github.com/QuanZhang-William/slither.git && cd slither
$ pip3 install . 
```

To install Mythril Pro:

```bash
$ git clone https://github.com/QuanZhang-William/M-Pro.git && cd M-Pro
$ pip3 install . 
```
Get the RawOnly branch:
```bash
$ git checkout RawOnly
$ pip3 install . 
```

To Run the Tool:

navigate to directory M-Pro
```bash
python3 myth -w <contract address> 
```

## Mythril Pro additional usage

Mythril Pro supports all functionalities and configuration flags of Mythril-Classic, with the following additional features:

To analyze a smart contract with branching heuristic enabled:

```bash
$ myth -w <smart contract file>
```

Example: 
```bash
$ myth -w solidity_examples/calls.sol
```

To generate CFG with with branching heuristic enabled:

```bash
$ myth --sgraph <output file> <smart contract file>
```

Example: 
```bash
$ myth --sgraph output.html solidity_examples/calls.sol
```


# Mythril Classic

<p align="center">
	<img src="/static/mythril_new.png" height="320px"/>
</p>

[![Discord](https://img.shields.io/discord/481002907366588416.svg)](https://discord.gg/E3YrVtG)
[![PyPI](https://badge.fury.io/py/mythril.svg)](https://pypi.python.org/pypi/mythril)
![Master Build Status](https://img.shields.io/circleci/project/github/ConsenSys/mythril-classic/master.svg)
[![Waffle.io - Columns and their card count](https://badge.waffle.io/ConsenSys/mythril-classic.svg?columns=In%20Progress)](https://waffle.io/ConsenSys/mythril-classic/)
[![Sonarcloud - Maintainability](https://sonarcloud.io/api/project_badges/measure?project=mythril&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=mythril)
[![Downloads](https://pepy.tech/badge/mythril)](https://pepy.tech/project/mythril)

Mythril Classic is an open-source security analysis tool for Ethereum smart contracts. It uses concolic analysis, taint analysis and control flow checking to detect a variety of security vulnerabilities. 

Whether you want to contribute, need support, or want to learn what we have cooking for the future, our [Discord server](https://discord.gg/E3YrVtG) will serve your needs.

Oh and by the way, we're also building an [easy-to-use security analysis platform called MythX](https://mythx.io) that integrates seamlessly with Truffle, Visual Studio Code, Github and other environments. If you're looking for tooling to plug into your SDLC you should check it out. 

## Installation and setup

Get it with [Docker](https://www.docker.com):

```bash
$ docker pull mythril/myth
```

Install from Pypi:

```bash
$ pip3 install mythril
```

See the [Wiki](https://github.com/ConsenSys/mythril/wiki/Installation-and-Setup) for more detailed instructions. 

## Usage

Instructions for using Mythril Classic are found on the [Wiki](https://github.com/ConsenSys/mythril-classic/wiki). 

For support or general discussions please join the Mythril community on [Discord](https://discord.gg/E3YrVtG).

## Vulnerability Remediation

Visit the [Smart Contract Vulnerability Classification Registry](https://smartcontractsecurity.github.io/SWC-registry/) to find detailed information and remediation guidance for the vulnerabilities reported.

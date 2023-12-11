## Dependency conflicts as of 23.04.2021
The current version 2.0.0 of `build_runner` conflicts with `floor_generator`.
Therefore the following dependency-overrides are needed:
`
build_config: '>=1.0.0 <1.1.0'
code_builder: ^4.0.0
`
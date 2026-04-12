#38 - Because without an initial boot chain there is no end-to-end test

Un test end-to-end serio significa:

1. start from the live ISO;
2. install the system;
3. restart;
4. verify that the boot actually takes place on the target path.

If the project stops before:

- generate the `UKI`;
- write `limine.conf`;
- install `Limine` on `ESP`;

then the test is not end-to-end.

It's only a partial bootstrap.

For this `Margine` needs a provisioner dedicated to the boot chain
initial: serves to transform the boot design into an installation
really bootable.
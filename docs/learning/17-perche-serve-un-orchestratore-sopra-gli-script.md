# Why do you need an orchestrator on top of the scripts

## The important point

Separating scripts is okay.

But asking the user to do all the orchestration by hand is not always one
virtue.

## The opposite risk

If we put everything in one mega-script:

- the code becomes more confusing;
- tests become worse;
- the reuse of pieces decreases;
- bugs do more damage.

## The correct compromise

The good compromise is this:

- small scripts with clear responsibilities;
- a top-level script that orchestrates them.

This is a very common structure in well-designed systems.

## Applied to Margin

In our case:

- `provision-storage` prepare the disk;
- `bootstrap-live-iso` prepares the basic system;
- `bootstrap-in-chroot` completes the next step.

The `install-live-iso` script does not have to reinvent those steps.

He just has to call them in the right order.

## Because it is educationally better

Because you can study the two-level system:

1. the details of the individual scripts;
2. the complete installation flow.

If one day you want to change something, you will know where to put your hands:

- in the right brick, if you change a local behavior;
- in the orchestrator, if you change the flow.

## The mental rule to remember

A good orchestrator connects the pieces well.

It doesn't include them.

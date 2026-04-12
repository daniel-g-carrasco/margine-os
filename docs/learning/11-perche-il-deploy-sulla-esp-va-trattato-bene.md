# Because the deployment on the ESP must be treated well

This note accompanies:

- [deploy-boot-artifacts](/home/daniel/dev/margine-os/scripts/deploy-boot-artifacts)

The important lesson is this:

- generating a file and installing it in `/etc` is not the same as writing it
on the `ESP`.

## 1. Why ESP is different

The `ESP` is different because:

- it is critical for startup;
- it is out of root snapshots;
- often already contains files from other boot paths;
- it's not the right place to do improvised editing.

This is why in the `Margine` project we treat it as a deployment area, not as
work area.

## 2. Because we generate first and then copy

This separation gives you two big advantages:

- you can verify the file before copying it;
- you can redeploy without having to rebuild the logic by hand.

The rule of thumb is:

- build out of `ESP`
- deploy sulla `ESP`

## 3. Because we backup before overwriting

Because deploying the boot path is a delicate operation.

If you mess up a file in `/etc`, you can often still go back in and fix it.
If you mess up a boot file, the fix can be much more cumbersome.

So backing up before overwriting is not paranoia.
It's hygiene.

## 4. Why don't we delete everything automatically

This is another point to learn well.

Many scripts become dangerous because they want to be "cleaned" too soon:

- they see extra files;
- they erase them;
- then you discover that one of those files served a recovery path or a
situation you hadn't considered.

In `v1` we prefer:

- copy well;
- understand well;
- clean only later, with stronger rules.

## 5. The final rule to remember

If one day you have to explain to someone how to deal with the boot path, the phrase
this is correct:

- the `ESP` cannot be "edited";
- la `ESP` si deploya.

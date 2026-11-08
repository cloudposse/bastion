# OpenSSH patches

OpenSSH will not compile out-of-the-box on Alpine. The patches under `openssh/alpine/` are the ones Alpine applies to the OpenSSH release this image builds. The base image is Alpine 3.24. OpenSSH itself is 10.6p2, which already contains the fixes that older Alpine branches carry as backports (`pw.patch`, the `0001`–`0012` security patches, `fix-utmp.patch`, and the utmps warning patch). Do not copy those onto this tree.

Source: [Alpine aports `main/openssh` on edge](https://gitlab.alpinelinux.org/alpine/aports/-/tree/master/main/openssh), which is the branch that packages 10.6p2.

We also add a couple of our own patches.

One patch ensures we have `SSH_ORIGINAL_COMMAND` available during PAM auth so we can send Slack notifications.
[original-command.diff](openssh/cloudposse/original-command.diff)

The other patch obscures the version of OpenSSH. We use this to hide the SSH version so it is not announced to port scanners.
[obfuscate-version.diff](openssh/cloudposse/obfuscate-version.diff)

When upgrading OpenSSH, refresh the Alpine patches from the aports branch that packages that version. Patches written for an older release will not apply.


## Dev Cheatsheet for Regenerating OpenSSH Patches

```
git clone --single-branch https://gitlab.alpinelinux.org/alpine/aports.git tmp
cp tmp/main/openssh/*.patch patches/openssh/alpine/
```

# OpenSSH patches

OpenSSH will not compile out-of-the-box on alpine. For this reason, we use the official patches found here:

- [https://git.alpinelinux.org/cgit/aports/tree/main/openssh](https://git.alpinelinux.org/cgit/aports/tree/main/openssh)

We also add a couple of our own patches.

One patch ensures we have `SSH_ORIGINAL_COMMAND` available during pam auth so we can send slack notifications.
[original-command.diff](openssh/cloudposse/original-command.diff)

The other patch obscures the version of OpenSSH. We use this to hide the SSH version so it's not announced to port-scanners.
[obfuscate-version.diff](openssh/cloudposse/obfuscate-version.diff)

Also we modified one alpine patch related to realpath, because it is outdated.
[bsd-compatible-realpath.diff](openssh/cloudposse/bsd-compatible-realpath.diff)

When upgrading version of OpenSSH, the patches might need to be regenerated.


## Dev Cheatsheet for Regenerating OpenSSH Patches

```
git clone --single-branch https://gitlab.alpinelinux.org/alpine/aports.git tmp
cp tmp/main/openssh/*.patch patches/openssh/alpine/
```

# Overview

This is a Git LFS repository, currently is tracking PNG file, you can use `git-lfs ls-files` to check it

# How to trigger auto pack

You need to push a tag by with format `r<major><minor><patch>`, like `r1.0.0`

Generate tag by `git tag <r1.0.0>`, then push tag `git push --tags`

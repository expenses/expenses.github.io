---
layout: post
title:  "My Jujutsu workflow, tips & tricks"
---

_This is sort-of a followup post to [my previous post](/2025/08/27/git-grievences-jujutsu.html)._

I've been using [Jujutsu](https://github.com/jj-vcs/jj) exclusively for a month and a bit. While not perfect, I consider it a substantial improvement over git. I'm considering removing the `git` command from my `$PATH` all together.

# Operating on a merge

I use a workflow that's similar if not identical to ['megamerges'](https://v5.chriskrycho.com/journal/jujutsu-megamerges-and-jj-absorb/). This involves working on a revision that merges in a whole bunch of different changes. Typically it looks something like this in the log:

```
@
├─┬─┬─╮
│ │ │ ○
| | | |
│ │ ○ │
| | | |
│ │ │ │ ○
├───────╯
○ │ │ │
| | | |
◆ │ │ │
├─╯ │ │
```

This could be work for 2 different pull requests, 1 pull request merged with master, changes that I don't want to upstream (e.g. adding a flake.nix) mixed in with ones that I do, whatever.

# Making Revisions

Generally you want to write changes into this merge revision then try and 'empty' it into other branches. I almost always use  `jj split -A <bookmark>` for this. This will bring up an interactive screen and I can select what changes I want to put into a new revision on top of the destination.

If the merge revision is empty, you can switch which branches are being merged in by just running `jj new X Y Z` and it'll create a new merge revision and delete the old one provided it didn't have a description. But if you're still working on whatever is in the merge revision, you'll need to rebase in order to take those changes with you. `jj rebase -s @ -d '@-~<rev to remove>' -d <rev to add>` works well for this, where `@` is the current revision, `@-` is its ancestors and `~` is an set exclusion operator.

# Bookmarks

Updating bookmarks is fairly standard. Often I use `jj bookmark move <bookmark> -t <bookmark>+` if I'm just moving things ahead by 1 revision and don't care about its ID.

# Unwanted changes

If you have a bunch of changes in a merge revision that you're almost certain you don't want (e.g. a bunch of debugging lines) then you might as well keep them around, but in a side revision that won't be merged in. Use `jj split -d <bookmark>` for this.

# Local-only changes

Additionally, if you want a bunch of changes you need in the working set but don't want to push, simply use `jj split -A <bookmark>` as per normal but don't update the bookmark. They any of these local-only changes will be rebased onto whatever new changes you add to the bookmark.

# Other commands

- I occasionally squash revisions. Generally after I've already created them with with `jj split -A` though.
- I don't use `jj absorb`. I really like the idea but it seems to squash revisions rather than create new ones.

# Grips


- Flags are inconsistent. `jj rebase` uses `-s` and `-d`, `jj squash` uses `-f` and `-t`. `jj bookmark set` uses `-r`, `jj bookmark move` uses `-t`.
- There are too many redundant commands. Why even have `bookmark set` and `move`? Why not have `jj split` be an alias of `jj commit -i` or something?

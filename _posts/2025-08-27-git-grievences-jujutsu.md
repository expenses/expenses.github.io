---
layout: post
title:  "Git grievances and Jujutsu"
---

I've been using git for possibly a decade at this point, and I've developed a certain workflow and habits using it. It's the best program in the world that also sucks a lot. Note that I always use git through the CLI.

# Current Workflow

I frequently use `git status` to check the current status of a repository. Sometimes I misspell it and because I have `help.autocorrect` set to `true` it interprets this as `git stash`:

```
~ git stuas
WARNING: You called a Git command named 'stuas', which does not exist.
Continuing under the assumption that you meant 'stash'.
```

Rather annoying. I think if I set up a `stuas` alias for `status` then this particular error would be avoided?

I also use `git diff` a lot to review all pending changes and use [`delta`](https://github.com/dandavison/delta) as a pager as I find the output to be a lot more pleasant and readable.

I almost always use the patch mode of `git add` (`git add -p`) because it serves as a useful way to review code before staging and then committing it

```diff
~ git add -p .
diff --git a/file.txt b/file.txt
index 7f785ff..3c3b509 100644
--- a/file.txt
+++ b/file.txt
@@ -1,4 +1,2 @@
 # line a
-$$ line b
-%%% line c
 line d
(1/1) Stage this hunk [y,n,q,a,d,e,p,?]?
```

Pressing `s` here let's you split up 'hunks' (whatever those are) into smaller changes for individual review. Only sometimes though. Here it won't let me:

```
(1/1) Stage this hunk [y,n,q,a,d,e,p,?]? s
Sorry, cannot split this hunk
(1/1) Stage this hunk [y,n,q,a,d,e,p,?]?
```

So in this case, if I were happy to commit the removal of `$$ line b` but not `%%% line c` I'd have to `e`dit the line and remove the `-%%% line c`. This is a bit messy. I also didn't know about this until doing research for this post and thought that you had to do some more manual file editing, so it's not exactly obvious as an option.

Sometimes, you're happy with a set of changes (**set A**), you want to hold back on committing another set (**set B**), but you're not sure if **set A** on its own is valid without some components of **set B**. What are your options here? If `git stash` was a good command, you'd be able to stash the set B~~ changes, run whatever commands you need to test the **set A** changes and then unstash the **set B** changes. `git stash` is unfortunately the opposite of a good command, and stashes both staged and unstaged changes, meaning that **set A** and **set B** go into the stash.

I think your only option is to commit the **set A** changes with some message like `WIP testing set A`, stash **set B**, see if things work, and if needed do `git commit --amend` with some components of **set B**. Yuck.

Other times, **set A** might be good to go and **set B** is just a bunch of changes you don't need anymore. I use `git checkout .` to get rid of the **set B** changes. I always use `git checkout` for both switching branch and file contents, I never use the woke (this is sarcasm) [`git switch` or `git branch` commands](https://towardsdatascience.com/its-finally-time-to-say-goodbye-to-git-checkout-fe95182c6100/).

Overall, this workflow works like 90% of the time, stumbles maybe 5% of the time and completely collapses another 5% of the time. I don't think there are any git workflows that are so much more reliable though.

# Jujutsu

[Jujutsu](https://github.com/jj-vcs/jj) (`jj`) is a git-compatible VCS that I've read a bunch of blog posts about that say that it's good. I've used it a few times but haven't switched to it properly because the git habit is hard to break outside of straight up disabling the command on my system. I wasn't sure how I'd adapt my workflow to it so I did some research.

`jj status` (also aliased as `jj st`) outputs something like this:

```
Working copy changes:
D default.nix
M flake.lock
M flake.nix
D nix/avoyd.nix
D nix/gaiasky-src copy.nix
D nix/gaiasky-src.nix
D nix/gaiasky.nix
D nix/magicavoxel.nix
M result
D x.py
Working copy  (@) : ypkuqzwy 7c6a5cef (no description set)
Parent commit (@-): kzlznoxq 6b7d8e7f (no description set)
(END)
```

I imagine this is customisable but by default is good enough for me, with the exception of using a pager (meaning that I have to press `q` to exit and it clears the terminal). `--no-pager` works.

`jj diff`, similar story, it shows the diff in a format that I don't recognize, also in a pager.

Jujutsu doesn't use a staging area. This is probably for the best and makes things much simpler, but I wasn't sure what it meant for my workflow. You can commit the whole repository with `jj new`, but the other options weren't clear. Turns out that `jj split` exists, and brings up a little TUI thingy where you can select which files, sections and even lines(!!) to commit:

![jj split screenshot](/assets/jj-split.png)

Big fan of that. Jujutsu commits don't need to be named, which at least removes the requirement of having to write `WIP blah blah`. It's much more open to the idea of modifying existing commits.

`jj show @-` (this is the equivalent of `git show`, as `@` is the current set of changes and `@-` is the previously committed set) now shows

```
Commit ID: 14763abf8df078e72a3c8484a963cf062a44e2ce
Change ID: tulxxpwzntwtwmrruwpzwpxlopkoturw
Author   : <snip>
Committer: <snip>

    (no description set)

Modified regular file file.txt:
   1    1: # line a
   2     : $$ line b
   3    2: %%% line c
   4    3: line d
```

I don't believe that there's a way of splitting off some changes into an existing commit, but something like `jj split` and `jj squash -t @-- -f @-` seems to work fine. It feels slightly awkward but maybe that's just how Jujutsu is meant to be used.

Shoutout to `jj undo` by the way, it has let me undo any and all mistakes in my testing here and has made the whole process a lot smoother.

The equivalent of `git checkout <path>` seems to be `git restore -f @- <path>`. Maybe there's a better way but this is fine and I like the consistency of using the whole `@`, `@-` and `@--` etc thing to indicate revset. It's a lot nicer than `HEAD^1` or whatever you do in git.

That's about it. Seems pretty good so far.

# Ignoring a deletion of a file that exists in the repository

In the repository for this blog, I've got a `Gemfile` file. This file needs to exist for the sake of the `jekyll` blog builder on GitHub, but it breaks my Jekyll workflow locally. I want to be able to delete it from my local filesystem without that deletion being committed. I could just rm `rm Gemfile` but then there'll permanently be a `deleted:    Gemfile` change that I'll need to ignore every time I run `git add` or `jj split`. Whatever I do to `.gitignore` makes no difference. Annoying.

[`ijmacd` on reddit](https://old.reddit.com/r/git/comments/yu5mpc/how_to_delete_a_filefolder_locally_but_not_commit/iw7mdxp/) suggested the following:

```
git update-index --assume-unchanged file.c
rm file.c
```

What the fuck?

```
--[no-]assume-unchanged
  When this flag is specified, the object names recorded for the paths
  are not updated. Instead, this option sets/unsets the "assume
  unchanged" bit for the paths. When the "assume unchanged" bit is on,
  the user promises not to change the file and allows Git to assume
  that the working tree file matches what is recorded in the index. If
  you want to change the working tree file, you need to unset the bit
  to tell Git. This is sometimes helpful when working with a big
  project on a filesystem that has a very slow lstat(2) system call
  (e.g. cifs).

  Git will fail (gracefully) in case it needs to modify this file in
  the index e.g. when merging in a commit; thus, in case the
  assumed-untracked file is changed upstream, you will need to handle
  the situation manually.
```

This very weird command doesn't do anything for Jujutsu. In git it's at least not strictly required. You simply avoid adding the deletion with `git add`. This means you can never run `git add .` but often you don't want to be running that command all the time anyway. Jujutsu _feels_ different. It _feels_ like you're meant to be using `jj new` all the time. But if you're in this situation, you can't, as that'd add the deletion. So you have to use `jj split` every time. Not ideal.
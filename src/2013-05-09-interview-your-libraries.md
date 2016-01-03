# Interview your libraries

I love working with John Barnette, even if we don't work on the same stuff
regularly. The other day, he wrote this in a discussion:

> Every time we bring in an external library, we inherit its opinions,
> shortcomings, idioms, and taste. This isn't a reason to rewrite everything
> ourselves, but it's good for us to interview libraries like we interview new
> GitHubbers.

I loved this. In two short sentences, Barnette summed up why we should
evaluate new dependencies before adding them to an existing project.

## Why not drop in a library?

It's tempting to add a library that promises to do 90% of your goal. But that
instant gratification often comes with delayed hidden costs. Things I've been
bitten by in the past include:

* Security. It's hard, and no one gets it right the first time.
* Performance. Sure it works in the simple case, but does it scale?
* Complexity. It's not worth importing a kitchen sink if you're only
  planning to use one small method.
* Lack of benefit. Some libraries just don't buy you very much.
  Syntactic sugar is nice if it wraps an ugly interface, but if it doesn't,
  it means keeping two interfaces in you head while you work.
* Organizational cost. Does your team know how to use it? If not,
  is it worth it for them to pick it up? It's better to choose something plainer,
  simpler, and more explicit if it means the rest of your team can easily
  understand and work with it.

## What about frameworks and ORMs?

I've worked with Rails for a long time now, and I have a good sense of where
to poke around if I have questions. But let's be honest, with 183 commits made
by 63 authors in the last week alone, I'll never *know* Rails inside and out.

![](http://f.cl.ly/items/0q0a1q2j3O2C1m1E3P1Y/Screen%20Shot%202013-05-07%20at%208.42.29%20PM.png)

Rails is large and complex. Yet, I'm happy to use it daily in my project. Why?
Because I trust the project and community to stick around. It'd be a pain to
rewrite what Rails buys you. Plus, the documentation is great, there are
timely security patches, and my team knows how to use it.

## Go with your gut

None of the hidden costs I listed above are hard rules for rejecting a
library. But the next time you think about adding a library to your codebase,
grill it with some hard questions and see if it's worth adding.

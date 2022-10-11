---
title: Mirage OS retreat (October 2022)
...

I went to the 11th Mirage OS retreat, a more or less yearly event gathering developers actively participating in, wanting to participate in, or curious about the [Mirage OS](https://mirage.io/) project — or adjacent projects.

Mirage OS is a framework for programming infrastructure/system/etc. applications: proxies, firewalls, web-servers, etc.
The application can be compiled to a variety of targets including stand-alone [unikernels](https://en.wikipedia.org/wiki/Unikernel).

Disclaimer: my employer paid for my participation and my transport to/from the retreat.

## What I worked on

**Lwt exception management:**  
I had a discussion with another participant.
I tried to explain why we couldn't keep track of exception backtraces in Lwt.
They kept asking how does [the ppx extension](https://ocaml.org/p/lwt_ppx/2.1.0) manages it, and why can't vanilla Lwt do something similar.
This discussion backed me into a corner where I mulled over the current exception management recommendation until I eventually realised that actually yes, it can be done in vanilla Lwt, with just one primitive and a little bit of discipline.
After this discussion I gave a short talk at the retreat centered around advice to best use Lwt — with respect to exception management and otherwise.
And after that I opened [a pull-request](https://github.com/ocsigen/lwt/pull/963) on the Lwt repository to propose the corresponding changes.

**Seq but with monad:**  
I had planned on working on a monad-friendly [`Seq`](https://v2.ocaml.org/api/Seq.html)-like library.
The Octez project uses [something along these lines](https://ocaml.org/p/tezos-lwt-result-stdlib/14.0) but the maintenance is too cumbersome — e.g., [this maintenance merge-request](https://gitlab.com/tezos/tezos/-/merge_requests/6464) adds support for OCaml 4.14 additions to the `Seq` module.

I was intending to work on this as a filler task: something to do in short spans of free time now and then.
I ended up spending a lot of time on it because I'd bounce ideas off of other participants and work on those ideas immediately.
I have opened a [repository for the project](https://gitlab.com/raphael-proust/seqes) and I hope to get it to a point where it can be released quickly.

Generally, the retreat is full of distractions, but the kind of distractions that makes you do stuff.

**First mirage application:**  
I built my first mirage application.
I had used some libraries from the mirage ecosystem before.
And I knew about some of the basic building blocks such as `functoria`.
But I had never built a binary using the mirage tool-chain before.

In retrospect, I should have done so before the retreat.
It would have given me a better understanding of the scope of the project and the coding discipline that it imposes.
This in turn would have helped me pick a couple of ideas to work on during the retreat.

If you have never built a mirage application before, I'd recommend following the [Hello World tutorial](https://mirage.io/docs/hello-world) which covers much more than the name would suggest.

## What else I did

In addition to the items listed above, I did a myriad other things that, whilst less tangible, are also important.
The retreat's organisation lends itself to a lot of productive discussions.
More accurately: the minimality of the organisation (what would in other situation be considered a _lack_ of organisation) lends itself to spurious productive exchange of ideas.

Topics that I had interesting conversation about include:

- Some finer points of Lwt semantics.
- What could Lwt evolve to.
- The ocaml-ci and the opam-ci.
- The opam-repository maintenance process.
- NixOS.
- Getting an open-source project adopted by a wider audience.
- How to efficiently work from home.


## What I did besides work

I ate very well.
The food was simply delicious and healthy and varried.

I learned some basic German vocabulary from a quadrilingual 4 year old.

I met some new people and I met back with people I hadn't seen for years.


## So you want to go to a Mirage OS retreat?

Do it!

I don't think two of these retreats are the same.
So the next one might be different.
But I have no doubt it'll still be a fun and productive time.

- Start to think about what you can use Mirage OS for.
- Watch out for announcements on [discuss.ocaml.org](https://discuss.ocaml.org/) and register as instructed.
- Ask the organiser whatever organisational question you need to know the answer to.

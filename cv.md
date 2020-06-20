---
title: Curriculum Vitæ
...

Raphaël Proust  
<code@bnwr.net> — [PGP key](/pgp--code-at-bnwr-dot-net)  
[Github profile](https://github.com/raphael-proust)  
[Gitlab profile](https://gitlab.com/raphael-proust)  


I am a software developer and a technical writer.

I work in a variety of programming languages —including OCaml, Python, Scala, Javascript— on various types of software —such as blockchains, document processors, web servers, libraries.

I write, edit and review courses, tutorials, manuals and rulebooks in French and English.


## Chronology

------------------------ ------------------------------------------------------
 Mar 2018–Present        Software developer on the
                         [Tezos project](https://gitlab.com/tezos/tezos)

 Aug 2017–Mar 2018       Freelance, remote software developer and technical
                         writer

 Sep 2016–Aug 2017       Software developer and technical writer at
                         [Cambridge Coding Academy](https://cambridgecoding.com/)
                         and [Cambridge Spark](https://cambridgespark.com/).

 Sep 2012–Jul 2016       PhD student at the
                         [University of Cambridge](http://www.cam.ac.uk/)
                         [Computer Laboratory](http://www.cl.cam.ac.uk/)

 Apr 2012–Aug 2012       Intern at
                         [INRIA's Gallium team](http://gallium.inria.fr/)
                         on “functional intermediate representations”

 Aug 2011–Feb 2012       Intern at the
                         [University of Cambridge](http://www.cam.ac.uk/)
                         [Computer Laboratory](http://www.cl.cam.ac.uk/)
                         on “programming language support for the
                         Mirage operating system”

 Sep 2010–Jul 2011       Masters degree in Computer Science at
                         [ÉNS Cachan, antenne de Bretagne](http://www.ens-cachan.fr/),
                         including internship at
                         [IRISA](https://www.irisa.fr/en)'s
                         [MYRIADS](https://team.inria.fr/myriads/)
                         research team on “distributed implementation of a
                         chemical abstract machine”

 Summer 2010             Research engineer in CNRS's
                         [Ocsigen Team](http://ocsigen.org/)

 Sep 2009–Jul 2010       Masters (1^st^ year) in Computer Science at
                         [Université Paris 7 Denis Diderot](https://www.univ-paris-diderot.fr/)

 Summer 2009             Research engineer in CNRS's
                         [Ocsigen Team](http://ocsigen.org/)

 Sep 2008–Jul 2009       ‘Licence’ (Bachelor) in Computer Science and Masters
                         (1^st^ year) in Mathematics, both at Université Paris
                         7 Denis Diderot

 Sep 2007–Jul 2008       ‘Licence’ in Mathematics at Université Paris 7 Denis
                         Diderot

 Sep 2005–Jul 2007       ‘Classes préparatoires’ (pre-engineering school)

 2005                    ‘Baccalauréat’ of Science
------------------------ -------------------------------------------------------


## Projects at Nomadic Labs

[Nomadic Labs](https://nomadic-labs.com/) is a company that provides software
development and research in formal verification, distributed systems and
programming languages.

I joined Nomadic Labs in March 2018 as the company was expending to handle the
development requirements of the [Tezos](https://tezos.com/) project. I am still
working at Nomadic Labs, on Tezos and other related projects. Some of the items
below are on-going.

- **Code review** and **merging**

	I reviewed merge requests (MRs): inspecting changes to the code before giving
	a greenlight for merging, or requesting changes, or discussing specific
	points with the original developers.

	I rebased and merged MRs that had been greenlit by other reviewers.

	I participated and, for a time, ran weekly meetings to discuss and triage
	open MRs.

- **Overhauling the Tezos mempool**

	The mempool is a component of the Tezos project responsible for receiving
	information from the P2P gossip, folding the received information into the
	local state, and, based on state changes, handing over some more information
	to the P2P layer to be gossiped. A few colleagues and myself rewrote a new
	mempool from scratch to fix some issues and improve performance.

	This software component involves concurrency (information is received from
	different peers at unpredictable times, but operations must be applied to the
	state sequentially) and more specifically defensive scheduling: it must
	protect against potential denial of service attacks whereby
	malicious peers saturate a node to the point that it ignores other,
	non-malicous, nodes. It also involves a high level of abstraction because the
	nature of the state and the way information is folded into it depends on
	another software component (the economic protocol) that can change
	dynamically.

	The development of this new mempool led to the release of
	[`lwt-pipeline`](https://gitlab.com/nomadic-labs/lwt_pipeline) and the
	extension of [`ringo`](https://gitlab.com/nomadic-labs/ringo).

- **Releasing internal libraries** and **upstreaming changes to vendored libraries**

	The Tezos project was originally built as a set of libraries and binaries all
	placed within the same repository. After a while, some parts of the code had
	matured into stable components with well-defined interfaces. These parts
	could be released.

	I took the lead in releasing libraries. This involved setting up their own
	repository (with continuous integration), setting up the packaging
	boilerplate, and modifying the code of Tezos to use the external libraries
	rather than the embedded version.

- **Other miscellaneous**

	Work at Nomadic Labs also included developing various features, fixing some
	bugs, triaging issues, etc. I also developed some of the tooling used for
	linting.


## Projects at Cambridge Coding Academy and Cambridge Spark

[Cambridge Coding Academy](https://cambridgecoding.com/) and
[Cambridge Spark](https://cambridgespark.com/) are twin companies that provide
teaching and training in programming, data analysis, machine learning, etc.
The former organises courses for teenagers; the latter for professionals.

I started working for the companies as they were set up. When I finished my
PhD, I started full time employment for these companies and worked on the
projects listed below.

- **Student evaluation system**

	I participated in the creation, maintenance and improvement of a system to
	automatically evaluate students. I also handled part of the system
	administration for the machines that run the system. The system analysed
	submitted code, recorded complete results for later review by the teachers and
	gave immediate summarised feedback to the students.

	The system involved Gitlab, Python, continuous integration, linting
	libraries, unit testing, Docker images (both building and running), and
	Amazon Web Services.


- **Course writing**

	I wrote, reviewed, and edited
	[courses for Cambridge Coding Academy](http://cambridgecoding.com/summerschool).
	These courses, aimed at teenagers, covered basic programming, making web
	pages, building games, programmatically generating music, and creating
	artificial intelligences.

	I wrote, reviewed, and edited
	[courses for Cambridge Spark](https://cambridgespark.com/training). These
	courses, aimed at professionals, covered basic programming, data-analysis,
	and quantitative finance.


- **Publication pipeline**

	I wrote and maintained a publication pipeline for content created by
	Cambridge Spark. The pipeline let authors submit content, make edits,
	and compile the files locally. It let reviewers make minor changes and
	request bigger changes. It automatically compiled the files as they were
	submitted and let project managers publish them online on demand.

	The system used Pandoc, custom LaTeX templates, custom HTML templates,
	Makefiles, integration tests, and continuous integrations.


- **Web development**

	I contributed to the implementation of the online learning platform of
	Cambridge Coding Academy. The program was written in Scala and Javascript
	and managed users through an SQL database. The User Interface included an
	online editor, and rendered user-edited HTML/Javascript/CSS in the browser.

	I contributed to two consecutive versions of the
	[Cambridge Spark website](https://cambridgespark.com/). The website, coded
	in Scala, used the Play and Bootstrap frameworks, an SQL database, and
	custom Javascript.

	I also assisted with the system administration. The website was hosted on
	Amazon Web Services.


- **Teaching**

	I taught numerous courses for both teenagers (with Cambridge Coding
	Academy) and professionals (with Cambridge Spark) about several aspects of
	computer science and programming. I also trained teachers and tutors.


## Projects at the University of Cambridge

I completed a PhD at the Computer Laboratory of the University of Cambridge.

- **PhD**

	The topic of my PhD is the use of compile-time memory management (to
	replace execution-time garbage collection) in the context of system
	programming.

	I wrote the
	[dissertation](http://www.cl.cam.ac.uk/techreports/UCAM-CL-TR-908.html) in
	LaTeX, used `mk` to drive the compilation into pdf, and managed the source
	files with Git.

	I wrote a prototype in OCaml, used `make` to drive the compilation as
	well as the tests and the benchmarks, and managed the source files with
	Git.

- **Computer Science Laboratory** (additional work)

	I supervised undergraduate students, both in tutoring sessions and for
	longer projects. I organised
	[a series of talks](http://talks.cam.ac.uk/user/show/25917) for my research
	team. I contributed to the early setup of the
	[Computer Science Admission Test](https://www.cl.cam.ac.uk/admissions/undergraduate/admissions-test/)
	which is used to evaluate candidates to the University of Cambridge
	Computer Science undergraduate program.

	I was awarded the
	[Wiseman Award](https://www.cl.cam.ac.uk/local/wiseman.html) for these
	contributions to the Computer Science Laboratory.

- **Magdalene College MCR Committee member**
	(MCR: the body of graduate students)

	I was Secretary, President and then IT officer of the
	[MCR](http://mcr.magd.cam.ac.uk/) committee of
	[Magdalene College](https://www.magd.cam.ac.uk/). I organised events for
	around 100 people, represented students in College matters, and organised
	committee elections.



## Miscellaneous

- Natural languages: French (native), English (fluent), Spanish (intermediate), Chinese (beginner), Toki Pona (beginner).
- Programming languages: OCaml (native), make (fluent), shell (intermediate), Javascript (rusty), Python (rusty), Scala (rusty), Scheme (beginner), Haskell (beginner), C (beginner).
- Markup languages: Markdown (native), HTML (fluent), LaTeX (intermediate).
- Environment: Archlinux, `vi`/`nvim`, `git`, `acme`, `make`, `mk`, `opam`, `sh`/`zsh`, `rc`, `pandoc`, etc.
- Other: driver's license, PADI Advanced Open Water Diver, fire warden training, skilled punter and skater.

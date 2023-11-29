---
title: Curriculum Vitæ
...

Raphaël Proust  
<code@bnwr.net> — [PGP key](/pgp--code-at-bnwr-dot-net)  
[Gitlab profile](https://gitlab.com/raphael-proust)  
[Github profile](https://github.com/raphael-proust)  


I am a software engineer and a technical writer.

I work primarily with OCaml but also in a variety of programming languages on various types of software.

I write, edit and review courses, tutorials, manuals and rulebooks in French and English.


## Chronology

------------------------ ------------------------------------------------------
 Mar 2018–Present        Software engineer at
                         [Nomadic Labs](https://nomadic-labs.com/) on the
                         [Tezos project](https://gitlab.com/tezos/tezos)

 Oct 2022–Present        Co-maintainer of the
                         [opam-repository](https://github.com/ocaml/opam-repository)

 Jul 2020–Present        Co-maintainer of the
                         [Lwt library](https://github.com/ocsigen/lwt/)

 Aug 2017–Mar 2018       Freelance, remote software developer and technical
                         writer

 Sep 2016–Aug 2017       Software developer and technical writer at
                         Cambridge Coding Academy
                         ([via wayback machine](http://web.archive.org/web/20200921170235/https://cambridgecoding.com/))
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

 2005                    ‘Baccalauréat’ in Science
------------------------ -------------------------------------------------------


## Projects at Nomadic Labs

[Nomadic Labs](https://nomadic-labs.com/) is a company that provides research and development in formal verification, distributed systems and programming languages.

I joined Nomadic Labs in March 2018 as the company was expanding to handle the development requirements of the [Tezos](https://tezos.com/) project.
I am still working at Nomadic Labs, on Tezos and other related projects.
Some of the items below are on-going.
All items are written in past tense for consistency.

- **Tooling show and tell**

	I organised a series of internal talks to share information about developer tooling.
	In each talk, one developer showed how they perform one specific task (e.g., rebasing), showcasing their tooling.

- **Internal training**

	I organised and ran several training sessions focused on the common libraries that are used within the Tezos project, most notably
	Lwt ([tutorial](/code/lwt-part-1.html)),
	the ocamldoc documentation markup language,
	our in-house error-management library ([tutorial](http://tezos.gitlab.io/developer/error_monad.html)), and
	our in-house data de/serialisation library ([tutorial](https://nomadic-labs.gitlab.io/data-encoding/data-encoding/tutorial.html)).

- **Code review** and **merging**

	I reviewed, rebased, and merged merge requests (MRs).

	I participated and, for a time, ran weekly meetings to discuss and triage open MRs.

- **Overhauling the Tezos mempool**

	The mempool is a component of the Tezos project responsible for receiving information from the P2P gossip, folding the received information into the local state, and, based on state changes, handing over some more information to the P2P layer to be gossiped.
	A few colleagues and myself rewrote a new mempool from scratch to fix some issues and improve performance.

	This software component involves concurrency and more specifically defensive scheduling: it must be resilient against potential denial of service attacks.
	It also involves a high level of abstraction because the nature of the state and the way information is folded into it depends on another software component (the economic protocol) that can change dynamically.

	The development of this new mempool led to the release of [`lwt-pipeline`](https://gitlab.com/nomadic-labs/lwt_pipeline) and the extension of [`ringo`](https://gitlab.com/nomadic-labs/ringo).

- **Releasing internal libraries** and **upstreaming changes to vendored libraries**

	The Tezos project was originally built as a set of libraries and binaries all placed within the same repository.
	After a while, some parts of the code had matured into stable components with well-defined interfaces.
	These parts could be released.

	I took the lead in releasing libraries.
	This involved improving their documentation, setting up their own repository (with continuous integration), setting up the packaging boilerplate, and modifying the code of Tezos to use the external libraries rather than the embedded version.

- **Modernising internal libraries**

	The in-house Error Monad library dates back to the very start of the Tezos project.
	Over the course of the project's lifetime it had accumulated many helper functions for different uses.

	I led the effort of cleaning up the interface, organising the code into separate components, bringing in a newer syntax (based on OCaml's binding operators) and developing an error-related supplement to the OCaml Stdlib.
	This task involved some changes to the library itself as well as corresponding changes throughout the rest of the project.
	Because changes to the rest of the code were large, it also involved carefully preparing the git history of the merge requests.

	Similarly, I led the effort in improving the in-house de/serialisation library and releasing it into the larger OCaml ecosystem.
	This also involved writing precise API documentation and a user-oriented tutorial.

- **Long term technical planning**

	I led the OCaml 5 readiness effort:
	fixing the issues that prevented the Tezos project from upgrading to the newer major release of OCaml,
	investigating the uses of the release's features and how they would integrate in our existing code-base.

    I led the roadmapping and part of the project management to shift the project to a monorepo.

- **Other miscellaneous**

	Work at Nomadic Labs also included developing various features, fixing some bugs, triaging issues, etc.
	I also developed some of the tooling used for linting and testing.


## Projects at Cambridge Coding Academy and Cambridge Spark

Cambridge Coding Academy ([via wayback machine](http://web.archive.org/web/20200921170235/https://cambridgecoding.com/)) and [Cambridge Spark](https://cambridgespark.com/) are twin companies that provide teaching and training in programming, data analysis, machine learning, etc.
The former organises courses for teenagers; the latter for professionals.

I started working for the companies as they were set up.
When I finished my PhD, I started full time employment for these companies and worked on the projects listed below.

- **Student evaluation system**

	I participated in the creation, maintenance and improvement of a system to automatically evaluate students.
	I also participated in the system-administration for the machines that hosted the system.

	The system analysed submitted code, recorded complete results for later review by the teachers and gave immediate summarised feedback to the students.

	The system involved a self-hosted Gitlab instance, the Gitlab API, Python, continuous integration, linting libraries, unit testing, Docker images (both building and running), and Amazon Web Services.


- **Course writing**

	I wrote, reviewed, and edited courses for Cambridge Coding Academy.
	These courses, aimed at teenagers, covered basic programming, making web pages, building games, programmatically generating music, and creating artificial intelligences.

	I wrote, reviewed, and edited courses for Cambridge Spark.
	These courses, aimed at professionals, covered basic programming, data-analysis, and quantitative finance.


- **Publication pipeline**

	I wrote and maintained a publication pipeline for content created by Cambridge Spark.
	The pipeline let authors submit content, make edits, and compile the files locally.
	It let reviewers make minor changes and request bigger changes.
	It automatically compiled the files as they were submitted and let project managers publish them online on demand.

	The system used Pandoc, custom LaTeX templates, custom HTML templates with CSS, Makefiles, integration tests, and continuous integrations.


- **Web development**

	I contributed to the implementation of the online learning platform of Cambridge Coding Academy.
	The program was written in Scala and Javascript and managed users through an SQL database.
	The User Interface included an online editor, and rendered user-edited HTML/Javascript/CSS in the browser.

	I contributed to two consecutive versions of the Cambridge Spark website.
	The website, coded in Scala, used the Play and Bootstrap frameworks, an SQL database, and custom Javascript.

	I also assisted with the system administration.
	The website was hosted on Amazon Web Services.


- **Teaching**

	I taught numerous courses for both teenagers (with Cambridge Coding Academy) and professionals (with Cambridge Spark) about several aspects of computer science and programming.
	I also trained teachers and tutors.


## Projects at the University of Cambridge

I completed a PhD at the Computer Laboratory of the University of Cambridge.

- **PhD**

	The topic of my PhD is the use of compile-time memory management (to replace execution-time garbage collection) in the context of system programming.

	I wrote the [dissertation](http://www.cl.cam.ac.uk/techreports/UCAM-CL-TR-908.html) in LaTeX, used `mk` to drive the compilation into pdf, and managed the source files with Git.

	I wrote a prototype in OCaml, used `make` to drive the compilation as well as the tests and the benchmarks, and managed the source files with Git.

- **Computer Science Laboratory** (additional work)

	I supervised undergraduate students, both in tutoring sessions and for longer projects.
	I organised [a series of talks](http://talks.cam.ac.uk/user/show/25917) for my research team.
	I contributed to the early setup of the [Computer Science Admission Test](https://www.cl.cam.ac.uk/admissions/undergraduate/admissions-test/) which is used to evaluate candidates to the University of Cambridge Computer Science undergraduate program.

	I was awarded the [Wiseman Award](https://www.cl.cam.ac.uk/local/wiseman.html) for these contributions to the Computer Science Laboratory.

- **Magdalene College MCR Committee member**
	(MCR: the body of graduate students)

	I was Secretary, President and then IT officer of the [MCR](http://mcr.magd.cam.ac.uk/) committee of [Magdalene College](https://www.magd.cam.ac.uk/).
	I organised events for around 100 people, represented students in College matters, and organised committee elections.



## Miscellaneous

- Natural languages: French (native), English (fluent), Spanish (intermediate), Chinese (beginner), Toki Pona (beginner).
- Programming languages: OCaml (native), make (fluent), shell (intermediate), Javascript (rusty), Python (rusty), Scala (rusty), rust (beginner), Scheme (beginner), Haskell (beginner), C (beginner).
- Markup languages: Markdown (native), HTML (fluent), LaTeX (rusty).
- Environment: Archlinux, `vi`(`nvim`), `git`, `acme`, `make`, `mk`, `opam`, `dune`, `sh`/`zsh`, `rc`, `pandoc`, etc.
- Other: driver's license, PADI Advanced Open Water Diver, skilled punter and skater.

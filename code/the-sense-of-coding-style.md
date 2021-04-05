---
title: The Sense of Coding Style
...

> Because discussions about code readability often slides into arguments about some subjective sense of æsthetics

Coding is writing source code.
Much like writing prose, writing source code is about communicating.
You communicate most often to fellow humans (colleagues, contributors, maintainers, reviewers) and occasionally to computers (compilers, language servers, linters).
Because fellow humans have limited attention span, cognitive bandwidth, and patience, you should make reading easy.

(Arguably, a program may be compiled more often than it is read.
However, whether you compile your program once or a thousand times, the same communication is repeated.
And so, for our purpose, multiple communications with the compiler count as one.)

(Below, I focus on communication between the programmer and a singular reviewer.
This is merely to make the examples simpler and clearer.
Nonetheless, the advice should help you just as much to write readable code for other people.)

Another way in which writing code is similar to writing prose: there is a plethora of style guides telling you what to do.
Very few of those style guides ever explain why you should follow their advice, just that you should.

-----------------------------------

*The Sense of Style* (Steven Pinker, ISBN 9780670025855) is a style guide for writing prose, with a focus on clear non-fiction prose.
The book stands out amongst style guides for multiple reasons, including that it explains its advice.
That is, the style guide tells you why a particular piece of advice makes sense and in which contexts it makes sense.
It gives a sense of purpose to the advice and helps you determine the extent to which you should apply it.

-----------------------------------

Some time ago, I reviewed some code.
I noticed a function that looked like this:

```
let dir =
	match dir_from_config () with
	| Some p -> p
	| None -> match dir_from_cli_arg () with
		| None -> def_dir
		| Some p -> p
```

And a little bit further something along the lines of:

```
List.iter
	(fun (formatter, channel) ->
		setup_formatter formatter
			(if is_a_tty channel then Ansi else Plain))
	[ (Format.std_formatter, Unix.stdout) ;
		(Format.err_formatter, Unix.stderr) ]
```

Both of these fragments are correct: they do what they are supposed to.
In other words, with both of these fragments, the programmer communicates successfully with the compiler.
However, the communication with a reviewer (me) fell short.
And so I wanted to suggest alternatives.

Importantly, I wanted to explain what made the alternatives more readable.
This is important because discussions about code, especially code readability, often slides into unfounded arguments about some subjective sense of æsthetics.

Explaining what made the alternatives more readable, I ended up paraphrasing Pinker's The Sense of Style.
And that got me thinking:  
How much of the advice in The Sense of Style can be applied to code?


-----------------------------------

## The Sense of Coding Style

Below is collected advice from The Sense of Style, adapted to writing source code.
I also recommend reading the original: it is indirectly applicable to writing code (as shown below) and directly applicable to writing documentation and tutorials.


### Preliminaries

A few things that need to be said beforehand.

#### What this is not

This is not a tutorial.
You cannot learn to code by reading this page.

This is not an exhaustive list of dos and donts about the minutia of styling.
Instead, this is a collection of pieces of general advice on writing more readable code, each with an explanation of why the advice is helpful.
As such, it stands somewhere between concrete advice about readability and non-specific discourse about what even is readability.

This is not a list of pieces of advice that you can all apply in all situations.
You will need to understand why each piece of advice makes sense and, in many cases, you will need to decide which piece of advice to prioritise.

Note that all the code examples are given in OCaml.
However, the advice is more general: it can be applied to programs written in other languages.


#### Why this is important

Writing readable code is important for multiple reasons.
First, it eases the life of the reviewer of your software.
Making someone else's life easy is nice.  
Be nice.

Second, writing readable code helps avoid bugs.
This is a take on Hoare's famous quote:

> There are two ways of constructing a software design: One way is to make it so simple that there are obviously no deficiencies, and the other way is to make it so complicated that there are no obvious deficiencies.

Whilst Hoare makes the distinction between simple and complicated code, the same distinction between readable and obscure code is just as valid.  
Just like simplicity, readability is a mean to an end: correctness.


### Boilerplate advice

Advice surrounding a software project.

#### Avoid metadiscourse

Metadiscourse is when you write about the structure of the writing (e.g., “Sections 1, 2 and 3 cover … and Sections 4 and 5 cover …”) or about the process of writing (e.g., “We started by researching … for which we attempted to interview … but we were unable to because …”).

A programming equivalent to metadiscourse is the comment that plainly describe the code.

```
(* Sort the elements and remove duplicates *)
List.sort xs |> List.deduplicate
```

Another is historical anecdotes about development.

```
(* This function used to be exposed in the public
   interface. Now it is hidden because … *)
```

Note that in this second example, a comment may be necessary.
However, the comment should focus on the code as it is (`This function is hidden because …`) and not on the trivia of development history (`This function used to…`).

Metadiscourse most often unnecessarily captures some of the limited attention of the reviewer.
Avoid it.


#### Build narratives

In a project, arrange code in an order that the reader can follow.
It can be general-to-specific, or big-to-small, or network-to-disk, or high-level-to-low-level, or user-inputs-to-screen-updates, or database-to-webpage.
The important thing is that the reader is able to latch onto a narrative in order to ease the reading.

One way to achieve this is to include a reading guide for the whole project in your README or for a specific component in a relevant file(s).
Simply add a short section explaining how that module there grabs the keyboard and translates the keycodes, then that other module there parses the keycodes into actions, etc.

Another way that the code can be thought of as a narrative is to lean on the type of narratives that your programming language supports.
In imperative languages such as C, procedure names should be active verbs because they act on the parameters.
In declarative languages such as Haskell, function names should be nouns or past-tense verbs because they create new values that relate to parameters in a certain way.
Compare `subtract(accumulator, delta)` (“actively subtract `delta` from the `accumulator`”) to `difference old_v new_v` (“this expression evaluates to the difference between `old_v` and `new_v`”).

In languages that support multiple styles of programming, use different kinds of names for different kinds of functions.
Compare Python's `someList.sort()` and `sorted(someList)`.

#### Balance

All the advice given on this page (above and below) should be applied only to the extent that it makes code more readable.
Never apply the advice blindly, ask yourself: what does this piece of advice achieve with my code?

Not sure about a specific case?
Ask a colleague's opinion.

Ask for feedback.  
Ask for reviews.  
Ask for advice.



### Identifiers

Naming things is hard.

#### Names

Whilst many style guides insist on using long descriptive names for all variables, there are situations where short names are preferable.

One such situation is with very abstract variables.
For example, in a library implementing a collection, be it a list or an array or a tree, the elements of the collection are abstract.
Because they are abstract, long descriptive names are very generic and abstract themselves: ‘element’, ‘item’, ‘member’, or some such.
In this case, the long name does not carry more information than a single-letter name: `e`, `x`, `v`, or some such.

You can also introduce the naming conventions of your module.

```
(* In this library, the following names are used:
   [e], [x], [y], [z]: elements held in a collection
   [c], [xs], [ys], [zs]: collections
   [acc]: accumulators when traversing a collection
*)
```

Another situation where short names are good is for very local variables.
When a variable is only in scope for a few lines, the reviewer does not need to commit the variable to a long-lived context.
In this case, a short name is sufficient: quickly parsed, quickly forgotten.
The shortness of the name signals to the reviewer that the variable is short-lived.
For example:

```
match … with
| Ok v -> Some v
| Error errors ->
	iter errors
		(fun error ->
			log_error error;
			if is_fatal error then exit 1);
	None
```

Because `v` is simply converted from a positive `result` to a positive `option`, there is no need to dwell on it.
Sure, `successful_result` would be more descriptive, but it would need to be forgotten just as soon.
On the other hand, `errors` deserves more attention because its scope is longer and because it is more consequential.
Thus, `errors` is given a more descriptive name.



#### The curse of knowledge

When you write code, you over-estimate your reader's familiarity with both the code and its context.
When you over-estimate your reader you write more obscure code.

Always consider that your reader is intelligent but unfamiliar with the libraries you are using, the concurrent processes that may be executing, the concurrency model of your scheduler, or any other such minute context.


**Abbreviations**:

To avoid relying on the familiarity of your reviewer, make abbreviations scarce.
And for abbreviations you do use, consider introducing them at the beginning of the module.

```
(* In this module, some variable names are
   reserved for the following uses
   [st]: variable carrying state as defined
         in {!State}
   [cfg]: variable carrying configuration as
          defined in {!Configuration}, the
          variables [cfg_env], and [cfg_cli]
          are inferred from the environment
          and the command line arguments
          respectively.
*)
```

Make abbreviations in interfaces even scarcer:
Even if you use `st` as a variable name in the implementation, the module that packs multiple functions handling such values should be spelled out `State`.
This is because the interface is used to communicate with a larger set of people – including other programmers working on separate projects using your library as a dependency.


**Abstractions**:

Over-estimating your reader, you might refer to abstractions by their technical academic names.
You might be satisfied with documenting a whole module with a blurb along the lines of “implements a *state monad* specialised to handling contexts” or a class with “a *factory* for cooperative threadlets schedulers”.

Using abstractions and defining your own abstractions is important.
In fact, it is arguably what programming/computer science is.
But readers might not know all the abstractions used in your code, nor the nomenclature surrounding them.
Explain abstractions, give examples.


**Functional fixity**:

The more you know how to use a thing, the less you see other ways to use it.
For example, you might start to see a monad as just that: an abstract way to thread data of a specific type through a computation.
But even when you provide a monad library, you should still consider giving a variant of your operators that is more grounded, that reflects more what the function does rather than how it is meant to be used.

Compare the following two chunks.

```
(** monadic bind for the list monad *)
val bind: 'a list -> ('a -> 'b list) -> 'b list
val ( >>= ): 'a list -> ('a -> 'b list) -> 'b list
```

```
(** [flat_map xs f] is equivalent to (but more efficient
    than) [flatten (map f xs)]. In other words,
    [flat_map [x1; x2; ..] f] is equivalent to
    [f x1 @ f x2 @ ..]. *)
val flat_map: 'a list -> ('a -> 'b list) -> 'b list
(** [bind] and [>>=] are aliases for [flat_map]. They are
    provided for use as monad operators for the list monad. *)
val bind: 'a list -> ('a -> 'b list) -> 'b list
val ( >>= ): 'a list -> ('a -> 'b list) -> 'b list
```

This helps in multiple ways.
First, for the reviewer, who might not be familiar with the specific monad they are reviewing, it splits the work into two easier tasks:
verify that the function's implementation is correct (i.e., that its behaviour matches its name and documentation)
and verify that the function combines with others according to the monadic laws.
By merely exporting a more explicitly named function alongside the abstractly named function, you prepare this two-step work for the reviewer.

Second, it helps users of your library to use your provided function in a non-monadic setting.

This advice applies equally to abstractions other than a monad.



### Grammars

Advice about trees.


#### The graph, the tree, and the string

The Sense of Style goes to great lengths to explain how grammar is a way to encode parts of a graph of ideas into a string of words.
Specifically, grammar allows a speaker/writer to represent a few ideas and the links between them (a graph) as a tree of grammatical constructs and then that tree as a string of words.
In other words, grammar is a serialiser.

Grammar is also a set of rules for retrieving the serialised graph of ideas from the string representation.
Specifically, grammar allows a listener/reader to recover, from a string of words, a tree of grammatical constructs, and then, from that tree, the ideas and links it represents.
In other words, grammar is also a parser.

For example “the quick brown fox jumps over the lazy dog” is a serialisation of an idea that a certain animal with a certain coat and a certain aptitude performs a specific action in a specific location relative to another animal with a certain character flaw.
The same idea can be serialised differently as “over the dog that is lazy, the fox that is fast and brown jumps” or other such variation.
A human that understands English understands how to deserialise either of the sentences to recover the meaning.

As far as this encoding/decoding goes, programmers and reviewers enjoy several advantage over the writers and readers of prose.

One advantage of programming languages is that the rules of parsing are formalised.
As a result, there are no ambiguous strings that may be interpreted as two distinct trees.
Or if there are, then it's neither the writer's nor the reader's fault: it's the compiler's.

Another advantage of programming languages is that programmers have much more freedom in the serialising.
For example, in most programming languages, programmers can add extraneous parentheses and break line freely.
Even if these syntactic options are not available, then a programmer can associate additional names to a value or break a function in multiple parts.

Finally, a big advantage of programming languages is that the tree has more importance than in prose.
Reviewers have explicit knowledge of what the tree is; the tree even bears a name: the abstract syntax tree (AST).
Reviewers attempt to first recover the tree, and then the process it describes.

These are two things programmers can help reviewers with: recovering the tree and inferring what process it describes.

#### From the pixels on a screen to the AST

A reviewer starts by parsing your code to build a mental representation of the abstract syntax tree.
The first step a reviewer takes is parsing your code: reading the visual representation of a stream of bytes on the screen, and building an AST from that visual representation.

A good exploration of this topic is available in the paper [“A visual perception account of programming languages: finding the natural science in the art” (by Stéphane Conversy)](https://hal.inria.fr/file/index/docid/737414/filename/langViz-popl-submitted.pdf).

The paper explains how a reader reads code, what visual processes it involves, etc.
It also explains how certain editor features (such as syntax colouring) or writing conventions (such as indentation) can be helpful to the reader.
All in all, this paper gives a good framework for talking about the pixels-to-AST conversion.


**Indentation**:

One way that the programmer can help the reviewer is to match the visual representation to the AST.
For example, indenting the code gives an easy way for the reviewer to asses the general shape of the AST.
The number of blank pixels on the left-hand-side of each line gives an indication of the shape of the program.

However, matching the indentation to the AST depths only addresses half of the indentation issue.
The other half of the issue is to shape the AST correctly.
Shaping the AST correctly makes for a simpler indentation pattern (as shown in the example below).
Additional (non indentation-related) advantages of shaping the AST correctly are explored later.

In general, flat or end-heavy trees are easier to read because they minimise the distances that separate related things.
Consider the three examples below which have equivalent but distinct ASTs.

As a beginning-heavy tree, finding the error-printing that matches the error condition requires scanning through many empty lines.

```
if time < now then
	if not (is_full buffer) then
		if valid_entry input then
			if is_unknown_entry input then
				insert_new_entry input
			else
				update_entry input
		else
			print_error "Input is invalid"
	else
		print_error "Buffer is full, cannot process"
else
	print_error "Update is in the future"
```

As a mixed-heavy tree, it is not immediately clear what are error conditions versus valid conditions, nor where the branches lead to.

```
if time < now then
	if is_full buffer then
		print_error "Buffer is full, cannot process"
	else if valid_entry input then
		if is_unknown_entry input then
			insert_new_entry input
		else
			update_entry input
	else
		print_error "Input is invalid"
else
	print_error "Update is in the future"
```

As a end-heavy tree, each error message follows immediately its error condition and the control-flow is immediately obvious.

```
if now <= time then
	print_error "Update is in the future"
else if is_full buffer then
	print_error "Buffer is full, cannot process"
else if not (valid_entry input) then
	print_error "Input is invalid"
else if is_unknown_entry input then
	insert_new_entry input
else
	update_entry input
```

Note that in many cases, end-heavy trees can be indented as flat trees.
This last example is one such case.
Sequences of binding are another.


**Syntactical parallelism**:

When two functions do similar things, they should have similar names.
When two variables hold similar values, they should have similar names.

For example, avoid mixing snake and camel case in a single project – or, if you do, do so to highlight fundamental differences between two kinds of values.
But also avoid having a `filter_elements_out_of_list` (active verb) along with a `collection_filter` (noun-phrase): if the two have the same effect, their naming should follow similar conventions.

In general, when things are alike, their textual representation should be similar.
This is the syntactical pendant to structural parallelism (see below for details).


#### From the AST to groking the code

After parsing the AST in their head, a reviewer then tries to understand what the AST means:  
How does control flow from one place to another?  
How does data flow from one place to another?  
How does a given part of the tree transforms a given piece of data?  
How does an error propagates through the tree?

Whilst building an understanding of the program, the reviewer needs to maintain a working memory of the context of the code they are reviewing.
For example, when reading a line, they need to have an idea of what variables are in scope and what their values represent, under what conditions can the program reach that line, etc.
To ease the review, programmers can shape their trees in a way that reduces cognitive workload for the reviewers.


**The depth and width of trees**:

In order to reduce the cognitive workload of reviewers, prefer flat-and-wide trees to deep-and-narrow trees.
This is because, in general, the conditions necessary to reach a deep node of the AST are more intricate.

(Remember that, as explained above, end-heavy trees are similar to flat-and-wide trees.)

Look back at the indentation examples above and notice how the end-heavy tree is easier to parse.
In particular, consider what information you need to keep in mind when reviewing this tree.
The conditions necessary to reach a given line is a conjunction of simple boolean expressions that appear above it.
That conjunction grows regularly as you read more and more lines.

Conversely, the beginning-heavy version requires more effort.
Whether you take a line-by-line approach (in which you must first build up a conjunction of expressions, and then unwind it carefully one after the other in LIFO order) or a condition-by-condition approach (in which you read a condition and immediately move your attention to the `else`-branch before coming back to the `then`-branch), you need to keep more context in mind.


**The order of branches**:

If you do have to include some deep trees, then prefer **end-heavy** trees.
The heaviness being at the end means that the reviewer can understand the beginning part, commit that understanding to memory, and then move on to understand the rest.
By contrast, a tree that is middle-heavy requires a lot of stack unwinding from the reviewer.

Refer back to the indentation examples above and work through how your focus has to move through the text whilst you attempt to understand them.

For the same reason, if you find yourself with a branch that requires a comment (because it is too hard to understand without it), then this branch should be placed at the end.

Another way to order branches is **given-before-new** (a.k.a. **known-before-unknown**): finish processing related data before processing the next bit.
In the example below, note how the order of the branches places the processing (`process_with_…`) near the respective queries (`find_…`).

```
match find_metadata_date picture with
| Some date -> process_with_metadata_date picture date
| None -> match find_file_creation_date picture with
	| Some date -> process_with_file_date picture date
	| None -> fail "cannot find date for picture"
```

Another factor to consider when ordering branches is **normal-before-exception**.
In general, inputs can be categorised into two: valid and expected inputs, and invalid or unexpected inputs.
Thinking about invalid/unexpected inputs has a greater cognitive load because it requires having to think about corner cases, unusual conditions, etc.

How to reconcile these rules?
When you have a simple exception handling and a complex normal case, do you put the normal (complex) branch first or the simple (exception) branch first?
You can try both and assess for yourself or ask a colleague to help.
You can also move part of the processing into a separate function with a descriptive name.

```
let retreive_information key =
	let connection = connect_to_server config.server in
	let request = get connection key in
	let raw_result = wait request in
	let result = parse_raw_information raw_result in
	result

let retreive_information key =
	try retreive_information key
	with e -> log e; exit 1
```

More generally, you can use the abstractions available in the programming language –or even introduce your own– so as to order your branches in a way that follows the different pieces of advice above.

Consider an error monad.
Specifically, consider the program below and how the error monad pushes the exception-handling code at the end.
This helps the reviewer to temporarily tune-down error management: first review the chain of calls (`open_file`, `read_content`, `split_into_lines`), and only later review the handling of errors.

```
let ( >>= ) v f = match v with
	| Ok ok -> f ok
	| Error error -> Error error

let catch_all f v =
	try Ok (f v) with e -> Error e

let lines_of_file file =
	match
		catch_all open_file file >>= fun handle ->
		catch_all read_content handle >>= fun content ->
		Ok (split_into_lines content)
	with
	| Ok lines -> lines
	| Error exc -> log_exception exc; exit 1
```


**Structural parallelism**:

When two functions do similar things, their AST should be shaped similarly.
When two variables hold similar values, the AST of the expressions that initialises them should be shaped similarly.

In many cases, avoiding repetitions is easy: two functions that do similar things can often be made into a single function that accepts an additional parameter.
Even when factoring the two functions into one is not possible, parts of them can sometimes still be factored out into a third function.
Because of the relative ease with which programmers can avoid repetition, they tend to try to always avoid repetition.

However, repetition is fine – especially when it simplifies the code.

For example, consider some limitation of a programming language that prevents the factoring out of two functions.
Let's say that we cannot use any fancy features due to backwards compatibility with early versions of the language or compatibility with some other compiler.
Let's say, specifically, that we need to duplicate a function to work on two different kinds of collections: lists and arrays.

```
let summarize_list l =
	let sum = List.fold_left (+) 0 l in
	let len = List.length l in
	if len > threshold_length then
		skewed_average (List.nth l 0) sum len
	else
		sum / len
```

The array counterpart to this list function should look very similar.
It should, as much as possible, be a simple substitution of module identifiers.

```
let summarize_array a =
	let sum = Array.fold_left (+) 0 a in
	let len = Array.length a in
	if len > threshold_length then
		skewed_average a.(0) sum len
	else
		sum / len
```

The similarity in the structure of the function's tree point to the similarities in the meaning of the function.
Understanding the second version becomes a simple game of “spot the difference”.
And a reviewer can easily cheat at such a game using tools such as `diff`.


#### Use positives

Avoid `not` in your conditional.
Prefer `length collection > threshold` rather than `not (length collection <= threshold)`.
The former is simpler to parse than the latter.

Applying this piece of advice is often impossible because libraries don't always export the needed values.
Indeed, it is common for collection libraries to export `is_empty` without `has_at_least_one_element`.

Exporting multiple values without increasing the expressive power of a library is often frowned upon:
it bloats the interface,
it increases the footprint of the namespace,
it requires additional maintenance.

Apply this advice when you can, but do not fret when you cannot.
In general, it is less important than ordering the branches of your conditional.



--------------------------------------------------------------------------------

Let's look back at the examples from the introduction, the pieces of code that spun this whole thing.
We can apply the advice above to make the code more readable.

**Chaining options**:

The original parsing of the directory option looked like this.

```
let dir =
	match conf_dir () with
	| Some p -> p
	| None -> match cli_dir () with
		| None -> def_dir
		| Some p -> p
```

It is difficult to read for several reasons:

- First, abbreviations are obscure.
	This is partly alleviated by the context in which the code originally appeared.
	Nonetheless, there is litlle point in not spelling out that `dir` refers to a directory and that `conf_` and `cli_` are prefixes for configuration file and command line interface argument respectively.
- Second, the ordering of the pattern in the two `match` constructs differ.
	This breaks structural parallelism and it makes the tree mixed-heavy.

More readable versions follow.
In the first improved version, we expand the variable names and we reorder the branches in the match clauses.


```
let directory =
	match directory_from_configuration () with
	| Some path -> path
	| None -> match directory_from_command_line () with
		| Some path -> path
		| None -> default_directory
```

Note that the indentation can be confusing.
Indeed, whilst syntactically the expressions are nested, conceptually they are more sequential.

```
let directory =
	match directory_from_configuration () with
	| Some path -> path
	| None ->

	match directory_from_command_line () with
	| Some path -> path
	| None ->

	default_directory
```

An even more readable version uses an abstraction to remove the repetitive boilerplate.

```
(* [>||>] separates multiple optional values and returns
   the left-most one (i.e., the first one) that is
   not [None].
   More formally: [None >||> f] is [f ()]
   and [Some v >||> _] is [v]. *)
let ( >||> ) o if_none = match o with
	| Some v -> v
	| None -> if_none ()

let dir =
	dir_from_configuration ()
	>||> fun () -> dir_from_command_line_argument ()
	>||> fun () -> default_dir
```

**Initialisation**:

The original code setting up the formatters was as follows.

```
List.iter
	(fun (formatter, channel) ->
		setup_formatter formatter
			(if is_a_tty channel then Ansi else Plain))
	[ (Format.std_formatter, Unix.stdout) ;
	  (Format.err_formatter, Unix.stderr) ]
```

The use of `List.iter` here is unnecessary.
It actually complicates the code both from a runtime point-of-view (the list with its tuples is allocated and then traversed dynamically) and from a syntactical point-of-view (the AST is deeper than the `List.iter`-less version is wide).

The choice to use `List.iter` seem to have been driven by the desire to avoid multiple syntactic calls to `setup_formatter`, to avoid syntactic repetition.
However, repetition is completely acceptable and even makes sense when used reasonably and consistently:


```
let mode_of_channel channel =
	if is_a_tty channel then Ansi else Plain in
setup_formatter Format.std_formatter (mode_of_channel Unix.stdout);
setup_formatter Format.err_formatter (mode_of_channel Unix.stderr)
```


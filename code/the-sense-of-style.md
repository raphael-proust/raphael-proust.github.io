---
title: The Sense of Style (of Source Code)
...

Coding is writing source code.
Much like writing prose, writing source code is about communicating.
You communicate most often to fellow humans (colleagues, contributors, maintainers, reviewers) and occasionally computers (compillers, language servers, linters)[^often-occasionally].
Because fellow humans have limited attention span, cognitive bandwidth, and patience, you should make reading easy.

[^often-occasionally]: Arguably, a program may be compiled more often than it is read.
However, whether you compile your program once or a thousand times, the communication is repeated exactly.
This means that many communications with the compiler count as one for our purpose.


Another way in which writing code is similar to writing prose: there is a plethora of style guides telling you how to do it.
Very few of those style guides ever explain why you should follow their advice, just that you should.

-----------------------------------

*The Sense of Style* (Steven Pinker, ISBN 9780670025855) is a style guide for writing prose, with a focus on clear non-fiction prose.
The book stands out amongst style guides for multiple reasons, including that it explains its advice.
That is, the style guide tells you why a particular piece of advice makes sense and in which contexts it makes sense.
It helps you to determine to what extent you should apply the pieces of advice because it gives them a sense of purpose.

-----------------------------------

I recently had to review some code.
I noticed a function that looked like this:

```
let dir =
  match dir_from_config () with
  | Some p -> p
  | None -> match dir_from_cli_arg () with
    | None -> def_dir
    | Some p -> p
```

Followed by something along the lines of:

```
List.iter
  (fun (formatter, channel) ->
    setup_formatter formatter (if is_a_tty channel then Ansi else Plain)
  )
  [ (Format.std_formatter, Unix.stdout) ;
    (Format.err_formatter, Unix.stderr)
  ]
```

Both of these fragments are correct: they do what they are supposed to.
In other words, with both of these fragments, the programmer communicates succesfully to the compiler.
However, as far as communicating with a fellow programmer or with a reviewer (as was the case), it fell a tiny bit short.
And so I wanted to suggest alternatives.

What's more, I wanted to explain what made the alternatives more readable.
This is important because discussion about code, especially code readability, can often slide into unfounded argumentation about some subjective sense of æsthetics.

For both suggestions, I ended up paraphrasing Pinker's The Sense of Style.
And that got me thinking:  
How much of the advice in The Sense of Style can be applied to code?


-----------------------------------

# The Sense of Coding Style

Below is collected advice from The Sense of Style, adapted to writing source code.
I recommend reading the original which contains much more detail – and is directly applicable to writing documentation, tutorials, etc.
But in addition, here are pointers to make your code more readable.


## Preliminaries

### What this is not

This is not a tutorial.
You cannot learn to code by reading this page.

This is not an exhaustive list of dos and donts about the minutia of styling.
Instead, this is a collection of pieces of general advice on writing more readable code, each with an explanation of why the advice is helpful.

This is not a list of advice that you can all apply in all situations.
You will need to understand why each piece of advice make sense and, in many cases, you will need to decide which to prioritise.


### Why this is important

Writing readable code is important.
It eases the life of the reviewers of your contributions and more generally the maintainers of your software.
In the remaining of this page, I will focus on the review process, understanding that the advice applies to communication with other people as well.

The obvious way in which writing readable code is important is that reviewers of your code have an easier time reading it, making the review process smoother.

A less obvious way in which writing readable code is important is that it can avoid bugs.
This is a take on Hoare's famous quote:

> There are two ways of constructing a software design: One way is to make it so simple that there are obviously no deficiencies, and the other way is to make it so complicated that there are no obvious deficiencies.

Whilst Hoare makes the distinction between simple and complicated code, it is just as true that when the code is readable then the deficiencies (or lack thereof) are just as obvious.
Simplicity is a mean to an end; the end is readability.


## Boilerplate advice

### Metadiscourse

Metadiscourse is when you write about the structure or the process of writing.
When an author writes about writing or about the research that lead to the writing or about the layout of all the facts that are written, it is metadiscourse.

In programming, metadiscourse often takes the form of comments that plainly describe the code.

```
(* Sort the elements and remove duplicates *)
List.sort xs |> List.deduplicate
```

Or historical annecdotes about development.

```
(* This function used to be exposed in the
   public interface. Now it is hidden
   because … *)
```

Note that in this second example, a comment may be necessary.
However, the comment should focus on the code as it is (`This function is hidden because …`) and not on the trivia of development history (`This function used to…`).


### Whole-project narative

In a project, arrange code in an order that the reader can follow.
It can be general-to-specific, or big-to-small, or network-to-disk, or high-level-to-low-level, or user-inputs-to-screen-updates, or database-to-webpage.
The important thing is that the reader follows a narrative in your code.

One way to acheive this is to include a reading guide for the whole project in your README or for a specific component in a relevant file(s).
Simply add a short section explaining how this module grabs the keyboard and translates the keycodes, then that module parses the keycodes into actions, then that module executes the actions, and finally that module updates the screen whenever an action finishes executing.

Another way that the code can be thought of as a narrative is to lean on the type of narrative that your programming language supports.
In imperative languages such as C, procedure names should be active verbs because they act on the parameters.
In declarative languages such as Haskell, function names should be nouns or past-tense verbs because they create new values that relate to parameters in a certain way.
Compare `subtract(accumulator, delta)` (“actively subtract `delta` from the `accumulator`”) to `difference old_v new_v` (“this expression evaluates to the difference between `old_v` and `new_v`”).
In languages that support multiple styles of programming, use different kinds of names for different kinds of functions.


### Names

In general, short names are good for very local or very abstract variables.
For example, in a library implementing a collection, be it a list or an array, the elements of the collection are abstract and can take on a generic variable name such as `e`, `elt`, `x`, `v`, or some such.
But even in that case, mentioning so in a comment is good.

```
(* In this List library, the following names
   are used:
   [e]: elements held in a list
   [l]: lists
   [acc]: accumulators when traversing a list
*)
```

Another example is a variable that is only in scope for a few lines.
In that case, using a short name signals to the reviewer that the variable is short-lived.

```
… >>= function
| Ok v -> Some v
| Error errors ->
	iter errors
		(fun e ->
			log_error e;
			if is_fatal e then exit 1);
	None
```


### The curse of knowledge

When you write code, you over-estimate your reader's familiarity with both the code and its context.
When you over-estimate your reader you write more obscure code.

Always consider that your reader is intelligent but unfamiliar with the libraries you are using, the concurrent processes that may be executing, the concurrency model of your scheduler, or any other such minute context.


**Abbreviations**:

Over-estimating the reader, you use copious amounts of abbreviations.
You name `st`, or even `s`, a variable holding some kind of state, you name configuration `cfg`, and a connection `conn`.

Make abbreviations scarce, and introduce them even if you consider them common practice.

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



**Jargon**:

Over-estimating the reader, you use copious amounts of jargon.
Overuse of jargon is very similar to overuse of abbreviations and similar effort should be made to introduce it.


**Abstractions**:

Over-estimating your reader, you refer to abstractions by their technical academic names.
You are satisfied with documenting a whole module with a blurb along the lines of “implements a *state monad* specialised to handling contexts defined in {Context}” or a class with “a *factory* for cooperative threadlets schedulers”.

Using abstractions and defining your own abstractions is important.
In fact, it is arguably what computer science/programming is.
But readers might not know all the abstractions used in your code, nor the nomenclature surrounding them.
Explain abstractions and their use.

Another way in which you may become overly abstract is in naming values.
Specifically, you may name `level` a variable that refers to the “level of verbosity” in a logging mechanism.
However, `level` is the abstract part of the phrase “level of verbosity” and is less informative than the concrete part: `verbosity`.
Compare

```
val emit: level -> event -> unit
val emit: verbosity -> event -> unit
```

Choose a more concrete name when one is available.


**Functional fixity**:

The more you know how to use a thing, the less you see other ways to use it.
For example, you might start to see a monad as just that: an abstract way to thread data of a specific type through a computation.
But even when you provide a monad library, you should still consider giving a variant of your operators that is more grounded, that reflects more what the function does rather than how it is meant to be used.

Compare

```
(** [bind] is the monadic bind for the list monad *)
val bind: 'a list -> ('a -> 'b list) -> 'b list
val ( >>= ): 'a list -> ('a -> 'b list) -> 'b list
```

and

```
(** [flat_map x f] is [flatten (map f x)]. In other words,
    [flat_map [x1; x2; ..] f] is [f x1 @ f x2 @ ..]. *)
val flat_map: 'a list -> ('a -> 'b list) -> 'b list
(** [bind] and [>>=] are aliases for [flat_map]. They are
    provided for use as monad operators. *)
val bind: 'a list -> ('a -> 'b list) -> 'b list
val ( >>= ): 'a list -> ('a -> 'b list) -> 'b list
```

This helps in multiple ways.
First, for the reviewer, who might not be familiar with the specific monad they are reviewing, it splits the work into two easier tasks: verify that the function's implementation is correct (i.e., that its behaviour matches its name and documentation) and verify that the function combines with others according to the monadic laws.
By exposing a more explicitely named function accompanied by an abstractly named function, you prepare this two-step work for the reviewer.

Second, it helps users of your library to use your provided function in a non-monadic setting.

This adivce applies to abstractions other than monad as well.


### Balance

Spelling out every acronym can be very condescending and may lead to overly-long lines or excessive line breaking.
With the advice above, as with the rest, apply it to the extent that it makes the reader's life easier.
Not sure about a specific case?
Er on the side of explaining more, and ask a colleague's opinion.

Seek feedback.  
Seek reviews.  
Seek advice.  
Seek help.


## The graph, the tree, and the string

The Sense of Style goes to great length to explain how grammar is a way to encode parts of a graph of ideas into a string of words.
Specifically, grammar allows a speaker/writer to represent a few ideas and the links between them as a tree of grammatical constructs and then that tree as a string of words.
In other words, grammar is a serialiser/pretty-printer.

Grammar is also a set of rules for retreiving the encoded graph of ideas from the string representation.
Specifically, grammar allows a listener/reader to recover, from a string of words, a tree of grammatical constructs, and then, from that tree, the ideas and links it represents.
In other words, grammar is a lexer/parser.

For example “the quick brown fox jumps over the lazy dog” is a serialisation of an idea that a certain animal with a certain coat and a certain aptitude performs a specific action in a specifc place relative to another animal with a certain character flaw.
The same idea can be serialised differently as “over the dog that is lazy, the fox that is fast and brown jumps” or other such variation.
A human that understands English understands how to deserialise either of the sentences to recover the meaning.

As far as this encoding/decoding goes, programmers and reviewers enjoy several advantage over the writers and readers of prose.

One advantage of programming languages is that the rules of parsing (and sometimes serialising) are formalised.
As a result, there are no ambiguous strings that may be interpreted as two distinct trees.
Or if there are, then it's neither the writer's nor the reader's fault: it's the compiler's.

Another advantage of programming languages is that programmers have much more freedom in the serialising.
For example, in most programming languages, programmers can add extraneous parentheses and break line freely.
Even if these syntactic options are not available, then a programmer can associate additional names to a value or break a function in multiple parts.

Finally, a big advantage of programming languages is that the tree is more important than in prose.
Reviewers have explicit knowledge of what the tree is; the tree even bears a name: the abstract syntax tree (AST).
Reviewers attempt to first recover the tree, and then the process it describes.

These are two things programmers can help reviewers with: recovering the tree and inferring the process from it.

### From the pixels on a screen to the AST

A reviewer starts by parsing your code to build a mental representation of the abstract syntax tree.
The first step a reviewer takes is parsing your code: reading the visual representation of a stream of bytes on the screen, and building an AST from that visual representation.

A good exploration of this topic is available in the published paper [“A visual perception account of programming languages: finding the natural science in the art” (by Stéphane Conversy)](https://hal.inria.fr/file/index/docid/737414/filename/langViz-popl-submitted.pdf).

The paper explains how a reader reads code, what visual processes it involves, etc.
It also explains why certain editor features (such as syntax colouring) or writing conventions (such as indentation) are helpful to the reader.
All in all, this paper gives a good framework for talking about the pixels-to-AST conversion.


#### Indentation

One way that the programmer can help the reviewer is to match the visual representation to the AST.
For example, indenting the code gives an easy way for the reviewer to asses the general shape of the AST.
The number of blank pixels on the left-hand-side of a line gives an indication of the shape of the program.

Whilst reading the pixels on the screen, the reviewer needs to understand how branches of the tree connect to each other: where conditional branches start and end, what flow-control structure surround the line they are currently scanning, etc.
In order to ease this part of the review, programmers can attempt to make their trees flat or end-heavy.
Consider the two examples below which have equivalent but distinct AST.

As a beginning-heavy tree, finding the error printing matching the error condition requires scanning through empty lines.

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
        print_error "Buffer full, cannot process"
else
    print_error "Update is in the future"
```

As a mixed-heavy tree, it is not immediately clear what are error conditions versus valid conditions, nor where the branches lead to.

```
if time < now then
    if is_full buffer then
        print_error "Buffer full, cannot process"
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
    print_error "Buffer full, cannot process"
else if not (valid_entry input) then
    print_error "Input is invalid"
else if is_unknown_entry input then
    insert_new_entry input
else
    update_entry input
```


#### Syntactical parallelism

When two functions do similar things, they should have similar names.
When two variables hold similar values, they should have similar names.

For example, avoid mixing snake and camel case in a single project – or, if you do, do so to highlight fundamental differences between two kinds of values.
But also avoid having a `filter_elements_out_of_list` (active verb) along with a `collection_filter` (noun-phrase): if the two have the same effect, their naming should follow similar conventions.

In general, when things are alike, their textual representation should be similar.
This is the syntactical pendant to structural parallelism (see below for details).


### From the AST to groking the code

After parsing the AST in their head, a reviewer then tries to understand what the AST means:  
How does control flow from one place to another?  
How does data flow from one place to another?  
How does a given part of the tree transform a given piece of data?  
How does an error propagates through the tree?

Whilst building an understanding of the program, the reviewer needs to maintain a working memory of the context of the code they are reviewing.
For example, when reading a line, they need to have an idea of what variables are in scope and what their values represent, under what conditions can the program reach that line, etc.
To ease the review, programmers can shape their trees in a way that reduces cognitive workload for the reviewers.


#### The shape of trees

In order to reduce the cognitive workload of reviewers, prefer flat-and-wide trees to deep-and-narrow trees.
This is because, in genreal, the conditions necessary to reach a deep node of the AST are more intricate.

#### The order of branches

If you do have to include some deep trees, then prefer **right-**/**end-heavy** trees.
The heaviness being at the end means that the reviewer can understand the beginning part, commit that understanding to memory, and then move on to understand the rest.
By contrast, a tree that is middle-heavy requires a lot of stack unwinding from the reviewer.

Refer back to the indentation examples above and work through how your focus has to move through the text whilst you attempt to understand them.

For the same reason, if you find yourself with a branch that requires a comment (because it is too hard to understand without it), then this branch should be places on the right/at the end.

Another way to order branches is **given-before-new**/**known-before-unknown**: finish processing related data before processing the next bit.
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
Thinking about invalid/unexcepted inputs has a greater cognitive load because it requires having to think about corner cases, unusual conditions, etc.

How to reconcile these rules?
When you have a simple exception handling and a complex normal case, do you put the normal branch first or the simple branch first?
You can try both and assess for yourself or ask a colleague to help.
You can also detach the exception handling from the normal processing using a function/procedure.

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
Specifically, consider the program below and how the error monad pushes the exception code at the end.
This helps the reviewer temporarily tune-down error management: first review the chain of calls (`open_file`, `read_content`, `split_into_lines`), and only later review the handling of errors.

```
let ( >>= ) v f = match v with
    | Ok ok -> f ok
    | Error error -> Error error

let catch_io f v =
    try Ok (f v) with IO_Error _ as e -> Error e

let lines_of_file file =
    match
        (catch_io open_file file) >>= fun file_handle ->
        (catch_io read_content file_handle) >>= fun file_content ->
        Ok (split_into_lines file_content)
    with
    | Ok lines -> lines
    | Error error ->
        log_error error;
        exit 1
```


#### Structural parallelism

When two functions do similar things, their AST should be shaped similarly.
When two variables hold similar values, the AST of the expression that initialises them should be shaped similarly.

In many cases, avoiding repetitions is easy: two functions that do similar things can often be made into a single function that accepts an additional argument.
Even when factoring the two functions into one is not possible, parts of them can sometimes still be factored out into a third function.
Because of the relative ease with which programmers can avoid repetition, they tend to try to always avoid repetition.

Let's go back to one of the opening examples of this page:

```
List.iter
  (fun (formatter, channel) ->
    setup_formatter formatter (if is_a_tty channel then Ansi else Plain)
  )
  [ (Format.std_formatter, Unix.stdout) ;
    (Format.err_formatter, Unix.stderr)
  ]
```

Notice the use of `List.iter` which allows to only write out a single call to `setup_formatter`.
However, avoiding this repetition requires a lot of boilerplate code and non-trivial control-flow.
Compare to the following version with a repeated call to the initialisation function:

```
let setup formatter channel =
    setup_formatter formatter (if is_a_tty channel then Ansi else Plain)
let () = setup Format.std_formatter Unix.stdout
let () = setup Format.err_formatter Unix.stderr
```

Repetition is ok, especially when it simplifies the code.
Moreover, when repetition needs to happen, the repetition should be made with a point.

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
It should, as much as possible, be a simple subsitution of identifiers.

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
Understanding the second version becomes a simple game of “spot the difference” – which can even be assisted by tools such as `diff`.


### Use positives

Avoid `not` in your conditional.
A condition along the lines of `not (is_empty l)` takes longer to parse and understand than a conditional that says `has_elements l`.
Similarly, `has_space` is better than `not is_full` and `is_broken` is better than `not is_valid`.

This advice has implications for library code: in order to allow application code to be written following this advice, libraries need to provide positive conditionals.

```
val is_full: buffer -> bool
val has_free_space: buffer -> bool
```

```
val is_sleeping: thread -> bool
val is_running: thread -> bool
```

```
val has_ended: task -> bool
val is_ongoing: task -> bool
```

Etc.



--------------------------------------------------------------------------------

Already, we can explore the examples from the introduction, the pieces of code that spun this whole thing.
We can apply the advice above to make the code more readable.

### Chaining options

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
	Nonetheless, there is litlle point in not spelling out that `dir` refers to a directory and that `conf_` and `cli_` are prefixes for configuration file and command line argument respectively.
- Second, the ordering of the pattern in the two `match` constructs differ.
	This breaks structural parallelism and it makes the tree middle-heavy.

More readable versions follow.
In the first improved version, we expand the variable names and we reorder the branches in the match clauses.


```
let directory =
  match directory_from_configuration () with
  | Some path -> path
  | None -> match directory_from_command_line_argument () with
    | Some path -> path
    | None -> default_directory
```

In the second version, we introduce a TODO


```
let ( ||> ) o if_none = match o with
  | Some v -> v
  | None -> if_none ()
in
let dir =
  dir_from_configuration ()
  ||> fun () -> dir_from_command_line_argument ()
  ||> fun () -> default_dir
```

```
let directory =
  match directory_from_configuration () with
  | Some path -> path
  | None ->

  match directory_from_command_line_argument () with
  | Some path -> path
  | None ->

  default_directory
```

### Initialisation

```
let mode_of_channel channel =
  if is_a_tty channel then Ansi else Plain
in
setup_formatter Format.std_formatter (mode_of_channel Unix.stdout);
setup_formatter Format.err_formatter (mode_of_channel Unix.stderr)
```


------------------------------------------------------------

```
match data_dir with
| Some data_dir -> return data_dir
| None ->
    match config_file with
    | None ->
        let default_config =
          Node_config_file.default_data_dir // "config.json" in
        if Sys.file_exists default_config then
          Node_config_file.read default_config >>=? fun cfg ->
          return cfg.data_dir
        else
          return Node_config_file.default_data_dir
    | Some config_file ->
        Node_config_file.read config_file >>=? fun cfg ->
        return cfg.data_dir
```

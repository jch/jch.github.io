# Kernel Designs #

I really enjoyed my introductory operating systems class at Berkeley.
The class focused on classic high level OS concepts like process
models, virtual memory, concurrency, and more.  To go along with the
material, teams of 4 formed to implement components in a toy OS called
[Nachos](http://www.cs.washington.edu/homes/tom/nachos/).  The purpose
of this was to keep students focused on the concepts rather than wade
through the quagmire that is x86 assembly.

I was very proud of the finished project.  We wrote basic processes
and threads with priorities, memory manangement, system calls, and a C
chat program.  All of this could be booted up and ran on the virtual
'Machine' object that emulated a MIPs architecture machine.

Unfortunately, I did not follow up with more advanced topics after the
class, and while those high level concepts are solid fundamentals, I
sorely wish to see what designs have been tried in practice, along
with their benefits and drawbacks.  Rather than dive blindly into the
source of popular open source kernels from Linux and BSD, I plan to
start by reading some research papers on kernel design.  Hopefully
this will refresh my memory about some key terms while letting me
survey what's available.

## Mach Microkernel ##

The Mach kernel is a microkernel developed by CMU in the eighties to
address issues with multiprocessors and networked environments, and
the growing complexity of BSD systems.

BSD began with a very clean and simple abstraction of files to model
major components such as devices and memory.  Using files allowed for
very natural manipulation of these resources with pipes and simple
utilities.  Unfortunately, this abstraction did not fit later desired
features.  This lead to adding orthogonal abstractions for different
tasks.  Mach tries to bring back a clean uniform interface with a
objected-oriented abstraction.  The 4 basic abstractions are:

* task - execution environment.  Think of this as a basic container
  for everything needed to run a program.  Things like virtual memory
  address space, file descriptors, threads, capabilities and other
  resources.  Example messages: fork, allocate (memory)

* thread - basic unit of computation.  Similar to threads in processes
  for Unix.  Example messages: destroy, suspend, resume.

* port - communication channel.  A way to reference other tasks and
  threads.  An object sends a 'message' to another object through a
  port on the receiving object.  Messages are queued up in ports.
  Think classic Smalltalk and Objective-C style message passing.

* message - actions and data between tasks and threads.

The emphasis on separating tasks and threads seems like a big idea of
the paper.  I originally thought that Unix had multiple threads per
process, but from the paper, it sounds like at that time Unix used
very expensive forks and hacks in order to achieve concurrency.  A
great example they used for supporting the task/thread abstraction is
machines with *N* processors.  Instead of creating *N* heavy weight
processes with 1 thread each, Mach would create 1 heavy weight task to
describe what's needed to run, and *N* relatively lightweight threads
to take advantage of the concurrency.


## Virtual Memory ##

The abstraction for virtual memory allows Mach to be machine
independent.  Each task holds it's own 'address map' of what memory it
owns.  This is the same as the basic concept I learned in class.  The
maps map from address to either virtual memory (VM) objects, or to
'shared maps'.  The 'shared maps' are a way for tasks to share memory.
VM objects are either pages that have already been fetched, or
instructions of where to fetch the page if it hasn't been fetched.
Pages themselves have attributes that specify their current status and
properties.

## Interprocess Communication ##

BSD sockets are simply streams of bytes left up to the application to
interpret.  Mach's port/message abstraction provides uniform
interprocess communication.  There is no difference between two
processes on the same host talking, verus two processes on different
network hosts talking.  On top of that, the port/message mechanism
lets you add meaning and stricter checking on the data that is passed
around.  Capabilites of who can send and receive what can also be
enforced.

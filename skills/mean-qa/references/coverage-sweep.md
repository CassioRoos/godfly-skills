# Coverage Sweep — Deciding What To Test Before Deciding How

Attack design (`attack-design.md`) tells you how to be mean. This tells you
where to point it, and — more importantly — makes your blind spots explicit
instead of silent.

Adapted from James Bach's Heuristic Test Strategy Model
(<https://www.satisfice.com/download/heuristic-test-strategy-model>), Elisabeth
Hendrickson's charter template (*Explore It!*), and the tour catalogue in James
Whittaker's *Exploratory Software Testing*.

## Step 1 — Sweep the product elements

Walk every element. For each, write **relevant** with a note, or **not
relevant** *with a reason*. The forced reason is the entire mechanism: a silent
skip is a coverage gap nobody can see, and a written "not relevant because this
feature has no file I/O" is a reviewable decision.

| Element | Prompts |
|---|---|
| **Structure** | Code, config, non-executable assets, external services it embeds |
| **Function** | What it does: calculation, transformation, state changes, error handling, start/stop, timing-related behaviour, security-related behaviour |
| **Data** | Input/output, preset, persistent, interdependent, **sequences and combinations**, **cardinality** (zero, one, many, max, must-be-unique), big/little, invalid/noise, **lifecycle** (created → accessed → modified → deleted) |
| **Interfaces** | UI, system, API, import/export, message surfaces |
| **Platform** | External dependencies, embedded components, what it assumes about its host |
| **Operations** | Real users and roles, common use, **disfavoured use** (ignorant, mistaken, careless, or malicious), **extreme use** (challenging but legitimate) |
| **Time** | Input/output timing, fast/slow, changing rates (spikes, bursts, hangs, interruptions), **concurrency** (multi-user, shared data, races) |

**Data→Cardinality, Data→Lifecycle, Time→Concurrency, and
Operations→Disfavoured Use are the four that repeatedly catch real integrity
bugs and that nobody generates unprompted.** If you skip them, say why.

## Step 2 — Sweep the quality criteria

Same discipline: relevant, or not relevant with a reason.

**Capability** (does it do the job) · **Reliability** (robustness, error
handling, **data integrity**, safety) · **Usability** (learnability,
operability, accessibility) · **Charisma** · **Security** (authentication,
authorisation, privacy) · **Scalability** · **Compatibility** ·
**Performance** · **Installability** · **Development** (supportability,
testability, maintainability)

For anything safety-, money-, rights-, or health-critical, Reliability→Safety
and Reliability→Data Integrity are never "not relevant."

## Step 3 — Turn relevant cells into charters

One charter per relevant cell, in Hendrickson's form:

> **Explore** *&lt;target&gt;* **with** *&lt;resources&gt;* **to discover** *&lt;information&gt;*

- **target** ← the product element
- **resources** ← the technique, tool, dataset, or interacting feature you'll use
- **information** ← the quality criterion you are characterising

*"Explore the medication administration endpoint with discontinued and expired
orders to discover whether order state is enforced at administration."*

A charter forces a commitment to a risk hypothesis and a method **before**
touching the product. That commitment is the defence against aimless probing
that ends in a confident "all good."

Keep unstarted charters in a **hopper** — a queue of charter-only entries. That
queue is also the natural unit of parallel work if you are fanning out.

## Step 4 — Force diversity with tours

Given "test this endpoint," a model reliably produces happy path, empty string,
very long string, injection, and stops. Tours break that mode collapse. Pick the
ones whose mechanics apply, and run one charter each. Names dropped, mechanics
kept:

| Tour | The mechanic |
|---|---|
| **Follow the data** | Track one record end-to-end through every stage of its lifecycle |
| **Saboteur** | Identify a resource the operation needs; remove or restrict it |
| **Cancel mid-flight** | Start operations and interrupt them; verify cleanup and that the action can be re-run |
| **Defaults and omissions** | Accept every default, leave every optional field blank, submit the minimum |
| **Illegal order** | Legal actions in an illegal sequence — resolve before creating, return before purchasing, administer after discontinuing |
| **Never reset** | Long-running session, nothing restarted, nothing closed; run other charters on top |
| **Bad neighbourhood** | The areas with recent bugs or recent churn; bugs congregate |
| **Do it twice** | Repeat every action; submit everything twice |

That set is deliberately short. The original catalogue has thirty-plus tours
with heavy overlap; handing an agent all of them yields thirty charters and
eight distinct behaviours.

## The sweep is an analysis tool, not a deliverable

**Never print the sweep.** The element grid, the criteria list, the
relevant/not-relevant reasoning and the tour selection are how you decide what
to test; none of them belong in the report. They produce two outputs a reader
needs — the charters you chose, and the paragraph below saying what you cannot
cover. Everything else stays in your head.

A report where a third of the words are testing taxonomy has spent the reader's
attention describing the method instead of the risk.

## Step 5 — State the shape of your coverage

Close the sweep by writing, in one paragraph, what this campaign covers and what
it structurally cannot. Not a percentage — a description. "Covers order entry
and administration through the API, single-user, on seeded data; does not cover
the nursing UI, concurrent administration, or anything requiring a second
clinician account."

That paragraph becomes the *what I could not verify* section of the report, and
it is the difference between a run that is honest about its edges and one that
implies it looked everywhere.

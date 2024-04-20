Require Extraction.
Extraction Language OCaml.
Require Export
  Coq.extraction.Extraction
  Coq.extraction.ExtrOcamlBasic
  Coq.extraction.ExtrOcamlZInt
  Coq.extraction.ExtrOcamlNatInt
.
From Coq Require Import String Bool Arith ZArith List.

From Minuska Require Export
    prelude
    default_everything
.


Extraction
    "Dsm.ml"
    default_everything.myBuiltinType
    default_everything.dmyBuiltin
    default_everything.myBuiltin
    default_everything.DSM
    default_everything.GT
    default_everything.gt_term
    default_everything.gt_over
    default_everything.global_naive_interpreter
    (*
      Error:
The informative inductive type prod has a Prop instance
in naive_interpreter.naive_interpreter_sound (or in its mutual block).
This happens when a sort-polymorphic singleton inductive type
has logical parameters, such as (I,I) : (True * True) : Prop.
Extraction cannot handle this situation yet.
Instead, use a sort-monomorphic type such as (True /\ True)
or extract to Haskell.
    *)
    (* default_everything.global_naive_interpreter_sound *)
.
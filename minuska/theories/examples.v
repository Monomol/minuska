From Coq.Logic Require Import ProofIrrelevance.


From Minuska Require Import
    prelude
    spec_syntax
    spec_semantics
    string_variables
    builtins
    flattened
    naive_interpreter
    default_static_model
    notations
    frontend
.


Module example_1.

    (*
    Import empty_builtin.*)
    #[local]
    Instance Σ : StaticModel :=
        default_model (empty_builtin.β)
    .
    
    Definition X : variable := "X".

    Definition cfg {_r : Resolver} := (apply_symbol "cfg").
    Arguments cfg {_r} _%rs.

    Definition s {_r : Resolver} := (apply_symbol "s").
    Arguments s {_r} _%rs.

    Definition Decls : list Declaration := [
        rule ["my_rule"]:
            cfg [ s [ s [ ($X) ] ] ]
            ~> cfg [ $X ]
        
    ].

    Definition Γ : FlattenedRewritingTheory
        := Eval vm_compute in (to_theory (process_declarations (Decls))).

    Definition interp :=
        naive_interpreter Γ
    .

    Fixpoint interp_loop
        (fuel : nat)
        (g : GroundTerm)
        : option GroundTerm
    :=
    match fuel with
    | 0 => Some g
    | S fuel' => g' ← interp g; interp_loop fuel' g'
    end
    .

    Fixpoint my_number' (n : nat) : AppliedOperator' symbol builtin_value  :=
    match n with
    | 0 => ao_operator "0"
    | S n' => ao_app_ao (ao_operator "s") (my_number' n')
    end
    .

    Fixpoint my_number'_inv
        (g : AppliedOperator' symbol builtin_value)
        : option nat
    :=
    match g with
    | ao_operator s => if bool_decide (s = "0") then Some 0 else None
    | ao_app_ao s arg =>
        match s with
        | ao_operator s => if bool_decide (s = "s") then
            n ← my_number'_inv arg;
            Some (S n)
        else None
        | _ => None
        end
    | ao_app_operand _ _ => None
    end
    .

    Definition my_number (n : nat) : GroundTerm :=
        aoo_app (ao_app_ao (ao_operator "cfg") (my_number' n))
    .

    Definition my_number_inv (g : GroundTerm) : option nat
    :=
    match g with
    | aoo_app (ao_app_ao (ao_operator "cfg") g') => my_number'_inv g'
    | _ => None
    end
    .

    Lemma my_number_inversion' : forall n,
        my_number'_inv (my_number' n) = Some n
    .
    Proof.
        induction n; simpl.
        { reflexivity. }
        {
            rewrite bind_Some.
            exists n.
            auto.
        }
    Qed.

    Lemma my_number_inversion : forall n,
        my_number_inv (my_number n) = Some n
    .
    Proof.
        intros n. simpl. apply my_number_inversion'.
    Qed.

    Compute (my_number 2).
    Compute (interp (my_number 2)).

    Definition interp_loop_number fuel := 
        fun n =>
        let og' := ((interp_loop fuel) ∘ my_number) n in
        g' ← og';
        my_number_inv g'
    .

End example_1.


Module two_counters.

    Import empty_builtin.

    #[local]
    Instance Σ : StaticModel := default_model (empty_builtin.β).


    Definition M : variable := "M".
    Definition N : variable := "N".
    
    Definition cfg {_r : Resolver} := (apply_symbol "cfg").
    Arguments cfg {_r} _%rs.

    Definition state {_r : Resolver} := (apply_symbol "state").
    Arguments state {_r} _%rs.

    Definition s {_r : Resolver} := (apply_symbol "s").
    Arguments s {_r} _%rs.

    Definition Γ : FlattenedRewritingTheory :=
    Eval vm_compute in (to_theory (process_declarations ([
        rule ["my-rule"]:
             cfg [ state [ s [ $M ], $N ] ]
          ~> cfg [ state [ $M, s [ $N ]  ] ]
    ]))).
    

    Definition interp :=
        naive_interpreter Γ
    .

    Fixpoint interp_loop
        (fuel : nat)
        (g : GroundTerm)
        : option GroundTerm
    :=
    match fuel with
    | 0 => Some g
    | S fuel' => g' ← interp g; interp_loop fuel' g'
    end
    .

    Definition pair_to_state (mn : nat*nat) : GroundTerm :=
        aoo_app (ao_app_ao (ao_operator "cfg")
        (
            ao_app_ao
                (
                ao_app_ao (ao_operator "state")
                    (example_1.my_number' mn.1)
                )
                (example_1.my_number' mn.2)
        )
        )
    .

    Definition state_to_pair (g : GroundTerm) : option (nat*nat) :=
    match g with
    | aoo_app (ao_app_ao (ao_operator "cfg")
        (ao_app_ao (ao_app_ao (ao_operator "state") (m')) n'))
        => 
            m ← example_1.my_number'_inv m';
            n ← example_1.my_number'_inv n';
            Some (m, n)
    | _ => None
    end
    .

    Lemma pair_state_inversion : forall m n,
        state_to_pair (pair_to_state (m,n)) = Some (m,n)
    .
    Proof.
        intros m n.
        simpl.
        rewrite bind_Some.
        exists m.
        split.
        { rewrite example_1.my_number_inversion'. reflexivity. }
        rewrite bind_Some.
        exists n.
        split.
        { rewrite example_1.my_number_inversion'. reflexivity. }
        reflexivity.
    Qed.

    Definition interp_loop_number fuel := 
        fun (m n : nat) =>
        let og' := ((interp_loop fuel) ∘ pair_to_state) (m,n) in
        g' ← og';
        state_to_pair g'
    .

End two_counters.

Module arith.

    Import default_builtin.
    Import default_builtin.Notations.

    #[local]
    Instance Σ : StaticModel := default_model (default_builtin.β).

    Definition X : variable := "X".
    Definition Y : variable := "Y".
    Definition REST_SEQ : variable := "$REST_SEQ".
    
    Definition cseq {_r : Resolver} := (apply_symbol "cseq").
    Arguments cseq {_r} _%rs.

    Definition emptyCseq {_r : Resolver} := (apply_symbol "emptyCseq").
    Arguments emptyCseq {_r} _%rs.

    Definition plus {_r : Resolver} := (apply_symbol "plus").
    Arguments plus {_r} _%rs.

    Definition cfg {_r : Resolver} := (apply_symbol "cfg").
    Arguments cfg {_r} _%rs.

    Definition state {_r : Resolver} := (apply_symbol "state").
    Arguments state {_r} _%rs.

    Definition s {_r : Resolver} := (apply_symbol "s").
    Arguments s {_r} _%rs.

    Declare Scope LangArithScope.
    Delimit Scope LangArithScope with larith.

    Notation "x '+' y" := (plus [ x, y ]).
    Set Printing All.
    Set Typeclasses Debug.
    Definition Decls : list Declaration := [
        rule ["plus-nat-nat"]:
             cfg [ cseq [ ($X + $Y), $REST_SEQ ] ]
          ~> (cfg [ (cseq [ (ft_binary b_plus ($X) ($Y)) (*(($X +Nat $Y) +Nat $Y)*) (*, $REST_SEQ*) ])%rs ])%rs
             (*where (
                (isNat $X)
                &&
                (isNat $Y)
             )*)
        (*;
        (* TODO *)
        rule ["plus-heat-any"]:
             top [< cseq [< plus [< $X, $Y >], $REST_SEQ >] >]
          => top [< cseq [< ($X +Nat $Y) , $REST_SEQ >] >]
        *)   

    ].

    Definition Γ : FlattenedRewritingTheory := Eval vm_compute in 
    (to_theory (process_declarations (Decls))).

End arith.


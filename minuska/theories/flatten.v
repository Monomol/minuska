From Minuska Require Import
    prelude
    tactics
    spec_syntax
    spec_semantics
.

Definition valuation_satisfies_scs
    {Σ : Signature}
    (ρ : Valuation)
    (scs : list SideCondition)
    : Prop
:= Forall (valuation_satisfies_sc ρ) scs
.

Record FlattenedRewritingRule {Σ : Signature} := {
    fr_from : OpenTerm ;
    fr_to : RhsPattern ;
    fr_scs : list SideCondition ;
}.

Definition flattened_rewrites_in_valuation_to
    {Σ : Signature}
    (ρ : Valuation)
    (r : FlattenedRewritingRule)
    (from to : GroundTerm)
    : Prop
:= in_val_GroundTerm_satisfies_OpenTerm
    ρ from (fr_from r)
/\ GroundTerm_satisfies_RhsPattern
    ρ to (fr_to r)
/\ valuation_satisfies_scs ρ (fr_scs r)
.

Definition flattened_rewrites_to
    {Σ : Signature}
    (r : FlattenedRewritingRule)
    (from to : GroundTerm)
    : Prop
:= exists ρ, flattened_rewrites_in_valuation_to ρ r from to
.

Fixpoint separate_scs
    {Σ : Signature}
    {A : Set}
    (wsc : WithASideCondition A):
    A * (list SideCondition)
:=
match wsc with
| wsc_base a => (a, [])
| wsc_sc wsc' sc =>
    match separate_scs wsc' with
    | (a, scs) => (a, sc::scs)
    end
end.

Print AppliedOperator'.
Print AppliedOperatorOr'.
Print OpenTerm.

Fixpoint AppliedOperator'_size
    {Operator Operand : Set}
    (x : AppliedOperator' Operator Operand)
    : nat :=
match x with
| ao_operator _ => 1
| ao_app_operand x' _ => 1 + AppliedOperator'_size x'
| ao_app_ao x1 x2 => 1 + AppliedOperator'_size x1 + AppliedOperator'_size x2
end.

Definition AppliedOperatorOr'_deep_size
    {Operator Operand : Set}
    (x : AppliedOperatorOr' Operator Operand)
    : nat :=
match x with
| aoo_operand _ _ o => 1
| aoo_app _ _ x' => 1 + AppliedOperator'_size x'
end.

(*
Equations AppliedOperatorOr'_symbol_A_to_pair_OpenTerm_SC
    {Σ : Signature}
    {A : Set}
    (A_to_OpenTerm_SC : A ->
        ((AppliedOperatorOr' symbol BuiltinOrVar) * (list SideCondition))
    )
    (x : AppliedOperatorOr' symbol A)
    : ((AppliedOperatorOr' symbol BuiltinOrVar) * (list SideCondition))
    by wf (AppliedOperatorOr'_deep_size x)
:=
AppliedOperatorOr'_symbol_A_to_pair_OpenTerm_SC f 
    (aoo_operand _ _ o) := aoo_operand _ _ o ;

AppliedOperatorOr'_symbol_A_to_pair_OpenTerm_SC f
    (aoo_app _ _ (ao_operator a)) := (aoo_app _ _ (ao_operator a), []) ;

AppliedOperatorOr'_symbol_A_to_pair_OpenTerm_SC f
    (aoo_app A B (ao_app_operand x2 o))
    with pair
        (AppliedOperatorOr'_symbol_A_to_pair_OpenTerm_SC f (aoo_app A B x2))
        (f o) => {
            | _,_ := 3
         } ;
.
*)
(*
Fixpoint AppliedOperatorOr'_symbol_A_to_pair_OpenTerm_SC
    {Σ : Signature}
    {A : Set}
    (A_to_OpenTerm_SC : A ->
        ((AppliedOperatorOr' symbol BuiltinOrVar) * (list SideCondition))
    )
    (x : AppliedOperatorOr' symbol A)
    : ((AppliedOperatorOr' symbol BuiltinOrVar) * (list SideCondition))
:=
match x with
| aoo_operand _ _ o => aoo_operand _ _ o
| aoo_app _ _ (ao_operator a) => (aoo_app _ _ (ao_operator a), [])
| aoo_app _ _ (ao_app_operand x' o) =>
    match AppliedOperatorOr'_symbol_A_to_pair_OpenTerm_SC A_to_OpenTerm_SC (aoo_app _ _ x') with
    | (t1, scs1) =>
        match A_to_OpenTerm_SC o with
        | (aoo_app _ _ t2, scs2) =>
            ((ao_app_operand t1 t2), scs1 ++ scs2)
        | (aoo_operand _ _ t2, scs2) =>
            ((ao_app_operand t1 t2), scs1 ++ scs2)
        end
    end
(*
| ao_app_operand x' o =>
    match AppliedOperator'_symbol_A_to_pair_OpenTerm_SC A_to_OpenTerm_SC x' with
    | (t1, scs1) =>
        match A_to_OpenTerm_SC o with
        | (aoo_app _ _ t2, scs2) =>
            ((ao_app_operand t1 t2), scs1 ++ scs2)
        | (aoo_operand _ _ t2, scs2) =>
            ((ao_app_operand t1 t2), scs1 ++ scs2)
        end
    end
| ao_app_ao x1 x2 =>
    match AppliedOperator'_symbol_A_to_pair_OpenTerm_SC A_to_OpenTerm_SC x1 with
    | (t1, scs1) =>
        match AppliedOperator'_symbol_A_to_pair_OpenTerm_SC A_to_OpenTerm_SC x2 with
        | (t2, scs2) => (ao_app_ao t1 t2, scs1 ++ scs2)
        end
    end
*)
end.
*)

Fixpoint AppliedOperator'_symbol_A_to_pair_OpenTerm_SC
    {Σ : Signature}
    {A : Set}
    (A_to_OpenTerm_SC : A ->
        ((AppliedOperatorOr' symbol BuiltinOrVar) * (list SideCondition))
    )
    (x : AppliedOperator' symbol A)
    : ((AppliedOperator' symbol BuiltinOrVar) * (list SideCondition))
:=
match x with
| ao_operator a => ((ao_operator a), [])
| ao_app_operand x' o =>
    match AppliedOperator'_symbol_A_to_pair_OpenTerm_SC A_to_OpenTerm_SC x' with
    | (t1, scs1) =>
        match A_to_OpenTerm_SC o with
        | (aoo_app _ _ t2, scs2) =>
            ((ao_app_ao t1 t2), scs1 ++ scs2)
        | (aoo_operand _ _ t2, scs2) =>
            ((ao_app_operand t1 t2), scs1 ++ scs2)
        end
    end
| ao_app_ao x1 x2 =>
    match AppliedOperator'_symbol_A_to_pair_OpenTerm_SC A_to_OpenTerm_SC x1 with
    | (t1, scs1) =>
        match AppliedOperator'_symbol_A_to_pair_OpenTerm_SC A_to_OpenTerm_SC x2 with
        | (t2, scs2) => (ao_app_ao t1 t2, scs1 ++ scs2)
        end
    end
end.

(*
Lemma helper
    {Σ : Signature}
    x:
    match AppliedOperator'_symbol_A_to_pair_OpenTerm_SC A_to_OpenTerm_SC x with
        | (y, scs) =>
*)
Lemma correct_AppliedOperator'_symbol_A_to_pair_OpenTerm_SC
    {Σ : Signature}
    {A : Set}
    (A_to_OpenTerm_SC : A ->
        ((AppliedOperatorOr' symbol BuiltinOrVar) * (list SideCondition))
    )
    (builtin_satisfies_A:
        Valuation -> builtin_value -> A -> Prop
    )
    (AppliedOperator'_symbol_builtin_satisfies_A:
        Valuation ->
        AppliedOperator' symbol builtin_value ->
        A ->
        Prop
    )
    (ρ : Valuation)
    (correct_A_to_OpenTerm_SC :
        forall γ (a : A),
            (match A_to_OpenTerm_SC a with
            | (aoo_app _ _ b, scb) => @aoxy_satisfies_aoxz symbol builtin_value BuiltinOrVar
                (builtin_satisfies_BuiltinOrVar ρ)
                (AppliedOperator'_symbol_builtin_satisfies_BuiltinOrVar ρ)
                γ b
                /\ valuation_satisfies_scs ρ scb
            | (aoo_operand _ _ b, scb) =>
                AppliedOperator'_symbol_builtin_satisfies_BuiltinOrVar ρ γ b
                /\ valuation_satisfies_scs ρ scb
            end
            <->
                AppliedOperator'_symbol_builtin_satisfies_A ρ γ a
            )
    )
    (correct2_A_to_OpenTerm_SC :
        ∀ (a : A) (b : builtin_value) (ρ : Valuation),
        builtin_satisfies_A ρ b a ->
        ∃ (bov : BuiltinOrVar) rest,
            (A_to_OpenTerm_SC a) = (aoo_operand _ _ bov, rest)
            /\ builtin_satisfies_BuiltinOrVar ρ b bov
            /\ valuation_satisfies_scs ρ rest
    )
    (x : AppliedOperator' symbol A)
    (g : AppliedOperator' symbol builtin_value)
    :
    (
        match AppliedOperator'_symbol_A_to_pair_OpenTerm_SC A_to_OpenTerm_SC x with
        | (y, scs) =>
            @aoxy_satisfies_aoxz
                symbol
                builtin_value
                BuiltinOrVar
                (builtin_satisfies_BuiltinOrVar ρ)
                (AppliedOperator'_symbol_builtin_satisfies_BuiltinOrVar ρ)
                g
                y
            /\ (valuation_satisfies_scs ρ scs)
        end

    )
    <-> @aoxy_satisfies_aoxz
                symbol
                builtin_value
                A
                (builtin_satisfies_A ρ)
                (AppliedOperator'_symbol_builtin_satisfies_A ρ)
                g
                x
.
Proof.
    split.
    { admit. }
    {
        intros H.
        induction H; cbn.
        {
            split.
            { constructor. }
            { apply Forall_nil. }
        }
        {
            remember (AppliedOperator'_symbol_A_to_pair_OpenTerm_SC A_to_OpenTerm_SC aoxz) as rec.
            destruct rec as [y0 scs].
            remember (A_to_OpenTerm_SC z) as occall.
            destruct occall as [a scs2].
            apply correct2_A_to_OpenTerm_SC in H0.
            destruct H0 as [bov [rest [H01 [H02 H03]]]]; cbn in *.
            rewrite H01 in Heqoccall.
            destruct a.
            {
                ltac1:(exfalso).
                inversion Heqoccall; subst; clear Heqoccall.
            }
            {
                split.
                {
                    constructor.
                    { apply IHaoxy_satisfies_aoxz. }
                    {
                        inversion Heqoccall; subst; clear Heqoccall.
                        exact H02.
                    }
                }
                {
                    inversion Heqoccall; subst; clear Heqoccall.
                    unfold valuation_satisfies_scs.
                    destruct IHaoxy_satisfies_aoxz as [IH1 IH2]; cbn in *.
                    rewrite Forall_app.
                    split.
                    { exact IH2. }
                    { exact H03. }
                }
            }
        }
        {
            
        }
    }
(*
    revert g.
    induction x; intros g; cbn.
    {
        unfold valuation_satisfies_scs.
        rewrite list.Forall_nil.
        split; intros H.
        {
            destruct H as [H _].
            inversion H; subst; constructor.
        }
        {
            inversion H; subst; repeat constructor.
        }
    }
    {
        remember (AppliedOperator'_symbol_A_to_pair_OpenTerm_SC A_to_OpenTerm_SC x) as rec.
        destruct rec as [y scs].
        remember (A_to_OpenTerm_SC b) as rec2.
        destruct rec2 as [t2 scs2].
        destruct t2 as [t2 | t2].
        split.
        {
            intros H.
            destruct H as [H1 H2].
            inversion H1; subst; clear H1.
            constructor.
            {
                rewrite <- IHx.
                split.
                { assumption. }
                {
                    unfold valuation_satisfies_scs.
                    unfold valuation_satisfies_scs in H2.
                    rewrite Forall_app in H2.
                    apply H2.
                }
            }
            {
                apply correct_A_to_OpenTerm_SC.
                rewrite <- Heqrec2.
                split.
                { assumption. }
                {
                    unfold valuation_satisfies_scs.
                    unfold valuation_satisfies_scs in H2.
                    rewrite Forall_app in H2.
                    apply H2.
                }
            }
        }
        {
            intros H.
            split.
            {
                (*
                assert (Hcor := correct_A_to_OpenTerm_SC g (ao_app_operand x b)).
                ltac1:(rewrite <- Heqrec2 in Hcor).
                *)
                (*apply IHx in H.*)
                inversion H; subst; clear H.
                {
                    apply IHx in H3.
                    constructor; cbn.
                }
            }
        }
    }
*)
Qed.

Print LhsPattern.

Fixpoint LhsPattern_to_pair_OpenTerm_SC
    {Σ : Signature}
    (l : LhsPattern)
    : (OpenTerm * (list SideCondition))
:=
match l with
| aoo_app _ _ 
end.

Print LocalRewrite.

Print LocalRewriteOrOpenTermOrBOV.

Print UncondRewritingRule.

Print RewritingRule.
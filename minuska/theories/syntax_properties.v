From Minuska Require Import
    prelude
    spec_syntax
.

 Section vars_of.

    Definition vars_of_AP
        {Σ : Signature}
        (ap : AtomicProposition)
        : gset variable :=
    match ap with
    | ap1 _ x => {[x]}
    | ap2 _ x y => {[x;y]}
    end.

    Fixpoint vars_of_Constraint
        { Σ : Signature }
        (c : Constraint)
        : gset variable :=
    match c with
    | c_True => ∅
    | c_atomic ap => vars_of_AP ap
    | c_and c1 c2 => vars_of_Constraint c1 ∪ vars_of_Constraint c2
    | c_not c' => vars_of_Constraint c'
    end.

    Fixpoint vars_of_aosb
        {Σ : Signature}
        (o : AppliedOperator' symbol BuiltinOrVar)
        : gset variable :=
    match o with
    | ao_operator _ => ∅
    | ao_app_operand o' (bov_builtin _) => vars_of_aosb o'
    | ao_app_operand o' (bov_variable x) => {[x]} ∪ vars_of_aosb o'
    | ao_app_ao o1 o2 => vars_of_aosb o1 ∪ vars_of_aosb o2
    end.

    Definition vars_of_OpenTerm
        {Σ : Signature}
        (φ : OpenTerm)
        : gset variable :=
    match φ with
    | aoo_app _ _ o => vars_of_aosb o
    | aoo_operand _ _ (bov_variable x) => {[x]}
    | aoo_operand _ _ (bov_builtin _) => ∅
    end.
    
    Definition vars_of_SideCondition
        {Σ : Signature}
        (c : SideCondition)
        : gset variable :=
    match c with
    | sc_constraint c' => vars_of_Constraint c'
    | sc_match x φ => {[x]} ∪ vars_of_OpenTerm φ
    end.

    Fixpoint vars_of_OpenTermWSC
        {Σ : Signature}
        (φc : OpenTermWSC)
        : gset variable :=
    match φc with
    | wsc_base φ => vars_of_OpenTerm φ
    | wsc_sc φ c
        => vars_of_OpenTermWSC φ ∪ vars_of_SideCondition c
    end.

    Fixpoint vars_of_AppliedOperator'_symbol_OpenTermWSC
        {Σ : Signature}
        (φ : AppliedOperator' symbol OpenTermWSC)
        : gset variable :=
    match φ with
    | ao_operator o => ∅
    | ao_app_operand x y
        => vars_of_AppliedOperator'_symbol_OpenTermWSC x ∪ vars_of_OpenTermWSC y
    | ao_app_ao x y
        => vars_of_AppliedOperator'_symbol_OpenTermWSC x ∪ vars_of_AppliedOperator'_symbol_OpenTermWSC y
    end.

    Definition vars_of_LhsPattern
        {Σ : Signature}
        (φ : LhsPattern)
        : gset variable :=
    match φ with
    | aoo_app _ _ aop => vars_of_AppliedOperator'_symbol_OpenTermWSC aop
    | aoo_operand _ _ otwsc => vars_of_OpenTermWSC otwsc
    end.

    Fixpoint vars_of_Expression
        {Σ : Signature}
        (t : Expression)
        : gset variable :=
    match t with
    | ft_element _ => ∅
    | ft_variable x => {[x]}
    | ft_unary _ t' => vars_of_Expression t'
    | ft_binary _ t1 t2 => vars_of_Expression t1 ∪ vars_of_Expression t2
    end.

    Fixpoint vars_of_AppliedOperator_sym_fterm
        {Σ : Signature}
        (op : AppliedOperator' symbol Expression)
        : gset variable :=
    match op with
    | ao_operator _ => ∅
    | ao_app_operand aps' o =>
        vars_of_AppliedOperator_sym_fterm aps' ∪ vars_of_Expression o
    | ao_app_ao aps1 aps2 =>
        vars_of_AppliedOperator_sym_fterm aps1 ∪ vars_of_AppliedOperator_sym_fterm aps2
    end.

    Fixpoint vars_of_AppliedOperator'_symbol_Expression
        {Σ : Signature}
        (φ : AppliedOperator' symbol Expression)
        : gset variable :=
    match φ with
    | ao_operator _ => ∅
    | ao_app_operand  φ' t
        => vars_of_AppliedOperator'_symbol_Expression φ' ∪ vars_of_Expression t
    | ao_app_ao φ1 φ2
        => vars_of_AppliedOperator'_symbol_Expression φ1 ∪ vars_of_AppliedOperator'_symbol_Expression φ2
    end.

    Definition vars_of_RhsPattern
        {Σ : Signature}
        (φ : RhsPattern)
        : gset variable :=
    match φ with
    | aoo_app _ _ aop => vars_of_AppliedOperator'_symbol_Expression aop
    | aoo_operand _ _ exp => vars_of_Expression exp
    end.

    Fixpoint var_of_WithASideCondition_variable
        {Σ : Signature}
        (x : WithASideCondition variable)
        : variable :=
    match x with
    | wsc_base x' => x'
    | wsc_sc x' sc => var_of_WithASideCondition_variable x'
    end.

    Definition vars_of_LocalRewrite
        {Σ : Signature}
        (lr : LeftRight)
        (r : LocalRewrite)
        : gset variable :=
    match lr,r with
    | LR_Left, Build_LocalRewrite _ φ1 φ2 => vars_of_LhsPattern φ1
    | LR_Right, Build_LocalRewrite _ φ1 φ2 => vars_of_RhsPattern φ2
    end.


End vars_of.
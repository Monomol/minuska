
Require Import Minuska.default_everything.
Existing Instance default_everything.DSM.
Definition myContext := (context-template (@t_term _ _ "c" [(HOLE); (t_over (notations.inject_variable "STATE"))]) with HOLE).
Definition isValue (X : Expression2) := (e_binary b_or (e_unary b_isZ (X)) (e_binary b_or (e_unary b_isBool (X)) (e_binary b_or (e_binary b_have_same_symbol (X) (e_ground (@t_term symbol builtin_value "unitValue" []))) (e_unary b_isString (X))))).


#[local]
Instance LangDefaults : Defaults := {|
    default_cseq_name := "builtin.cseq" ;
    default_empty_cseq_name := "builtin.empty_cseq" ;
    default_context_template := myContext ;

    default_isValue := isValue ;
|}.

Definition frame_simple : (variable*(TermOver BuiltinOrVar)) := ("X",(@t_term symbol BuiltinOrVar "c" [(@t_term symbol BuiltinOrVar "builtin.cseq" [(t_over (bov_variable "X")); (t_over (bov_variable "REST"))]); (t_over (bov_variable "STATE"))])).
Definition Lang_Decls : list Declaration := [
(decl_strict (mkStrictnessDeclaration DSM "plus" 2 [0; 1] isValue myContext))
;(decl_strict (mkStrictnessDeclaration DSM "minus" 2 [0; 1] isValue myContext))
;(decl_strict (mkStrictnessDeclaration DSM "assign" 2 [1] isValue myContext))
;(decl_strict (mkStrictnessDeclaration DSM "seq" 2 [0] isValue myContext))
;(decl_strict (mkStrictnessDeclaration DSM "ite" 3 [0] isValue myContext))
;(decl_strict (mkStrictnessDeclaration DSM "eq" 2 [0; 1] isValue myContext))
;(decl_strict (mkStrictnessDeclaration DSM "le" 2 [0; 1] isValue myContext))
;(decl_strict (mkStrictnessDeclaration DSM "lt" 2 [0; 1] isValue myContext))
;(decl_strict (mkStrictnessDeclaration DSM "neg" 1 [0] isValue myContext))
] ++ [
(basic_rule "init" (@t_term symbol BuiltinOrVar "builtin.init" [(t_over (bov_variable "X"))]) (@t_term symbol Expression2 "c" [(@t_term symbol Expression2 "builtin.cseq" [(@t_over symbol Expression2(e_variable "X")); (@t_term symbol Expression2 "builtin.empty_cseq" [])]); (@t_over symbol Expression2(e_nullary b_map_empty))]) (e_nullary b_true))
; (framed_rule frame_simple "aexpr.plus" (@t_term symbol BuiltinOrVar "plus" [(t_over (bov_variable "X")); (t_over (bov_variable "Y"))]) (@t_over symbol Expression2(e_binary b_Z_plus (e_variable "X") (e_variable "Y"))) (e_binary b_and (e_unary b_isZ (e_variable "X")) (e_unary b_isZ (e_variable "Y"))))
; (framed_rule frame_simple "aexpr.minus" (@t_term symbol BuiltinOrVar "minus" [(t_over (bov_variable "X")); (t_over (bov_variable "Y"))]) (@t_over symbol Expression2(e_binary b_Z_minus (e_variable "X") (e_variable "Y"))) (e_binary b_and (e_unary b_isZ (e_variable "X")) (e_unary b_isZ (e_variable "Y"))))
; (basic_rule "var.assign" (@t_term symbol BuiltinOrVar "c" [(@t_term symbol BuiltinOrVar "builtin.cseq" [(@t_term symbol BuiltinOrVar "assign" [(t_over (bov_variable "X")); (t_over (bov_variable "V"))]); (t_over (bov_variable "REST"))]); (t_over (bov_variable "STATE"))]) (@t_term symbol Expression2 "c" [(@t_term symbol Expression2 "builtin.cseq" [(@t_term symbol Expression2 "unitValue" []); (@t_over symbol Expression2(e_variable "REST"))]); (@t_over symbol Expression2(e_ternary b_map_update (e_variable "STATE") (e_variable "X") (e_variable "V")))]) (e_binary b_and (e_binary b_have_same_symbol (e_variable "X") (e_ground (@t_term symbol builtin_value "var" []))) (e_binary b_or (e_unary b_isZ (e_variable "V")) (e_unary b_isString (e_variable "V")))))
; (basic_rule "var.lookup" (@t_term symbol BuiltinOrVar "c" [(@t_term symbol BuiltinOrVar "builtin.cseq" [(t_over (bov_variable "X")); (t_over (bov_variable "REST"))]); (t_over (bov_variable "STATE"))]) (@t_term symbol Expression2 "c" [(@t_term symbol Expression2 "builtin.cseq" [(@t_over symbol Expression2(e_binary b_map_lookup (e_variable "STATE") (e_variable "X"))); (@t_over symbol Expression2(e_variable "REST"))]); (@t_over symbol Expression2(e_variable "STATE"))]) (e_binary b_have_same_symbol (e_variable "X") (e_ground (@t_term symbol builtin_value "var" []))))
; (framed_rule frame_simple "stmt.seq" (@t_term symbol BuiltinOrVar "seq" [(@t_term symbol BuiltinOrVar "unitValue" []); (t_over (bov_variable "X"))]) (@t_over symbol Expression2(e_variable "X")) (e_nullary b_true))
; (framed_rule frame_simple "bexpr.eq" (@t_term symbol BuiltinOrVar "eq" [(t_over (bov_variable "X")); (t_over (bov_variable "Y"))]) (@t_over symbol Expression2(e_binary b_eq (e_variable "X") (e_variable "Y"))) (e_binary b_and (e_unary b_isZ (e_variable "X")) (e_unary b_isZ (e_variable "Y"))))
; (framed_rule frame_simple "bexpr.le" (@t_term symbol BuiltinOrVar "le" [(t_over (bov_variable "X")); (t_over (bov_variable "Y"))]) (@t_over symbol Expression2(e_binary b_Z_isLe (e_variable "X") (e_variable "Y"))) (e_binary b_and (e_unary b_isZ (e_variable "X")) (e_unary b_isZ (e_variable "Y"))))
; (framed_rule frame_simple "bexpr.lt" (@t_term symbol BuiltinOrVar "lt" [(t_over (bov_variable "X")); (t_over (bov_variable "Y"))]) (@t_over symbol Expression2(e_binary b_Z_isLt (e_variable "X") (e_variable "Y"))) (e_binary b_and (e_unary b_isZ (e_variable "X")) (e_unary b_isZ (e_variable "Y"))))
; (framed_rule frame_simple "bexpr.neg" (@t_term symbol BuiltinOrVar "not" [(t_over (bov_variable "X"))]) (@t_over symbol Expression2(e_unary b_bool_neg (e_variable "X"))) (e_unary b_isBool (e_variable "X")))
; (framed_rule frame_simple "stmt.ite.true" (@t_term symbol BuiltinOrVar "ite" [(t_over (bov_variable "B")); (t_over (bov_variable "X")); (t_over (bov_variable "Y"))]) (@t_over symbol Expression2(e_variable "X")) (e_binary b_and (e_unary b_isBool (e_variable "B")) (e_binary b_eq (e_variable "B") (e_nullary b_true))))
; (framed_rule frame_simple "stmt.ite.false" (@t_term symbol BuiltinOrVar "ite" [(t_over (bov_variable "B")); (t_over (bov_variable "X")); (t_over (bov_variable "Y"))]) (@t_over symbol Expression2(e_variable "Y")) (e_binary b_and (e_unary b_isBool (e_variable "B")) (e_binary b_eq (e_variable "B") (e_nullary b_false))))
; (framed_rule frame_simple "while.unfold" (@t_term symbol BuiltinOrVar "while" [(t_over (bov_variable "B")); (t_over (bov_variable "S"))]) (@t_term symbol Expression2 "ite" [(@t_over symbol Expression2(e_variable "B")); (@t_term symbol Expression2 "seq" [(@t_over symbol Expression2(e_variable "S")); (@t_term symbol Expression2 "while" [(@t_over symbol Expression2(e_variable "B")); (@t_over symbol Expression2(e_variable "S"))])]); (@t_term symbol Expression2 "unitValue" [])]) (e_nullary b_true))

].
Definition T := Eval vm_compute in (to_theory Act (process_declarations Act default_act Lang_Decls)). 
Definition lang_interpreter : StepT := global_naive_interpreter (fst T).

    (* This lemma asserts well-formedness of the definition *)
    Lemma language_well_formed: isSome(RewritingTheory2_wf_heuristics (fst T)).
    Proof.
      (* This is the main syntactic check. If this fails, the semantics contain a bad rule. *) ltac1:(compute_done).
    Qed.
    (* This lemma asserts soundness of the generated interpreter. *)
    (* Unfortunately, we cannot rely on the extraction here.
    Lemma interp_sound:
        Interpreter_sound'
        (fst T)
        lang_interpreter
    .
    Proof.
        apply @global_naive_interpreter_sound.
        { apply _. }
        ltac1:(assert(Htmp: isSome(RewritingTheory2_wf_heuristics (fst T)))).
        {
            apply language_well_formed.
        }
        unfold is_true, isSome in Htmp.
        destruct (RewritingTheory2_wf_heuristics (fst T)) eqn:Heq>[|inversion Htmp].
        assumption.
    Qed.
    *)
  

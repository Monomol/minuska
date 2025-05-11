From Minuska Require Import
    spec
    empty
    trivial
    default_everything
    martelli_montanari
.

Instance sm : StaticModel := @DSM mysignature β MyProgramInfo.

Definition dec_paper_input1 : list (TermOver BuiltinOrVar) := [
    t_term "f"
        [
            t_over (bov_variable "x1");
            t_term "g"
                [t_term "a" [];
                    t_term "f"
                        [ t_over (bov_variable "x5"); t_term "b" [] ]
                ]
        ];
    t_term "f"
        [
            t_term "h"
                [ t_term "c" [] ];
            t_term "g"
                [t_over (bov_variable "x2");
                    t_term "f"
                        [ t_term "b" []; t_over (bov_variable "x5") ]
                ]
        ];
    t_term "f"
        [
            t_term "h"
                [ t_over (bov_variable "x4") ];
            t_term "g"
                [t_over (bov_variable "x6");
                 t_over (bov_variable "x3")
                ]
        ]
    ]
.

Compute (@dec sm dec_paper_input1).

Definition unify_paper1_input1 : TermOver BuiltinOrVar := (t_term "f" [
  t_over (bov_variable "x1");
  t_term "g" [t_over (bov_variable "x2"); t_over (bov_variable "x3")];
  t_over (bov_variable "x2");
  t_term "b" []]).
Definition unify_paper1_input2 : TermOver BuiltinOrVar := (t_term "f" [
  t_term "g" [t_term "h" [t_term "a" []; t_over (bov_variable "x5")]; t_over (bov_variable "x2")];
  t_over (bov_variable "x1");
  t_term "h" [t_term "a" []; t_over (bov_variable "x4")];
  t_over (bov_variable "x4")]).

Compute (@init_r sm U_listset_ops [unify_paper1_input1; unify_paper1_input2]).

Compute (@unify_terms sm U_listset_ops [unify_paper1_input1; unify_paper1_input2]).
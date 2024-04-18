open Core
open Syntax

let builtins_alist =
  [ "bool.neg", "b_bool_neg";
    "bool.and", "b_and";
    "bool.or", "b_or";
    "bool.eq", "b_eq";
    "bool.false", "b_false";
    "bool.true", "b_true";
    "term.same_symbol", "b_have_same_symbol";
  ]

let builtins_map = Map.of_alist_exn (module String) builtins_alist

let myiter (f : 'a -> 'b) (g : unit -> unit) (l : 'a list)  : unit =
    let ln = List.length l in
    List.iteri ~f:(fun idx x -> if (idx + 1 = ln) then (f x) else (f x; g ())) l;
    ()


let output_part_1 = {|
Require Extraction.
Extraction Language OCaml.
Require Import
  Coq.extraction.Extraction
  Coq.extraction.ExtrOcamlBasic
  Coq.extraction.ExtrOcamlNativeString
.
From Minuska Require Import
    prelude
    spec
    string_variables
    builtins
    default_static_model
    naive_interpreter
    frontend
    default_everything
.
|}


let output_part_2 = {delimiter|
Definition myContext := (context-template (@t_term _ _ "u_cfg") ([ HOLE ]) with HOLE) .

#[local]
Instance LangDefaults : Defaults := {|
    default_cseq_name := "__builtin_cseq" ;
    default_empty_cseq_name := "__builtin_empty_cseq" ;
    default_context_template := myContext ;

    default_isValue := isValue ;
|}.
|delimiter}

let rec print_groundterm (oux : Out_channel.t) (g : Syntax.groundterm) : unit =
  match g with
  | `GTerm (`Id s, gs) ->
    fprintf oux "(@t_term symbol builtin_value \"%s\" [" s;
    myiter (fun x -> print_groundterm oux x; ()) (fun () -> fprintf oux "; "; ()) gs;
    fprintf oux "])"

let rec print_pattern_w_hole (oux : Out_channel.t) (p : Syntax.pattern) (hole : string option) : unit =
  match p with
  | `PVar (`Var s) -> (
      match hole with
      | None ->
          fprintf oux "(t_over (bov_variable \"%s\"))" s
      | Some s2 ->
          if String.(s = s2) then
              fprintf oux "(%s)" s2
          else
              fprintf oux "(t_over (bov_variable \"%s\"))" s
    )
  | `PTerm (`Id s, ps) ->
    fprintf oux "(@t_term symbol BuiltinOrVar \"%s\" [" s;
    myiter (fun x -> print_pattern_w_hole oux x hole; ()) (fun () -> fprintf oux "; "; ()) ps;
    fprintf oux "])"

let print_pattern (oux : Out_channel.t) (p : Syntax.pattern) : unit =
  print_pattern_w_hole oux p None


let rec print_expr_w_hole (oux : Out_channel.t) (e : Syntax.expr) (hole : string option) : unit =
  match e with
  | `EVar (`Var s) -> (
        match hole with
        | None -> fprintf oux "(e_variable \"%s\")" s
        | Some s2 ->
            if String.(s = s2) then
                fprintf oux "(%s)" s2
            else
                fprintf oux "(e_variable \"%s\")" s
        )
  | `EGround g ->
    fprintf oux "(e_ground ";
    print_groundterm oux g;
    fprintf oux ")"

  | `ECall (`Id s, es) ->
    let name0 = Map.find builtins_map s in
    match name0 with
    | None -> failwith (String.append "Unknown builtin: " s)
    | Some name1 ->
        let name = (String.append "default_builtin." name1) in
        match List.length es with
        | 0 -> fprintf oux "(e_nullary %s)" name
        | 1 ->
            fprintf oux "(e_unary %s " name;
            print_expr_w_hole oux (List.nth_exn es 0) hole;
            fprintf oux ")"
        | 2 ->
            fprintf oux "(e_binary %s " name;
            print_expr_w_hole oux (List.nth_exn es 0) hole;
            fprintf oux " ";
            print_expr_w_hole oux (List.nth_exn es 1) hole;
            fprintf oux ")"
        | 3 ->
            fprintf oux "(e_ternary %s " name;
            print_expr_w_hole oux (List.nth_exn es 0) hole;
            fprintf oux " ";
            print_expr_w_hole oux (List.nth_exn es 1) hole;
            fprintf oux " ";
            print_expr_w_hole oux (List.nth_exn es 2) hole;
            fprintf oux ")"
        | _ -> failwith "Bad length"



let print_expr (oux : Out_channel.t) (e : Syntax.expr) : unit =
  print_expr_w_hole oux e None

let rec print_exprterm (oux : Out_channel.t) (p : Syntax.exprterm) : unit =
  match p with
  | `EExpr e -> fprintf oux "(@t_over symbol Expression2"; print_expr oux e; fprintf oux ")";
  | `ETerm (`Id s, ps) ->
    fprintf oux "(@t_term symbol Expression2 \"%s\" [" s;
    myiter (fun x -> print_exprterm oux x; ()) (fun () -> fprintf oux "; "; ()) ps;
    fprintf oux "])"



let print_rule (oux : Out_channel.t) (r : Syntax.rule) : unit =
    fprintf oux "(";
    (
      match (r.frame) with
      | None -> 
        fprintf oux "basic_rule \"%s\" " (r.name)
      | Some (`Id s) ->
        fprintf oux "framed_rule frame_%s \"%s\" " s (r.name)
    );
    
    print_pattern oux (r.lhs);
    fprintf oux " ";
    print_exprterm oux (r.rhs);
    fprintf oux " ";
    print_expr oux (r.cond);
    fprintf oux ")\n";
    ()

let print_frame oux fr =
  fprintf oux "Definition frame_%s : (variable*(TermOver BuiltinOrVar)) := (" (match fr.name with `Id s -> s);
  fprintf oux "\"%s\"" (match fr.var with `Var s -> s);
  fprintf oux ",";
  print_pattern oux (fr.pat);
  fprintf oux ").\n";
  ()

let print_strict oux str =
  fprintf oux "(decl_strict (mkStrictnessDeclaration DSM \"%s\" %d " (match str.symbol with `Id s -> s) (str.arity) ;
  fprintf oux "[";
  myiter (fun x -> fprintf oux "%d" x; ()) (fun () -> fprintf oux ", "; ()) (str.strict_places);
  fprintf oux "] isValue myContext";
  fprintf oux "))\n";
  ()

let print_definition def oux =
    let _ = def in
    fprintf oux "%s" output_part_1;
    fprintf oux "Definition isValue (";
    fprintf oux "%s" (match (fst (def.Syntax.value)) with `Var s -> s);
    fprintf oux " : Expression2) := ";
    print_expr_w_hole oux (snd (def.Syntax.value)) (Some (match (fst (def.Syntax.value)) with `Var s -> s));
    fprintf oux ".\n";
    fprintf oux "%s\n" output_part_2;
    List.iter ~f:(fun fr -> print_frame oux fr) (def.frames);
    (* fprintf oux "%s\n" {|
    Definition basic_rule (name : string) (l : TermOver BuiltinOrVar) (r : TermOver Expression2) (cond : Expression2) : Declaration :=
      (decl_rule (@mkRuleDeclaration DSM Act name (@mkRewritingRule2 DSM Act l r [(mkSideCondition2 _ (e_nullary default_builtin.b_true) cond)] default_act)))
    .
    |}; *)
    fprintf oux "Definition Lang_Decls : list Declaration := [\n";
    myiter (fun x -> print_strict oux x; ()) (fun () -> fprintf oux ";" ; ()) (def.Syntax.strictness) ;
    fprintf oux "%s" "] ++ [\n";
    myiter (fun x -> print_rule oux x; ()) (fun () -> fprintf oux "; "; ()) (def.Syntax.rules);
    fprintf oux "\n].\n";
    ()
    
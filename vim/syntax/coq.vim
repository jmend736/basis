if exists('b:current_syntax')
    finish
endif

"syntax match coqIdentifier /\<[A-Z]\w\+\>/

syntax keyword coqSort Set Prop SProp Type

" Coq.Init.Logic
syntax keyword coqStuff nat S O
syntax keyword coqStuff True I False
syntax keyword coqStuff and conj
syntax keyword coqStuff or or_introl or_intror
syntax keyword coqStuff iff iff_refl iff_trans iff_sym
syntax keyword coqStuff not
syntax keyword coqStuff ex ex_intro ex2 ex_intro2 all
syntax keyword coqStuff eq eq_refl
syntax match coqStuff /\v(\~|\/\\|\\\/|<->|\=|\<\>)/

" Coq.Init.DataTypes
syntax keyword coqStuff Empty_set unit tt
syntax keyword coqStuff bool true false andb orb implb xorb negb
syntax keyword coqStuff eq_true is_true
syntax keyword coqStuff option Some None
syntax keyword coqStuff sum prod sft snd
syntax keyword coqStuff length app
syntax keyword coqStuff comparison Eq Lt Gt CompOpp
syntax keyword coqStuff identity identity_refl ID id IDProp idProp

" Coq.Init.Nat
syntax keyword coqStuff zero one two
syntax keyword coqStuff succ pred add double mul sub
syntax keyword coqStuff eqb leb ltb compare
syntax keyword coqStuff max min even odd pow div divmod modulo gcd
syntax keyword coqStuff square sqrt_iter sqrt log2_iter log2 iter
syntax keyword coqStuff div2 testbit shiftl shiftr bitwise
syntax keyword coqStuff land lor ldiff lxor
syntax match coqStuff /\v(\+|\*|\-|\=\?|\<\=\?|\<\?|\?\=|\^)/

syntax keyword coqVernac Require Import
syntax keyword coqVernac Show Compute Eval Check Print
syntax keyword coqVernac Locate SearchRewrite

syntax keyword coqVernac Scheme Induction Sort

syntax keyword coqVernac Section End Variable Variables Implicit Types
syntax keyword coqVernac Variable Variables Implicit Types
syntax keyword coqVernac Hypothesis

syntax keyword coqVernac Definition
syntax keyword coqVernac Inductive CoInductive
syntax keyword coqVernac Fixpoint  CoFixpoint

syntax keyword coqVernac Theorem Proof Lemma Qed Abort Defined Admitted
syntax keyword coqVernac Goal

syntax keyword coqLtac for

syntax keyword coqGallina forall match with end fun fix cofix let in
syntax keyword coqGallina exists

syntax keyword coqTactics intro intros
syntax keyword coqTactics constructor
syntax keyword coqTactics split left right
syntax keyword coqTactics simpl reflexivity exact apply rewrite
syntax keyword coqTactics assumption
syntax keyword coqTactics unfold fold at induction as f_equal
syntax keyword coqTactics destruct discriminate injection
syntax keyword coqTactics trivial info_trivial
syntax keyword coqTactics assert revert clear rename move

" Tactics from 'Certified Tactics with Dependent Types'
syntax keyword coqTacticsCPDT crush

syntax match coqArrow /[=-]>/
syntax match coqArrow /<-/
syntax match coqArrow /[:,]/
syntax match coqArrow /:=/

syntax region coqComment start=/(\*/ end=/\*)/

highlight default link coqArrow Type
highlight default link coqSort Type
highlight default link coqStuff Identifier
highlight default link coqIdentifier Identifier
highlight default link coqVernac Special
highlight default link coqLtac Constant
highlight default link coqComment Comment
highlight default link coqGallina Statement
highlight default link coqTactics Function
highlight default link coqTacticsCPDT Function


let b:current_syntax = 'coq'

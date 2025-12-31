if exists('b:current_syntax')
    finish
endif

syntax match coqIdentifier /\<[A-Z]\w\+\>/

syntax keyword coqSort Set Prop SProp Type

syntax keyword coqVernac Require Import
syntax keyword coqVernac Show Compute Eval Check Print
syntax keyword coqVernac Locate SearchRewrite

syntax keyword coqVernac Scheme Induction Sort

syntax keyword coqVernac Section End Variable Variables Implicit Types

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
highlight default link coqTypes Type
highlight default link coqVernac Special
highlight default link coqLtac Constant
highlight default link coqComment Comment
highlight default link coqGallina Statement
highlight default link coqTactics Function
highlight default link coqTacticsCPDT Function
highlight default link coqIdentifier Identifier


let b:current_syntax = 'coq'

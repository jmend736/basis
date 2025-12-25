if exists('b:current_syntax')
    finish
endif

syntax match coqIdentifier /\<[A-Z]\w\+\>/

syntax keyword coqSort Set Prop SProp Type

syntax keyword coqVernac Require Fixpoint
syntax keyword coqVernac Theorem Proof Lemma Qed Abort Defined
syntax keyword coqVernac Show Compute Check Print
syntax keyword coqVernac Inductive Definition
syntax keyword coqVernac Require Import

syntax keyword coqGallina forall match with end fun fix cofix let in

syntax keyword coqTactics intro intros
syntax keyword coqTactics simpl reflexivity exact apply rewrite
syntax keyword coqTactics unfold fold at induction as f_equal
syntax keyword coqTactics destruct discriminate injection trivial

syntax region coqComment start=/(\*/ end=/\*)/

highlight default link coqSort Special
highlight default link coqVernac Special
highlight default link coqComment Comment
highlight default link coqGallina Statement
highlight default link coqTactics PreProc
highlight default link coqIdentifier Identifier

let b:current_syntax = 'coq'
